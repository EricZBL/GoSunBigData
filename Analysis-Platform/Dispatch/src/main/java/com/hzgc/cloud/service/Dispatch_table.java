package com.hzgc.cloud.service;

import com.hzgc.common.service.sql.Table;

public interface Dispatch_table extends Table {

    public String SQL_DISPATCH = "CREATE TABLE IF NOT EXISTS  t_dispatch(\n" +
            "  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT '布控ID',\n" +
            "  region BIGINT(20) NOT NULL COMMENT '区域ID（布控区域）',\n" +
            "  name VARCHAR(10) COMMENT '姓名',\n" +
            "  idcard VARCHAR(18) COMMENT '身份证',\n" +
            "  face LONGBLOB COMMENT '布控人脸',\n" +
            "  feature VARCHAR(8192) COMMENT '特征值',\n" +
            "  bit_feature VARCHAR(512) COMMENT 'bit特征值',\n" +
            "  threshold FLOAT COMMENT '阈值',\n" +
            "  car VARCHAR(50) COMMENT '布控车辆',\n" +
            "  mac VARCHAR(50) COMMENT '布控MAC',\n" +
            "  notes VARCHAR(100) COMMENT '备注',\n" +
            "  status INT(2) NOT NULL DEFAULT 0 COMMENT '布控状态（0：开启，1：停止）',\n" +
            "  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',\n" +
            "  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',\n" +
            "  UNIQUE KEY (id)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '布控库';";

    public String SQL_DISPATCH_RECOGNIZE = "CREATE TABLE IF NOT EXISTS  t_dispatch_recognize (\n" +
            "  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT '布控识别ID',\n" +
            "  dispatch_id VARCHAR(32) NOT NULL COMMENT '布控ID',\n" +
            "  record_time TIMESTAMP NOT NULL COMMENT '识别时间',\n" +
            "  device_id VARCHAR(50) NOT NULL COMMENT '设备ID',\n" +
            "  burl VARCHAR(255) COMMENT '识别大图（人脸大图、车辆大图）',\n" +
            "  surl VARCHAR(255) COMMENT '识别小图（人脸小图、车辆小图）',\n" +
            "  similarity FLOAT COMMENT '相似度',\n" +
            "  type INT(2) NOT NULL COMMENT '识别类型（0：人脸识别，1：车辆识别，2：MAC识别）',\n" +
            "  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',\n" +
            "  UNIQUE KEY (id),\n" +
            "  KEY `T_INDEX_RECORD_TIME` (`record_time`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '布控识别库';";


    public String INDEX_RECOGNIZE = "alter table t_device_recognize add index idx_device_recognize(community,peopleid,currenttime,deviceid);";

    public String INDEX_IDX_RECOGNIZE = "alter table t_dispatch_recognize add index idx_recognize(type,record_time);";

}
