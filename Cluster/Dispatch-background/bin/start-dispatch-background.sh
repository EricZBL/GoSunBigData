#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud start dispatch-background
## Description: 启动dispatch后台程序
## Author:      chenke
## Created:     2018-10-22
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`    ##bin目录地址
cd ..
DISPATCH_BACKGROUND_DIR=`pwd`    ##host目录地址
LIB_DIR=${DISPATCH_BACKGROUND_DIR}/lib
DISPATCH_BACKGROUND_JAR_NAME=`ls ${LIB_DIR} | grep ^dispatch-background.jar$`
DISPATCH_BACKGROUND_JAR=${LIB_DIR}/${DISPATCH_BACKGROUND_JAR_NAME}
CONF_DIR=${DISPATCH_BACKGROUND_DIR}/conf

#---------------------------------------------------------------------#
#                          springcloud配置参数                        #
#---------------------------------------------------------------------#
EUREKA_IP=172.18.18.191     ##注册中心的ip地址
EUREKA_PORT=9000
KAFKA_HOST=172.18.18.100:9092
MYSQL_HOST=172.18.18.105:3306
#MYSQL_USERNAME=
#MYSQL_PASSWORD=

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
   DISPATCH_BACKGROUND_PID=`jps | grep ${DISPATCH_BACKGROUND_JAR_NAME} | awk '{print $1}'`
   if [ -n "${DISPATCH_BACKGROUND_PID}" ];then
       echo "Dispatch-background service already started"
   else
       nohup java -jar ${DISPATCH_BACKGROUND_JAR} --spring.profiles.active=pro  \
       --eureka.ip=${EUREKA_IP} \
       --eureka.port=${EUREKA_PORT} \
       --kafka.host=${KAFKA_HOST} \
       --mysql.host=${MYSQL_HOST} \
       --spring.cloud.config.enabled=false  2>&1 &
   fi

}
#---------------------------------------------------------------------#
#                              定义函数                               #
#---------------------------------------------------------------------#

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