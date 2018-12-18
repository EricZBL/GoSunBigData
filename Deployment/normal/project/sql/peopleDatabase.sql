-- noinspection SqlNoDataSourceInspectionForFile

CREATE DATABASE IF NOT EXISTS lts;
CREATE DATABASE IF NOT EXISTS people;

USE people;

CREATE TABLE IF NOT EXISTS  `t_people` (
  `id` varchar(32) NOT NULL COMMENT '人员全局ID',
  `name` varchar(32) NOT NULL COMMENT '人员姓名',
  `idcard` varchar(18) NOT NULL COMMENT '身份证',
  `region` bigint(20) NOT NULL COMMENT '区域ID(省市区)',
  `household` varchar(100) DEFAULT NULL COMMENT '户籍',
  `address` varchar(100) DEFAULT NULL COMMENT '现居地',
  `sex` varchar(2) DEFAULT '0' COMMENT '性别',
  `age` int(2) DEFAULT NULL COMMENT '年龄',
  `birthday` varchar(10) DEFAULT NULL COMMENT '出生日期',
  `politic` varchar(10) DEFAULT NULL COMMENT '政治面貌',
  `edulevel` varchar(10) DEFAULT NULL COMMENT '文化程度',
  `job` varchar(32) DEFAULT NULL COMMENT '职业',
  `birthplace` varchar(20) DEFAULT NULL COMMENT '籍贯',
  `community` bigint(20) DEFAULT NULL COMMENT '小区ID',
  `lasttime` timestamp NULL DEFAULT NULL COMMENT '最后出现时间',
  `createtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `idcard` (`idcard`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='人口库';

CREATE TABLE IF NOT EXISTS  `t_car` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `car` varchar(50) NOT NULL COMMENT '车辆信息',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='车辆信息表';

CREATE TABLE IF NOT EXISTS  `t_flag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `flagid` int(2) NOT NULL COMMENT '标签标识ID',
  `flag` varchar(10) NOT NULL COMMENT '标签',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='标签表';

CREATE TABLE IF NOT EXISTS  `t_house` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `house` varchar(100) NOT NULL COMMENT '房产信息',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='房产信息表';

CREATE TABLE IF NOT EXISTS  `t_imsi` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `imsi` varchar(20) NOT NULL COMMENT 'IMSI码',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='IMSI码表';

CREATE TABLE IF NOT EXISTS  `t_phone` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `phone` varchar(11) NOT NULL COMMENT '联系方式',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='联系方式表';

CREATE TABLE IF NOT EXISTS  `t_picture` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `idcardpic` longblob DEFAULT NULL COMMENT '证件照片',
  `capturepic` longblob DEFAULT NULL COMMENT '实际采集照片',
  `feature` varchar(8192) NOT NULL COMMENT '特征值',
  `bitfeature` varchar(512) NOT NULL COMMENT 'bit特征值',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='照片信息库';

CREATE TABLE IF NOT EXISTS `t_imei` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `imei` varchar(20) NOT NULL COMMENT 'IMEI码',
  `guardianName` varchar(20) NOT NULL COMMENT '监护人名称',
  `guardianPhone` varchar(11) COMMENT '监护人联系方式',
  `cadresName` varchar(20) COMMENT '负责干部名称',
  `cadresPhone` varchar(11) COMMENT '负责干部联系方式',
  `policeName` varchar(20) COMMENT '负责干警名称',
  `policePhone` varchar(11) COMMENT '负责干警联系方式',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `T_INDEX_PEOPLE_ID` (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='IMEI码表';

CREATE TABLE IF NOT EXISTS  `t_inner_feature` (
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `feature` varchar(8192) NOT NULL COMMENT '特征值',
  `bitfeature` varchar(512) NOT NULL COMMENT 'bit特征值',
  PRIMARY KEY (`peopleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='内部人脸特征库';

CREATE TABLE IF NOT EXISTS  `t_24hour_count` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `community` bigint(20) NOT NULL COMMENT '小区ID',
  `hour` varchar(10) NOT NULL COMMENT '抓拍小时:yyyyMMddHH',
  `count` int(11) NOT NULL COMMENT '抓拍次数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='24小时抓拍统计表';

CREATE TABLE IF NOT EXISTS `t_recognize_record` (
 `id` VARCHAR(32) NOT NULL COMMENT 'ID',
 `peopleid` VARCHAR(32) NOT NULL COMMENT '人口库人员全局唯一ID',
 `community` BIGINT(20) NOT NULL COMMENT '小区ID（设备所在小区）',
 `pictureid` BIGINT(20) DEFAULT NULL COMMENT '人口库图片ID',
 `deviceid` VARCHAR(50) NOT NULL COMMENT '抓拍设备ID',
 `capturetime` TIMESTAMP NOT NULL COMMENT '抓拍时间',
 `surl` VARCHAR(255) DEFAULT NULL COMMENT '小图ftp路径(带hostname的ftpurl)',
 `burl` VARCHAR(255) DEFAULT NULL COMMENT '大图ftp路径(带hostname的ftpurl)',
 `flag` INT(2) DEFAULT NULL COMMENT '识别标签(0:未知, 1:实名, 2:新增 ,10:原图)',
 `similarity` FLOAT DEFAULT NULL COMMENT '匹配相似度',
 `plate` VARCHAR(50) DEFAULT NULL COMMENT '抓拍车牌',
 `type` INT(2) NOT NULL COMMENT '识别类型(1:人脸, 2:侦码, 3:车辆)',
 `imsi` VARCHAR (20) DEFAULT NULL COMMENT '手机imsi码',
 `mac` VARCHAR (20) DEFAULT NULL COMMENT 'Mac地址',
 PRIMARY KEY (`id`)
)  ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='识别记录表';

CREATE TABLE IF NOT EXISTS  `t_device_recognize` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `community` bigint(20) NOT NULL COMMENT '小区ID',
  `deviceid` varchar(50) NOT NULL COMMENT '设备ID',
  `currenttime` varchar(8) NOT NULL COMMENT '当天日期(yyyyMMdd)',
  `count` int(11) NOT NULL COMMENT '统计次数',
  `flag` int(2) NOT NULL COMMENT '设备类型(1：人脸相机，2：侦码设备)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='设备抓拍次数记录表';

CREATE TABLE IF NOT EXISTS  `t_fusion_imsi` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `community` bigint(20) NOT NULL COMMENT '小区ID',
  `deviceid` varchar(50) NOT NULL COMMENT '帧码设备ID',
  `receivetime` timestamp NOT NULL COMMENT '接收时间',
  `imsi` varchar(20) NOT NULL COMMENT 'imsi码',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='数据融合记录表';

CREATE TABLE IF NOT EXISTS  `t_mac_all` (
  `time` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT '存储时间',
  `mac` varchar(20) DEFAULT NULL COMMENT 'mac地址',
  `wifisn` varchar(15) DEFAULT NULL COMMENT 'wifi编号',
  `sn` varchar(15) DEFAULT NULL COMMENT '设备编号',
  `id` bigint(15) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `communityId` bigint NOT NULL COMMENT '社区id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='mac地址信息库';

CREATE TABLE IF NOT EXISTS  `t_imsi_all` (
  `imsi` varchar(20) DEFAULT NULL COMMENT '手机imsi码',
  `controlsn` varchar(20) DEFAULT NULL COMMENT '设备id',
  `sourcesn` varchar(20) DEFAULT NULL COMMENT '基站',
  `imei` varchar(20) DEFAULT NULL COMMENT '手机imei码',
  `mscid` varchar(20) DEFAULT NULL COMMENT 'msc编号',
  `lac` varchar(20) DEFAULT NULL COMMENT '区域码',
  `cellid` varchar(20) DEFAULT NULL COMMENT '小区id',
  `freq` varchar(20) DEFAULT NULL COMMENT '频点',
  `biscorpci` varchar(20) DEFAULT NULL COMMENT '小区识别',
  `attach` varchar(20) DEFAULT NULL COMMENT '通道编号',
  `savetime` timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  `standard` varchar(10) DEFAULT NULL COMMENT '运营商',
  `id` varchar(32) NOT NULL COMMENT 'uuid',
  `communityId ` bigint NOT NULL COMMENT '社区id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=74 COMMENT='IMSI码总表';

CREATE TABLE IF NOT EXISTS  `t_imsi_blacklist` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `imsi` varchar(20) NOT NULL COMMENT 'imsi码',
  `currenttime` date NOT NULL COMMENT '当天日期(yyyy-MM-dd)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='侦码黑名单表';

CREATE TABLE IF NOT EXISTS  `t_imsi_filter` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `imsi` varchar(20) NOT NULL COMMENT 'imsi码',
  `currenttime` date NOT NULL COMMENT '当天日期(yyyy-MM-dd)',
  `count` int(10) NOT NULL COMMENT '统计次数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='侦码过滤记录表';

CREATE TABLE IF NOT EXISTS  `t_people_new` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `community` bigint(20) NOT NULL COMMENT '小区ID',
  `month` varchar(6) NOT NULL COMMENT '疑似迁入月份:yyyyMM',
  `isconfirm` int(2) NOT NULL COMMENT '是否确认迁入(1:未确认，2：已确认迁入，3：确认未迁入)',
  `flag` int(2) NOT NULL COMMENT '标签(1:预实名, 2:新增)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='疑似迁入记录表';

CREATE TABLE IF NOT EXISTS  `t_people_out` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `peopleid` varchar(32) NOT NULL COMMENT '人员全局ID',
  `community` bigint(20) NOT NULL COMMENT '小区ID',
  `month` varchar(6) NOT NULL COMMENT '疑似迁出月份:yyyyMM',
  `isconfirm` int(2) NOT NULL COMMENT '是否确认迁出(1:未确认，2：已确认迁出，3：确认未迁出)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=30001 COMMENT='疑似迁出记录表';

CREATE TABLE IF NOT EXISTS  t_dispatch(
  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT '布控ID',
  region BIGINT(20) NOT NULL COMMENT '区域ID（布控区域）',
  name VARCHAR(10) COMMENT '姓名',
  idcard VARCHAR(18) COMMENT '身份证',
  face LONGBLOB COMMENT '布控人脸',
  feature VARCHAR(8192) COMMENT '特征值',
  bit_feature VARCHAR(512) COMMENT 'bit特征值',
  threshold FLOAT COMMENT '阈值',
  car VARCHAR(50) COMMENT '布控车辆',
  mac VARCHAR(50) COMMENT '布控MAC',
  notes VARCHAR(100) COMMENT '备注',
  status INT(2) NOT NULL DEFAULT 0 COMMENT '布控状态（0：开启，1：停止）',
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '布控库';

CREATE TABLE IF NOT EXISTS  t_dispatch_recognize (
  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT '布控识别ID',
  dispatch_id VARCHAR(32) NOT NULL COMMENT '布控ID',
  record_time TIMESTAMP NOT NULL COMMENT '识别时间',
  device_id VARCHAR(50) NOT NULL COMMENT '设备ID',
  burl VARCHAR(255) COMMENT '识别大图（人脸大图、车辆大图）',
  surl VARCHAR(255) COMMENT '识别小图（人脸小图、车辆小图）',
  similarity FLOAT COMMENT '相似度',
  type INT(2) NOT NULL COMMENT '识别类型（0：人脸识别，1：车辆识别，2：MAC识别）',
  create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY (id),
  KEY `T_INDEX_RECORD_TIME` (`record_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '布控识别库';

CREATE TABLE IF NOT EXISTS  t_dispatch_white(
  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT '白名单ID',
  name VARCHAR(32) NOT NULL COMMENT '白名单名称',
  devices TEXT NOT NULL COMMENT '设备ID列表 ',
  organization TEXT COMMENT '相机组织',
  status INT(2) NOT NULL DEFAULT 0 COMMENT  '状态值(0:开启,1:停止)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '白名单库';

CREATE TABLE IF NOT EXISTS  t_dispatch_whiteinfo(
  id BIGINT(20) PRIMARY KEY AUTO_INCREMENT NOT NULL COMMENT '白名单人员ID',
  white_id VARCHAR(32)  NOT NULL COMMENT '白名单ID',
  name VARCHAR(10) COMMENT '人员姓名',
  picture LONGBLOB NOT NULL COMMENT '人员照片',
  feature VARCHAR(8192) NOT NULL COMMENT '特征值',
  bit_feature VARCHAR(64) NOT NULL COMMENT 'bit位特征值'
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '白名单人员表';

CREATE TABLE IF NOT EXISTS  t_dispatch_alive(
  id VARCHAR(32) PRIMARY KEY NOT NULL COMMENT 'ID',
  name VARCHAR(32) COMMENT '布控名称',
  devices TEXT COMMENT  '设备ID列表 ',
  organization TEXT COMMENT '相机组织',
  start_time VARCHAR(10) NOT NULL COMMENT '开始时间',
  end_time VARCHAR(10) NOT NULL COMMENT '结束时间',
  status INT(2) NOT NULL DEFAULT 0 COMMENT  '状态值(0:开启,1:停止)',
  create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '活体检测表';

SET GLOBAL sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
SET SESSION sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
