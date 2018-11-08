#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expend_conf.properties
## Description: 同步新老配置文件的脚本
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
LOG_FILE=${LOG_DIR}/synConf-expand.log
## 集群扩展的节点
EXPAND_NODE=$(grep Node_HostName ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
EXPAND_NODE_ARRY=(${EXPAND_NODE//;/ })

component=$1

function main()
{
##在主配置文件中追加组件节点
    if [[ "$component" = "datanode" ]] ; then
        echo "扩展节点安装datanode服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
            DATANODE=$(grep Hadoop_DataNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
            if [[ "$DATANODE" =~ "$node" ]] ; then
                echo "配置文件中已存在此节点:$node"
		    else
                sed -i "s#Hadoop_DataNode=$DATANODE#Hadoop_DataNode=$DATANODE;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                echo "在主配置文件DataNode中加入节点:$node"
            fi
        done
    fi

    if [[ "$component" = "hive" ]] ; then
        echo "扩展节点安装hive服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
            HIVE=$(grep Meta_ThriftServer ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
            if [[ "$HIVE" =~ "$node" ]] ; then
                echo "配置文件中已存在此节点:$node"
		    else
                sed -i "s#Meta_ThriftServer=$HIVE#Meta_ThriftServer=$HIVE;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                echo "在主配置文件ThriftServer中加入节点:$node"
            fi
        done
    fi
    if [[ "$component" = "es" ]] ; then
        echo "扩展节点安装ES服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
             ES=$(grep ES_InstallNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
             if [[ "$ES" =~ "$node" ]] ; then
                 echo "配置文件中已存在此节点:$node"
		     else
                 sed -i "s#ES_InstallNode=$ES#ES_InstallNode=$ES;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                 echo "在主配置文件ES中加入节点:$node"
             fi
        done
    fi
    if [[ "$component" = "kafka" ]];then
        echo "扩展节点安装kafka服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
             KAFKA=$(grep Kafka_InstallNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
             if [[ "$KAFKA" =~ "$node" ]] ; then
                 echo "配置文件中已存在此节点:$node"
		     else
                 sed -i "s#Kafka_InstallNode=$KAFKA#Kafka_InstallNode=$KAFKA;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                 echo "在主配置文件Kafka中加入节点:$node"
             fi
        done
    fi
    if [[ "$component" = "zookeeper" ]] ; then
        echo "扩展节点安装zookeeper服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
             ZOOKEEPER=$(grep Zookeeper_InstallNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
             if [[ "$ZOOKEEPER" =~ "$node" ]] ; then
                 echo "配置文件中已存在此节点:$node"
		     else
                 sed -i "s#Zookeeper_InstallNode=$ZOOKEEPER#Zookeeper_InstallNode=$ZOOKEEPER;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                 echo "在主配置文件Zookeeper中加入节点:$node"
             fi
        done
    fi
    if [[ "$component" = "scala" ]] ; then
        echo "扩展节点安装scala服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
             SCALA=$(grep Scala_InstallNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
             if [[ "$SCALA" =~ "$node" ]] ; then
                 echo "配置文件中已存在此节点:$node"
		     else
                 sed -i "s#Scala_InstallNode=$SCALA#Scala_InstallNode=$SCALA;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                 echo "在主配置文件Scala中加入节点:$node"
             fi
        done
    fi

    if [[ "$component" = "spark" ]] ; then
        echo "扩展节点安装spark服务，在主配置文件中添加"
        for node in ${EXPAND_NODE_ARRY[@]}; do
             SPARK=$(grep Spark_ServiceNode ${ROOT_HOME}/conf/cluster_conf.properties |cut -d '=' -f2)
             if [[ "$SPARK" =~ "$node" ]] ; then
                 echo "配置文件中已存在此节点:$node"
		     else
                 sed -i "s#Spark_ServiceNode=$SPARK#Spark_ServiceNode=$SPARK;$node#g" ${ROOT_HOME}/conf/cluster_conf.properties
                 echo "在主配置文件Spark中加入节点:$node"
             fi
        done
    fi

}

main

