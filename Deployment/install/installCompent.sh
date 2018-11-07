#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    installAll.sh
## Description: 安装所有组件的脚本.
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-6-26
################################################################################

#set -x
#set -e

cd `dirname $0`
## BIN目录，脚本所在的目录
BIN_DIR=`pwd`
cd ../..
##安装包根目录
ROOT_HOME=`pwd`
##配置文件目录
CONF_DIR=${ROOT_HOME}/conf
WebUI_Dir=$(grep WebUI_Dir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
WebUI_File=${WebUI_Dir}/WebUI_Address
if [[ -d ${WebUI_Dir} ]]; then
    touch ${WebUI_File}
    else
    mkdir -p ${WebUI_Dir}
    touch ${WebUI_File}
fi

## 本地模式目录
LOCAL_DIR=${BIN_DIR}/../local

ISLOCAL=$(grep "ISLOCAL" ${CONF_DIR}/cluster_conf.properties | cut -d "=" -f2)

if  [[ "${ISLOCAL}" == "yes"  ]]; then
    sh ${LOCAL_DIR}/bin/componentInstall_local.sh
    echo "安装本地模式集群完成"
else
    cd ${BIN_DIR}
    #检查selinux状态
    sh selinuxStatus.sh
    flag=$?
    if [[ $flag == 1 ]]; then
        exit 1
    fi

    ##安装mysql
    sh mysqlInstall.sh

    ##安装jdk
    sh jdkInstall.sh

    ##安装zookeeper
    sh zookeeperInstall.sh

    ##安装hadoop
    sh hadoopInstall.sh

    ##安装hive
    sh hiveInstall.sh

    ##安装scala
    sh scalaInstall.sh

    ##安装kafka
    sh kafkaInstall.sh

    #安装kafka-eagle
    sh kafkaEagleInstall.sh

    ##安装spark
    sh sparkInstall.sh

    ##安装haproxy
    sh haproxyInstall.sh

    ##安装elastic
    sh elasticInstall.sh

    ##安装kibana
    sh kibanaInstall.sh

    ##安装lts
    sh ltsInstall.sh

    ##安装azkaban
    sh azkabanInstall.sh

    #配置环境变量
    sh create-global-env.sh

    #配置组件日志目录
    sh logconfig.sh

     echo "安装分布式集群完成"
fi

