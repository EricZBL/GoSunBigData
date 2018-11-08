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


function main
{
	    echo "**********************************************"
	    echo "正在查看SELinux状态"
        STATUS=`getenforce`
        #`ssh $host "/usr/sbin/sestatus -v | grep 'SELinux status'|cut -d ':' -f2 | tr -d ' ' "`
        if [[ "x$STATUS" = "xenabled" ]]; then
            echo "selinux状态为enable"
            exit 1
            else
            echo "selinux状态为disabled"
        fi
}

main