#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    create_kafka_topic
## Description: 创建Kafka topic，相关参数从配置文件project-deploy.properties中配置
## Author:      mashencai
## Created:     2017-12-01
################################################################################
set -x  ## 用于调试用，不用的时候可以注释掉

#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#
cd `dirname $0`
BIN_DIR=`pwd`                                         ### bin目录：脚本所在目录
cd ..
SPARK_DIR=`pwd`                                         ### spark模块部署目录
CONF_DIR=$SPARK_DIR/conf                            ### 配置文件目录
LOG_DIR=$SPARK_DIR/logs                                 ### log日志目录
LOG_FILE=$LOG_DIR/create-kafka-topic.log              ### log日志目录
CONF_FILE=${CONF_DIR}/project-deploy.properties   ### 项目配置文件
## 最终安装的根目录，所有bigdata 相关的根目录：/opt/hzgc/bigdata
INSTALL_HOME=$(grep install_homedir $CONF_FILE |cut -d '=' -f2)
## KAFKA_INSTALL_HOME kafka 安装目录
KAFKA_INSTALL_HOME=${INSTALL_HOME}/Kafka
## KAFKA_HOME  kafka 根目录
KAFKA_HOME=${INSTALL_HOME}/Kafka/kafka

if [ ! -d $LOG_DIR ]; then
    mkdir $LOG_DIR
fi


#####################################################################
# 函数名: create_kafka_topic
# 描述: 创建kafka的topic
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function create_kafka_topic()
{
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
	echo "开始创建kafka的topic.."                       | tee  -a  $LOG_FILE

    # 根据zookeeper字段，查找配置文件中，zk的IP地址和端口号
    #ZK_IP_PORTS=`sed '/zookeeper/!d;s/.*=//' ${CONF_FILE} | tr -d '\r'`
	ZK_IP_PORTS=$(grep zookeeper_installnode ${CONF_FILE}|cut -d '=' -f2)
    # 将读取的IP（原本为分号分割），配置为以逗号分割
    zk_arr=(${ZK_IP_PORTS//;/ })
    zkpro=''
    for zk_host in ${zk_arr[@]}
    do
        zkpro=$zkpro$zk_host":2181,"
    done
    zkpro=${zkpro%?}

    # 从配置文件中获取创建kafka topic的副本数和分区数
	repl_factor=$(grep kafka_replicationFactor ${CONF_FILE}|cut -d '=' -f2)
	part_num=$(grep kafka_partitions ${CONF_FILE}|cut -d '=' -f2)

    # 进入到kafka的bin目录下
    cd ${KAFKA_HOME}/bin
    # 创建kafka feature topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num}  \
    --topic feature >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
		echo "创建 feature topic 成功...."  | tee  -a  $LOG_FILE
		echo "kafka feature topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
	else
		echo "创建 feature topic 失败...." | tee -a $LOG_FILE
	fi

    # 创建kafka person topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num}  \
    --topic person >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
		echo "创建 person topic 成功...."  | tee  -a  $LOG_FILE
		echo "kafka person topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
	else
		echo "创建 preson topic 失败...." | tee -a $LOG_FILE
	fi

    # 创建kafka car topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num}  \
    --topic car >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
		echo "创建 car topic 成功...."  | tee  -a  $LOG_FILE
		echo "kafka car topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
	else
		echo "创建 car topic 失败...." | tee -a $LOG_FILE
	fi

	#创建kafka PeoMan-Fusion topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num} \
    --topic PeoMan-Fusion >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
        echo "创建 PeoMan-Fusion topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka PeoMan-Fusion topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
    else
        echo "创建 PeoMan-Fusion topic 失败...." | tee -a $LOG_FILE
    fi

    #创建kafka PeoMan-Inner topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num} \
    --topic PeoMan-Inner >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
        echo "创建 PeoMan-Inner topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka PeoMan-Inner topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
    else
        echo "创建 PeoMan-Inner topic 失败...." | tee -a $LOG_FILE
    fi

    #创建kafka face topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions 10 \
    --topic face  >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
        echo "创建 face topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka face topic 副本数为${repl_factor},分区数为10." | tee -a $LOG_FILE
    else
        echo "创建 face topic 失败...." | tee -a $LOG_FILE
    fi

   #创建kafka imsi topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num} \
    --topic imsi  >> ${LOG_FILE} 2>&1 &

    if [ $? = 0 ];then
        echo "创建 imsi topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka imsi topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
    else
        echo "创建 imsi topic 失败...." | tee -a $LOG_FILE
    fi

    #创建kafka mac topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num} \
    --topic mac  >> ${LOG_FILE} 2>&1 &
     if [ $? = 0 ];then
        echo "创建 mac topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka mac topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
    else
        echo "创建 mac topic 失败...." | tee -a $LOG_FILE
    fi
     #创建kafka dispatch topic
    ./kafka-topics.sh --create \
    --zookeeper ${zkpro} \
    --replication-factor ${repl_factor} \
    --partitions ${part_num} \
    --topic dispatch  >> ${LOG_FILE} 2>&1 &
     if [ $? = 0 ];then
        echo "创建 dispatch topic 成功...."  | tee  -a  $LOG_FILE
        echo "kafka dispatch topic 副本数为${repl_factor},分区数为${part_num}." | tee -a $LOG_FILE
    else
        echo "创建 dispatch topic 失败...." | tee -a $LOG_FILE
    fi

    # 列出所有topic
	echo ""  | tee -a $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE
	echo ""  | tee -a $LOG_FILE
	echo "验证Kafka创建是否成功....." | tee -a $LOG_FILE
    echo "执行${KAFKA_HOME}/bin/kafka-topics.sh --list --zookeeper ${zkpro}，列出所有topic..." | tee -a $LOG_FILE
	sleep 2s
	./kafka-topics.sh --list \
    --zookeeper ${zkpro} | tee  -a  $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE

}


#####################################################################
# 函数名: main
# 描述: 脚本主要业务入口
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function main()
{
    create_kafka_topic
}


#---------------------------------------------------------------------#
#                              执行流程                                #
#---------------------------------------------------------------------#

## 打印时间
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE
main

set +x