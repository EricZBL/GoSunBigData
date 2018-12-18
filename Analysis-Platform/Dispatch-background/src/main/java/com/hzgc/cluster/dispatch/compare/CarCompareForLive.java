package com.hzgc.cluster.dispatch.compare;

import com.hzgc.cluster.dispatch.cache.CaptureCache;
import com.hzgc.cluster.dispatch.cache.TableCache;
import com.hzgc.cluster.dispatch.dao.DispatchRecognizeMapper;
import com.hzgc.cluster.dispatch.model.DispatchAlive;
import com.hzgc.cluster.dispatch.model.DispatchRecognize;
import com.hzgc.cluster.dispatch.producer.AlarmMessage;
import com.hzgc.cluster.dispatch.producer.Producer;
import com.hzgc.common.collect.bean.CarObject;
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
public class CarCompareForLive implements Runnable{
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

    public CarCompareForLive(){
        action = true;
    }

    @Override
    public void run() {
        while (action) {
            long start = System.currentTimeMillis();
            List<CarObject> carObjects = captureCache.getCarObjectsForLive();
            if(carObjects.size() == 0){
                try {
                    log.info("The size of car for live is 0");
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                continue;
            }

            List<String> ipcIds = new ArrayList<>();
            for(CarObject carObject : carObjects){
                ipcIds.add(carObject.getIpcId());
            }

            Map<String, CameraQueryDTO> map = new HashMap<>();
            try {
                map = platformService.getCameraInfoByBatchIpc(ipcIds);
            }catch (Exception e){
                log.error(e.getMessage());
                e.printStackTrace();
                continue;
            }
            for(CarObject carObject : carObjects){
                List<DispatchAlive> dispachAliveRules = tableCache.getDispachAlive(carObject.getIpcId());
                if(dispachAliveRules == null || dispachAliveRules.size() == 0){
                    continue;
                }
                String captachDate = carObject.getTimeStamp();
                if(captachDate == null || captachDate.equals("") || !captachDate.contains(":") || !captachDate.contains(" ")){
                    log.error("The time of captach is not complant format :" + captachDate);
                    continue;
                }

                try {
                    String captachTime = captachDate.split(" ")[1];
                    for(DispatchAlive dispachAliveRule : dispachAliveRules) {
                        if (dispachAliveRule.getStartTime().compareTo(captachTime) < 0 && dispachAliveRule.getEndTime().compareTo(captachTime) > 0) {
                            DispatchRecognize dispatureRecognize = new DispatchRecognize();
                            dispatureRecognize.setId(UuidUtil.getUuid().substring(0, 32));
                            dispatureRecognize.setDispatchId(dispachAliveRule.getId());
                            dispatureRecognize.setDeviceId(carObject.getIpcId());
                            dispatureRecognize.setType(4);
                            String surl = CollectUrlUtil.toHttpPath(carObject.getHostname(), "2573", carObject.getsAbsolutePath());
                            String burl = CollectUrlUtil.toHttpPath(carObject.getHostname(), "2573", carObject.getbAbsolutePath());
                            dispatureRecognize.setSurl(surl);
                            dispatureRecognize.setBurl(burl);
                            dispatureRecognize.setRecordTime(sdf.parse(carObject.getTimeStamp()));
                            dispatureRecognize.setCreateTime(new Date());
                            try {
                                dispatureRecognizeMapper.insertSelective(dispatureRecognize);
                            } catch (Exception e) {
                                e.printStackTrace();
                                log.error(e.getMessage());
                            }

                            AlarmMessage alarmMessage = new AlarmMessage();
                            String ip = carObject.getIp();
                            alarmMessage.setBCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", carObject.getbAbsolutePath()));
                            alarmMessage.setCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", carObject.getsAbsolutePath()));
                            alarmMessage.setDeviceId(carObject.getIpcId());
                            alarmMessage.setName(dispachAliveRule.getName());
                            alarmMessage.setDeviceName(map.get(carObject.getIpcId()).getCameraName());
                            alarmMessage.setType(4);
                            alarmMessage.setTime(carObject.getTimeStamp());
                            producer.send(topic, JacksonUtil.toJson(alarmMessage));
                            break;
                        }
                    }
                } catch (Exception e) {
                    log.error(e.getMessage());
                    e.printStackTrace();
                }

            }
            log.info("The size of car compared for live is " + carObjects.size() + " , the time is " + (System.currentTimeMillis() - start));
        }
    }
}
