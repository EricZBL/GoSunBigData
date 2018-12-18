package com.hzgc.cluster.dispatch.compare;

import com.hzgc.cluster.dispatch.cache.CaptureCache;
import com.hzgc.cluster.dispatch.cache.TableCache;
import com.hzgc.cluster.dispatch.dao.DispatchRecognizeMapper;
import com.hzgc.cluster.dispatch.model.DispatchAlive;
import com.hzgc.cluster.dispatch.model.DispatchRecognize;
import com.hzgc.cluster.dispatch.producer.AlarmMessage;
import com.hzgc.cluster.dispatch.producer.Producer;
import com.hzgc.common.collect.bean.FaceObject;
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
public class FaceCompareForLive implements Runnable{
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

    public FaceCompareForLive(){
        action = true;
    }

    @Override
    public void run() {
        while (action) {
            long start = System.currentTimeMillis();
            List<FaceObject> faceObjects = captureCache.getFaceObjectsForLive();
            if(faceObjects.size() == 0){
                log.info("The size of face for live is 0");
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                continue;
            }

            List<String> ipcIds = new ArrayList<>();
            for(FaceObject faceObject : faceObjects){
                ipcIds.add(faceObject.getIpcId());
            }
            Map<String, CameraQueryDTO> map = new HashMap<>();
            try {
                map = platformService.getCameraInfoByBatchIpc(ipcIds);
            }catch (Exception e){
                log.error(e.getMessage());
                e.printStackTrace();
                continue;
            }

//            Map<String, CameraQueryDTO> map = new HashMap<>();
//            CameraQueryDTO cameraQueryDTO = new CameraQueryDTO();
//            cameraQueryDTO.setCameraName("asgag");
//            map.put("4C05839PAJE8728", cameraQueryDTO);
            for(FaceObject faceObject : faceObjects){
                List<DispatchAlive> dispachAliveRules = tableCache.getDispachAlive(faceObject.getIpcId());
                if(dispachAliveRules == null || dispachAliveRules.size() == 0){
                    continue;
                }
                String captachDate = faceObject.getTimeStamp();
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
                            dispatureRecognize.setDeviceId(faceObject.getIpcId());
                            dispatureRecognize.setType(4);
                            String surl = CollectUrlUtil.toHttpPath(faceObject.getHostname(), "2573", faceObject.getsAbsolutePath());
                            String burl = CollectUrlUtil.toHttpPath(faceObject.getHostname(), "2573", faceObject.getbAbsolutePath());
                            dispatureRecognize.setSurl(surl);
                            dispatureRecognize.setBurl(burl);
                            dispatureRecognize.setRecordTime(sdf.parse(faceObject.getTimeStamp()));
                            dispatureRecognize.setCreateTime(new Date());
                            try {
                                dispatureRecognizeMapper.insertSelective(dispatureRecognize);
                            } catch (Exception e) {
                                e.printStackTrace();
                                log.error(e.getMessage());
                            }
                            AlarmMessage alarmMessage = new AlarmMessage();
                            String ip = faceObject.getIp();
                            alarmMessage.setBCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", faceObject.getbAbsolutePath()));
                            alarmMessage.setCaptureImage(CollectUrlUtil.toHttpPath(ip, "2573", faceObject.getsAbsolutePath()));
                            alarmMessage.setName(dispachAliveRule.getName());
                            alarmMessage.setDeviceId(faceObject.getIpcId());
                            alarmMessage.setDeviceName(map.get(faceObject.getIpcId()).getCameraName());
                            alarmMessage.setType(4);
                            alarmMessage.setTime(faceObject.getTimeStamp());
                            producer.send(topic, JacksonUtil.toJson(alarmMessage));
                            break;
                        }
                    }
                } catch (Exception e) {
                    log.error(e.getMessage());
                    e.printStackTrace();
                }
            }
            log.info("The size of face compared for live is " + faceObjects.size() + " , the time is " + (System.currentTimeMillis() - start));
        }
    }
}
