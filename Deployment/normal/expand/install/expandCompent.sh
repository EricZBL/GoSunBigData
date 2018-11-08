#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_conf.properties
## Description: 扩展集群的脚本
## Version:     2.0
## Author:      zhangbaolin && yinhang
## Created:     2018-7-2
################################################################################
#set -e
#set -x

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 主集群配置文件目录
CLUSTER_CONF_DIR=${ROOT_HOME}/conf
##扩展集群配置文件目录
EXPAND_CONF_DIR=${ROOT_HOME}/expand/conf
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/synConf.log
## 集群扩展的节点
EXPAND_NODE=$(grep Node_HostName ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
EXPAND_NODE_ARRY=(${EXPAND_NODE//;/ })

cd ${BIN_DIR}

function main() 
{
    #修改主配置文件Cluster_HostName的值

    for node in ${EXPAND_NODE_ARRY[@]}; do
        CLUSTER_HOST=$(grep Cluster_HostName ${CLUSTER_CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
        if [[ "$CLUSTER_HOST" =~ "$node" ]] ; then
            echo "配置文件中已存在此节点:$node"
		else
            sed -i "s#Cluster_HostName=$CLUSTER_HOST#Cluster_HostName=${CLUSTER_HOST};${EXPAND_NODE}#g" ${CLUSTER_CONF_DIR}/cluster_conf.properties
            echo "在主配置文件Cluster_HostName中加入节点:$node"
        fi
    done

    ## 扩展Zookeeper
    echo  "开始在扩展加点上安装zookeeper服务"
    Is_Zookeeper=$(grep Is_Zookeeper_InstallNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$Is_Zookeeper" = "xyes" ] ;then
        sh syncConf.sh zookeeper
		sh expand_zookeeper.sh
    fi

    ## 扩展datanode
    echo  "开始在扩展加点上安装datanode服务"
    IS_DataNode=$(grep Is_Hadoop_DataNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$IS_DataNode" = "xyes" ] ;then
	    sh syncConf.sh datanode
        sh expand_hadoop.sh
    fi

    ## 扩展hive
    echo  "开始在扩展加点上安装hive服务"
    IS_HIVE=$(grep Is_Meta_ThriftServer ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$IS_HIVE" = "xyes" ] ;then
        sh syncConf.sh hive
		sh expand_hive.sh
    fi

    ## 扩展kafka
    echo  "开始在扩展加点上安装kafka服务"
    Is_Kafka=$(grep Is_Kafka_InstallNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$Is_Kafka" = "xyes" ] ;then
        sh syncConf.sh kafka
		sh expand_kafka.sh
    fi

    ## 扩展Scala
    echo  "开始在扩展加点上安装scala服务"
    Is_Scala=$(grep Is_Scala_InstallNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$Is_Scala" = "xyes" ] ;then
        sh syncConf.sh scala
		sh expand_scala.sh
    fi

	## 扩展Spark
	echo  "开始在扩展加点上安装spark服务"
    Is_Spark=$(grep Is_Spark_ServiceNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$Is_Spark" = "xyes" ] ;then
        sh syncConf.sh spark
		sh expand_spark.sh
    fi

    ## 扩展ES
    echo  "开始在扩展加点上安装es服务"
    Is_ES=$(grep Is_ES_InstallNode ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
    if [ "x$Is_ES" = "xyes" ] ;then
        sh syncConf.sh es
		sh expand_elasicsearch.sh
    fi

    sh expand_global_env.sh
}

main

