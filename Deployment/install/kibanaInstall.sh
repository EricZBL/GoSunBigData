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

#set -x
##set -e

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
LOG_FILE=${LOG_DIR}/kibanaInstall.log
## kibana 安装包目录
KIBANA_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## kibana的安装节点，放入数组中
KIBANA_NODE=$(grep Kibana_InstallNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)

## KIBANA_INSTALL_HOME kibana 安装目录
KIBANA_INSTALL_HOME=${INSTALL_HOME}/Kibana
## KIBANA_HOME  kibana 根目录
KIBANA_HOME=${INSTALL_HOME}/Kibana/kibana


if [ ! -d $LOG_DIR ];then
    echo "创建安装日志目录"
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

function sync_file(){
## 首先检查本机上是否安装有kibana 如果有，则删除本机的kibana
if [ -e ${KIBANA_INSTALL_HOME} ];then
    echo "删除原有kibana"
    rm -rf ${KIBANA_INSTALL_HOME};
fi
mkdir -p ${KIBANA_INSTALL_HOME}
cp -r ${KIBANA_SOURCE_DIR}/kibana ${KIBANA_INSTALL_HOME}
chmod -R 755 ${KIBANA_INSTALL_HOME}
}

function mod_conf(){
    ## 修改server.host
    num=`grep -n "server.host:" ${KIBANA_HOME}/config/kibana.yml | cut -d ':' -f1`
    sed -i "${num}c server.host: \"${KIBANA_NODE}\"" ${KIBANA_HOME}/config/kibana.yml

    ## 修改server.name
    num=`grep -n "server.name:" ${KIBANA_HOME}/config/kibana.yml | cut -d ':' -f1`
    sed -i "${num}c server.name: \"${KIBANA_NODE}\"" ${KIBANA_HOME}/config/kibana.yml

    ## 修改es url
    num=`grep -n "elasticsearch.url:" ${KIBANA_HOME}/config/kibana.yml | cut -d ':' -f1`
    sed -i "${num}c elasticsearch.url: \"http://${KIBANA_NODE}:9200\"" ${KIBANA_HOME}/config/kibana.yml

    ## 修改requestTimeout
    num=`grep -n "elasticsearch.requestTimeout:" ${KIBANA_HOME}/config/kibana.yml | cut -d ':' -f1`
    sed -i "${num}c elasticsearch.requestTimeout: 3000000" ${KIBANA_HOME}/config/kibana.yml

}

function main(){
    sync_file
    mod_conf
}

main

set +x
