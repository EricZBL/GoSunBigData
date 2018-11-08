#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    installAll.sh
## Description: 安装环境的脚本.
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-7-2
################################################################################

#set -x
#set -e

cd `dirname $0`
## BIN目录，脚本所在的目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 本地模式目录
LOCAL_DIR=${BIN_DIR}/../local

ISLOCAL=$(grep "ISLOCAL" ${CONF_DIR}/cluster_conf.properties | cut -d "=" -f2)

if  [[ "${ISLOCAL}" == "yes"  ]]; then
    sh ${LOCAL_DIR}/bin/envInstall_local.sh
    else
    cd ${BIN_DIR}
    ## 安装sshpass
    sh sshpassInstall.sh

    ## 安装dos2unix
    sh dos2unixInstall.sh

    ## 安装expect
    sh expectInstall.sh

    ## 配置免密登录
    sh sshCilentLogin.sh

    ## 分发host
    sh ${ROOT_HOME}/tool/xsync /etc/hosts

    ## 删除环境变量
    sh delete_env_variable.sh

    ## 关闭防火墙
    sh offIptables.sh

    sh selinuxStatus.sh
    flag=$?
    if [[ $flag == 1 ]]; then
        exit 1
    fi
fi
