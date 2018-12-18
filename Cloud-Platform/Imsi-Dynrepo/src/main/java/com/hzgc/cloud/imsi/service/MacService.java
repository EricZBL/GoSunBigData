package com.hzgc.cloud.imsi.service;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import com.hzgc.common.service.response.ResponseResult;
import com.hzgc.cloud.imsi.dao.MacInfoMapper;
import com.hzgc.cloud.imsi.model.MacInfo;
import com.hzgc.cloud.imsi.model.MacParam;
import com.hzgc.cloud.imsi.model.MacVO;
import com.hzgc.cloud.imsi.model.SearchMacDTO;
import com.hzgc.common.util.json.JacksonUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class MacService {
    @Autowired
    private MacInfoMapper macInfoMapper;

    public ResponseResult <List <MacInfo>> queryBySns(MacParam macParam) {
        try {
            List <MacInfo> macInfos = macInfoMapper.selectBySns(macParam);
            return ResponseResult.init(macInfos);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ResponseResult<List<MacVO>> searchIMSI(SearchMacDTO searchMacDTO) {
        List<MacVO> macVOList = new ArrayList<>();
        Page page = PageHelper.offsetPage(searchMacDTO.getStart(), searchMacDTO.getLimit(), true);
        List<MacInfo> imsiInfoList = macInfoMapper.searchMac(searchMacDTO);




        return ResponseResult.init(macVOList, page.getTotal());
    }
}
