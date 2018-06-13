package com.hzgc.cluster.spark.consumer;

import com.hzgc.cluster.spark.util.PropertiesUtil;
import com.hzgc.common.es.ElasticSearchHelper;
import com.hzgc.common.table.dynrepo.AlarmTable;
import com.hzgc.common.table.dynrepo.DynamicTable;
import com.hzgc.jni.FaceAttribute;
import jodd.util.StringUtil;
import org.apache.log4j.Logger;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.update.UpdateResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.rest.RestStatus;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class PutDataToEs implements Serializable {
    private SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private static Logger LOG = Logger.getLogger(PutDataToEs.class);
    private TransportClient esClient;

    private PutDataToEs() {
        Properties properties = PropertiesUtil.getProperties();
        String es_cluster = properties.getProperty("es.cluster.name");
        String es_hosts = properties.getProperty("es.hosts");
        Integer es_port = Integer.parseInt(properties.getProperty("es.cluster.port"));
        esClient = ElasticSearchHelper.getEsClient(es_cluster, es_hosts, es_port);
    }

    private static PutDataToEs instance = null;

    public static PutDataToEs getInstance() {
        if (instance == null) {
            synchronized (PutDataToEs.class) {
                if (instance == null) {
                    instance = new PutDataToEs();
                }
            }
        }
        return instance;
    }

    public int putDataToEs(String ftpurl, FaceObject faceObject) {
        String timestamp = faceObject.getTimeStamp();
        String ipcid = faceObject.getIpcId();
        int timeslot = faceObject.getTimeSlot();
        String date = faceObject.getDate();
        IndexResponse indexResponse = new IndexResponse();
        Map<String, Object> map = new HashMap<>();
        FaceAttribute faceAttr = faceObject.getAttribute();
        int haircolor = faceAttr.getHairColor();
        map.put(DynamicTable.HAIRCOLOR, haircolor);
        int eyeglasses = faceAttr.getEyeglasses();
        map.put(DynamicTable.EYEGLASSES, eyeglasses);
        int gender = faceAttr.getGender();
        map.put(DynamicTable.GENDER, gender);
        int hairstyle = faceAttr.getHairStyle();
        map.put(DynamicTable.HAIRSTYLE, hairstyle);
        int hat = faceAttr.getHat();
        map.put(DynamicTable.HAT, hat);
        int huzi = faceAttr.getHuzi();
        map.put(DynamicTable.HUZI, huzi);
        int tie = faceAttr.getTie();
        int sharpness = faceAttr.getSharpness();
        map.put(DynamicTable.SHARPNESS, sharpness);
        map.put(DynamicTable.TIE, tie);
        map.put(DynamicTable.DATE, date);
        map.put(DynamicTable.TIMESTAMP, timestamp);
        map.put(DynamicTable.IPCID, ipcid);
        map.put(DynamicTable.TIMESLOT, timeslot);
        if (ftpurl != null) {
            indexResponse = esClient.prepareIndex(DynamicTable.DYNAMIC_INDEX,
                    DynamicTable.PERSON_INDEX_TYPE, ftpurl).setSource(map).get();
        }
        if (indexResponse.getVersion() == 1) {
            return 1;
        } else {
            return 0;
        }
    }

    public int upDateDataToEs(String ftpurl, String cluserId, String alarmTime, int alarmId) {
        UpdateResponse updateResponse = new UpdateResponse();
        Map<String, Object> map = new HashMap<>();
        map.put(DynamicTable.ALARM_ID, alarmId);
        map.put(DynamicTable.ALARM_TIME, alarmTime);
        map.put(DynamicTable.CLUSTERING_ID, cluserId);
        if (ftpurl != null) {
            updateResponse = esClient.prepareUpdate(DynamicTable.DYNAMIC_INDEX,
                    DynamicTable.PERSON_INDEX_TYPE, ftpurl).setDoc(map).get();
        }
        if (updateResponse.status().getStatus() == 200) {
            return RestStatus.OK.getStatus();
        } else {
            return RestStatus.CREATED.getStatus();
        }
    }

    public int alarmToEs(FaceObject obj, String ipcId, String paltId, String staticId,
                         String sim, String staticObjectType, String alarmType){
        Map<String, Object> map = new HashMap<>();
        map.put(AlarmTable.IPC_ID, ipcId);
        map.put(AlarmTable.ALARM_TYPE, alarmType);
        map.put(AlarmTable.HOST_NAME, obj.getHostname());
        map.put(AlarmTable.BIG_PICTURE_URL, obj.getBurl());
        map.put(AlarmTable.SMALL_PICTURE, obj.getSurl());
        if(! StringUtil.isBlank(staticId)){
            map.put(AlarmTable.STATIC_ID, staticId);
        }
        if(! StringUtil.isBlank(sim)) {
            map.put(AlarmTable.SIMILARITY, sim);
        }
        if(! StringUtil.isBlank(staticObjectType)) {
            map.put(AlarmTable.OBJECT_TYPE, staticObjectType);
        }
        map.put(AlarmTable.ALARM_TIME, df.format(new Date()));
        map.put(AlarmTable.FLAG, 0);
        map.put(AlarmTable.CONFIRM, 1);
        IndexResponse indexResponse =
                esClient.prepareIndex(AlarmTable.ALARM_INDEX,
                        AlarmTable.RECOGENIZE_ALARM_TYPE).setSource(map).get();
        if (indexResponse.getVersion() == 1) {
            return 1;
        } else {
            return 0;
        }
    }
}
