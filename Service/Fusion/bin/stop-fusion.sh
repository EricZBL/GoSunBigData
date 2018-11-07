#!/bin/bash
################################################################################
##opyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud stop fusion
## Description:  停止fusion服务
## Author:      chenke
## Created:     2018-09-19
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`    ##bin目录地址
cd ..
FUSION_DIR=`pwd`    ##host目录地址
cd lib
LIB_DIR=`pwd`
FUSION_JAR_NAME=`ls | grep ^fusion.jar$`
FUSION_PID=`jps | grep ${FUSION_JAR_NAME} | awk '{print $1}'`
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
    if [ -n "${FUSION_PID}" ];then
        echo "fusion service is exist, exit with 0, kill service now"
        kill -9 ${FUSION_PID}
        echo "stop service successfull"
    else
        echo "fusion service is not start"
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
