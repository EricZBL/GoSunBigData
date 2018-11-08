#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    create-all.sh
## Description: 一键创建静态库和动态库的表
## Author:      mashencai
## Created:     2017-11-30
################################################################################
#set -x  ## 用于调试用，不用的时候可以注释掉

#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#
cd `dirname $0`
BIN_DIR=`pwd`                                          ### bin目录：脚本所在目录

sh ${BIN_DIR}/create-elasticsearch-index.sh
sh ${BIN_DIR}/create-kafka-topic.sh
sh ${BIN_DIR}/create-sparksql-table.sh
sh ${BIN_DIR}/create-spark-udf.sh
sh ${BIN_DIR}/create-people-table.sh

set +x
