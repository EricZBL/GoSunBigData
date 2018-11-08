#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    kibanaInstall.sh
## Description: 安装并启动kibana。
##              实现自动化的脚本
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-06-28
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
LOG_FILE=${LOG_DIR}/kibanaInstall.log
## kibana 安装包目录
KIBANA_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## hive的安装节点，放入数组中
KIBANA_NODE=$(grep Kibana_InstallNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)

## HIVE_INSTALL_HOME hive 安装目录
KIBANA_INSTALL_HOME=${INSTALL_HOME}/Kibana
## HIVE_HOME  hive 根目录
KIBANA_HOME=${INSTALL_HOME}/Kibana/kibana


if [ ! -d $LOG_DIR ];then
    echo "创建安装日志目录"
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

## 启动kibana
cd ${KIBANA_HOME}/bin

echo "启动kibana"
 ./kibana > /dev/null &

set +x
