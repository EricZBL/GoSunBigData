#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_hadoop.sh
## Description: 扩展hadoop datanode/nodemanager服务的脚本
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-7-4
################################################################################
#set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
##扩展集群配置文件目录
EXPAND_CONF_DIR=${ROOT_HOME}/expand/conf
## 日记目录
LOG_DIR=${ROOT_HOME}/logs
## hadoop 安装日记
LOG_FILE=${LOG_DIR}/hadoopInstall.log
##  hadoop 安装包目录
HADOOP_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## HADOOP_INSTALL_HOME hadoop 安装目录
HADOOP_INSTALL_HOME=${INSTALL_HOME}/Hadoop
## HADOOP_HOME  hadoop 根目录
HADOOP_HOME=${HADOOP_INSTALL_HOME}/hadoop
## 集群组件的日志文件目录 /opt/logs
LOGS_PATH=$(grep Cluster_LOGSDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
HADOOP_LOG_PATH=${LOGS_PATH}/hadoop
## JAVA_HOME
JAVA_HOME=${INSTALL_HOME}/JDK/jdk
## <value>
VALUE="<value>"
## </value>
VALUE_END="</value>"
## 集群扩展的节点
EXPAND_NODE=$(grep Node_HostName ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
EXPAND_NODE_ARRY=(${EXPAND_NODE//;/ })

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 hadoop 扩展安装操作 ing~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

mkdir -p ${HADOOP_HOME}

ZK_LISTS=""
HADOOP_TMP_DIR=$HADOOP_HOME/tmp
DK_SLAVES=""
DFS_JOURNALNODE_EDITS_DIR=${HADOOP_HOME}/dfs_journalnode_edits_dir

## 获取ZK节点
ZK_HOSTS=$(grep Zookeeper_InstallNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
zkhost_arr=(${ZK_HOSTS//;/ })
for zk_host in ${zkhost_arr[@]}
do
    ZK_LISTS="${zk_host}:2181,${ZK_LISTS}"
    DK_SLAVES="${zk_host}:8485;${DK_SLAVES}"
done

##获取hadoop主备节点
Hadoop_Masters=$(grep Hadoop_NameNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
namenode_arr=(${Hadoop_Masters//;/ })
MASTER1=${namenode_arr[0]}
MASTER2=${namenode_arr[1]}

##获取数据存储节点节点
Hadoop_Data=$(grep Hadoop_DataNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
datanode_arr=(${Hadoop_Data//;/ })
HADOOP_IP_LISTS=${Hadoop_Data}
for node in ${namenode_arr};do
    if [[ ${Hadoop_Data} =~ ${node} ]]; then
        echo ""
    else
        HADOOP_IP_LISTS=${Hadoop_Data}";"${node}

    fi
done
HADOOP_IP_ARRY=(${HADOOP_IP_LISTS//;/ })

#####################################################################
# 函数名: config_conf_slaves
# 描述: 配置hadoop配置目录下yarn-site.xml,core-site.xml,slaves文件。
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_conf_slaves()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo ""  >  ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/slaves
    for data_host in ${HADOOP_IP_ARRY[@]}
    do
        NUM=$[`grep -n ha.zookeeper.quorum ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/core-site.xml | cut -d ':' -f1`+1]
        sed -i "${NUM}c ${VALUE}${ZK_LISTS}${VALUE_END}" ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/core-site.xml
        echo ${data_host} >> ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/slaves
    done
}


#####################################################################
# 函数名: xync_hadoop
# 描述: 分发 hadoop
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function xync_hadoop()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "hadoop 配置文件分发中，please waiting......"    | tee -a $LOG_FILE
    CLUSTER_HOST=$(grep Cluster_HostName ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
    host_arr=(${CLUSTER_HOST//;/ })
    for hostname in ${EXPAND_NODE_ARRY[@]}
    do
        ssh root@$hostname  "rm -rf ${HADOOP_HOME}"
        rsync -rvl ${HADOOP_INSTALL_HOME}/hadoop  root@${hostname}:${HADOOP_INSTALL_HOME}  >/dev/null
        rm -rf ${HADOOP_INSTALL_HOME}/hadoop/tmp/dfs/data/*
        ssh root@$hostname  "chmod -R 755   ${HADOOP_HOME}"
        ssh root@${hostname} "mkdir -p ${HADOOP_LOG_PATH};chmod -R 777 ${HADOOP_LOG_PATH}"
    done
    for host_name in ${host_arr[@]}
    do
        scp  ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/core-site.xml  root@${host_name}:${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/
        scp  ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/yarn-site.xml  root@${host_name}:${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/
        scp  ${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/slaves root@${host_name}:${HADOOP_INSTALL_HOME}/hadoop/etc/hadoop/
        ssh root@$host_name  "chmod -R 755   ${HADOOP_HOME}"
    done
    #rm -rf  ${HADOOP_SOURCE_DIR}/hadoop
    echo "分发hadoop 安装配置done..."  | tee -a $LOG_FILE
}

#####################################################################
# 函数名: writeUI_file
# 描述: 将hadoop的UI地址写到指定文件中
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function writeUI_file()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "准备将hadoop的UI地址写到指定文件中............"    | tee -a $LOG_FILE
    HadoopWebUI_Dir=$(grep WebUI_Dir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
    HadoopWebUI_File=${HadoopWebUI_Dir}/WebUI_Address
    MASTER_IP=$(cat /etc/hosts|grep "$MASTER1" | awk '{print $1}')
    Hadoop_UI="http://${MASTER_IP}:50070"
    mkdir -p ${HadoopWebUI_Dir}
    grep -q "HadoopUI_Address=" ${HadoopWebUI_Dir}/WebUI_Address
    if [ "$?" -eq "0" ]  ;then
        sed -i "s#^HadoopUI_Address=.*#HadoopUI_Address=${Hadoop_UI}#g" ${HadoopWebUI_Dir}/WebUI_Address
    else
        echo "##Hadoop_WebUI" >> ${HadoopWebUI_Dir}/WebUI_Address
        echo "HadoopUI_Address=${Hadoop_UI}" >> ${HadoopWebUI_Dir}/WebUI_Address
    fi
}

#####################################################################
# 函数名: main
# 描述:  修改hadoop HA模式下所需要修改的配置
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    config_conf_slaves
    writeUI_file
    xync_hadoop
}

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE
main
echo "-------------------------------------" | tee  -a $LOG_FILE
echo " hadoop 扩展安装操作完成 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

set +x


