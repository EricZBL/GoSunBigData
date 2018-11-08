#!/bin/bash
################################################################################
## Copyright:    HZGOSUN Tech. Co, BigData
## Filename:     hiveInstall.sh
## Description:  安装 hive
## Version:      1.0
## Hive.Version: 2.3.0
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-06-28
################################################################################
#set -e
#set -x

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
## 安装日记目录
LOG_DIR=${ROOT_HOME}/logs
## 安装日记目录
LOG_FILE=${LOG_DIR}/hiveInstall.log
## hive 安装包目录
HIVE_SOURCE_DIR=${ROOT_HOME}/component/bigdata
## 集群组件的日志文件目录 /opt/logs
LOGS_PATH=$(grep Cluster_LOGSDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
HIVE_LOG_PATH=${LOGS_PATH}/hive
## 最终安装的根目录，所有bigdata 相关的根目录
INSTALL_HOME=$(grep Install_HomeDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## hive的安装节点，放入数组中
HIVE_HOSTNAME_LISTS=$(grep Meta_ThriftServer ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
HIVE_HOSTNAME_ARRY=(${HIVE_HOSTNAME_LISTS//;/ })
HOST1=${HIVE_HOSTNAME_ARRY[0]}
## 集群扩展的节点
EXPAND_NODE=$(grep Node_HostName ${EXPAND_CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
EXPAND_NODE_ARRY=(${EXPAND_NODE//;/ })

# HIVE_INSTALL_HOME hive 安装目录
HIVE_INSTALL_HOME=${INSTALL_HOME}/Hive
## HIVE_HOME  hive 根目录
HIVE_HOME=${INSTALL_HOME}/Hive/hive

## <value>
VALUE="<value>"
## </value>
VALUE_END="</value>"

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 hive 扩展安装操作 ing~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

if [ ! -d $LOG_DIR ];then
    mkdir -p $LOG_DIR;
fi

## 打印当前时间
echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"                       | tee  -a  $LOG_FILE


mkdir -p ${HIVE_INSTALL_HOME}

function sync_hive()
{
## HIVE配置文件分发

echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "hive 配置文件分发中，please waiting......"    | tee -a $LOG_FILE
for hostname in ${EXPAND_NODE_ARRY[@]}
do
    ssh root@${hostname}  "mkdir -p ${HIVE_INSTALL_HOME}"
    rsync -rvl ${HIVE_HOME}   root@${hostname}:${HIVE_INSTALL_HOME}  >/dev/null
    ssh root@${hostname}  "chmod -R 755   ${HIVE_HOME}"
    ssh root@${hostname} "mkdir -p ${HIVE_LOG_PATH};chmod -R 777 ${HIVE_LOG_PATH}"
done
    echo "分发hive 安装配置done..."  | tee -a $LOG_FILE
}


function config_conf ()
{
    ####################################################################
    ##
    ## 修改/bin/beeline脚本，使Hive/bin/beeline在执行$>beeline命令时，
    ## 能直接进到jdbc:hive://s103:2181$>下；
    ## 可以自动读取节点的Ip，不需手动修改；
    ## 已修改hive.tar.gz压缩包中beeline文件，添加了一行：
    ## jdbc:hive2://hostnameportlist/;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2
    ##
    ####################################################################
    tmp=""
    for insName in ${HIVE_HOSTNAME_ARRY[@]}
    do
        echo "修改${insName}上的beeline"

          for hostname in ${EXPAND_NODE_ARRY[@]}
          do
             old_tmp=`ssh root@$insName "grep beeline ${HIVE_HOME}/bin/beeline | cut -d ' ' -f6|cut -d '/' -f3"`
             echo $old_tmp
             tmp=(${hostname}:2181)
             if [[ ${old_tmp} =~ ${tmp} ]];then
               echo "${insName}  beeline中已存在${tmp}"
             else
               ssh root@$insName "sed -i 's#${old_tmp}#${old_tmp}\,${tmp}#g'  ${HIVE_HOME}/bin/beeline"
             fi
         done
    done

    ## 配置zookeeper、hive matestore集群地址
    hazk=""
    hith=""
    for insName in ${HIVE_HOSTNAME_ARRY[@]}
    do
        hazk="${hazk}${insName}:2181,"
        hith="${hith}thrift://${insName}:9083,"
    done
    for insName in ${HIVE_HOSTNAME_ARRY[@]}
    do
        echo ""  | tee  -a  $LOG_FILE
        echo ""  | tee  -a  $LOG_FILE
        echo "==================================================="  | tee -a $LOG_FILE
        echo "修改hiveserver2 WEBUI地址 in ${insName}目录...... "  | tee -a $LOG_FILE
        NUM=$[`grep -n hive.zookeeper.quorum ${HIVE_HOME}/conf/hive-site.xml | cut -d " " -f1| cut -d ':' -f1`+1]
        ssh root@$insName "sed -i '${NUM}c ${VALUE}${hazk%?}${VALUE_END}'  ${HIVE_HOME}/conf/hive-site.xml"
        NUM=$[`grep -n hive.metastore.uris ${HIVE_HOME}/conf/hive-site.xml | cut -d " " -f1| cut -d ':' -f1`+1]
        ssh root@$insName "sed -i '${NUM}c ${VALUE}${hith%?}${VALUE_END}'  ${HIVE_HOME}/conf/hive-site.xml"
    done


    ## 修改hiveserver2 webUI地址
    for insName in ${HIVE_HOSTNAME_ARRY[@]}
    do
        echo ""  | tee  -a  $LOG_FILE
        echo ""  | tee  -a  $LOG_FILE
        echo "==================================================="  | tee -a $LOG_FILE
        echo "修改hiveserver2 WEBUI地址 in {$insName}目录...... "  | tee -a $LOG_FILE
        NUM=$[`grep -n hive.server2.webui.bind.host ${HIVE_HOME}/conf/hive-site.xml| cut -d ':' -f1`+1]
        ##${VALUE}$insName${VALUE_END}
        ssh root@$insName "sed -i '${NUM}c ${VALUE}${insName}${VALUE_END}' ${HIVE_HOME}/conf/hive-site.xml"
    done


    ## 修改hiveserver2 thrift UI地址
    for insName in ${HIVE_HOSTNAME_ARRY[@]}
    do
        echo ""  | tee  -a  $LOG_FILE
        echo ""  | tee  -a  $LOG_FILE
        echo "==================================================="  | tee -a $LOG_FILE
        echo "修改hiveserver2 thrift 地址 in ${insName}目录...... "  | tee -a $LOG_FILE
        NUM=$[`grep -n hive.server2.thrift.bind.host ${HIVE_HOME}/conf/hive-site.xml| cut -d ':' -f1`+1]
        ssh root@$insName "sed -i '${NUM}c ${VALUE}${insName}${VALUE_END}' ${HIVE_HOME}/conf/hive-site.xml"
    done
        echo "hive 安装完成......"  | tee  -a  $LOG_FILE
}


function writeUI_file()
{
    ## 将Hive的UI地址写到指定文件中
    echo ""  | tee -a $LOG_FILE
    echo "**********************************************" | tee -a $LOG_FILE
    echo "准备将hive的UI地址写到指定文件中............"    | tee -a $LOG_FILE
    HiveWebUI_Dir=$(grep WebUI_Dir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
    Host_IP=$(cat /etc/hosts|grep "$HOST1" | awk '{print $1}')
    Hive_UI="http://${Host_IP}:10002"
    mkdir -p ${HiveWebUI_Dir}
    grep -q "HiveUI_Address=" ${HiveWebUI_Dir}/WebUI_Address
    if [ "$?" -eq "0" ]  ;then
        sed -i "s#^HiveUI_Address=.*#HiveUI_Address=${Hive_UI}#g" ${HiveWebUI_Dir}/WebUI_Address
    else
        echo "##Hive_WebUI" >> ${HiveWebUI_Dir}/WebUI_Address
        echo "HiveUI_Address=${Hive_UI}" >> ${HiveWebUI_Dir}/WebUI_Address
    fi
}

## 初始化元数据
#ssh root@${MYSQL_INSTALLNODE} "${HIVE_HOME}/bin/schematool -initSchema -dbType mysql"

function main()
{
    sync_hive
    config_conf
    writeUI_file
}
main
echo "-------------------------------------" | tee  -a $LOG_FILE
echo " hive 扩展安装操作完成 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE
set +x
