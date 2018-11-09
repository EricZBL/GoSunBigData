#!/bin/bash

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
##  docker 安装包目录
DOCKER_RPM_DIR=${BIN_DIR}/basic_suports/docker
## dos2unix rpm 软件目录
DOS2UNIX_RPM_DIR=${BIN_DIR}/basic_suports/dos2unixRpm

##安装dos2unix
echo "==================================================="
echo "$(date "+%Y-%m-%d  %H:%M:%S")"
echo "intall dos2unix ...... "
rpm -ivh ${DOS2UNIX_RPM_DIR}/dos2unix-6.0.3-7.el7.x86_64.rpm

##把执行脚本的节点上的脚本转成unix编码
dos2unix `find ${BIN_DIR} -name '*.sh' -or -name '*.properties'`
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