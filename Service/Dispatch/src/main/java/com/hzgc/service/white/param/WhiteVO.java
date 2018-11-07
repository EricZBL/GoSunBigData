package com.hzgc.service.white.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@ApiModel(value = "信息展示返回封装")
@Data
public class WhiteVO implements Serializable {
    @ApiModelProperty(value = "名称ID")
    private String id;
    @ApiModelProperty(value = "布控名称")
    private String name;
    @ApiModelProperty(value = "布控设备ID列表")
    private List<String> deviceIds;
    @ApiModelProperty(value = "布控设备名称列表")
    private List<String> deviceNames;
    @ApiModelProperty(value = "相机组织")
    private String organization;
    @ApiModelProperty(value = "状态值")
    private int status;
    @ApiModelProperty(value = "人员信息列表")
    private List<WhiteInfoVO> whiteInfoVOS;
}

