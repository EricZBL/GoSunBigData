package com.hzgc.service.alive.dao;

import com.hzgc.service.alive.model.Alive;

import java.util.List;

public interface AliveMapper {
    int deleteByPrimaryKey(String id);

    int insert(Alive record);

    int insertSelective(Alive record);

    Alive selectByPrimaryKey(String id);

    int updateByPrimaryKeySelective(Alive record);

    int updateByPrimaryKeyWithBLOBs(Alive record);

    int updateByPrimaryKey(Alive record);

    List<Alive> searchAliveInfo(String name);
}