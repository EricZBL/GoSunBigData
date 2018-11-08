#!/bin/bash
################################################################################
## Copyright:     HZGOSUN Tech. Co, BigData
## Filename:      kafkaEagleInstall.sh
## Description:   安装 kafka-Eagle
## Version:       1.0
## Kafka-eagle.Version: 1.2.4
## Version:     2.0
## Author:      liangshiwei
## Created:     2018-10-16
################################################################################

#set -x
##set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
## kafka 安装包目录
KAFKA_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)

## KE_HOME  Kafka-eagle 根目录
KAFKA_EAGLE_HOME=${INSTALL_HOME}/Kafka-eagle/kafka-eagle

## zookeeper的安装节点，放入数组中
ZOOKEEPER_HOSTNAME_LISTS=$(grep Zookeeper_InstallNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
ZOOKEEPER_HOSTNAME_ARRY=(${ZOOKEEPER_HOSTNAME_LISTS//;/ })

if [[ ! -e "${INSTALL_HOME}/Kafka-eagle" ]]; then
    mkdir -p ${INSTALL_HOME}/Kafka-eagle
fi

cp -r ${KAFKA_SOURCE_DIR}/kafka-eagle ${INSTALL_HOME}/Kafka-eagle

kfkepro=''
for zk in ${ZOOKEEPER_HOSTNAME_ARRY[@]}
do
    kfkepro="$kfkepro$zk:2181,"
done
    sed -i "s;cluster1.zk.list=.*;cluster1.zk.list=${kfkepro%?};g"  ${KAFKA_EAGLE_HOME}/conf/system-config.properties

## 获取源数据存放的类型
MYSQL_INSTALL_NODE=$(grep Mysql_InstallNode ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
MYSQL_PORT=$(grep MYSQL_Port ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
DATABASE_USER=$(grep MYSQL_USER ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
DATABASE_PASSWORD=$(grep MYSQL_Password ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)


EAGLE_URL="jdbc:mysql://${MYSQL_INSTALL_NODE}:${MYSQL_PORT}/ke?useUnicode=true\&characterEncoding=UTF-8\&zeroDateTimeBehavior=convertToNull"
echo ${EAGLE_URL}
sed -i "s;kafka.eagle.url=.*;kafka.eagle.url=${EAGLE_URL};g"  ${KAFKA_EAGLE_HOME}/conf/system-config.properties
sed -i "s;kafka.eagle.username=.*;kafka.eagle.username=${DATABASE_USER};g"  ${KAFKA_EAGLE_HOME}/conf/system-config.properties
sed -i "s;kafka.eagle.password=.*;kafka.eagle.password=${DATABASE_PASSWORD};g"  ${KAFKA_EAGLE_HOME}/conf/system-config.properties


## 配置环境变量
kehome_exists=`grep "export KE_HOME=" /etc/profile`
path_exists=`grep '$KE_HOME/bin' /etc/profile`
# 存在"export KE_HOME="这一行：则替换这一行；不存在则添加
    if [ "${kehome_exists}" != "" ];then
         `sed -i "s#^export KE_HOME=.*#export KE_HOME=${KAFKA_EAGLE_HOME}#g" /etc/profile`
         else
         `echo '#KE_HOME'>>/etc/profile ;echo export KE_HOME=\${KAFKA_EAGLE_HOME} >> /etc/profile`
    fi
# 存在"export PATH=$KE_HOME"这一部分：则替换这一行；不存在则添加
    if [[ "X${path_exists}" != "X" ]]; then
         `sed -i 's#^export PATH=\$KE_HOME.*#export PATH=\$KE_HOME/bin:\$PATH#g' /etc/profile`
        else
         `echo 'export PATH=$KE_HOME/bin:\$PATH'  >> /etc/profile; echo ''>> /etc/profile`
    fi

    `source /etc/profile`

set +x
