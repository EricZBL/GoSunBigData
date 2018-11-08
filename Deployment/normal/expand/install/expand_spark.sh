#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expand_spark.sh
## Description: spark扩展安装
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-14
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
## 安装日志文件
LOG_FILE=${LOG_DIR}/expand_spark.log
## 集群组件的日志文件目录 /opt/hzgc/logs
LOGS_PATH=$(grep Cluster_LOGSDir ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
SPARK_LOG_PATH=${LOGS_PATH}/spark
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
## 原集群节点
INSTALL=$(grep Cluster_HostName ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
INSTALL_HOSTNAMES=(${INSTALL//;/ })
## 集群新增节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
echo "读取的新增集群节点IP为："${CLUSTER_HOST} | tee -a $LOG_FILE
HOSTNAMES=(${CLUSTER_HOST//;/ })
## SPARK_INSTALL_HOME spark 安装目录
SPARK_INSTALL_HOME=${INSTALL_HOME}/Spark
## SPARK_HOME  spark 根目录
SPARK_HOME=${INSTALL_HOME}/Spark/spark
## spark conf 目录
SPARK_CONF_DIR=${SPARK_HOME}/conf
## spark spark-env.sh 文件
SPARK_ENV_FILE=${SPARK_CONF_DIR}/spark-env.sh
## spark slaves 文件
SLAVES_FILE=${SPARK_CONF_DIR}/slaves
## spark beeline 文件
BEELINE_FILE=${SPARK_HOME}/bin/spark-beeline
## spark-defaults.conf 文件
DEFAULT_CONF_FILE=${SPARK_CONF_DIR}/spark-defaults.conf


## spark的安装节点，需要拼接，放入数组中
SPARK_NAMENODE=$(grep Spark_NameNode ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
SPARK_SERVICENODE=$(grep Spark_ServiceNode ${CLUSTER_BUILD_SCRIPTS_DIR}/conf/cluster_conf.properties|cut -d '=' -f2)
SERVICE_HOSTS=(${SPARK_SERVICENODE//;/ })
SPARK_HOSTNAME_LISTS=${SPARK_NAMENODE}";"${SPARK_SERVICENODE}
SPARK_HOSTNAME_ARRY=(${SPARK_HOSTNAME_LISTS//;/ })

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 spark 扩展安装操作 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

#####################################################################
# 函数名:spark_distribution
# 描述: 将spark安装包分发到新增节点
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function spark_distribution ()
{
for insName in ${HOSTNAMES[@]}
do
    echo "准备将 spark 发到新增节点 ${insName} ..." | tee -a $LOG_FILE
    scp -r ${SPARK_INSTALL_HOME} root@${insName}:${INSTALL_HOME} > /dev/null
    ssh root@${insName} "mkdir -p ${SPARK_LOG_PATH};chmod -R 777 ${SPARK_LOG_PATH}"
    echo "分发到新增 ${insName} 节点完毕！！！" | tee -a $LOG_FILE
done
}

#####################################################################
# 函数名:spark_env
# 描述: 修改spark_env文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
zkconf=""
for zk in ${HOSTNAMES[@]}
do
    zkconf="$zkconf$zk:2181,"
done
function spark_env ()
{
VALUE=$(grep "SPARK_DAEMON_JAVA_OPTS=" ${SPARK_ENV_FILE} | cut -d '=' -f4 | cut -d ' ' -f1)
VALUE2=$(grep "${zkconf%?}" ${SPARK_ENV_FILE})
if [ -n "${VALUE2}" ];then
    echo "SPARK_DAEMON_JAVA_OPTS 配置中新增节点IP及端口号已存在，不需要添加"
else
    sed -i "s#${VALUE}#${VALUE},${zkconf%?}#g" ${SPARK_ENV_FILE}
fi

## 拷贝到所有节点
for host in ${INSTALL_HOSTNAMES[@]};
do
    scp ${SPARK_ENV_FILE} root@${host}:${SPARK_ENV_FILE}
done
}

#####################################################################
# 函数名:salves
# 描述: 修改salves文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function salves ()
{
## 将新增节点IP添加到 slaves 文件中
for insName in ${HOSTNAMES[@]}
do
    value1=$(grep "${insName}"  ${SLAVES_FILE})
    if [ -n "${value1}" ];then
    ## 不为空
        echo "slaves 文件中已存在新增节点 ${insName} 的IP，不需要添加"
    else
        echo ${insName} >> ${SLAVES_FILE}
    fi
done
## 拷贝到所有节点
for host in ${INSTALL_HOSTNAMES[@]};
do
    scp ${SLAVES_FILE} root@${host}:${SLAVES_FILE}
done
}

#####################################################################
# 函数名:spark_beeline
# 描述: 修改spark-beeline文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function spark_beeline ()
{
VALUE1=$(grep "jdbc:hive2://" ${BEELINE_FILE} | cut -d '/' -f5)
VALUE2=$(grep "${zkconf%?}" ${BEELINE_FILE})
if [ -n "${VALUE2}" ];then
    echo "spark_beeline 配置中新增节点IP及端口号已存在，不需要添加"
else
    sed -i "s#${VALUE1}#${VALUE1},${zkconf%?}#g" ${BEELINE_FILE}
fi
## 拷贝到所有节点
for host in ${INSTALL_HOSTNAMES[@]};
do
    scp ${BEELINE_FILE} root@${host}:${BEELINE_FILE}
done
}


#####################################################################
# 函数名:defaults_conf
# 描述: 修改spark-defaults.conf 文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function defaults_conf ()
{
for insName in ${HOSTNAMES[@]}
do
    VALUE=$(grep "spark.yarn.historyServer.address" ${DEFAULT_CONF_FILE} )
    VALUE2=${VALUE##* }
    echo $VALUE2
    echo "value为："${VALUE}
    echo "准备修改spark ${insName} 的conf文件"
    ssh root@${insName} "sed -i 's#$VALUE2#${insName}:18080#g' ${DEFAULT_CONF_FILE}"
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
spark_distribution
spark_env
salves
spark_beeline
defaults_conf
}

#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#
## 打印时间
echo "" | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")" | tee  -a  $LOG_FILE
main
echo "-------------------------------------" | tee  -a $LOG_FILE
echo "spark 扩展安装操作完成 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE
