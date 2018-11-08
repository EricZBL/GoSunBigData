#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_scala.sh
## Description: kafka扩展安装
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-14
################################################################################
## set -x  ## 用于调试用，不用的时候可以注释掉
#set -e
#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#
cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## ClusterBuildScripts 目录
CLUSTER_BUILD_SCRIPTS_DIR=`pwd`
## expand conf 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/expand/conf
## 安装日志目录
LOG_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/expand_scala.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })
## SCALA_INSTALL_HOME scala 安装目录
SCALA_INSTALL_HOME=${INSTALL_HOME}/Scala
## Scala_HOME  scala根目录
SCALA_HOME=${INSTALL_HOME}/Scala/scala


echo "-------------------------------------" | tee  -a  $LOG_FILE
echo "准备进行 scala 扩展安装操作 ing~" | tee  -a  $LOG_FILE
echo "-------------------------------------" | tee  -a  $LOG_FILE

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "===================================================" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

## 分发 scala 新增节点
for scala_host in ${HOSTNAMES[@]}
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将Scala分发到节点${scala_host}" | tee -a $LOG_FILE
    scp -r ${SCALA_INSTALL_HOME} root@${scala_host}:${INSTALL_HOME} > /dev/null
    echo "分发到节点${scala_host}完毕" | tee -a $LOG_FILE
done

echo "-------------------------------------" | tee  -a  $LOG_FILE
echo " scala 扩展安装操作完成 zzZ~" | tee  -a  $LOG_FILE
echo "-------------------------------------" | tee  -a  $LOG_FILE