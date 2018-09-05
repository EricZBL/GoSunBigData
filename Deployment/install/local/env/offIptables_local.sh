#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    offIptables.sh
## Description: 关闭防火墙，防火墙对大数据有影响。
##              实现自动化的脚本
## Version:     1.0
## Author:      yinhang
## Created:     2018-07-28
################################################################################

#set -x

cd `dirname $0`
## bin 目录
BIN_DIR=`pwd`
cd ../../..
## 安装根目录
ROOT_HOME=`pwd`
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 关闭防火墙日记 
LOG_FILE=${LOG_DIR}/offIpTable.log

mkdir -p ${LOG_DIR}

echo "" | tee  -a  $LOG_FILE
echo "**************************************************" | tee  -a  $LOG_FILE
echo "将/etc/selinux/config 里面 SELINUX 的配置 enforcing 改成 disabled ..." | tee -a $LOG_FILE
sed -i "s#enforcing#disabled#g" /etc/selinux/config
echo "准备关闭节点的防火墙..." | tee -a $LOG_FILE
systemctl stop firewalld.service
systemctl disable firewalld.service
echo "关闭防火墙成功!!!" | tee -a $LOG_FILE
