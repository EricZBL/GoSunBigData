package com.hzgc.service.white.dao;

import com.hzgc.service.white.model.White;
import com.hzgc.service.white.param.SearchWhiteDTO;

import java.util.List;

public interface WhiteMapper {
    int deleteByPrimaryKey(String id);

    int insert(White record);

    int insertSelective(White record);

    White selectByPrimaryKey(String id);

    int updateByPrimaryKeySelective(White record);

    int updateByPrimaryKeyWithBLOBs(White record);

    int updateByPrimaryKey(White record);

    List<White> searchWhiteInfo(SearchWhiteDTO dto);
}