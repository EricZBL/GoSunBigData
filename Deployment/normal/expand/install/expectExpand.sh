#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expectInstall.sh
## Description: 安装 expect 工具，安装后可以用expect命令减少人与linux之间的交互
##              实现自动化的脚本
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-7-5
################################################################################
#set -e
#set -x

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
##扩展配置文件目录
EXPAND_CONF_DIR=${ROOT_HOME}/expand/conf
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/expectInstall.log
## expect rpm 软件目录
EXPECT_RPM_DIR=${ROOT_HOME}/component/basic_suports/expectRpm
## 基础工具安装路径
INSTALL_HOME_BASIC=$(grep System_SuportDir ${EXPAND_CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
## expect rpm 软件最终目录
EXPECT_RPM_INSTALL_HOME=${INSTALL_HOME_BASIC}/expectRpm
## expect的安装节点，集群扩展的节点ip，放入数组中
CLUSTER_HOSTNAME_LISTS=$(grep Node_HostName ${EXPAND_CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
CLUSTER_HOSTNAME_ARRY=(${CLUSTER_HOSTNAME_LISTS//;/ })
PASSWORD=$(grep SSH_Password ${EXPAND_CONF_DIR}/expand_conf.properties|cut -d '=' -f2)

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE

for name in ${CLUSTER_HOSTNAME_ARRY[@]}
do
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "intall expect in  ${name}...... "  | tee -a $LOG_FILE
    sshpass -p ${PASSWORD}  ssh -o StrictHostKeyChecking=no $name "mkdir -p  ${EXPECT_RPM_INSTALL_HOME}" 
    sshpass -p ${PASSWORD} scp -o StrictHostKeyChecking=no -r  ${EXPECT_RPM_DIR}/* $name:${EXPECT_RPM_INSTALL_HOME}  > /dev/null
    if [ $? == 0 ];then
        echo "scp expect to the ${EXPECT_RPM_INSTALL_HOME} done !!!"  | tee -a $LOG_FILE
    else 
        echo "scp expect to the ${EXPECT_RPM_INSTALL_HOME} failed !!!"  | tee -a $LOG_FILE
    fi
    sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no root@$name "rpm -ivh ${EXPECT_RPM_INSTALL_HOME}/tcl-8.5.7-6.el6.x86_64.rpm; rpm -ivh ${EXPECT_RPM_INSTALL_HOME}/expect-5.44.1.15-5.el6_4.x86_64.rpm; which expect; rm -rf ${INSTALL_HOME_BASIC}"  
done




set +x
