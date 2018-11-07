################################################################################
##opyright:   HZGOSUN Tech. Co, BigData
## Filename:    springCloud stop face
## Description:  停止dynrepo服务
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
FACE_DYNREPO_JAR_NAME=`ls | grep ^face-dynrepo.jar$`
FACE_DYNREPO_PID=`jps | grep ${FACE_DYNREPO_JAR_NAME} | awk '{print $1}'`
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
    FACE_DYNREPO_PID=`jps | grep ${FACE_DYNREPO_JAR_NAME} | awk '{print $1}'`
    if [ -n "${FACE_DYNREPO_PID}" ];then
        echo "face-dynrepo service is exist, exit with 0, kill service now"
        kill -9 ${FACE_DYNREPO_PID}
        echo "stop service successfull"
    else
        echo "dynrepo service is not start"
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
