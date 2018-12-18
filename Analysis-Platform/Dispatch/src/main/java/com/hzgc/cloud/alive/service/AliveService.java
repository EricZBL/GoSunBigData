package com.hzgc.cloud.alive.service;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.hzgc.common.service.api.service.PlatformService;
import com.hzgc.common.util.basic.UuidUtil;
import com.hzgc.common.util.json.JacksonUtil;
import com.hzgc.cloud.alive.dao.AliveMapper;
import com.hzgc.cloud.alive.model.Alive;
import com.hzgc.cloud.alive.param.AliveInfo;
import com.hzgc.cloud.alive.param.AliveInfoDTO;
import com.hzgc.cloud.alive.param.AliveInfoVO;
import com.hzgc.cloud.alive.param.SearchAliveInfoDTO;
import com.hzgc.cloud.dispatch.param.KafkaMessage;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import javax.validation.constraints.NotNull;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Service
@Slf4j
public class AliveService {
    @Autowired
    @SuppressWarnings("unused")
    private AliveMapper aliveMapper;

    @Autowired
    @SuppressWarnings("unused")
    private PlatformService platformService;

    @Autowired
    @SuppressWarnings("unused")
    private KafkaTemplate<String, String> kafkaTemplate;

    @Value("${dispatch.kafka.topic}")
    @NotNull
    @SuppressWarnings("unused")
    private String kafkaTopic;

    private static final String KEY = "DISPATCH_LIVE_UPDATE";

    private SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");

    private void sendKafka(Object data) {
        kafkaTemplate.send(kafkaTopic, AliveService.KEY, JacksonUtil.toJson(data));
    }

    public Integer insertAliveInfo(AliveInfoDTO dto) {
        Alive alive = new Alive();
        alive.setId(UuidUtil.getUuid());
        alive.setName(dto.getName());
        alive.setDevices(StringUtils.join(dto.getDeviceIds().toArray(), ","));
        alive.setOrganization(dto.getOrganization());
        alive.setStartTime(dto.getStarttime());
        alive.setEndTime(dto.getEndtime());
        int status = aliveMapper.insertSelective(alive);
        if (status != 1) {
            log.info("Insert info,but insert info to t_dispatch_white failed");
            return 0;
        }
        KafkaMessage message = new KafkaMessage();
        message.setId(alive.getId());
        this.sendKafka(message);
        log.info("Insert info successfully");
        return 1;
    }

    public Integer updateAliveInfo(AliveInfoDTO dto) {
        Alive alive = new Alive();
        alive.setId(dto.getId());
        alive.setName(dto.getName());
        alive.setDevices(StringUtils.join(dto.getDeviceIds().toArray(), ","));
        alive.setOrganization(dto.getOrganization());
        alive.setStartTime(dto.getStarttime());
        alive.setStatus(0);
        alive.setEndTime(dto.getEndtime());
        alive.setCreateTime(new Date());
        int status = aliveMapper.updateByPrimaryKeyWithBLOBs(alive);
        if (status != 1) {
            log.info("Insert info,but insert info to t_dispatch_alive failed");
            return 0;
        }
        KafkaMessage message = new KafkaMessage();
        message.setId(alive.getId());
        this.sendKafka(message);
        log.info("update info successfully");
        return 1;
    }

    public Integer deleteAliveInfo(String id) {
        int status = aliveMapper.deleteByPrimaryKey(id);
        if (status != 1){
            log.info("Delete info failed ");
            return 0;
        }
        this.sendKafka(id);
        log.info("Delete info successfully ");
        return status;
    }

    public Integer updateAliveInfoStatus(String id, int status) {
        Alive  alive = new Alive();
        alive.setId(id);
        alive.setStatus(status);
        int i = aliveMapper.updateByPrimaryKeySelective(alive);
        if (i == 1) {
            if (status == 0) {
                this.sendKafka(id);
            }
            if (status == 1) {
                this.sendKafka(id);
            }
            return 1;
        }
        return 0;
    }

    public AliveInfoVO searchAliveInfo(SearchAliveInfoDTO dto) {
        AliveInfoVO vo = new AliveInfoVO();
        Page page = PageHelper.offsetPage(dto.getStart(),dto.getLimit(), true);
        List<Alive> aliveList = aliveMapper.searchAliveInfo(dto.getName());
        PageInfo info = new PageInfo(page.getResult());
        int total = (int) info.getTotal();
        vo.setTotal(total);
        List<AliveInfo> list = new ArrayList<>();
        for (Alive alive : aliveList){
            AliveInfo aliveInfo = new AliveInfo();
            aliveInfo.setId(alive.getId());
            aliveInfo.setName(alive.getName());
            List<String> deviceIds = Arrays.asList(alive.getDevices().split(","));
            aliveInfo.setDeviceIds(deviceIds);
            List<String> deviceNames = new ArrayList<>();
            for (String deviceId : deviceIds){
                String deviceName = platformService.getCameraDeviceName(deviceId);
                deviceNames.add(deviceName);
            }
            aliveInfo.setDeviceNames(deviceNames);
            aliveInfo.setOrganization(alive.getOrganization());
            aliveInfo.setStartTime(alive.getStartTime());
            aliveInfo.setEndTime(alive.getEndTime());
            aliveInfo.setStatus(alive.getStatus());
            aliveInfo.setCreatetime(sdf.format(alive.getCreateTime()));
            list.add(aliveInfo);
        }
        vo.setAliveInfoVOS(list);
        return vo;
    }
}
