#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    distributionHosts.sh
## Description: 扩展节点后新增hosts配置和分发hosts文件
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-06
################################################################################
#set -x  ## 用于调试用，不用的时候可以注释掉
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
## conf 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/expand/conf
## log 日记目录
LOG_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/logs
## hosts 文件
HOSTS_FILE=/etc/hosts
## 原集群节点
INSTALL_HOME=$(grep Cluster_HostName ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
INSTALL_HOSTNAMES=(${INSTALL_HOME//;/ })
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })
function distribution_hosts ()
{
for host in ${INSTALL_HOSTNAMES[@]};
do
scp ${HOSTS_FILE} root@${host}:${HOSTS_FILE}
done
for host in ${HOSTNAMES[@]};
do
scp ${HOSTS_FILE} root@${host}:${HOSTS_FILE}
done
}

function main ()
{
distribution_hosts
}
main