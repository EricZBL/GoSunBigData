package com.hzgc.service.white.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;

@ApiModel(value = "白名单布控人员信息封装")
@Data
public class WhiteInfoVO implements Serializable {
    @ApiModelProperty(value = "人员ID")
    private Long id;
    @ApiModelProperty(value = "布控ID")
    private String whiteId;
    @ApiModelProperty(value = "姓名")
    private String name;
}
