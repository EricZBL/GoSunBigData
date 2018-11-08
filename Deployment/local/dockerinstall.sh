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

cd ${DOCKER_RPM_DIR}
./bin/docker-ce.sh

cp -pf ${DOCKER_RPM_DIR}/compose/docker-compose /usr/local/bin/docker-compose