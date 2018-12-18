package com.hzgc.cloud.people.dao;

import com.hzgc.cloud.people.model.Imei;

public interface ImeiMapper {
    int deleteByPrimaryKey(Long id);

    int insert(Imei imei);

    int insertSelective(Imei imei);

    Imei selectByPrimaryKey(Long id);

    int updateByPrimaryKeySelective(Imei imei);

    int updateByPrimaryKey(Imei record);

    Imei selectByPeopleId(String peopleId);

    int delete(String peopleid);

    String selectPeopleIdByImei(String imeiId);
}