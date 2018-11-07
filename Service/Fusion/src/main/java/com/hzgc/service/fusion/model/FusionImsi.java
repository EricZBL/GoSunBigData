package com.hzgc.service.fusion.model;

import java.io.Serializable;


public class FusionImsi implements Serializable {
    private Long id;

    private String peopleid;

    private String deviceid;

    private Long community;

    private String receivetime;

    private String imsi;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPeopleid() {
        return peopleid;
    }

    public void setPeopleid(String peopleid) {
        this.peopleid = peopleid == null ? null : peopleid.trim();
    }

    public String getDeviceid() {
        return deviceid;
    }

    public void setDeviceid(String deviceid) {
        this.deviceid = deviceid == null ? null : deviceid.trim();
    }

    public String getReceivetime() {
        return receivetime;
    }

    public void setReceivetime(String receivetime) {
        this.receivetime = receivetime;
    }

    public String getImsi() {
        return imsi;
    }

    public void setImsi(String imsi) {
        this.imsi = imsi == null ? null : imsi.trim();
    }

    public Long getCommunity() {
        return community;
    }
    public void setCommunity(Long community) {
        this.community = community;
    }
}