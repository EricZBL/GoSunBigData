#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    expandEnv.sh
## Description: 安装环境的脚本.
## Version:     2.0
## Author:      zhangbaolin
## Created:     2018-7-2
################################################################################
#set -e
#set -x

cd `dirname $0`
## BIN目录，脚本所在的目录
BIN_DIR=`pwd`
cd ../..
## 安装包根目录
ROOT_HOME=`pwd`
## 配置文件目录
CONF_DIR=${ROOT_HOME}/conf

cd ${BIN_DIR}

## 安装dos2unix
sh dos2unixExpand.sh

## 安装expect
sh expectExpand.sh

## 配置免密登录
sh sshCilentLogin.sh

## 分发host
sh distributionHosts.sh

## 删除环境变量
sh delete_env_variable_expand.sh

## 关闭防火墙
sh offIptables_expand.sh

## 安装JDK
sh expand_jdk.sh
