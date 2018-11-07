#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    sshpassInstall.sh
## Description: 安装sshpass的脚本.
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-6-30
################################################################################
set -x
#set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/sshpassInstall.log
## sshpass rpm 软件目录
SSHPASS_RPM_DIR=${ROOT_HOME}/component/basic_suports/sshpassRpm

cd ${SSHPASS_RPM_DIR}

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

rpm -ivh ${SSHPASS_RPM_DIR}/sshpass-1.06-1.el6.x86_64.rpm

which sshpass

set +x

