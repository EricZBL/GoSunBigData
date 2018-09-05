#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    selinuxStatus.sh
## Description: selinux状态检查
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-06
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
## conf 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/conf
## 集群所有节点主机名，放入数组中
CLUSTER_HOST=$(grep Cluster_HostName ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)
HOSTNAMES=(${CLUSTER_HOST//;/ })

function main
{
    HOSTS=""
    for host in ${HOSTNAMES[@]}
	do
	    echo "**********************************************"
	    echo "正在查看${host}的SELinux状态"
        STATUS=`getenforce`
        #`ssh $host "/usr/sbin/sestatus -v | grep 'SELinux status'|cut -d ':' -f2 | tr -d ' ' "`
        if [[ "x$STATUS" = "xenabled" ]]; then
            HOSTS=(${host},$HOSTS)
            echo "${host}上的selinux状态为enable"
            else
            echo "${host}上的selinux状态为disabled"
        fi
	done
	if [[ -n "${HOSTS}" ]]; then
	    echo "${HOSTS}的selinux状态为enable，需设置为disabled，重启机器生效后安装组件"
	    exit 1
	fi

}

main