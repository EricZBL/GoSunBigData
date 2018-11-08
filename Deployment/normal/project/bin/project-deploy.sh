#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    project_distribute.sh
## Description: 一键配置及分发微服务模块
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
## FTP服务器地址
FTPIP=$(grep 'FTPIP' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
## 集群节点地址
CLUSTERNODELIST=$(grep 'Cluster_HostName' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
CLUSTERNODE=(${CLUSTERNODELIST//;/ })
## 本节点ip
LOCALIP=`hostname -i`

COMPONENT_HOME=${ROOT_HOME}/component
cd ${COMPONENT_HOME}
## 判断GoSunBigData目录是否存在
if [[ ! -e GoSunBigData ]]; then
    echo "GoSunBigData 目录不存在"
    exit 1
fi

## 判断Collect目录是否存在
if [[ ! -e Collect ]]; then
    echo "Collect 目录不存在"
    exit 1
fi
cd ${COMPONENT_HOME}/GoSunBigData
## GoSunBigData 目录
GOSUN_HOME=`pwd`
GOSUNINSTALL_HOME=/opt/GoSunBigData
## cluster模块目录
CLUSTER_DIR=${GOSUN_HOME}/Cluster
CLUSTER_INSTALL_DIR=${GOSUNINSTALL_HOME}/Cluster
PEOPLEMANAGER_INSTALL_DIR=${CLUSTER_INSTALL_DIR}/peoplemanager
FACECOMPARE_INSTALL_DIR=${CLUSTER_INSTALL_DIR}/FaceCompare
## service模块目录
SERVICE_DIR=${GOSUN_HOME}/Service
SERVICE_INSTALL_DIR=${GOSUNINSTALL_HOME}/Service
## cluster-spark模块目录
SPARK_DIR=${GOSUN_HOME}/Cluster/spark
PEOPLEMANAGER_DIR=${GOSUN_HOME}/Cluster/peoplemanager
PEOPLEMANAGER_CLIENT_DIR=${PEOPLEMANAGER_DIR}/peoplemanager-client
PEOPLEMANAGER_WORKER_DIR=${PEOPLEMANAGER_DIR}/peoplemanager-worker
PEOPLEMANAGER_CLIENT_BIN_DIR=${PEOPLEMANAGER_CLIENT_DIR}/bin
PEOPLEMANAGER_WORKER_BIN_DIR=${PEOPLEMANAGER_WORKER_DIR}/bin
PEOPLEMANAGER_CLIENT_START_FILE=${PEOPLEMANAGER_CLIENT_BIN_DIR}/start-peoman-client.sh
PEOPLEMANAGER_WORKER_START_FILE=${PEOPLEMANAGER_WORKER_BIN_DIR}/start-peoman-worker.sh
##cluster-dispatch模块
DISPATCH_BACKGROUND_DIR=${GOSUN_HOME}/Cluster/Dispatch-background
DISPATCH_BACKGROUND_BIN_DIR=${DISPATCH_BACKGROUND_DIR}/bin
DISPATCH_BACKGROUND_START_FILE=${DISPATCH_BACKGROUND_BIN_DIR}/start-dispatch-background.sh
DISPATCH_BACKGROUND_CONF_DIR=${DISPATCH_BACKGROUND_DIR}/conf
DISPATCH_BACKGROUND_CONF_FILE=${DISPATCH_BACKGROUND_CONF_DIR}/application-pro.properties
## facecompare模块
FACECOMPARE_DIR=${GOSUN_HOME}/Cluster/FaceCompare
FACECOMPARE_CONF_DIR=${FACECOMPARE_DIR}/conf
FACECOMPARE_MASTER_FILE=${FACECOMPARE_CONF_DIR}/master.properties
FACECOMPARE_WORKER_FILE=${FACECOMPARE_CONF_DIR}/worker.properties

## cluster spark模块bin目录
SPARK_BIN_DIR=${SPARK_DIR}/bin
## cluster-spark模块配置文件目录
CONF_SPARK_DIR=${SPARK_DIR}/conf
## service的log日志目录
SERVICE_LOG_DIR=${SERVICE_DIR}/logs
## Service log日志文件
SERVICE_LOG_FILE=${SERVICE_LOG_DIR}/config-service.log
## cluster-spark log日志目录
SPARK_LOG_DIR=${SPARK_DIR}/logs
## cluster-spark log日志文件
SPARK_LOG_FILE=${SPARK_LOG_DIR}/config-cluster.log

mkdir -p ${SPARK_LOG_DIR}
mkdir -p ${SERVICE_LOG_DIR}

## Basic服务
## collect face-dispatch face-dyn vehicle-dyn person-dyn
## face-dispatch模块部署目录
FACE_DISPATCH_DIR=${SERVICE_DIR}/Basic/face-dispatch
FACE_DISPATCH_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Basic/face-dispatch
FACE_DISPATCH_BIN_DIR=${FACE_DISPATCH_DIR}/bin                           ##face-dispatch模块脚本存放目录
FACE_DISPATCH_START_FILE=${FACE_DISPATCH_BIN_DIR}/start-face-dispatch.sh       ##face-dispatch模块启动脚本
FACE_DISPATCH_CONF_DIR=${FACE_DISPATCH_DIR}/conf                         ##face-dispatch模块conf目录
FACE_DISPATCH_PRO_FILE=${FACE_DISPATCH_CONF_DIR}/application-pro.properties   ##face-dispatch模块配置文件
## face-dynrepo模块部署目录
DYNREPO_DIR=${SERVICE_DIR}/Basic/face-dynrepo
DYNREPO_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Basic/face-dynRepo
DYNREPO_BIN_DIR=${DYNREPO_DIR}/bin                           ##face-dynrepo模块脚本存放目录
DYNREPO_START_FILE=${DYNREPO_BIN_DIR}/start-face-dynrepo.sh       ##face-dynrepo模块启动脚本
DYNREPO_CONF_DIR=${DYNREPO_DIR}/conf                         ##face-dynrepo模块conf目录
DYNREPO_PRO_FILE=${DYNREPO_CONF_DIR}/application-pro.properties   ##face-dynrepo模块配置文件
## collect模块部署目录
COLLECT_DIR=${SERVICE_DIR}/Basic/collect
COLLECT_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Basic/collect
COLLECT_BIN_DIR=${COLLECT_DIR}/bin                           ##collect模块脚本存放目录
COLLECT_START_FILE=${COLLECT_BIN_DIR}/start-collect.sh       ##collect模块启动脚本
COLLECT_CONF_DIR=${COLLECT_DIR}/conf                         ##collect模块conf目录
COLLECT_PRO_FILE=${COLLECT_CONF_DIR}/application-pro.properties   ##collect模块配置文件
## person-dynrepo模块目录
PERSON_DYN_DIR=${SERVICE_DIR}/Basic/person-dynrepo
PERSON_DYN_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Basic/person-dynrepo
PERSON_DYN_BIN_DIR=${PERSON_DYN_DIR}/bin                           ##person-dynRepo模块脚本存放目录
PERSON_DYN_START_FILE=${PERSON_DYN_BIN_DIR}/start-person-dynrepo.sh       ##person-dynRepo模块启动脚本
PERSON_DYN_CONF_DIR=${PERSON_DYN_DIR}/conf                         ##person-dynRepo模块conf目录
PERSON_DYN_PRO_FILE=${PERSON_DYN_CONF_DIR}/application-pro.properties   ##person-dynRepo模块配置文件
## vehicle-dynrepo模块部署目录
CAR_DIR=${SERVICE_DIR}/Basic/vehicle-dynrepo
CAR_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Basic/vehicle-dynrepo
CAR_BIN_DIR=${CAR_DIR}/bin                           ##vehicle-dynrepo模块脚本存放目录
CAR_START_FILE=${CAR_BIN_DIR}/start-vehicle-dynrepo.sh       ##vehicle-dynrepo模块启动脚本
CAR_CONF_DIR=${CAR_DIR}/conf                       ##vehicle-dynrepo模块conf目录
CAR_PRO_FILE=${CAR_CONF_DIR}/application-pro.properties   ##vehicle-dynrepo模块配置文件

## cloud服务
## imsi-dyn people fusion
## imsi-dynrepo模块部署目录
IMSI_DIR=${SERVICE_DIR}/Cloud/imsi-dynrepo
IMSI_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Cloud/imsi-dynrepo
IMSI_BIN_DIR=${IMSI_DIR}/bin                                ##imsi模块脚本存放目录
IMSI_START_FILE=${IMSI_BIN_DIR}/start-imsi-dynrepo.sh         ##imsi模块启动脚本
IMSI_CONF_FILE=${IMSI_DIR}/conf                              ##imsi模块conf目录
IMSI_PRO_FILE=${IMSI_CONF_FILE}/application-pro.properties   ##imsi模块配置文件
## people模块部署目录(未完成)
PEOPLE_DIR=${SERVICE_DIR}/Cloud/people
PEOPLE_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Cloud/people
PEOPLE_BIN_DIR=${PEOPLE_DIR}/bin                           ##people模块脚本存放目录
PEOPLE_START_FILE=${PEOPLE_BIN_DIR}/start-people.sh       ##people模块启动脚本
PEOPLE_CONF_DIR=${PEOPLE_DIR}/conf                       ##people模块conf目录
PEOPLE_PRO_FILE=${PEOPLE_CONF_DIR}/application-pro.properties   ##people模块配置文件
##dispatch模块部署目录
DISPATCH_DIR=${SERVICE_DIR}/Cloud/dispatch
DISPATCH_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Cloud/dispatch
DISPATCH_BIN_DIR=${DISPATCH_DIR}/bin
DISPATCH_START_FILE=${DISPATCH_BIN_DIR}/start-dispatch.sh
DISPATCH_CONF_DIR=${DISPATCH_DIR}/conf
DISPATCH_PRO_FILE=${DISPATCH_CONF_DIR}/application-pro.properties
## fusion模块部署目录
FUSION_DIR=${SERVICE_DIR}/Cloud/fusion
FUSION_INSTALL_DIR=${SERVICE_INSTALL_DIR}/Cloud/fusion
FUSION_BIN_DIR=${FUSION_DIR}/bin                           ##fusion模块脚本存放目录
FUSION_START_FILE=${FUSION_BIN_DIR}/start-fusion.sh       ##fusion模块启动脚本
FUSION_CONF_DIR=${FUSION_DIR}/conf                       ##fusion模块conf目录
FUSION_PRO_FILE=${FUSION_CONF_DIR}/application-pro.properties   ##fusion模块配置文件

## 安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep install_homedir ${CONF_FILE}|cut -d '=' -f2)

HADOOP_INSTALL_HOME=${INSTALL_HOME}/Hadoop            ### hadoop 安装目录
HADOOP_HOME=${HADOOP_INSTALL_HOME}/hadoop             ### hadoop 根目录
CORE_FILE=${HADOOP_HOME}/etc/hadoop/core-site.xml
HDFS_FILE=${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
HBASE_INSTALL_HOME=${INSTALL_HOME}/HBase              ### hbase 安装目录
HBASE_HOME=${HBASE_INSTALL_HOME}/hbase                ### hbase 根目录
HBASE_FILE=${HBASE_HOME}/conf/hbase-site.xml
HIVE_INSTALL_HOME=${INSTALL_HOME}/Hive                ### hive 安装目录
HIVE_HOME=${HIVE_INSTALL_HOME}/hive                   ### hive 根目录
SPARK_INSTALL_HOME=${INSTALL_HOME}/Spark              ### spark 安装目录
SPARK_HOME=${SPARK_INSTALL_HOME}/spark                ### spark 根目录


#####################################################################
# 函数名: config_projectconf
# 描述: 配置RealTimeFaceCompare模块
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_projectconf()
{

      #  ## 分发RealTimeFaceCompare，若是本节点则不分发
      #  if [[  x"${node}" != x"${LOCALIP}" ]]; then
      #      scp -r ${RTFC_HOME} root@node:${RTFC_HOME}
      #  fi
        ## 修改common模块配置文件
        ## 修改配置文件 zookeeper安装节点
        echo "配置$ project-deploy.properties中的zookeeper地址"
        zookeeper=$(grep 'Zookeeper_InstallNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        sed -i "s#zookeeper_installnode=.*#zookeeper_installnode=${zookeeper}#g" ${CONF_FILE}

        ## 修改配置文件 kafka安装节点
        echo "配置 project-deploy.properties中的kafka地址"
        kafka=$(grep 'Kafka_InstallNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        sed -i "s#kafka_install_node=.*#kafka_install_node=${kafka}#g" ${CONF_FILE}

        ## 修改配置文件 rocketmq安装节点
        echo "配置 project-deploy.properties中的rocketmq地址"
        rocketmq=$(grep 'RocketMQ_Namesrv' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        sed -i "s#rocketmq_nameserver=.*#rocketmq_nameserver=${rocketmq}#g" ${CONF_FILE}

         ## 修改配置文件 es安装节点
        echo "配置 project-deploy.properties中的rocketmq地址"
        es=$(grep 'ES_InstallNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2 | cut -d ';' -f1)
        sed -i "s#es_service_node=.*#es_service_node=${es}#g" ${CONF_FILE}

        ## 修改配置文件 jdbc_service节点
         echo "配置 project-deploy.properties中的jdbc_service地址"
        sparknode=$(grep 'Spark_ServiceNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        sparknamenode=$(grep 'Spark_NameNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        if [[ "${sparknode}" =~ "${sparknamenode}" ]]; then
            sparknode=(${sparknode#/$sparknamenode})
            sed -i "s#jdbc_service_node=.*#jdbc_service_node=${sparknode}#g" ${CONF_FILE}
        else
            sed -i "s#jdbc_service_node=.*#jdbc_service_node=${sparknode};${sparknamenode}#g" ${CONF_FILE}
        fi

        ## 修改配置文件 mysql安装节点
        echo "配置 project-deploy.properties中的mysql地址"
        ismini=$(grep ISMINICLUSTER ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        MYSQL=$(grep Mysql_InstallNode ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
        if [[ ${ismini} = "no" && (-n ${MYSQL})  ]]; then
            if [[ ! -e "/opt/tidb-ansible/inventory.ini" ]]; then
                echo "找不到inventory.ini，tidb可能未安装"
                else
                MYSQL=`grep '\[tidb_servers\]' /opt/tidb-ansible/inventory.ini -A 1 | tail -1`:4000
                echo "部署tidb"
            fi
        elif [[ ${ismini} = "yes" && (-n ${MYSQL}) ]]; then
            echo "mysql ip为tidb的ip"
            MYSQL=${MYSQL%%,*}:4000
        else
            echo "mysql为当前节点ip"
            MYSQL=`host -i`:3306
        fi
        sed -i "s#mysql_host=.*#mysql_host=${MYSQL}#g" ${CONF_FILE}

}


#####################################################################
# 函数名: distribute_service
# 描述:  分发service各个模块
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function distribute_service()
{
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "**************************************************" | tee -a ${SERVICE_LOG_FILE}
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "分发service的各个组件......" | tee -a ${SERVICE_LOG_FILE}

    ##basic:face-dispatch,face-dynrepo,vehicle-dynrepo,person-dynrepo,collect
    ##开始分发face-dispatch
    FACE_DISPATCH_HOST_LISTS=$(grep face_dispatch_distribution ${CONF_FILE} | cut -d '=' -f2)
    FACE_DISPATCH_HOST_ARRAY=(${FACE_DISPATCH_HOST_LISTS//;/ })
    for hostname in ${FACE_DISPATCH_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${FACE_DISPATCH_INSTALL_DIR}" ];then mkdir -p "${FACE_DISPATCH_INSTALL_DIR}";fi"
      rsync -rvl ${FACE_DISPATCH_DIR} root@${hostname}:${FACE_DISPATCH_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${FACE_DISPATCH_INSTALL_DIR}"
      echo "${hostname}上分发face-dispatch完毕........." | tee -a ${SERVICE_LOG_FILE}
    done
    ##开始分发dispatch
    DISPATCH_HOST_LISTS=$(grep dispatch_distribution ${CONF_FILE} | cut -d '=' -f2)
    DISPATCH_HOST_ARRAY=(${DISPATCH_HOST_LISTS//;/ })
    for hostname in ${DISPATCH_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${DISPATCH_INSTALL_DIR}" ]; then mkdir -p "${DISPATCH_INSTALL_DIR}"; fi"
      rsync -rvl ${DISPATCH_DIR} root@${hostname}:${DISPATCH_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${DISPATCH_INSTALL_DIR}"
      echo "${hostname}上分发Dispatch完毕........." | tee -a ${SERVICE_LOG_FILE}
    done
    ##开始分发face-dynrepo
    DYNREPO_HOST_LISTS=$(grep face_dynrepo_distribution ${CONF_FILE} | cut -d '=' -f2)
    DYNREPO_HOST_ARRAY=(${DYNREPO_HOST_LISTS//;/ })
    for hostname in ${DYNREPO_HOST_ARRAY[@]}
    do
       ssh root@${hostname} "if [ ! -x "${DYNREPO_INSTALL_DIR}" ];then mkdir -p "${DYNREPO_INSTALL_DIR}";fi"
       rsync -rvl ${DYNREPO_DIR} root@${hostname}:${DYNREPO_INSTALL_DIR} >/dev/null
       ssh root@${hostname} "chmod -R 755 ${DYNREPO_INSTALL_DIR}"
       echo "${hostname}上分发face-dynrepo完毕........." | tee -a ${SERVICE_LOG_FILE}
    done

    ##开始分发collect
    FACE_HOST_LISTS=$(grep collect_distribution ${CONF_FILE} | cut -d '=' -f2)
    FACE_HOST_ARRAY=(${FACE_HOST_LISTS//;/ })
    for hostname in ${FACE_HOST_ARRAY[@]}
    do
       ssh root@${hostname} "if [ ! -x "${COLLECT_INSTALL_DIR}" ];then mkdir -p "${COLLECT_INSTALL_DIR}";fi"
       rsync -rvl ${COLLECT_DIR} root@${hostname}:${COLLECT_INSTALL_DIR} >/dev/null
       ssh root@${hostname} "chmod -R 755 ${COLLECT_INSTALL_DIR}"
       echo "${hostname}上分发collect完毕......." | tee -a ${SERVICE_LOG_FILE}
    done

    ##开始分发person-dynrepo
    PERSON_DYN_HOST_LISTS=$(grep person_dynrepo_distribution ${CONF_FILE} | cut -d '=' -f2)
    PERSON_DYN_HOST_ARRAY=(${PERSON_DYN_HOST_LISTS//;/ })
    for hostname in ${PERSON_DYN_HOST_ARRAY[@]}
    do
       ssh root@${hostname} "if [ ! -x "${PERSON_DYN_INSTALL_DIR}" ];then mkdir -p "${PERSON_DYN_INSTALL_DIR}";fi"
       rsync -rvl ${PERSON_DYN_DIR} root@${hostname}:${PERSON_DYN_INSTALL_DIR} >/dev/null
       ssh root@${hostname} "chmod -R 755 ${PERSON_DYN_INSTALL_DIR}"
       echo "${hostname}上分发person-dynrepo完毕......." | tee -a ${SERVICE_LOG_FILE}
    done

     ##开始分发car
    CAR_HOST_LISTS=$(grep car_dynrepo_distribution ${CONF_FILE} | cut -d '=' -f2)
    CAR_HOST_ARRAY=(${CAR_HOST_LISTS//;/ })
    for hostname in ${CAR_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${CAR_INSTALL_DIR}" ];then mkdir -p "${CAR_INSTALL_DIR}";fi"
      rsync -rvl ${CAR_DIR} root@${hostname}:${CAR_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${CAR_INSTALL_DIR}"
      echo "${hostname}上分发vehicle-dynrepo完毕........" | tee -a ${SERVICE_LOG_FILE}
    done

    ##cloud:people,fusion,imsi
     ##开始分发people
    PEOPLE_HOST_LISTS=$(grep people_distribution ${CONF_FILE} | cut -d '=' -f2)
    PEOPLE_HOST_ARRAY=(${PEOPLE_HOST_LISTS//;/ })
    for hostname in ${PEOPLE_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${PEOPLE_INSTALL_DIR}" ];then mkdir -p "${PEOPLE_INSTALL_DIR}";fi"
      rsync -rvl ${PEOPLE_DIR} root@${hostname}:${PEOPLE_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${PEOPLE_INSTALL_DIR}"
      echo "${hostname}上分发people完毕........" | tee -a ${SERVICE_LOG_FILE}
    done

    ##开始分发imsi
    IMSI_HOST_LISTS=$(grep imsi_distribution ${CONF_FILE} | cut -d '=' -f2)
    IMSI_HOST_ARRAY=(${IMSI_HOST_LISTS//;/ })
    for hostname in ${IMSI_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${IMSI_INSTALL_DIR}" ];then mkdir -p "${IMSI_INSTALL_DIR}"; fi"
      rsync -rvl ${IMSI_DIR} root@${hostname}:${IMSI_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${IMSI_INSTALL_DIR}"
      echo "${hostname}上分发imsi完毕........" | tee -a ${SERVICE_LOG_FILE}
    done

    ##开始分发fusion
    FUSION_HOST_LISTS=$(grep fusion_distribution ${CONF_FILE} | cut -d '=' -f2)
    FUSION_HOST_ARRAY=(${FUSION_HOST_LISTS//;/ })
    for hostname in ${FUSION_HOST_ARRAY[@]}
    do
      ssh root@${hostname} "if [ ! -x "${FUSION_INSTALL_DIR}" ];then mkdir -p "${FUSION_INSTALL_DIR}"; fi"
      rsync -rvl ${FUSION_DIR} root@${hostname}:${FUSION_INSTALL_DIR} >/dev/null
      ssh root@${hostname} "chmod -R 755 ${FUSION_INSTALL_DIR}"
      echo "${hostname}上分发fusion完毕........" | tee -a ${SERVICE_LOG_FILE}
    done

    ## 拷贝GoSun到opt目录下
    cp -r ${GOSUN_HOME} /opt

    ## 分发peoplemanager
    CLUSTERNODELIST=$(grep 'Cluster_HostName' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    CLUSTERNODE=(${CLUSTERNODELIST//;/ })
    CLUSTER_NODE_NUM=${#CLUSTERNODELIST[@]}
    localhost=`hostname -i`
    num=1
    for hostname in ${CLUSTERNODE}
    do
      if [[ ${localhost} != ${hostname} ]]; then
          ssh root@${hostname} "if [ ! -x "${PEOPLEMANAGER_INSTALL_DIR}" ];then mkdir -p "${PEOPLEMANAGER_INSTALL_DIR}"; fi"
          rsync -rvl ${PEOPLEMANAGER_DIR} root@${hostname}:${PEOPLEMANAGER_INSTALL_DIR} >/dev/null
          ssh root@${hostname} "chmod -R 755 ${PEOPLEMANAGER_INSTALL_DIR}"
          echo "${hostname}上分发peoplemanager完毕........" | tee -a ${SERVICE_LOG_FILE}
      fi
      if [[ ${num} -lt ${CLUSTER_NODE_NUM} ]]; then
           ssh root@${hostname} "sed -i 's#lts.tasktracker.node-group=.*#lts.tasktracker.node-group=worker-${num}#g' ${PEOPLEMANAGER_INSTALL_DIR}/peoplemanager-worker/conf/application-pro.properties"
           ((num++))
      fi
    done

    rm -rf /opt/GoSunBigData/Service/logs
    echo "配置完毕......" | tee -a ${SERVICE_LOG_FILE}

}

#####################################################################
# 函数名: copy_xml_to_spark
# 描述: 配置Hbase服务，移动所需文件到cluster/spark/conf下
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function copy_xml_to_spark()
{
    echo ""  | tee -a ${SPARK_LOG_FILE}
    echo "**********************************************" | tee -a ${SPARK_LOG_FILE}
    echo "" | tee -a ${SPARK_LOG_FILE}
    echo "copy 文件 hbase-site.xml core-site.xml hdfs-site.xml hive-site.xml到 cluster/conf......"  | tee  -a  ${SPARK_LOG_FILE}

    cp ${HBASE_HOME}/conf/hbase-site.xml ${CONF_SPARK_DIR}
    cp ${HADOOP_HOME}/etc/hadoop/core-site.xml ${CONF_SPARK_DIR}
    cp ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml ${CONF_SPARK_DIR}
    cp ${HIVE_HOME}/conf/hive-site.xml ${CONF_SPARK_DIR}

    echo "copy完毕......"  | tee  -a  ${SPARK_LOG_FILE}
}



#####################################################################
# 函数名: config_sparkjob
# 描述:  配置cluster模块下的sparkjob.properties文件
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_sparkjob()
{
    echo ""  | tee -a ${SPARK_LOG_FILE}
    echo "**********************************************" | tee -a ${SPARK_LOG_FILE}
    echo "" | tee -a ${SPARK_LOG_FILE}
    echo "配置cluster/spark/conf/sparkJob 文件......"  | tee  -a  ${SPARK_LOG_FILE}

    ### 从project-deploy.properties读取sparkJob所需配置IP
    # 根据字段kafka，查找配置文件中，Kafka的安装节点所在IP端口号的值，这些值以分号分割
	KAFKA_IP=$(grep kafka_install_node ${CONF_FILE}|cut -d '=' -f2)
    # 将这些分号分割的ip用放入数组
    spark_arr=(${KAFKA_IP//;/ })
    sparkpro=''
    for spark_host in ${spark_arr[@]}
    do
        sparkpro="${sparkpro}${spark_host}:9092,"
    done
    sparkpro=${sparkpro%?}

    # 替换sparkJob.properties中：key=value（替换key字段的值value）
    sed -i "s#^kafka.metadata.broker.list=.*#kafka.metadata.broker.list=${sparkpro}#g" ${CONF_SPARK_DIR}/sparkJob.properties
    sed -i "s#^job.faceObjectConsumer.broker.list=.*#job.faceObjectConsumer.broker.list=${sparkpro}#g" ${CONF_SPARK_DIR}/sparkJob.properties
    sed -i "s#^job.kafkaToTidb.kafka=.*#job.kafkaToTidb.kafka=${sparkpro}#g" ${CONF_SPARK_DIR}/sparkJob.properties


    # 根据字段zookeeper_installnode，查找配置文件中，Zk的安装节点所在IP端口号的值，这些值以分号分割
    ZK_IP=$(grep zookeeper_installnode ${CONF_FILE}|cut -d '=' -f2)
    # 将这些分号分割的ip用放入数组
    zk_arr=(${ZK_IP//;/ })
    zkpro=''
    for zk_ip in ${zk_arr[@]}
    do
        zkpro="${zkpro}${zk_ip}:2181,"
    done
    zkpro=${zkpro%?}
    # 替换sparkJob.properties中：key=value（替换key字段的值value）
    sed -i "s#^job.zkDirAndPort=.*#job.zkDirAndPort=${zkpro}#g" ${CONF_SPARK_DIR}/sparkJob.properties
    sed -i "s#^job.kafkaToTidb.zookeeper=.*#job.kafkaToTidb.zookeeper=${zkpro}#g" ${CONF_SPARK_DIR}/sparkJob.properties

    #根据字段es_service_node，查找配置文件中，es的安装节点所在ip端口号的值，这些值以分号分割
    ES_IP=$(grep es_service_node ${CONF_FILE} | cut -d '=' -f2)
    #将这些分号分割的ip用于放入数组中
    es_arr=(${ES_IP//;/ })
    espro=${es_arr[0]}
    echo "++++++++++++++++++++++++++++++++++"
    #替换sparkJob.properties中：key=value(替换key字段的值value)
    sed -i "s#^job.kafkaToParquet.esNodes=.*#job.kafkaToParquet.esNodes=${espro}#g" ${CONF_SPARK_DIR}/sparkJob.properties
    sed -i "s#^job.kafkaToTidb.jdbc.ip=.*#job.kafkaToTidb.jdbc.ip=${espro}#g" ${CONF_SPARK_DIR}/sparkJob.properties

    echo "配置完毕......"  | tee  -a  ${SPARK_LOG_FILE}

    echo "开始分发SparkJob文件......"  | tee  -a  ${SPARK_LOG_FILE}
    for spark_hname in ${spark_arr[@]}
    do
        scp -r ${CONF_SPARK_DIR}/sparkJob.properties root@${spark_hname}:${SPARK_HOME}/conf
    done


    ##配置spark standalone模式
    sparknamenode=$(grep 'Spark_NameNode' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    #start-kafka-to-parquet.sh
    sed -i "s#spark://.*#spark://${sparknamenode}:7077 \ #g" ${SPARK_BIN_DIR}/start-kafka-to-parquet.sh
    #start-kafka-to-tidb.sh
    sed -i "s#spark://.*#spark://${sparknamenode}:7077 \ #g" ${SPARK_BIN_DIR}/start-kafka-to-tidb.sh

}


#####################################################################
# 函数名: config_service
# 描述:  配置service模块下的各个子模块的配置文件，启停脚本
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function config_service()
{
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "**************************************************" | tee -a ${SERVICE_LOG_FILE}
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "开始配置service底下的各个模块......" | tee -a ${SERVICE_LOG_FILE}

    #配置kafka.host
    #从project-deploy.properties中读取kafka配置IP
    KAFKA_IP=$(grep kafka_install_node $CONF_FILE | cut -d '=' -f2)
    #将这些分号分割的ip用于放入数组中
    kafka_arr=(${KAFKA_IP//;/ })
    kafkapro=''
    for kafka_host in ${kafka_arr[@]}
    do
      kafkapro=${kafkapro}${kafka_host}":9092,"
    done
    kafkapro=${kafkapro%?}

	#配置es.hosts:
    #从project-deploy.properties中读取es所需配置IP
    #根据字段es，查找配置文件，这些值以分号分隔
    ES_IP=$(grep es_service_node $CONF_FILE | cut -d '=' -f2)
    #将这些分号分割的ip用于放入数组中
    es_arr=(${ES_IP//;/ })
    espro=''
    for es_host in ${es_arr[@]}
    do
       espro="${espro}${es_host},"
    done
    espro=${espro%?}

	#配置zookeeper：
    #从project-deploy.properties中读取zookeeper所需配置IP
    #根据字段zookeeper，查找配置文件，这些值以分号分隔
    ZK_HOSTS=$(grep zookeeper_installnode $CONF_FILE | cut -d '=' -f2)
    zk_arr=(${ZK_HOSTS//;/ })
    zkpro=${zk_arr[0]}":2181"

	#配置eureka_node:
    #从project-deploy.properties中读取eureka_node所需配置ip
    #根据字段eureka_node，查找配置文件，这些值以分号分隔
    EUREKA_NODE_HOSTS=$(grep spring_cloud_eureka_node $CONF_FILE | cut -d '=' -f2)
    eureka_node_arr=(${EUREKA_NODE_HOSTS//;/ })
    eurekapro=''
    for eureka_host in ${eureka_node_arr[@]}
    do
      eurekapro=${eurekapro}${eureka_host}","
    done
    eurekapro=${eurekapro%?}

	#配置eureka_port:
    #从project-deploy.properties中读取eureka_port所需配置port
    #根据字段eureka_port,查找配置文件
    EUREKA_PORT=$(grep spring_cloud_eureka_port $CONF_FILE | cut -d '=' -f2)

	#配置MYSQL
    IS_TIDB=$(grep is_TIDB ${CONF_FILE} | cut -d '=' -f2)
    #从project-deploy.properties中读取mysql所需配置host和port
    MYSQL_HOST=$(grep mysql_host ${CONF_FILE} | cut -d '=' -f2)
    #从project-deploy.properties中读取mysql所需配置username
    MYSQL_USERNAME=$(grep mysql_username ${CONF_FILE} | cut -d '=' -f2)
    #从project-deploy.properties中读取mysql所需配置password
    MYSQL_PASSWORD=$(grep mysql_password ${CONF_FILE} | cut -d '=' -f2)
    if [[ "Xtrue" = "X${IS_TIDB}" ]]; then
        MYSQL_PASSWORD=""
    fi

    ############################    CLOUD   #############################

    ####################################################
	####					PEOPLE					####
	####################################################

	#替换people模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${PEOPLE_START_FILE}
    echo "start-people.sh脚本配置eureka_node完成......."

	#替换people模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${PEOPLE_START_FILE}
    echo "start-people.sh脚本配置eureka_port完成......."

	#替换people模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${PEOPLE_START_FILE}
    echo "start-people.sh脚本配置数据库host完成......."

    #替换people模块启动脚本中的KAFKA_HOST的value
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${PEOPLE_START_FILE}
    echo "start-people.sh脚本配置kafka的host完成......."

	#替换people模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${PEOPLE_START_FILE}
    #echo "start-people.sh脚本配置数据库username完成"

    #替换people模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${PEOPLE_START_FILE}
    #echo "start-people.sh脚本配置数据库password完成"


    ####################################################
	####					DISPATCH	     		####
	####################################################

	#替换dispatch模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${DISPATCH_START_FILE}
    echo "start-dispatch.sh脚本配置eureka_node完成......."

	#替换dispatch模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${DISPATCH_START_FILE}
    echo "start-dispatch.sh脚本配置eureka_port完成......."

    #替换dispatch模块启动脚本中KAFKA_HOST的value
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${DISPATCH_START_FILE}
    echo "start-dispatch.sh脚本配置kafka完成......"

	#替换dispatch模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${DISPATCH_START_FILE}
    echo "start-dispatch.sh脚本配置数据库host完成......."

	#替换dispatch模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${DISPATCH_START_FILE}
    #echo "start-dispatch.sh脚本配置数据库username完成"

    #替换dispatch模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${DISPATCH_START_FILE}
    #echo "start-dispatch.sh脚本配置数据库password完成"


     ####################################################
	####			DISPATCH-BACKGROUND	     		####
	####################################################

	#替换dispatch-background模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${DISPATCH_BACKGROUND_START_FILE}
    echo "start-dispatch-background.sh脚本配置eureka_node完成......."

	#替换dispatch-background模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${DISPATCH_BACKGROUND_START_FILE}
    echo "start-dispatch-background.sh脚本配置eureka_port完成......."

    #替换dispatch-background模块启动脚本中KAFKA_HOST的value
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${DISPATCH_BACKGROUND_START_FILE}
    echo "start-dispatch-background.sh脚本配置kafka完成......"

	#替换dispatch-background模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${DISPATCH_BACKGROUND_START_FILE}
    echo "start-dispatch-background.sh脚本配置数据库host完成......."

	#替换dispatch-background模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${DISPATCH_BACKGROUND_START_FILE}
    #echo "start-dispatch-background.sh脚本配置数据库username完成"

    #替换dispatch-background模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${DISPATCH_BACKGROUND_START_FILE}
    #echo "start-dispatch-background.sh脚本配置数据库password完成"


	####################################################
	####					FUSION					####
	####################################################

	#替换fusion模块中start-fusion.sh脚本中的EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${FUSION_START_FILE}
    echo "start-fusion.sh脚本配置eureka_node完成......."

	#替换fusion模块中start-fusion.sh脚本中的EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${FUSION_START_FILE}
    echo "start-fusion.sh脚本配置eureka_port完成......."

	#替换fusion模块中start-fusion.sh脚本中的kafka字段
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${FUSION_START_FILE}
    echo "start-fusion.sh脚本配置kafka完成......"

    ##替换fusion模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${FUSION_START_FILE}
    echo "start-fusion.sh脚本配置数据库host完成......."

	#替换fusion模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${FUSION_START_FILE}
    #echo "start-fusion.sh脚本配置数据库username完成"

    #替换fusion模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${FUSION_START_FILE}
    #echo "start-fusion.sh脚本配置数据库password完成"


	####################################################
	####	    PEOPLEMANAGER_WORKER				####
	####################################################

	#替换peoplemanager-worker模块启动脚本中KAFKA_HOST的value
    #kafka=`echo ${kafkapro}| cut -d "," -f1`
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${PEOPLEMANAGER_WORKER_START_FILE}
    echo "start-peoman-worker.sh脚本配置kafka完成......"

    #替换start-peoman-worker.sh脚本中的zk的value
    sed -i "s#^ZK_ADDRESS=.*#ZK_ADDRESS=${zk_arr[0]}#g" ${PEOPLEMANAGER_WORKER_START_FILE}
    echo "start-peoman-worker.sh脚本配置zookeeper完成........"

    #替换peoplemanager模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${PEOPLEMANAGER_WORKER_START_FILE}
    echo "start-peoman-worker.sh脚本配置数据库host完成......."

    #替换peoplemanager模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${PEOPLEMANAGER_WORKER_START_FILE}
    #echo "start-peoman-worker.sh脚本配置数据库username完成"

    #替换peoplemanager模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${PEOPLEMANAGER_WORKER_START_FILE}
    #echo "start-peoman-worker.sh脚本配置数据库password完成"


    ####################################################
	####	    PEOPLEMANAGER_CILENT				####
	####################################################

	#替换start-peoman-client.sh脚本中的zk字段
    sed -i "s#^ZK_ADDRESS=.*#ZK_ADDRESS=${zk_arr[0]}#g" ${PEOPLEMANAGER_CLIENT_START_FILE}
    echo "start-peoman-client.sh脚本配置zookeeper完成......."

    #替换peoplemanager模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${PEOPLEMANAGER_CLIENT_START_FILE}
    echo "start-peoman-client.sh脚本配置数据库host完成......."

    #替换peoplemanager模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${PEOPLEMANAGER_CLIENT_START_FILE}
    #echo "start-peoman-client.sh脚本配置数据库username完成"

    #替换peoplemanager模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${PEOPLEMANAGER_CLIENT_START_FILE}
    #echo "start-peoman-client.sh脚本配置数据库password完成"


	####################################################
	####					IMSI					####
	####################################################

	#替换imsi模块启动脚本中BOOTSTRAP_SERVERS的value
    sed -i "s#^BOOTSTRAP_SERVERS=.*#BOOTSTRAP_SERVERS=${kafkapro}#g" ${IMSI_START_FILE}
    echo "start-imsi-dynrepo.sh脚本配置es完成......"

	#替换imsi模块启动脚本中ES_HOST的value
    sed -i "s#^ES_HOST=.*#ES_HOST=${espro}#g" ${IMSI_START_FILE}
    echo "start-imsi-dynrepo.sh脚本配置es完成......"

	#替换imsi模块启动脚本中ZOOKEEPER_HOST的value
    sed -i "s#^ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zkpro}#g" ${IMSI_START_FILE}
    echo "start-imsi.sh脚本配置zookeeper完成......"

	#替换imsi模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${IMSI_START_FILE}
    echo "start-imsi-dynrepo.sh脚本配置eureka_node完成......."

	#替换imsi模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${IMSI_START_FILE}
    echo "start-imsi-dynrepo.sh脚本配置eureka_port完成......."

	#替换imsi模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${IMSI_START_FILE}
    echo "start-imsi-dynrepo.sh脚本配置数据库host完成......."

	#替换imsi-dynrepo模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${IMSI_START_FILE}
    #echo "start-imsi-dynrepo.sh脚本配置数据库username完成"

    #替换imsi-dynrepo模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${IMSI_START_FILE}
    #echo "start-imsi-dynrepo.sh脚本配置数据库password完成"

    ############################    BASIC   #############################

    ####################################################
	####				PERSON-DYNREPO				####
	####################################################


	#替换person-dynrepo模块启动脚本中ES_HOST的value
    sed -i "s#^ES_HOST=.*#ES_HOST=${espro}#g" ${PERSON_DYN_START_FILE}
    echo "start-persoon-dynrepo.sh脚本配置es完成......"

	#替换person-dynrepo模块启动脚本中ZOOKEEPER_HOST的value
    sed -i "s#^ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zkpro}#g" ${PERSON_DYN_START_FILE}
    echo "start-person-dynrepo.sh脚本配置zookeeper完成......"

	#替换person-dynrepo模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${PERSON_DYN_START_FILE}
    echo "start-person-dynrepo.sh脚本配置eureka_node完成......."

	#替换person-dynrepo模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${PERSON_DYN_START_FILE}
    echo "start-person-dynrepo.sh脚本配置eureka_port完成......."


	####################################################
	####				FACE-DYNREPO				####
	####################################################

	#替换face-dynrepo模块启动脚本中ES_HOST的value
    sed -i "s#^ES_HOST=.*#ES_HOST=${espro}#g" ${DYNREPO_START_FILE}
    echo "start-face-dynrepo.sh脚本配置es完成......"

	#替换face-dynrepo模块启动脚本中ZOOKEEPER_HOST的value
    sed -i "s#^ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zkpro}#g" ${DYNREPO_START_FILE}
    echo "start-face-dynrepo.sh脚本配置zookeeper完成......"

	#替换face-dynrepo模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${DYNREPO_START_FILE}
    echo "start-face-dynrepo.sh脚本配置eureka_node完成......."

	#替换face-dynrepo模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${DYNREPO_START_FILE}
    echo "start-face-dynrepo.sh脚本配置eureka_port完成......."


	####################################################
	####			    FACE-DISPATCH				####
	####################################################

	 #替换face-dispatch模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${FACE_DISPATCH_START_FILE}
    echo "start-face-dispatch.sh脚本配置eureka_node完成......."

    #替换face-dispatch模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${FACE_DISPATCH_START_FILE}
    echo "start-face-dispatch.sh脚本配置eureka_port完成......."

    #替换face-dispatch模块启动脚本中KAFKA_HOST的value
    sed -i "s#^KAFKA_HOST=.*#KAFKA_HOST=${kafkapro}#g" ${FACE_DISPATCH_START_FILE}
    echo "start-face-dispatch.sh脚本配置kafka完成......"

	#替换face-dispatch模块启动脚本中MYSQL_HOST的value
    sed -i "s#^MYSQL_HOST=.*#MYSQL_HOST=${MYSQL_HOST}#g" ${FACE_DISPATCH_START_FILE}
    echo "start-face-dispatch.sh脚本配置数据库host完成......."

	#替换face-dispatch模块启动脚本中MYSQL_USERNAME的value
    #sed -i "s#^MYSQL_USERNAME=.*#MYSQL_USERNAME=${MYSQL_USERNAME}#g" ${FACE_DISPATCH_START_FILE}
    #echo "start-face-dispatch.sh脚本配置数据库username完成"

    #替换face-dispatch模块启动脚本中MYSQL_PASSWORD的value
    #sed -i "s#^MYSQL_PASSWORD=.*#MYSQL_PASSWORD=${MYSQL_PASSWORD}#g" ${FACE_DISPATCH_START_FILE}
    #echo "start-face-dispatch.sh脚本配置数据库password完成"


	####################################################
	####					CAR						####
	####################################################

	#替换vehicle-dynrepo模块启动脚本中ES_HOST的value
    sed -i "s#^ES_HOST=.*#ES_HOST=${espro}#g" ${CAR_START_FILE}
    echo "start-vehicle-dynrepo.sh脚本配置es完成......"

	#替换vehicle-dynrepo模块启动脚本中ZOOKEEPER_HOST的value
    sed -i "s#^ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zkpro}#g" ${CAR_START_FILE}
    echo "start-vehicle-dynrepo.sh脚本配置eureka_node完成......."

	#替换vehicle-dynrepo模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${CAR_START_FILE}
    echo "start-vehicle-dynrepo.sh脚本配置eureka_node完成......."

	 #替换vehicle-dynrepo模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${CAR_START_FILE}
    echo "start-vehicle-repo.sh脚本配置eureka_port完成......."


	####################################################
	####					COLLECT					####
	####################################################

    #替换collect模块启动脚本中ZOOKEEPER_HOST的value
    sed -i "s#^ZOOKEEPER_HOST=.*#ZOOKEEPER_HOST=${zkpro}#g" ${COLLECT_START_FILE}
    echo "start-collect.sh脚本配置zookeeper完成......"

   #替换collect模块启动脚本中EUREKA_IP的value
    sed -i "s#^EUREKA_IP=.*#EUREKA_IP=${eurekapro}#g" ${COLLECT_START_FILE}
    echo "start-collect.sh脚本配置eureka_node完成......."

	#替换collect模块启动脚本中EUREKA_PORT的value
    sed -i "s#^EUREKA_PORT=.*#EUREKA_PORT=${EUREKA_PORT}#g" ${COLLECT_START_FILE}
    echo "start-collect.sh脚本配置eureka_port完成......."

}

################################################################################
# 函数名：copy_xml_to_service
# 描述：将hbase-site、core-site、hdfs-site拷贝至需要的模块conf底下
# 参数：N/A
# 返回值：N/A
# 其他：N/A
################################################################################
function copy_xml_to_service()
{
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "**************************************************" | tee -a ${SERVICE_LOG_FILE}
    echo "" | tee -a ${SERVICE_LOG_FILE}
    echo "开始将配置文件拷贝至需要的模块下......" | tee -a ${SERVICE_LOG_FILE}

    cp -r ${CORE_FILE} ${HDFS_FILE} ${HBASE_FILE} ${COLLECT_CONF_DIR}
    cp -r ${CORE_FILE} ${HDFS_FILE} ${HBASE_FILE} ${DYNREPO_CONF_DIR}
    cp -r ${CORE_FILE} ${HDFS_FILE} ${HBASE_FILE} ${PERSON_DYN_CONF_DIR}
    cp -r ${CORE_FILE} ${HDFS_FILE} ${HBASE_FILE} ${FACE_DISPATCH_CONF_DIR}
    cp -r ${CORE_FILE} ${HDFS_FILE} ${HBASE_FILE} ${CAR_CONF_DIR}
}

function config_facecompare(){
    KAFKA_IP_LIST=$(grep Kafka_InstallNode ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    kafkaarr=(${KAFKA_IP_LIST//;/ })
        for kafkahost in ${kafkaarr[@]}
        do
            kafkalist="${kafkahost}:9092,${kafkalist}"
        done
    sed -i "s#kafka.bootstrap.servers=.*#kafka.bootstrap.servers=${kafkalist}#g" ${FACECOMPARE_WORKER_FILE}
    echo "修改worker.properties中kafka完成"

    ZOOKEEPER_IP_LIST=$(grep Zookeeper_InstallNode ${CLUSTER_CONF_FILE} | cut -d "=" -f2)
    zookeeperarr=(${ZOOKEEPER_IP_LIST//;/ })
        for zookeeperhost in ${zookeeperarr[@]}
        do
            zookeeperlist="${zookeeperhost}:2181,${zookeeperlist}"
        done
    sed -i "s#zookeeper.address=.*#zookeeper.address=${zookeeperlist}#g" ${FACECOMPARE_WORKER_FILE}
    echo "修改worker.properties中zookeeper完成"
    sed -i "s#zookeeper.address=.*#zookeeper.address=${zookeeperlist}#g" ${FACECOMPARE_MASTER_FILE}
    echo "修改master.properties中zookeeper完成"

    ES_IP=$(grep ES_InstallNode ${CLUSTER_CONF_FILE} | cut -d "=" -f2 | cut -d ";" -f1)
    sed -i "s#es.hosts=.*#es.hosts=${ES_IP}#g" ${FACECOMPARE_WORKER_FILE}
    echo "修改worker.properties中es完成"

}

function distribute_facecompare(){
    CLUSTERNODELIST=$(grep 'Cluster_HostName' ${CLUSTER_CONF_FILE} | cut -d '=' -f2)
    CLUSTERNODE=(${CLUSTERNODELIST//;/ })
    CLUSTER_NODE_NUM=${#CLUSTERNODE[@]}
    num=1
    for node in ${CLUSTERNODE[@]} ;do
        if [[ -x "${FACECOMPARE_INSTALL_DIR}" ]]; then
            ssh root@${node} "mkdir -p ${CLUSTER_INSTALL_DIR}"
        fi
        scp -r ${FACECOMPARE_DIR} root@${node}:${CLUSTER_INSTALL_DIR}
        ssh root@${node} "sed -i 's#master.ip=.*#master.ip=${node}#g' ${FACECOMPARE_INSTALL_DIR}/conf/master.properties"
        ssh root@${node} "sed -i 's#worker.address=.*#worker.address=${node}#g' ${FACECOMPARE_INSTALL_DIR}/conf/worker.properties"


        if [[ ${num} -lt ${CLUSTER_NODE_NUM} ]]; then
            ssh root@${node} "sed -i 's#tasktracker.group=.*#tasktracker.group=facecompare-compareTask${num}#g' ${FACECOMPARE_INSTALL_DIR}/conf/worker.properties"
            ((num++))
        fi
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
  config_projectconf      ##配置project-deploy.properties
  ## cluster模块
  copy_xml_to_spark       ##复制集群xml文件到cluster/spark目录下
  config_sparkjob         ##配置sparkjob.properties
  ## service模块
  config_service          ##配置service各个子模块的配置文件及启停脚本
  copy_xml_to_service     ##复制集群xml文件到各个子模块的conf下
  distribute_service      ##分发service模块

  config_facecompare
  distribute_facecompare
#  cp -f ${CONF_FILE} ${COMMON_DIR}/conf/
#  ditribute_common
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


