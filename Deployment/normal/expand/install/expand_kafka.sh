#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:   expand_kafka.sh
## Description: kafka扩展安装
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
## 安装日志目录
LOG_FILE=${LOG_DIR}/expand_kafka.log
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
## 所有集群节点
INSTALL=$(grep Cluster_HostName ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
INSTALL_HOSTNAMES=(${INSTALL//;/ })
## bigdata 目录
BIGDATA=/opt/hzgc/bigdata/
## KAFKA_INSTALL_HOME kafka 安装目录
KAFKA_INSTALL_HOME=${INSTALL_HOME}/Kafka
## KAFKA_HOME kafka 根目录
KAFKA_HOME=${INSTALL_HOME}/Kafka/kafka

##kafka日志目录
KAFKA_LOG=$(grep Cluster_LOGSDir ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
KAFKA_LOG_PATH=${LOGS_PATH}/kafka
## kafka的config目录
KAFKA_CONFIG=${KAFKA_HOME}/config
## kafka的server.properties文件
KAFKA_SERVER_PROPERTIES=${KAFKA_CONFIG}/server.properties
## kafka的server.properties文件
KAFKA_PRODUCER_PROPERTIES=${KAFKA_CONFIG}/producer.properties
## kafka的application.conf文件
KAFKA_APPLICATION_CONF=${KAFKA_HOME}/kafka-manager/conf/application.conf

## kafka的安装节点，放入数组中
KAFKA_HOSTNAME_LISTS=$(grep Kafka_InstallNode ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
echo "读取的集群节点IP为："${KAFKA_HOSTNAME_LISTS} | tee -a $LOG_FILE
KAFKA_HOSTNAME_ARRY=(${KAFKA_HOSTNAME_LISTS//;/ })
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })

## server.properties文件节点名称
SERVER_HOSTS=$(grep zookeeper.connect= ${KAFKA_SERVER_PROPERTIES} | cut -d '=' -f2)
SERVER_HOSTNAMES=(${SERVER_HOSTS//;/ })
## producer.properties文件节点名称
PRODUCER_HOSTS=$(grep bootstrap.servers ${KAFKA_PRODUCER_PROPERTIES} | cut -d '=' -f2)
PRODUCER_HOSTNAMES=(${PRODUCER_HOSTS//;/ })
## application.conf文件
APPLICATION_HOSTS=$(grep kafka-manager.zkhosts=\" ${KAFKA_APPLICATION_CONF} | cut -d '=' -f2 | cut -d '"' -f2)
APPLICATION_HOSTNAMES=(${APPLICATION_HOSTS//;/ })

echo "-------------------------------------" | tee  -a  $LOG_FILE
echo "准备进行 kafka 扩展安装操作 zzZ~" | tee  -a  $LOG_FILE
echo "-------------------------------------" | tee  -a  $LOG_FILE

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi
if [ ! -d $KAFKA_LOG ];then
    mkdir -p $KAFKA_LOG;
fi

#####################################################################
# 函数名:kafka_distribution
# 描述: 将kafka安装包分发到每个节点
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function kafka_distribution ()
{
for insName in ${INSTALL_HOSTNAMES[@]}
do
    echo "准备将kafka发到新增节点 ${insName} ..." | tee -a $LOG_FILE
    # ssh root@$insName "mkdir -p ${KAFKA_INSTALL_HOME}"
    # rsync -rvl ${KAFKA_SOURCE_DIR}/$insName/kafka $insName:${KAFKA_INSTALL_HOME}  > /dev/null
    # ssh root@$insName "chmod -R 755 ${KAFKA_HOME}"
    ssh root@${insName} "mkdir -p ${BIGDATA}"
    scp -r ${KAFKA_INSTALL_HOME} root@${insName}:${BIGDATA} > /dev/null
    ssh root@${insName} "mkdir -p ${KAFKA_LOG_PATH};chmod -R 777 ${KAFKA_LOG_PATH}"
    echo "分发到新增 ${insName} 节点完毕！！！" | tee -a $LOG_FILE
done
}

#####################################################################
# 函数名:zookeeper_connect
# 描述: 修改 server_properties 文件中的 zookeeper.connect
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function zookeeper_connect ()
{
for insName in ${HOSTNAMES[@]}
do
    if [[ "${SERVER_HOSTS}" =~ "$insName" ]] ; then
        echo "zookeeper.connect 配置文件中已添加新增节点 $insName 的IP以及端口，不需要重复添加！！！" | tee -a $LOG_FILE
    else
        VALUE=$(grep zookeeper.connect= ${KAFKA_SERVER_PROPERTIES} | cut -d '=' -f2)
        sed -i "s#zookeeper.connect=${VALUE}#zookeeper.connect=${VALUE},${insName}:2181#g" ${KAFKA_SERVER_PROPERTIES}
    fi
done

}
#####################################################################
# 函数名:producer_properties
# 描述: 修改producer.properties文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function producer_properties ()
{
for insName in ${HOSTNAMES[@]}
do
    if [[ "${PRODUCER_HOSTS}" =~ "${insName}" ]] ; then
        echo "bootstrap.servers配置文件中已添加新增节点 $insName 的IP以及端口，不需要重复操作！！！" | tee -a $LOG_FILE
    else
        value=$(grep bootstrap.servers ${KAFKA_PRODUCER_PROPERTIES} | cut -d '=' -f2)
        sed -i "s#bootstrap.servers=${value}#bootstrap.servers=${value},${insName}:9092#g" ${KAFKA_PRODUCER_PROPERTIES}
    fi
done
}

#####################################################################
# 函数名:application_conf
# 描述: 修改application.conf文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function application_conf ()
{
for insName in ${HOSTNAMES[@]}
do
    if [[ "${APPLICATION_HOSTS}" =~ "$insName" ]] ; then
        echo $insName "新增节点已添加，不需要重复操作！！！" | tee -a $LOG_FILE
    else
        value=$(grep kafka-manager.zkhosts=\" ${KAFKA_APPLICATION_CONF} | cut -d '=' -f2 | cut -d '"' -f2)
        sed -i "s#kafka-manager.zkhosts=\"${value}\"#kafka-manager.zkhosts=\"${value},${insName}:2181\"#g" ${KAFKA_APPLICATION_CONF}
    fi
done
}


#####################################################################
# 函数名:server_properties
# 描述: 修改server.properties文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
LISTENERS=PLAINTEXT:
LOG_DIRS=/opt/hzgc/logs/kafka/kafka-logs
function server_properties ()
{
num=1
for insName in ${INSTALL_HOSTNAMES[@]}
do
    ##修改 brokerID
    echo "正在修改${insName}的 broker.id ..." | tee -a $LOG_FILE
    ssh root@${insName} "sed -i 's#broker.id=.*#broker.id=${num}#g' ${KAFKA_SERVER_PROPERTIES}"
    echo "${insName}的 broker.id 配置修改完毕！！！" | tee -a $LOG_FILE

    ##修改 listeners
    echo "正在修改${insName}的 listeners ..." | tee -a $LOG_FILE
    value2=`ssh root@${insName} "grep 'listeners=PLAINTEXT' ${KAFKA_SERVER_PROPERTIES} | cut -d ':' -f2| sed -n '1p;1q'"`
    ssh root@${insName} "sed -i 's#listeners=${LISTENERS}${value2}\:9092#listeners=${LISTENERS}\/\/${insName}\:9092#g' ${KAFKA_SERVER_PROPERTIES}"
    echo "${insName}的 listeners 配置修改完毕！！！" | tee -a $LOG_FILE

    ## 修改 log.dirs
    echo "正在修改${insName}的 log.dirs ..." | tee -a $LOG_FILE
    value3=`ssh root@${insName} "grep 'log.dirs' ${KAFKA_SERVER_PROPERTIES} | cut -d '=' -f2"`
    ssh root@${insName} "sed -i 's#log.dirs=${value3}#log.dirs=${LOG_DIRS}#g' ${KAFKA_SERVER_PROPERTIES}"
    echo "${insName}的 log.dirs 配置修改完毕！！！" | tee -a $LOG_FILE

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
zookeeper_connect
producer_properties
application_conf
kafka_distribution
server_properties
}

#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#
## 打印时间
echo "" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")" | tee  -a  $LOG_FILE
main
echo "-------------------------------------" | tee  -a  $LOG_FILE
echo "kafka 扩展安装完成 zzZ~ " | tee  -a  $LOG_FILE
echo "-------------------------------------" | tee  -a  $LOG_FILE
