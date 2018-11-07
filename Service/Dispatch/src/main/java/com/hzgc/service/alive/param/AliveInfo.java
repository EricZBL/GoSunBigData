package com.hzgc.service.alive.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@ApiModel(value = "信息展示返回封装")
@Data
public class AliveInfo implements Serializable {
    @ApiModelProperty(value = "ID")
    private String id;
    @ApiModelProperty(value = "布控名字")
    private String name;
    @ApiModelProperty(value = "设备ID列表")
    private List<String> deviceIds;
    @ApiModelProperty(value = "设备名称列表")
    private List<String> deviceNames;
    @ApiModelProperty(value = "相机组织")
    private String organization;
    @ApiModelProperty(value = "开始时间")
    private String startTime;
    @ApiModelProperty(value = "结束时间")
    private String endTime;
    @ApiModelProperty(value = "状态")
    private Integer status;
    @ApiModelProperty(value = "创建时间")
    private String createtime;
}
