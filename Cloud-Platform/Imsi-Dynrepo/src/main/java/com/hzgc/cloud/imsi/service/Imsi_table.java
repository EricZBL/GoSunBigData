package com.hzgc.cloud.imsi.service;

import com.hzgc.common.service.sql.Table;

public interface Imsi_table extends Table {

    public String SQL_MAC = "CREATE TABLE IF NOT EXISTS  `t_mac_all` (\n" +
            "  `time` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT '存储时间',\n" +
            "  `mac` varchar(20) DEFAULT NULL COMMENT 'mac地址',\n" +
            "  `wifisn` varchar(15) DEFAULT NULL COMMENT 'wifi编号',\n" +
            "  `sn` varchar(15) DEFAULT NULL COMMENT '设备编号',\n" +
            "  `id` bigint(15) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `communityId` bigint(10) NOT NULL COMMENT '社区id',\n" +
            "  PRIMARY KEY (`id`),\n" +
            "  UNIQUE KEY `id` (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='mac地址信息库';";

    public String SQL_IMSI = "CREATE TABLE IF NOT EXISTS  `t_imsi_all` (\n" +
            "  `imsi` varchar(20) DEFAULT NULL COMMENT '手机imsi码',\n" +
            "  `controlsn` varchar(20) DEFAULT NULL COMMENT '设备id',\n" +
            "  `sourcesn` varchar(20) DEFAULT NULL COMMENT '基站',\n" +
            "  `imei` varchar(20) DEFAULT NULL COMMENT '手机imei码',\n" +
            "  `mscid` varchar(20) DEFAULT NULL COMMENT 'msc编号',\n" +
            "  `lac` varchar(20) DEFAULT NULL COMMENT '区域码',\n" +
            "  `cellid` varchar(20) DEFAULT NULL COMMENT '小区id',\n" +
            "  `freq` varchar(20) DEFAULT NULL COMMENT '频点',\n" +
            "  `biscorpci` varchar(20) DEFAULT NULL COMMENT '小区识别',\n" +
            "  `attach` varchar(20) DEFAULT NULL COMMENT '通道编号',\n" +
            "  `savetime` timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',\n" +
            "  `standard` varchar(10) DEFAULT NULL COMMENT '运营商',\n" +
            "  `id` varchar(32) NOT NULL COMMENT 'uuid',\n" +
            "  `communityId` bigint NOT NULL COMMENT '社区id',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=74 COMMENT='IMSI码总表';";

    public String SQL_IMSI_BLACKLIST = "CREATE TABLE IF NOT EXISTS  `t_imsi_blacklist` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `imsi` varchar(20) NOT NULL COMMENT 'imsi码',\n" +
            "  `currenttime` date NOT NULL COMMENT '当天日期(yyyy-MM-dd)',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='侦码黑名单表';";

    public String SQL_IMSI_FILTER = "CREATE TABLE IF NOT EXISTS  `t_imsi_filter` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `imsi` varchar(20) NOT NULL COMMENT 'imsi码',\n" +
            "  `currenttime` date NOT NULL COMMENT '当天日期(yyyy-MM-dd)',\n" +
            "  `count` int(10) NOT NULL COMMENT '统计次数',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='侦码过滤记录表';";

    public String INDEX_IMSI = "alter table t_imsi_all add index idx_imsi(imsi,communityId,savetime);";
}
