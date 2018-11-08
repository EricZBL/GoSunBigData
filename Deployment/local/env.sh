#!/bin/bash

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf
##  docker 安装包目录
DOCKER_RPM_DIR=${ROOT_HOME}/component/basic_suports/docker

## dos2unix rpm 软件目录
DOS2UNIX_RPM_DIR=${ROOT_HOME}/component/basic_suports/dos2unixRpm
## 基础工具安装路径
INSTALL_HOME_BASIC=$(grep System_SuportDir ${CONF_DIR}/cluster_conf.properties|cut -d '=' -f2)
## dos2unix rpm 软件最终目录
DOS2UNIX_RPM_INSTALL_HOME=${INSTALL_HOME_BASIC}/dos2unixRpm

##安装dos2unix
echo "==================================================="
echo "$(date "+%Y-%m-%d  %H:%M:%S")"
echo "intall dos2unix ...... "
mkdir -p  ${DOS2UNIX_RPM_INSTALL_HOME}
cp  -r  ${DOS2UNIX_RPM_DIR}/* ${DOS2UNIX_RPM_INSTALL_HOME}  > /dev/null
if [ $? == 0 ];then
    echo "cp dos2unix to the ${DOS2UNIX_RPM_INSTALL_HOME} done !!!"
else
    echo "cp dos2unix to the ${DOS2UNIX_RPM_INSTALL_HOME} failed !!!"
fi
rpm -ivh ${DOS2UNIX_RPM_INSTALL_HOME}/dos2unix-3.1-37.el6.x86_64.rpm; which dos2unix; rm -rf ${INSTALL_HOME_BASIC}

##把执行脚本的节点上的脚本转成unix编码
dos2unix `find ${ROOT_HOME} -name '*.sh' -or -name '*.properties'`
dos2unix ${ROOT_HOME}/tool/*
echo "转换脚本编码格式完成"

####关闭防火墙，设置selinux为disable
echo "==================================================="
echo "$(date "+%Y-%m-%d  %H:%M:%S")"

echo "准备关闭防火墙"
sed -i "s;enforcing;disabled;g" /etc/selinux/config
setenforce 0
systemctl stop firewalld.service
systemctl disable firewalld.service
echo "关闭防火墙成功。"

### 查看selinux状态，若为enable则需要重启
echo "**********************************************"
echo "正在查看SELinux状态"
STATUS=`getenforce`
if [[ "x$STATUS" = "xenabled" ]]; then
    echo "selinux状态为enable"
    exit 1
    else
    echo "selinux状态为disabled"
fi

## 安装docker
echo "开始安装docker"
cd ${DOCKER_RPM_DIR}
./bin/docker-ce.sh
echo "docker安装完成"

## 安装docker-compose
echo "开始安装docker-compose"
cp -pf ${DOCKER_RPM_DIR}/compose/docker-compose /usr/local/bin/docker-compose
echo "docker-compose安装完成"