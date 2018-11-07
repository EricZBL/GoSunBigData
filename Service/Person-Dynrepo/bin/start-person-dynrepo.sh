#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud start face
## Description: 启动person服务提取特征
## Author:      zhangbaolin
## Created:     2018-08-27
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`    ##bin目录地址
cd ..
HOME_DIR=`pwd`    ##host目录地址
LIB_DIR=${HOME_DIR}/lib
PERSON_DYNREPO_JAR_NAME=`ls ${LIB_DIR} | grep ^person-dynrepo.jar$`
PERSON_DYNREPO_JAR=${LIB_DIR}/${PERSON_DYNREPO_JAR_NAME}
CONF_DIR=${HOME_DIR}/conf

#---------------------------------------------------------------------#
#                          springcloud配置参数                        #
#---------------------------------------------------------------------#
EUREKA_IP=192.168.1.57     ##注册中心的ip地址
EUREKA_PORT=8761
ES_HOST=172.18.18.100
ZOOKEEPER_HOST=172.18.18.100:2181


#---------------------------------------------------------------------#
#                              定义函数                               #
#---------------------------------------------------------------------#

#####################################################################
# 函数名: start_spring_cloud
# 描述: 启动 springCloud face服务
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function start_springCloud()
{
   PERSON_DYNREPO_PID=`jps | grep ${PERSON_DYNREPO_JAR_NAME} | awk '{print $1}'`
   if [ -n "${PERSON_DYNREPO_PID}" ];then
       echo "person service already started"
   else
       nohup java -jar ${PERSON_DYNREPO_JAR} --spring.profiles.active=pro  \
       --eureka.ip=${EUREKA_IP} \
       --eureka.port=${EUREKA_PORT} \
       --es.host=${ES_HOST} \
       --spring.cloud.config.enabled=false \
       --zookeeper.host=${ZOOKEEPER_HOST} 2>&1 &
   fi

}

#---------------------------------------------------------------------#
#                              定义函数                               #
#---------------------------------------------------------------------#

#####################################################################
# 函数名: start_spring_cloud
# 描述: 启动 springCloud face服务
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################

#####################################################################
# 函数名: main
# 描述: 脚本主要业务入口
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    start_springCloud
}

main
