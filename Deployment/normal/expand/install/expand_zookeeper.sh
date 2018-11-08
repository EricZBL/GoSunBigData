#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_zookeeper.sh
## Description: zookeeper扩展安装
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-06
################################################################################
## set -x  ## 用于调试用，不用的时候可以注释掉
#set -e
#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#
cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## ClusterBuildScripts 目录
CLUSTER_BUILD_SCRIPTS_DIR=`pwd`
## expand conf 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/expand/conf
## 安装日志目录
LOG_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/expand_zookeeper.log
## 集群组件的日志文件目录 /opt/logs
LOGS_PATH=$(grep Cluster_LOGSDir ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
ZK_LOG_PATH=${LOGS_PATH}/zookeeper
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
## 所有集群节点
INSTALL=$(grep Cluster_HostName ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
INSTALL_HOSTNAMES=(${INSTALL//;/ })
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })
## 原集群节点和新增节点
Host_Arr=${INSTALL}";"${CLUSTER_HOST}
Host_Arrs=(${Host_Arr//;/ })
## ZOOKEEPER_INSTALL_HOME zookeeper 安装目录
ZOOKEEPER_INSTALL_HOME=${INSTALL_HOME}/Zookeeper
## ZOOKEEPER_HOME  zookeeper 根目录
ZOOKEEPER_HOME=${INSTALL_HOME}/Zookeeper/zookeeper

## zookeeper conf 目录
ZOOKEEPER_CONF=${ZOOKEEPER_HOME}/conf
## zookeeper zoo,cfg 文件
ZOO_CFG_FILE=${ZOOKEEPER_CONF}/zoo.cfg
## zookeeper data 目录
ZOOKEEPER_DATA=${ZOOKEEPER_HOME}/data
## zookeeper myid 文件
ZOOKEEPER_MYID=${ZOOKEEPER_DATA}/myid

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 zookeeper 扩展安装操作 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

## 打印当前时间
echo "" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE
echo "===================================================" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"

#####################################################################
# 函数名:zookeeper_distribution
# 描述: 分发新增节点 zookeeper
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function zookeeper_distribution ()
{
for insName in ${HOSTNAMES[@]}
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将zookeeper分发到节点$insName：" | tee -a $LOG_FILE
    echo "zookeeper 分发中,请稍候......" | tee -a $LOG_FILE
    scp -r ${ZOOKEEPER_INSTALL_HOME} root@${insName}:${INSTALL_HOME} > /dev/null
    ssh root@${insName} "mkdir -p ${ZK_LOG_PATH};chmod -R 777 ${ZK_LOG_PATH}"
    echo "zookeeper 分发完毕......" | tee -a $LOG_FILE
done
}

#####################################################################
# 函数名:zoo_cfg
# 描述: 修改 zoo.cfg
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
NUM=$(sed -n '$p' ${ZOO_CFG_FILE} | cut -d '.' -f2 | cut -d '=' -f1)
NUMBER=$[${NUM}+1]
function zoo_cfg ()
{
for insName in ${HOSTNAMES[@]}
do
    ## 修改 zoo.cfg
    value1=$(grep "${insName}"  ${ZOO_CFG_FILE})
    if [ -n "${value1}" ];then
        sed -i "s#server.${NUMBER}=.*#server.${NUMBER}=${insName}:2888:3888#g" ${ZOO_CFG_FILE}
    else
        echo "server.${NUMBER}=${insName}:2888:3888" >> ${ZOO_CFG_FILE}
    fi

    NUMBER=$[${NUMBER}+1]
done
## 拷贝到其他节点
for host in ${INSTALL_HOSTNAMES[@]};
do
scp ${ZOO_CFG_FILE} root@${host}:${ZOO_CFG_FILE}
done
}

#####################################################################
# 函数名:myid
# 描述: 修改 myid
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function myid ()
{
num=1
for insName in ${INSTALL_HOSTNAMES[@]}
do
    ##修改 myid
    echo "正在修改${insName}的 myid ..." | tee -a $LOG_FILE
    ssh root@${insName} "sed -i 's#.*#${num}#g'  ${ZOOKEEPER_MYID}"
    echo "${insName}的 myid 配置修改完毕！！！" | tee -a $LOG_FILE
    num=$(($num+1))
done
}
#####################################################################
# 函数名: main
# 描述: 脚本主要业务入口
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main ()
{
zookeeper_distribution
zoo_cfg
myid
}

#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#
## 打印时间
echo "" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")" | tee  -a  $LOG_FILE
main
echo "-------------------------------------" | tee  -a $LOG_FILE
echo " zookeeper 扩展安装操作完成 zzZ~ " | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE


