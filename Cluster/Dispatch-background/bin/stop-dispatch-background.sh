#!/bin/bash
################################################################################
##opyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud stop dispatch-background
## Description:  停止dispatch-background服务
## Author:      chenke
## Created:     2018-10-22
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`    ##bin目录地址
cd ..
DISPATCH_BACKGROUND_DIR=`pwd`    ##host目录地址
cd lib
LIB_DIR=`pwd`
DISPATCH_BACKGROUND_JAR_NAME=`ls | grep ^dispatch-background.jar$`
DISPATCH_BACKGROUND_PID=`jps | grep ${DISPATCH_BACKGROUND_JAR_NAME} | awk '{print $1}'`
cd ..

#---------------------------------------------------------------------#
#                              定义函数                                #
#---------------------------------------------------------------------#
#####################################################################
# 函数名:stop_spring_cloud
# 描述: 停止spring cloud
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function stop_springCloud()
{
    if [ -n "${DISPATCH_BACKGROUND_PID}" ];then
        echo "Dispatch-background service is exist, exit with 0, kill service now"
        kill -9 ${DISPATCH_BACKGROUND_PID}
        echo "stop service successfull"
    else
        echo "Dispatch-background service is not start"
    fi
}

#####################################################################
# 函数名: main
# 描述: 脚本主要业务入口
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    stop_springCloud
}

main