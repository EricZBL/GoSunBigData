#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    offIptables_extended_.sh
## Description: 删除扩展节点的/etc/profile中的Java环境变量
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
## 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/expand/conf
## 日记目录
LOG_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/logs
## 关闭防火墙日记
LOG_FILE=${LOG_DIR}/offIpTable.log
##etc所在目录
ETC_FILE=/opt/source
## 集群所有节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
HOSTNAMES=(${CLUSTER_HOST//;/ })

mkdir -p  ${LOG_DIR}

#####################################################################
# 函数名: offIptables_extended
# 描述: 关闭扩展节点上的防火墙
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function offIptables_extended ()
{
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "===================================================" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee -a $LOG_FILE
for name in ${HOSTNAMES[@]}
do
    echo ""  | tee  -a  $LOG_FILE
    echo "**************************************************" | tee -a $LOG_FILE
    echo "准备关闭节点$name的防火墙" | tee -a $LOG_FILE
    ssh root@$name "sed -i \"s;enforcing;disabled;g\" /etc/selinux/config "
    ssh root@$name 'service iptables stop'
    ssh root@$name 'chkconfig iptables off'
    echo "关闭防火 $name 的防火墙成功。" | tee -a $LOG_FILE
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
offIptables_extended
}

#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#
## 打印时间
echo "" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")" | tee  -a  $LOG_FILE
main
