#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_jdk.sh
## Description: 新增节点jdk的安装
##              实现自动化的脚本
## Version:     2.0
## Author:      yinhang
## Created:     2018-07-20
################################################################################
#set -x
#set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
echo ${ROOT_HOME}
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## 日记目录
LOG_DIR=${ROOT_HOME}/logs
## jdk 安装日记
LOG_FILE=${LOG_DIR}/jdkInstall.log
##  jdk 安装包目录
JDK_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${ROOT_HOME}/expand/conf/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })
## JAVA_INSTALL_HOME jdk 安装目录
JAVA_INSTALL_HOME=${INSTALL_HOME}/JDK
## JAVA_HOME  jdk 根目录
JAVA_HOME=${INSTALL_HOME}/JDK/jdk

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 jdk 扩展安装操作 ing~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

mkdir -p ${JAVA_INSTALL_HOME}
mkdir -p ${LOG_DIR}

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

## 获取JDK分发节点
for jdk_host in ${HOSTNAMES[@]}
do
    echo ""  | tee  -a  $LOG_FILE
    echo "************************************************"
    echo "准备将JDK分发到节点$jdk_host："  | tee -a $LOG_FILE
    ssh root@$jdk_host "source /etc/profile; mkdir -p  ${JAVA_INSTALL_HOME};"
    ssh root@$jdk_host 'mkdir /home/test;
        cd /home/test;
        rpm -qa | grep java   > java.tmp;
        for rpm_pak in $(cat  java.tmp);do
            echo "删除原先系统java rpm 软件包: ${rpm_pak}"  |  tee  -a  $LOG_FILE;
            rpm -e --nodeps ${rpm_pak};
        done;
        rm -rf /home/test'

    echo "jdk 分发中,请稍候......"  | tee -a $LOG_FILE
    rsync -rvl $JDK_SOURCE_DIR/jdk $jdk_host:${JAVA_INSTALL_HOME}   > /dev/null
    ssh root@${jdk_host} "chmod -R 755 ${JAVA_INSTALL_HOME}"
    ### 增加java环境变量，若先前有配置，要先删除原来的
    ### ssh到每个节点，查找etc/profile中是否存在java系统变量行，若存在，则替换；若不存在，则追加。
    javahome_exists=$(ssh root@${jdk_host} 'grep "export JAVA_HOME=" /etc/profile')
    javapath_exists=$(ssh root@${jdk_host} 'grep "export PATH=\$JAVA_HOME" /etc/profile')
    # 存在"export JAVA_HOME="这一行：则替换这一行
    if [ "${javahome_exists}" != "" ];then
        ssh root@${jdk_host} "sed -i 's#^export JAVA_HOME=.*#export JAVA_HOME=$JAVA_HOME#g' /etc/profile"
    fi
    # 存在"export PATH=$JAVA_HOME"这一行：则替换这一行
    if [ "${javapath_exists}" != "" ];then
        ssh root@${jdk_host} 'sed -i "s#^export PATH=\$JAVA_HOME.*#export PATH=\$JAVA_HOME/bin:\$PATH#g" /etc/profile'
    fi
    # 不存在这两行，则追加在文件末尾
    if [ "${javahome_exists}" = "" ] && [ "${javapath_exists}" = "" ]; then
        ssh root@${jdk_host} "echo '#JAVA_HOME'>>/etc/profile ;echo export JAVA_HOME=$JAVA_HOME >> /etc/profile"
        ssh root@${jdk_host} 'echo export PATH=\$JAVA_HOME/bin:\$PATH  >> /etc/profile; echo "">> /etc/profile'
    fi
    ssh root@${jdk_host} "source /etc/profile"
done
echo "-------------------------------------" | tee  -a $LOG_FILE
echo " jdk 扩展安装操作完成 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE
set +x
