package com.hzgc.cluster.dispatch.compare;


import com.hzgc.cluster.dispatch.cache.CaptureCache;
import com.hzgc.cluster.dispatch.cache.TableCache;
import com.hzgc.cluster.dispatch.dao.DispatchRecognizeMapper;
import com.hzgc.cluster.dispatch.model.DispatchAlive;
import com.hzgc.cluster.dispatch.model.DispatchRecognize;
import com.hzgc.cluster.dispatch.producer.AlarmMessage;
import com.hzgc.cluster.dispatch.producer.Producer;
import com.hzgc.common.collect.bean.PersonObject;
import com.hzgc.common.collect.util.CollectUrlUtil;
import com.hzgc.common.service.api.bean.CameraQueryDTO;
import com.hzgc.common.service.api.service.PlatformService;
import com.hzgc.common.util.basic.UuidUtil;
import com.hzgc.common.util.json.JacksonUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.text.SimpleDateFormat;
import java.util.*;

@Slf4j
@Component
public class PersonCompareForLive implements Runnable{
    private boolean action;
    @Autowired
    private CaptureCache captureCache;
    @Autowired
    private TableCache tableCache;
    @Autowired
    private DispatchRecognizeMapper dispatureRecognizeMapper;
    @Autowired
    private PlatformService platformService;
    @Autowired
    private Producer producer;
    @Value("${kafka.topic.dispatch-show}")
    private String topic;

    private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    public PersonCompareForLive(){
        action = true;
    }

    @Override
    public void run() {
        while (action) {
            long start = System.currentTimeMillis();
            List<PersonObject> personObjects = captureCache.getPersonObjectForLive();
            if(personObjects.size() == 0){
                log.info("The size of person for live is 0");
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                continue;
            }

            List<String> ipcIds = new ArrayList<>();
            for(PersonObject personObject : personObjects){
                ipcIds.add(personObject.getIpcId());
            }

            Map<String, CameraQueryDTO> map = new HashMap<>();
            try {
                map = platformService.getCameraInfoByBatchIpc(ipcIds);
            }catch (Exception e){
                log.error(e.getMessage());
                e.printStackTrace();
                continue;
            }

            for(PersonObject personObject : personObjects){
                List<DispatchAlive> dispachAliveRules = tableCache.getDispachAlive(personObject.getIpcId());
                if(dispachAliveRules == null || dispachAliveRules.size() == 0){
                    continue;
                }

                String captachDate = personObject.getTimeStamp();
                if(captachDate == null || captachDate.equals("") || !captachDate.contains(":") || !captachDate.contains(" ")){
                    log.error("The time of captach is not complant format :" + captachDate);
                    continue;
                }
                try {
                    String captachTime = captachDate.split(" ")[1];
                    for(DispatchAlive dispachAliveRule : dispachAliveRules) {
                        if (dispachAliveRule.getStartTime().compareTo(captachTime) < 0 && dispachAliveRule.getEndTime().compareTo(captachTime) > 0) {
                            DispatchRecognize dispatureRecognize = new DispatchRecognize();
                            dispatureRecognize.setDispatchId(dispachAliveRule.getId());
                            dispatureRecognize.setId(UuidUtil.getUuid().substring(0, 32));
                            dispatureRecognize.setDeviceId(personObject.getIpcId());
                            dispatureRecognize.setType(4);
                            String surl = CollectUrlUtil.toHttpPath(personObject.getHostname(), "2573", personObject.getsAbsolutePath());
                            String burl = CollectUrlUtil.toHttpPath(personObject.getHostname(), "2573", personObject.getbAbsolutePath());
                            dispatureRecognize.setSurl(surl);
                            dispatureRecognize.setBurl(burl);
                            dispatureRecognize.setRecordTime(sdf.parse(personObject.getTimeStamp()));
                            dispatureRecognize.setCreateTime(new Date());
                            try {
                                dispatureRecognizeMapper.insertSelective(dispatureRecognize);
                            } catch (Exception e) {
                                e.printStackTrace();
                                log.error(e.getMessage());
                            }

                            AlarmMessage alarmMessage = new AlarmMessage();
                            String ip = personObject.getIp();
                            alarmMessage.setBCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", personObject.getbAbsolutePath()));
                            alarmMessage.setCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", personObject.getsAbsolutePath()));
                            alarmMessage.setName(dispachAliveRule.getName());
                            alarmMessage.setDeviceId(personObject.getIpcId());
                            alarmMessage.setDeviceName(map.get(personObject.getIpcId()).getCameraName());
                            alarmMessage.setType(4);
                            alarmMessage.setTime(personObject.getTimeStamp());
                            producer.send(topic, JacksonUtil.toJson(alarmMessage));
                            break;
                        }
                    }
                } catch (Exception e) {
                    log.error(e.getMessage());
                    e.printStackTrace();
                }
            }
            log.info("The size of person compared for live is " + personObjects.size() + " , the time is " + (System.currentTimeMillis() - start));
        }
    }
}
