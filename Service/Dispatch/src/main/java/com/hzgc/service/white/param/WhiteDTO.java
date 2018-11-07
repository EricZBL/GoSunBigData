package com.hzgc.service.white.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@ApiModel(value = "添加，修改白名单布控信息入参封装")
@Data
public class WhiteDTO implements Serializable {
    @ApiModelProperty(value = "布控ID")
    private String id;
    @ApiModelProperty(value = "布控名称")
    private String name;
    @ApiModelProperty(value = "人员信息")
    private List<PeopleInfo> peopleInfos;
    @ApiModelProperty(value = "设备ID列表")
    private List<String> deviceIds;
    @ApiModelProperty(value = "相机组织")
    private String organization;
}

