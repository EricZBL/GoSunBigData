#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    ltsInstall.sh
## Description: 安装配置lts集群
##              实现自动化的脚本
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-06-28
################################################################################
#set -x

cd `dirname $0`                            ##脚本所在目录
BIN_DIR=`pwd`
cd ../..
ROOT_HOME=`pwd`                             ##安装包根目录
CONF_DIR=${ROOT_HOME}/conf                 ## 配置文件目录
LOG_DIR=${ROOT_HOME}/logs                  ## 日记目录
LOG_FILE=${LOG_DIR}/ltsInstall.log         ## lts 安装日记
LTS_SOURCE_DIR=${ROOT_HOME}/component/bigdata    ##lts安装包目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)  ## 最终安装的根目录，所有bigdata 相关的根目录
LTS_INSTALL_HOME=${INSTALL_HOME}/Lts          ##LTS安装目录
LTS_HOME=${INSTALL_HOME}/Lts/lts           ##安装完成之后lts根目录
LTS_CONF_DIR=${LTS_HOME}/dist/lts-1.7.2-SNAPSHOT-bin/conf   ##安装完成之后lts的配置文件目录
LTS_ZOO_DIR=${LTS_CONF_DIR}/zoo        ##安装完成之后zoo的配置文件目录

##获取clusterName
CLUSTER_NAME=$(grep ClusterName ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)     ##lts集群的名字
REGISTRY_ADDRESS=$(grep RegistryAddress ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2) ##lts集群所在的节点
MYSQL_USERNAME=$(grep MYSQL_USER ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2 )  ##lts连接mysql的用户名
MYSQL_PASSWORD=$(grep MYSQL_Password ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)  ##lts连接mysql的密码
MYSQL_PORT=$(grep MYSQL_Port ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)  ##lts连接mysql的端口号
LTS_USERNAME=$(grep Lts_UserName ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)    ##lts集群monitor的用户
LTS_PASSWORD=$(grep Lts_PassWord ${CONF_DIR}/cluster_conf.properties | cut -d '=' -f2)    ##lts集群monitor的密码
ZK_REGISTRY="zookeeper://${REGISTRY_ADDRESS}:2181"
JDBC_URL="jdbc:mysql://${REGISTRY_ADDRESS}:${MYSQL_PORT}/lts"
MONGO_ADDRESS="${REGISTRY_ADDRESS}:27017"




function sync_file(){
##首先检查本机上是否安装有lts，如果有，则删除本机的lts
     if [ -e ${LTS_INSTALL_HOME} ]; then
         echo "删除原有LTS"
         rm -rf ${LTS_INSTALL_HOME}
     fi
     mkdir -p ${LTS_INSTALL_HOME}
     cp -r ${LTS_SOURCE_DIR}/lts ${LTS_INSTALL_HOME}
     chmod -R 755 ${LTS_INSTALL_HOME}
}

function config_lts_properties(){
      echo "" | tee -a ${LOG_FILE}
      echo "****************************" | tee -a ${LOG_FILE}
      echo "开始配置lts配置文件******"  | tee -a ${LOG_FILE}
      sed -i "s#^console.username=.*#console.username=${LTS_USERNAME}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag1=$?
      sed -i "s#^console.password=.*#console.password=${LTS_PASSWORD}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag2=$?
      sed -i "s#^registryAddress=.*#registryAddress=${ZK_REGISTRY}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag3=$?
      sed -i "s#^clusterName=.*#clusterName=${CLUSTER_NAME}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag4=$?
      sed -i "s#^configs.jdbc.url=.*#configs.jdbc.url=${JDBC_URL}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag5=$?
      sed -i "s#^configs.jdbc.username=.*#configs.jdbc.username=${MYSQL_USERNAME}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag18=$?
      sed -i "s#^configs.jdbc.password=.*#configs.jdbc.password=${MYSQL_PASSWORD}#g" ${LTS_CONF_DIR}/lts-admin.cfg
      flag19=$?
      sed -i "s#^registryAddress=.*#registryAddress=${ZK_REGISTRY}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag6=$?
      sed -i "s#^clusterName=.*#clusterName=${CLUSTER_NAME}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag7=$?
      sed -i "s#^configs.jdbc.url=.*#configs.jdbc.url=${JDBC_URL}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag8=$?
      sed -i "s#^configs.jdbc.username=.*#configs.jdbc.username=${MYSQL_USERNAME}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag20=$?
      sed -i "s#^configs.jdbc.password=.*#configs.jdbc.password=${MYSQL_PASSWORD}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag21=$?
      sed -i "s#^configs.mongo.addresses=.*#configs.mongo.addresses=${MONGO_ADDRESS}#g" ${LTS_CONF_DIR}/lts-monitor.cfg
      flag9=$?
      sed -i "s#^registryAddress=.*#registryAddress=${ZK_REGISTRY}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag10=$?
      sed -i "s#^clusterName=.*#clusterName=${CLUSTER_NAME}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag11=$?
      sed -i "s#^configs.jdbc.url=.*#configs.jdbc.url=${JDBC_URL}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag12=$?
      sed -i "s#^configs.jdbc.username=.*#configs.jdbc.username=${MYSQL_USERNAME}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag22=$?
      sed -i "s#^configs.jdbc.password=.*#configs.jdbc.password=${MYSQL_PASSWORD}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag23=$?
      sed -i "s#^configs.mongo.addresses=.*#configs.mongo.addresses=${MONGO_ADDRESS}#g" ${LTS_ZOO_DIR}/jobtracker.cfg
      flag13=$?
      sed -i "s#^registryAddress=.*#registryAddress=${ZK_REGISTRY}#g"  ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag14=$?
      sed -i "s#^clusterName=.*#clusterName=${CLUSTER_NAME}#g" ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag15=$?
      sed -i "s#^configs.jdbc.url=.*#configs.jdbc.url=${JDBC_URL}#g" ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag16=$?
      sed -i "s#^configs.jdbc.username=.*#configs.jdbc.username=${MYSQL_USERNAME}#g" ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag24=$?
      sed -i "s#^configs.jdbc.password=.*#configs.jdbc.password=${MYSQL_PASSWORD}#g" ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag25=$?
      sed -i "s#^configs.mongo.addresses=.*#configs.mongo.addresses=${MONGO_ADDRESS}#g" ${LTS_ZOO_DIR}/lts-monitor.cfg
      flag17=$?
      
      if [[ ($flag1 == 0)  && ($flag2 == 0)  &&  ($flag3 == 0)  && ($flag4 == 0)  &&  ($flag5 == 0)  && ($flag6 == 0)  && ($flag7 == 0)  && ($flag8 == 0)  && ($flag9 == 0)  && ($flag10 == 0)  && ($flag11 == 0)  && ($flag12 == 0)  && ($flag13 == 0)  && ($flag14 == 0)  && ($flag15 == 0)  && ($flag16 == 0)  && ($flag17 == 0) && ($flag18 == 0) && ($flag19 == 0) && ($flag20 == 0) && ($flag21 == 0) && ($flag22 == 0) && ($flag23 == 0) && ($flag24 == 0) && ($flag25 == 0) ]]; then
          echo "lts目录下的文件配置成功！" | tee -a ${LOG_FILE}
          else
          echo "lts目录下的文件配置失败！" | tee -a ${LOG_FILE}
      fi
}

function main()
{
    sync_file
    config_lts_properties
}


echo ""  | tee  -a  ${LOG_FILE}
echo ""  | tee  -a  ${LOG_FILE}
echo "==================================================="  | tee -a ${LOG_FILE}
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  ${LOG_FILE}
main

set +x