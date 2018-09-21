package com.hzgc.service.people.service;

import com.github.pagehelper.PageHelper;
import com.hzgc.service.people.dao.*;
import com.hzgc.service.people.model.DeviceRecognize;
import com.hzgc.service.people.model.FusionImsi;
import com.hzgc.service.people.model.People;
import com.hzgc.service.people.model.PeopleRecognize;
import com.hzgc.service.people.param.*;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@Slf4j
public class CommunityService {
    @Autowired
    private PeopleMapper peopleMapper;
    @Autowired
    private NewPeopleMapper newPeopleMapper;
    @Autowired
    private ConfirmRecordMapper confirmRecordMapper;
    @Autowired
    private PeopleRecognizeMapper peopleRecognizeMapper;
    @Autowired
    private FusionImsiMapper fusionImsiMapper;
    @Autowired
    private DeviceRecognizeMapper deviceRecognizeMapper;

    private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    public CommunityPeopleCountVO countCommunityPeople(Long communityId) {
        CommunityPeopleCountVO vo = new CommunityPeopleCountVO();
        vo.setCommunityPeoples(peopleMapper.countCommunityPeople(communityId));
        vo.setImportantPeoples(peopleMapper.countImportantPeople(communityId));
        vo.setCarePeoples(peopleMapper.countCarePeople(communityId));
        vo.setNewPeoples(confirmRecordMapper.countNewPeople(communityId));
        vo.setOutPeoples(confirmRecordMapper.countOutPeople(communityId));
        return vo;
    }

    public List<CommunityPeopleVO> searchCommunityPeople(CommunityPeopleDTO param) {
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<People> peopleList = peopleMapper.searchCommunityPeople(param.getCommunityId());
        return this.shift(peopleList);
    }

    public List<CommunityPeopleVO> searchCommunityImportantPeople(CommunityPeopleDTO param) {
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<People> peopleList = peopleMapper.searchImportantPeople(param.getCommunityId());
        return this.shift(peopleList);
    }

    public List<CommunityPeopleVO> searchCommunityCarePeople(CommunityPeopleDTO param) {
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<People> peopleList = peopleMapper.searchCarePeople(param.getCommunityId());
        return this.shift(peopleList);
    }

    public List<CommunityPeopleVO> searchCommunityNewPeople(CommunityPeopleDTO param) {
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<People> peopleList = peopleMapper.searchNewPeople(param.getCommunityId());
        return this.shift(peopleList);
    }

    public List<CommunityPeopleVO> searchCommunityOutPeople(CommunityPeopleDTO param) {
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<People> peopleList = peopleMapper.searchOutPeople(param.getCommunityId());
        return this.shift(peopleList);
    }

    private List<CommunityPeopleVO> shift(List<People> peopleList) {
        List<CommunityPeopleVO> voList = new ArrayList<>();
        if (peopleList != null && peopleList.size() > 0) {
            for (People people : peopleList) {
                CommunityPeopleVO vo = new CommunityPeopleVO();
                vo.setId(people.getId());
                vo.setIdCard(people.getIdcard());
                vo.setName(people.getName());
                if (people.getLasttime() != null) {
                    vo.setLastTime(sdf.format(people.getLasttime()));
                }
                voList.add(vo);
            }
        }
        return voList;
    }

    public List<CommunityPeopleCaptureVO> searchCapture1Month(CommunityPeopleCaptureDTO param) {
        List<CommunityPeopleCaptureVO> voList = new ArrayList<>();
        PageHelper.offsetPage(param.getStart(), param.getLimit());
        List<PeopleRecognize> peopleList = peopleRecognizeMapper.searchCapture1Month(param.getPeopleId());
        List<FusionImsi> imsiList = fusionImsiMapper.searchCapture1Month(param.getPeopleId());
        if (peopleList != null && peopleList.size() > 0) {
            for (PeopleRecognize people : peopleList) {
                CommunityPeopleCaptureVO vo = new CommunityPeopleCaptureVO();
                vo.setCaptureTime(sdf.format(people.getCapturetime()));
                vo.setDeviceId(people.getDeviceid());
                vo.setFtpUrl(people.getBurl());
                voList.add(vo);
            }
        }
        if (imsiList != null && imsiList.size() > 0) {
            for (FusionImsi imsi : imsiList) {
                CommunityPeopleCaptureVO vo = new CommunityPeopleCaptureVO();
                vo.setCaptureTime(sdf.format(imsi.getReceivetime()));
                vo.setDeviceId(imsi.getDeviceid());
                vo.setImsi(imsi.getImsi());
                voList.add(vo);
            }
        }
        this.listSort(voList);
        return voList;
    }

    public List<CommunityPeopleCaptureVO> searchPeopleTrack1Month(CommunityPeopleCaptureDTO param) {
        List<CommunityPeopleCaptureVO> voList = new ArrayList<>();
        List<PeopleRecognize> peopleList = peopleRecognizeMapper.searchCapture1Month(param.getPeopleId());
        List<FusionImsi> imsiList = fusionImsiMapper.searchCapture1Month(param.getPeopleId());
        if (peopleList != null && peopleList.size() > 0) {
            for (PeopleRecognize people : peopleList) {
                CommunityPeopleCaptureVO vo = new CommunityPeopleCaptureVO();
                vo.setCaptureTime(sdf.format(people.getCapturetime()));
                vo.setDeviceId(people.getDeviceid());
                voList.add(vo);
            }
        }
        if (imsiList != null && imsiList.size() > 0) {
            for (FusionImsi imsi : imsiList) {
                CommunityPeopleCaptureVO vo = new CommunityPeopleCaptureVO();
                vo.setCaptureTime(sdf.format(imsi.getReceivetime()));
                vo.setDeviceId(imsi.getDeviceid());
                voList.add(vo);
            }
        }
        this.listSort(voList);
        return voList;
    }

    private void listSort(List<CommunityPeopleCaptureVO> voList){
        voList.sort((o1, o2) -> {
            try {
                Date d1 = sdf.parse(o1.getCaptureTime());
                Date d2 = sdf.parse(o2.getCaptureTime());
                return Long.compare(d1.getTime(), d2.getTime());
            } catch (ParseException e) {
                e.printStackTrace();
            }
            return 0;
        });
    }

    public List<CommunityPeopleCaptureCountVO> countDeviceCaptureNum1Month(CommunityPeopleCaptureDTO param) {
        List<CommunityPeopleCaptureCountVO> voList = new ArrayList<>();
        List<DeviceRecognize> deviceRecognizeList = deviceRecognizeMapper.countDeviceCaptureNum1Month(param.getPeopleId());
        if (deviceRecognizeList != null && deviceRecognizeList.size() > 0){
            List<String> deviceIdList = new ArrayList<>();
            for (DeviceRecognize device : deviceRecognizeList){
                String deviceId = device.getDeviceid();
                if (StringUtils.isNotBlank(deviceId) && !deviceIdList.contains(deviceId)){
                    deviceIdList.add(deviceId);
                }
            }
            if (deviceIdList.size() > 0){
                for (String deviceId : deviceIdList){
                    CommunityPeopleCaptureCountVO vo = new CommunityPeopleCaptureCountVO();
                    vo.setDeviceId(deviceId);
                    for (DeviceRecognize deviceRecognize : deviceRecognizeList){
                        if (deviceId.equals(deviceRecognize.getDeviceid())){
                            vo.setCount(vo.getCount() + deviceRecognize.getCount());
                        }
                    }
                    voList.add(vo);
                }
            }
        }
        return voList;
    }

    public List<CommunityPeopleCaptureCountVO> countCaptureNum3Month(CommunityPeopleCaptureDTO param) {
        List<CommunityPeopleCaptureCountVO> voList = new ArrayList<>();
        List<DeviceRecognize> deviceRecognizeList = deviceRecognizeMapper.countCaptureNum3Month(param.getPeopleId());
        return null;
    }
}
