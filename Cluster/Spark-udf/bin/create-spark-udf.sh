#!/bin/bash
################################################################################
## Copyright:    HZGOSUN Tech. Co, BigData
## Filename:     create-spark-udf.sh
## Description:  向hive中添加并注册udf函数
## Author:       qiaokaifeng
## Created:      2017-11-28
################################################################################

#set -x
#---------------------------------------------------------------------#
#                              定义变量                               #
#---------------------------------------------------------------------#

cd `dirname $0`
SPARK_DIR=`pwd`                         ### spark 目录
## log 日记目录
LOG_DIR=${SPARK_DIR}/logs
##  log 日记文件
LOG_FILE=${LOG_DIR}/add-udf.log

cd ../..
SCRIPT_DIR=`pwd`
CONF_FILE=${SCRIPT_DIR}/conf/project-conf.properties

## udf jar version
UDF_VERSION=`ls ${SPARK_DIR}/lib | grep ^spark-udf-[0-9].[0-9].[0-9].jar$`
## bigdata cluster path
BIGDATA_CLUSTER_PATH=$(grep install_homedir ${CONF_FILE} |cut -d '=' -f2)
## bigdata hadoop path
HADOOP_PATH=${BIGDATA_CLUSTER_PATH}/Hadoop/hadoop
## bigdata hive path
HIVE_PATH=${BIGDATA_CLUSTER_PATH}/Hive/hive
## udf function name
UDF_FUNCTION_NAME=compare
## udf class path
UDF_CLASS_PATH=com.hzgc.cluster.spark.udf.UDFArrayCompare
## hdfs udf  path
HDFS_UDF_PATH=/user/hive/udf
## hdfs udf Absolute path
HDFS_UDF_ABSOLUTE_PATH=hdfs://hzgc/${HDFS_UDF_PATH}/${UDF_VERSION}

source /opt/hzgc/env_bigdata.sh
## 判断hdfs上/user/hive/udf目录是否存在
${HADOOP_PATH}/bin/hdfs dfs -test -e ${HDFS_UDF_PATH}
if [ $? -eq 0 ] ;then
	echo "=================================="
    echo "${HDFS_UDF_PATH}已经存在"
	echo "=================================="
else
	echo "=================================="
    echo "${HDFS_UDF_PATH}不存在,正在创建"
	echo "=================================="
	${HADOOP_PATH}/bin/hdfs dfs -mkdir -p ${HDFS_UDF_PATH}
	if [ $? == 0 ];then
    echo "=================================="
    echo "创建${HDFS_UDF_PATH}目录成功......"
	echo "=================================="
else
    echo "====================================================="
    echo "创建${HDFS_UDF_PATH}目录失败,请检查服务是否启动......"
	echo "====================================================="
    fi
fi

## 上传udf到hdfs指定目录
${HADOOP_PATH}/bin/hdfs dfs -test -e ${HDFS_UDF_PATH}/${UDF_VERSION}
if [ $? -eq 0 ] ;then
	echo "=================================="
	echo "${HDFS_UDF_PATH}/${UDF_VERSION}已经存在"
	echo "=================================="
else
	echo "=================================="
	echo "${HDFS_UDF_PATH}/${UDF_VERSION}不存在,正在上传"
	echo "=================================="
    ${HADOOP_PATH}/bin/hdfs dfs -put ${SPARK_DIR}/lib/${UDF_VERSION} ${HDFS_UDF_PATH}
	if [ $? == 0 ];then
		echo "===================================="
		echo "上传udf函数成功......"
		echo "===================================="
	else
		echo "===================================="
		echo "上传udf函数失败,请查找失败原因......"
		echo "===================================="
	fi
fi

## 在hive中添加并注册udf函数
${HIVE_PATH}/bin/hive -e "create function ${UDF_FUNCTION_NAME} as '${UDF_CLASS_PATH}' using jar '${HDFS_UDF_ABSOLUTE_PATH}';show functions"

echo "================================================================================="
echo "Please see if there is a UDF function with the function called default.${UDF_FUNCTION_NAME}!!!"
echo "================================================================================="

#set +x
