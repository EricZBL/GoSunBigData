package com.hzgc.cloud.peoman.worker.service;

import com.hzgc.common.service.sql.Table;

public interface People_background_table extends Table {

    public String SQL_24HOUR_COUNT = "CREATE TABLE IF NOT EXISTS  `t_24hour_count` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',\n" +
            "  `community` bigint(20) NOT NULL COMMENT '小区ID',\n" +
            "  `hour` varchar(10) NOT NULL COMMENT '抓拍小时:yyyyMMddHH',\n" +
            "  `count` int(11) NOT NULL COMMENT '抓拍次数',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='24小时抓拍统计表';";

    public String SQL_RECOGNIZE_RECORD = "CREATE TABLE IF NOT EXISTS `t_recognize_record` (\n" +
            " `id` VARCHAR(32) NOT NULL COMMENT 'ID',\n" +
            " `peopleid` VARCHAR(32) NOT NULL COMMENT '人口库人员全局唯一ID',\n" +
            " `community` BIGINT(20) NOT NULL COMMENT '小区ID（设备所在小区）',\n" +
            " `pictureid` BIGINT(20) DEFAULT NULL COMMENT '人口库图片ID',\n" +
            " `deviceid` VARCHAR(50) NOT NULL COMMENT '抓拍设备ID',\n" +
            " `capturetime` TIMESTAMP NOT NULL COMMENT '抓拍时间',\n" +
            " `surl` VARCHAR(255) DEFAULT NULL COMMENT '小图ftp路径(带hostname的ftpurl)',\n" +
            " `burl` VARCHAR(255) DEFAULT NULL COMMENT '大图ftp路径(带hostname的ftpurl)',\n" +
            " `flag` INT(2) DEFAULT NULL COMMENT '识别标签(0:未知, 1:实名, 2:新增 ,10:原图)',\n" +
            " `similarity` FLOAT DEFAULT NULL COMMENT '匹配相似度',\n" +
            " `plate` VARCHAR(50) DEFAULT NULL COMMENT '抓拍车牌',\n" +
            " `type` INT(2) NOT NULL COMMENT '识别类型(1:人脸, 2:侦码, 3:车辆)',\n" +
            " `imsi` VARCHAR (20) DEFAULT NULL COMMENT '手机imsi码',\n" +
            " `mac` VARCHAR (20) DEFAULT NULL COMMENT 'Mac地址',\n" +
            " PRIMARY KEY (`id`)\n" +
            ")  ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='识别记录表';";

    public String SQL_DEVICE_RECOGNIZE = "CREATE TABLE IF NOT EXISTS  `t_device_recognize` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',\n" +
            "  `community` bigint(20) NOT NULL COMMENT '小区ID',\n" +
            "  `deviceid` varchar(50) NOT NULL COMMENT '设备ID',\n" +
            "  `currenttime` varchar(8) NOT NULL COMMENT '当天日期(yyyyMMdd)',\n" +
            "  `count` int(11) NOT NULL COMMENT '统计次数',\n" +
            "  `flag` int(2) NOT NULL COMMENT '设备类型(1：人脸相机，2：侦码设备)',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='设备抓拍次数记录表';";

    public String SQL_PEOPLE_NEW = "CREATE TABLE IF NOT EXISTS  `t_people_new` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',\n" +
            "  `community` bigint(20) NOT NULL COMMENT '小区ID',\n" +
            "  `month` varchar(6) NOT NULL COMMENT '疑似迁入月份:yyyyMM',\n" +
            "  `isconfirm` int(2) NOT NULL COMMENT '是否确认迁入(1:未确认，2：已确认迁入，3：确认未迁入)',\n" +
            "  `flag` int(2) NOT NULL COMMENT '标签(1:预实名, 2:新增)',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='疑似迁入记录表';";

    public String SQL_PEOPLE_OUT = "CREATE TABLE IF NOT EXISTS  `t_people_out` (\n" +
            "  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',\n" +
            "  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',\n" +
            "  `community` bigint(20) NOT NULL COMMENT '小区ID',\n" +
            "  `month` varchar(6) NOT NULL COMMENT '疑似迁出月份:yyyyMM',\n" +
            "  `isconfirm` int(2) NOT NULL COMMENT '是否确认迁出(1:未确认，2：已确认迁出，3：确认未迁出)',\n" +
            "  PRIMARY KEY (`id`)\n" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='疑似迁出记录表';";

    public String INDEX_IDX_RECOGNIZE = "alter table t_recognize_record add index idx_recognize(type,community,capturetime);";

    public String INDEX_IDX_RECOGNIZE_01 = "alter table t_recognize_record add index idx_recognize_01(community,capturetime);";

    public String INDEX_FLAG = "alter table t_recognize_record add index flag(peopleid, flag);";

}
