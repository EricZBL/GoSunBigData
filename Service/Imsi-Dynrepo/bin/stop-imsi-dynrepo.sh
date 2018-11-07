################################################################################
##opyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud stop imsi
## Description:  停止imsi服务
## Author:      yansen
## Created:     2018-05-19
################################################################################
#set -x

cd `dirname $0`
BIN_DIR=`pwd`    ##bin目录地址
cd ..
HOME_DIR=`pwd`    ##host目录地址
cd lib
LIB_DIR=`pwd`
IMSI_DYNREPO_JAR_NAME=`ls | grep ^imsi-dynrepo.jar$`
IMSI_DYNREPO_PID=`jps | grep ${IMSI_DYNREPO_JAR_NAME} | awk '{print $1}'`
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
    IMSI_DYNREPO_PID=`jps | grep ${IMSI_DYNREPO_JAR_NAME} | awk '{print $1}'`
    if [ -n "${IMSI_DYNREPO_PID}" ];then
        echo "imsi service is exist, exit with 0, kill service now"
        kill -9 ${IMSI_DYNREPO_PID}
        echo "stop service successfull"
    else
        echo "imsiDynrepo service is not start"
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
