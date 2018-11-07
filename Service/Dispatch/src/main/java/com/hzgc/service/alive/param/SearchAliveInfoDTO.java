package com.hzgc.service.alive.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;

@ApiModel(value = "信息展示入参封装")
@Data
public class SearchAliveInfoDTO implements Serializable {
    @ApiModelProperty(value = "查询内容")
    private String name;
    @ApiModelProperty(value = "起始行数")
    private int start;
    @ApiModelProperty(value = "分页行数")
    private int limit;
}
