#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    ftp_distribute.sh
## Description: 一键配置及分发Collect（FTP）模块
## Author:      zhangbaolin
## Created:     2018-07-26
################################################################################
#set -x  ## 用于调试用，不用的时候可以注释掉
#set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
CONF_DIR=${BIN_DIR}/../conf
CONF_FILE=${CONF_DIR}/project-deploy.properties

## 安装包根目录
ROOT_HOME=`pwd`   ##ClusterBuildScripts
## 集群配置文件目录
CLUSTER_CONF_DIR=${ROOT_HOME}/conf
## 集群配置文件
CLUSTER_CONF_FILE=${CLUSTER_CONF_DIR}/cluster_conf.properties
COLLECT_INSTALL_HOME=/opt/Collect
COLLECT_HOME=${ROOT_HOME}/component/Collect
## collect模块脚本目录
COllECT_BIN_DIR=${COLLECT_HOME}/bin
## collect模块配置文件目录
COllECT_CONF_DIR=${COLLECT_HOME}/conf
## collect模块配置文件
COllECT_START_FILE=${COllECT_BIN_DIR}/start-ftpserver.sh
## haproxy-ftp映射配置文件
HAPROXY_FTP_CONF_FILE=${BIN_DIR}/../conf/collect-deploy.properties
## FTP服务器地址
FTPIP=$(grep 'FTPIP' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
## 集群节点地址
CLUSTERNODE=$(grep 'Cluster_HostName' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)

COLLECT_LOG_DIR=${COLLECT_HOME}/logs                      ##collect的log目录
LOG_FILE=${COLLECT_LOG_DIR}/collect.log
mkdir -p ${COLLECT_LOG_DIR}

## 修改collect配置文件
function modify_config()
{
    ## 在collect中配置zookeeper地址
    echo "配置collect.properties里的zookeeper地址"
    zookeeper=$(grep 'Zookeeper_InstallNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    zkarr=(${zookeeper//;/ })
        for zkhost in ${zkarr[@]}
        do
            zklist="${zkhost}:2181,${zklist}"
        done
        zklist=${zklist%,*}
    sed -i "s#ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zklist}#g" ${COllECT_START_FILE}

    ## 在collect中配置rocketmq地址
    echo "配置collect.properties里的rocketmq地址"
    rocketmq=$(grep 'RocketMQ_Namesrv' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    sed -i "s#ROCKETMQ_HOST=.*#ROCKETMQ_HOST=${rocketmq}:9876#g" ${COllECT_START_FILE}

    ## 在collect中配置kafka地址
    echo "配置collect.properties里的kafka地址"
    kafka=$(grep 'Kafka_InstallNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    kafkaarr=(${kafka//;/ })
        for kafkahost in ${kafkaarr[@]}
        do
            kafkalist="${kafkahost}:9092,${kafkalist}"
        done
    kafkalist=${kafkalist%,*}
    sed -i "s#KAFKA_HOST=.*#KAFKA_HOST=${kafkalist}#g" ${COllECT_START_FILE}

    ## 在collect中配置eureka_port
    EUREKA_PORT=$(grep spring_cloud_eureka_port ${CONF_FILE} | cut -d '=' -f2)
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${COllECT_START_FILE}
    echo "start-ftpserver.sh脚本配置eureka_port完成......."

    ## 在collect中配置eureka_ip
    EUREKA_NODE_HOSTS=$(grep spring_cloud_eureka_node $CONF_FILE | cut -d '=' -f2)
    eureka_node_arr=(${EUREKA_NODE_HOSTS//;/ })
    enpro=''
    for en_host in ${eureka_node_arr[@]}
    do
      enpro=${enpro}${en_host}","
    done
    enpro=${enpro%?}

    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${enpro}#g" ${COllECT_START_FILE}
    echo "start-ftpserver.sh脚本配置eureka_ip完成......."

    ## 在colloect中配置需要分发的节点
    #echo "配置需要分发collect（FTP）的节点"
    #sed -i "s#collect.distribute=.*#collect.distribute=${CLUSTERNODE}#g" ${COllECT_START_FILE}

}

## 分发collect（FTP）模块
function distribute_collect()
{
    echo "" | tee -a $LOG_FILE
    echo "**************************************" | tee -a $LOG_FILE
    echo "" | tee -a $LOG_FILE
    echo "分发collect.................." | tee -a $LOG_FILE

    numlist=`grep "ftp.type." ${HAPROXY_FTP_CONF_FILE} | cut -d '=' -f1 | cut -d '.' -f3`
    num=${numlist// / }
    for n in ${num[@]};do
        type=`grep "ftp.type.${n}" ${HAPROXY_FTP_CONF_FILE} | cut -d '=' -f2`
        haproxy=`grep "haproxy.${n}" ${HAPROXY_FTP_CONF_FILE} | cut -d '=' -f2`
        ftpip=`grep "ftp.iplist.${n}" ${HAPROXY_FTP_CONF_FILE} | cut -d '=' -f2`
        if [[ -z "${type}" || -z "${haproxy}" || -z "${ftpip}" ]]; then
            echo "配置出错，请检查ftp.type.${n},haproxy.${n},ftp.ip.list.${n}"
            exit 1
        fi
        ftplist=${ftpip//;/ }
        for ip in ${ftplist[@]}; do
            rsync -rvl ${COLLECT_HOME} root@${ip}:/opt  >/dev/null
            ssh root@${ip} "chmod -R 755 /opt/Collect"
            ##修改配置文件中的ftp type
#            echo "${ip}上分发collect完毕，开始配置配置文件中ftp.type................." | tee -a $LOG_FILE
#            ssh root@${ip} "sed -i 's#^ftp.type=.*#ftp.type=${type}#g' ${COLLECT_INSTALL_HOME}/bin/start-ftpserver.sh"
            ##修改配置文件中的proxy ip
#            echo "${ip}上分发collect完毕，开始配置配置文件中proxy.ip................." | tee -a $LOG_FILE
#            ssh root@${ip} "sed -i 's#^proxy.ip=.*#proxy.ip=${haproxy}#g' ${COLLECT_INSTALL_HOME}/conf/collect.properties"
            ##修改配置文件中的ftp ip
            echo "${ip}上分发collect完毕，开始配置配置文件中ftp.ip................." | tee -a $LOG_FILE
            ssh root@${ip} "sed -i 's#^FTP_IP=.*#FTP_IP=${ip}#g' ${COLLECT_INSTALL_HOME}/bin/start-ftpserver.sh"
            echo "${ip}上修改配置文件完成.................." | tee -a $LOG_FILE
        done
    done
}

##############################################################################
# 函数名： main
# 描述： 脚本主要业务入口
# 参数： N/A
# 返回值： N/A
# 其他： N/A
##############################################################################
function main()
{
  modify_config
  distribute_collect
}

#--------------------------------------------------------------------------#
#                                  执行流程                                #
#--------------------------------------------------------------------------#
##打印时间
echo ""
echo "=========================================================="
echo "$(date "+%Y-%m-%d  %H:%M:%S")"

main

set +x


