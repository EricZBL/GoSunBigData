package com.hzgc.service.white.model;

public class WhiteInfo {
    private Long id;

    private String whiteId;

    private String name;

    private String feature;

    private String bitFeature;

    private byte[] picture;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getWhiteId() {
        return whiteId;
    }

    public void setWhiteId(String whiteId) {
        this.whiteId = whiteId == null ? null : whiteId.trim();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }

    public String getFeature() {
        return feature;
    }

    public void setFeature(String feature) {
        this.feature = feature == null ? null : feature.trim();
    }

    public String getBitFeature() {
        return bitFeature;
    }

    public void setBitFeature(String bitFeature) {
        this.bitFeature = bitFeature == null ? null : bitFeature.trim();
    }

    public byte[] getPicture() {
        return picture;
    }

    public void setPicture(byte[] picture) {
        this.picture = picture;
    }
}