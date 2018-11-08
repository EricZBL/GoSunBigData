#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    sparkStart.sh
## Description: 启动spark集群的脚本.
## Version:     1.0
## Author:      chenke
## Created:     2017-10-24
################################################################################
#set -e
#set -x

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/kafkaStart.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## spark的sbin目录
SPARK_SBIN_DIR=${INSTALL_HOME}/Spark/spark/sbin

## spark的安装节点，需要拼接，放入数组中
SPARK_NAMENODE=$(grep Spark_NameNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
SPARK_STANDBYNODE=$(grep Spark_StandbyNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)

sh ${SPARK_SBIN_DIR}/stop-all.sh
ssh root@$SPARK_STANDBYNODE "sh ${SPARK_SBIN_DIR}/stop-master.sh"