#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud start collect
## Description: 启动 collect服务
## Author:      chenke
## Created:     2018-05-19
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`                         ##bin目录地址
cd ..
COLLECT_DIR=`pwd`                     ##collect目录地址
LIB_DIR=${COLLECT_DIR}/lib            ##lib目录地址
CONF_DIR=${COLLECT_DIR}/conf          ##conf目录地址
COLLECT_JAR_NAME=`ls ${LIB_DIR} | grep ^collect.jar$`          ##获取collect的jar包名称
COLLECT_JAR=${LIB_DIR}/${COLLECT_JAR_NAME}                        ##获取jar包的全路径



#-----------------------------------------------------------------------------#
#                               springcloud配置参数                            #
#-----------------------------------------------------------------------------#
EUREKA_IP=172.18.18.201     ##注册中心的ip地址
EUREKA_PORT=9000            ##服务注册中心端口
ZOOKEEPER_HOST=172.18.18.105:2181

#------------------------------------------------------------------------------#
#                                定义函数                                      #
#------------------------------------------------------------------------------#
#####################################################################
# 函数名: start_clustering
# 描述: 启动 springCloud device服务
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function start_springCloud()
{
   COLLECT_PID=`jps | grep ${COLLECT_JAR_NAME} | awk '{print $1}'`
   if [  -n "${COLLECT_PID}" ];then
      echo "Collect service already started!!"
   else
      nohup java -jar ${COLLECT_JAR} --spring.profiles.active=pro \
      --spring.cloud.config.enabled=false \
      --eureka.ip=${EUREKA_IP} \
      --zookeeper.host=${ZOOKEEPER_HOST} \
      --eureka.port=${EUREKA_PORT} 2>&1 &
   fi
}
#####################################################################
# 函数名: start_spring_cloud
# 描述: 启动 springCloud collect服务
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