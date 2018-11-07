package com.hzgc.service.alive.param;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.io.Serializable;
import java.util.List;

@ApiModel(value = "添加，修改活体名单布控信息入参封装")
@Data
public class AliveInfoDTO implements Serializable {
    @ApiModelProperty(value = "ID")
    private String id;
    @ApiModelProperty(value = "布控名称")
    private String name;
    @ApiModelProperty(value = "设备ID列表")
    private List<String> deviceIds;
    @ApiModelProperty(value = "相机组织")
    private String organization;
    @ApiModelProperty(value = "开始时间")
    private String starttime;
    @ApiModelProperty(value = "结束时间")
    private String endtime;
}
