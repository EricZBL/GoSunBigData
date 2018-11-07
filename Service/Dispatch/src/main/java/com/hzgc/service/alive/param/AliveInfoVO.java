package com.hzgc.service.alive.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@ApiModel(value = "活体名单库模糊查询出参")
@Data
public class AliveInfoVO implements Serializable {
    @ApiModelProperty(value = "总条数")
    private int total;
    @ApiModelProperty(value = "人员信息列表")
    private List<AliveInfo> aliveInfoVOS;
}
