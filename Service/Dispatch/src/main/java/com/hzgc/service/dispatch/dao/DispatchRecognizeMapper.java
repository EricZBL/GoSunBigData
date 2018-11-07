package com.hzgc.service.dispatch.dao;

import com.hzgc.service.dispatch.model.DispatchRecognize;
import com.hzgc.service.dispatch.param.DispatchRecognizeDTO;
import org.apache.ibatis.annotations.CacheNamespace;

import java.util.List;

@CacheNamespace
public interface DispatchRecognizeMapper {
    int deleteByPrimaryKey(String id);

    int insert(DispatchRecognize record);

    int insertSelective(DispatchRecognize record);

    List<DispatchRecognize> selectSelective(DispatchRecognizeDTO record);

    DispatchRecognize selectByPrimaryKey(String id);

    int updateByPrimaryKeySelective(DispatchRecognize record);

    int updateByPrimaryKey(DispatchRecognize record);
}