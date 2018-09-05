#!/usr/bin/env bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    start-resident-clustering-job.sh
## Description: to start resident clustering job(启动聚类任务)
## Author:      pengcong
## Created:     2018-03-26
################################################################################
#set -x  ## 用于调试使用，不用的时候可以注释掉

#---------------------------------------------------------------------#
#                              定义变量                               #
#---------------------------------------------------------------------#
cd `dirname $0`
## bin目录
BIN_DIR=`pwd`
cd ..
SPARK_DIR=`pwd`                                    #spark模块目录
cd ..
DEPLOY_DIR=`pwd`                                       #cluster目录
REALTIME_DIR=`pwd`                                     #RealTimeFaceCompare目录
######## cluster目录 ########
SPARK_CONF_DIR=${SPARK_DIR}/conf
SPARK_LIB_DIR=${SPARK_DIR}/lib
SPARK_LOG_DIR=${SPARK_DIR}/logs
LOG_FILE=${SPARK_LOG_DIR}/KMeansClusteringJob.log
######## common目录 ########
COMMON_CONF_DIR=${DEPLOY_DIR}/common/conf
########service目录###########

## bigdata_env
BIGDATA_ENV=/opt/hzgc/env_bigdata.sh
## spark class
SPARK_CLASS_PARAM=com.hzgc.cluster.spark.clustering.KMeansClustering
## bigdata cluster path
BIGDATA_CLUSTER_PATH=/opt/hzgc/bigdata
# spark conf path
SPARK_CONF_PATH=${BIGDATA_CLUSTER_PATH}/Spark/spark/conf
#---------------------------------------------------------------------#
#                              jar版本控制                            #
#---------------------------------------------------------------------#
## module version(模块)
SPARK_API_VERSION=`ls ${SPARK_LIB_DIR} | grep ^spark-[0-9].[0-9].[0-9].jar$`
JNI_VERSION=`ls ${SPARK_LIB_DIR}| grep ^common-jni-[0-9].[0-9].jar$`
COMMON_UTIL_VERSION=`ls ${SPARK_LIB_DIR} | grep ^common-util-[0-9].[0-9].jar$`
COMMON_HBASE_VERSION=`ls ${SPARK_LIB_DIR} | grep ^common-hbase-[0-9].[0-9].jar$`
COMMON_TABLE_VERSION=`ls ${SPARK_LIB_DIR} | grep ^common-table-[0-9].[0-9].jar$`

## quote version(引用)
MYSQL_CONNECTOR_VERSION=mysql-connector-java-5.1.38.jar
TWILL_API_VERSION=twill-api-0.8.0.jar
TWILL_COMMON_VERSION=twill-common-0.8.0.jar
TWILL_CORE_VERSION=twill-core-0.8.0.jar
TWILL_DIS_API_VERSION=twill-discovery-api-0.8.0.jar
TWILL_DIS_CORE_VERSION=twill-discovery-core-0.8.0.jar
TWILL_ZOOKEEPER_VERSION=twill-zookeeper-0.8.0.jar
TEPHRA_HBASE_VERSION=tephra-hbase-compat-1.1-0.13.0-incubating.jar
TEPHRA_CORE_VERSION=tephra-core-0.13.0-incubating.jar
TEPHRA_API_VERSION=tephra-api-0.13.0-incubating.jar
PHOENIXDRIVER_VERSION=phoenix-core-4.13.1-HBase-1.2.jar
GSON_VERSION=gson-2.8.0.jar
JACKSON_CORE_VERSION=jackson-core-2.8.10.jar
SPARK_STREAMING_KAFKA_VERSION=spark-streaming-kafka-0-8_2.11-2.2.0.jar
HBASE_SERVER_VERSION=hbase-server-1.3.2.jar
HBASE_CLIENT_VERSION=hbase-client-1.3.2.jar
HBASE_COMMON_VERSION=hbase-common-1.3.2.jar
HBASE_PROTOCOL_VERSION=hbase-protocol-1.3.2.jar
KAFKA_VERSION=kafka_2.11-0.8.2.1.jar
ELASTICSEARCH_VERSION=elasticsearch-5.5.0.jar
ROCKETMQ_CLIENT_VERSION=rocketmq-client-4.2.0.jar
ROCKETMQ_COMMON_VERSION=rocketmq-common-4.2.0.jar
ROCKETMQ_REMOTING_VERSION=rocketmq-remoting-4.2.0.jar
FASTJSON_VERSION=fastjson-1.2.47.jar
KAFKA_CLIENTS_VERSION=kafka-clients-1.0.0.jar
METRICS_CORE_VERSION=metrics-core-2.2.0.jar
ZKCLIENT_VERSION=zkclient-0.3.jar


############ 创建log目录 ###############
if [ ! -d ${SPARK_LOG_DIR} ];then
   mkdir ${SPARK_LOG_DIR}
fi
############ 判断是否存在大数据集群###################
if [ ! -d ${BIGDATA_CLUSTER_PATH} ];then
   echo "${BIGDATA_CLUSTER_PATH} does not exit,please go to the node of the existing bigdata cluster !"
   exit 0
fi
############### 判断是否存在配置文件 ##################
if [ ! -e ${SPARK_CONF_DIR}/sparkJob.properties ];then
    echo "${SPARK_CONF_DIR}/sparkJob.properties does not exit!"
    exit 0
else
    cp ${SPARK_CONF_DIR}/sparkJob.properties /opt/hzgc/bigdata/Spark/spark/conf/
fi
if [ ! -e ${SPARK_CONF_DIR}/log4j.properties ];then
    echo "${SPARK_CONF_DIR}/log4j.properties does not exit!"
    exit 0
else
    echo "===================开始配置log4j.properties===================="
    sed -i "s#^log4j.appender.FILE.File=.*#log4j.appender.FILE.File=${LOG_FILE}#g" ${SPARK_CONF_DIR}/log4j.properties
fi
################# 判断是否存在jar ###################
if [ ! -e ${SPARK_LIB_DIR}/${JNI_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${JNI_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${SPARK_API_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${SPARK_API_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${HBASE_CLIENT_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${HBASE_CLIENT_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${HBASE_COMMON_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${HBASE_COMMON_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${GSON_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${GSON_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${JACKSON_CORE_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${JACKSON_CORE_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${SPARK_STREAMING_KAFKA_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${SPARK_STREAMING_KAFKA_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${HBASE_SERVER_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${HBASE_SERVER_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${HBASE_PROTOCOL_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${HBASE_PROTOCOL_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${JNI_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${JNI_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${KAFKA_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${KAFKA_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${ELASTICSEARCH_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${ELASTICSEARCH_VERSION} does not exit!"
    exit 0
fi
 if [ ! -e ${SPARK_LIB_DIR}/${ROCKETMQ_CLIENT_VERSION} ];then
     echo "${SPARK_LIB_DIR}/${ROCKETMQ_CLIENT_VERSION} does not exit!"
     exit 0
 fi
 if [ ! -e ${SPARK_LIB_DIR}/${ROCKETMQ_COMMON_VERSION} ];then
     echo "${SPARK_LIB_DIR}/${ROCKETMQ_COMMON_VERSION} does not exit!"
     exit 0
 fi
 if [ ! -e ${SPARK_LIB_DIR}/${ROCKETMQ_REMOTING_VERSION} ];then
     echo "${SPARK_LIB_DIR}/${ROCKETMQ_REMOTING_VERSION} does not exit!"
     exit 0
 fi
 if [ ! -e ${SPARK_LIB_DIR}/${FASTJSON_VERSION} ];then
     echo "${SPARK_LIB_DIR}/${FASTJSON_VERSION} does not exit!"
     exit 0
 fi
if [ ! -e ${SPARK_LIB_DIR}/${KAFKA_CLIENTS_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${KAFKA_CLIENTS_VERSION} does not exit!"
    exit 0
fi
if [ ! -e ${SPARK_LIB_DIR}/${METRICS_CORE_VERSION} ];then
    echo "${SPARK_LIB_DIR}/${METRICS_CORE_VERSION} does not exit!"
    exit 0
fi

################## 聚类任务 ###################
source /etc/profile
source ${BIGDATA_ENV}
nohup spark-submit \
--master yarn \
--deploy-mode client \
--driver-memory 4g \
--executor-cores 4 \
--num-executors 8 \
--class ${SPARK_CLASS_PARAM} \
--jars ${SPARK_LIB_DIR}/${GSON_VERSION},\
${SPARK_LIB_DIR}/${JACKSON_CORE_VERSION},\
${SPARK_LIB_DIR}/${MYSQL_CONNECTOR_VERSION},\
${SPARK_LIB_DIR}/${COMMON_UTIL_VERSION},\
${SPARK_LIB_DIR}/${COMMON_HBASE_VERSION},\
${SPARK_LIB_DIR}/${PHOENIXDRIVER_VERSION},\
${SPARK_LIB_DIR}/${TEPHRA_API_VERSION},\
${SPARK_LIB_DIR}/${TEPHRA_CORE_VERSION},\
${SPARK_LIB_DIR}/${TEPHRA_HBASE_VERSION},\
${SPARK_LIB_DIR}/spark-indexedrdd-0.4.0.jar,\
${SPARK_LIB_DIR}/part_2.10-0.1.jar,\
${SPARK_LIB_DIR}/common-faceclustering-1.0.jar,\
${SPARK_LIB_DIR}/common-es-1.0.jar,\
${SPARK_LIB_DIR}/common-facestarepo-1.0.jar,\
${SPARK_LIB_DIR}/common-facedispatch-1.0.jar,\
${SPARK_LIB_DIR}/common-rocketmq-1.0.jar,\
${SPARK_LIB_DIR}/common-collect-1.0.jar,\
${SPARK_LIB_DIR}/transport-5.5.0.jar,\
${SPARK_LIB_DIR}/lucene-core-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-highlighter-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-join-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-queryparser-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-queries-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-spatial-6.6.0.jar,\
${SPARK_LIB_DIR}/lucene-sandbox-6.6.0.jar,\
${SPARK_LIB_DIR}/t-digest-3.0.jar,\
${SPARK_LIB_DIR}/netty-common-4.1.11.Final.jar,\
${SPARK_LIB_DIR}/transport-netty3-client-5.5.0.jar,\
${SPARK_LIB_DIR}/transport-netty4-client-5.5.0.jar,\
${SPARK_LIB_DIR}/reindex-client-5.5.0.jar,\
${SPARK_LIB_DIR}/percolator-client-5.5.0.jar,\
${SPARK_LIB_DIR}/lang-mustache-client-5.5.0.jar,\
${SPARK_LIB_DIR}/parent-join-client-5.5.0.jar,\
${SPARK_LIB_DIR}/hppc-0.7.1.jar,\
${SPARK_LIB_DIR}/log4j-api-2.7.jar,\
${SPARK_LIB_DIR}/${TWILL_API_VERSION},\
${SPARK_LIB_DIR}/${TWILL_COMMON_VERSION},\
${SPARK_LIB_DIR}/${TWILL_CORE_VERSION},\
${SPARK_LIB_DIR}/${TWILL_DIS_API_VERSION},\
${SPARK_LIB_DIR}/${TWILL_DIS_CORE_VERSION},\
${SPARK_LIB_DIR}/${TWILL_ZOOKEEPER_VERSION},\
${SPARK_LIB_DIR}/${SPARK_STREAMING_KAFKA_VERSION},\
${SPARK_LIB_DIR}/${HBASE_SERVER_VERSION},\
${SPARK_LIB_DIR}/${HBASE_CLIENT_VERSION},\
${SPARK_LIB_DIR}/${HBASE_COMMON_VERSION},\
${SPARK_LIB_DIR}/${HBASE_PROTOCOL_VERSION},\
${SPARK_LIB_DIR}/${ZKCLIENT_VERSION},\
${SPARK_LIB_DIR}/${JNI_VERSION},\
${SPARK_LIB_DIR}/${KAFKA_VERSION},\
${SPARK_LIB_DIR}/${ELASTICSEARCH_VERSION},\
${SPARK_LIB_DIR}/${ROCKETMQ_CLIENT_VERSION},\
${SPARK_LIB_DIR}/${ROCKETMQ_COMMON_VERSION},\
${SPARK_LIB_DIR}/${ROCKETMQ_REMOTING_VERSION},\
${SPARK_LIB_DIR}/${FASTJSON_VERSION},\
${SPARK_LIB_DIR}/${KAFKA_CLIENTS_VERSION},\
${SPARK_LIB_DIR}/${METRICS_CORE_VERSION} \
--conf "spark.driver.extraJavaOptions=-Dlog4j.configuration=file:${SPARK_CONF_DIR}/log4j.properties" \
--files ${SPARK_CONF_DIR}/sparkJob.properties,\
/opt/hzgc/bigdata/HBase/hbase/conf/hbase-site.xml,\
/opt/hzgc/bigdata/Hive/hive/conf/hive-site.xml \
${SPARK_LIB_DIR}/${SPARK_API_VERSION} > ${LOG_FILE} 2>&1 &