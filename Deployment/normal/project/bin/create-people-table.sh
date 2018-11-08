#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    create-people-table.sh
## Description: 创建数据库表结构
## Author:      liangshiwei
## Created:     2018-10-15
################################################################################
#set -x  ## 用于调试用，不用的时候可以注释掉
#set -e

cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
CONF_DIR=${BIN_DIR}/../conf
SQL_DIR=${BIN_DIR}/../sql
CONF_FILE=${CONF_DIR}/project-deploy.properties
MYSQL_HOST=$(grep mysql_host ${CONF_FILE} | cut -d '=' -f2)
MYSQL_IP=`echo ${MYSQL_HOST} | cut -d ':' -f1`
MYSQL_PORT=`echo ${MYSQL_HOST} | cut -d ':' -f2`
MYSQL_USER=$(grep mysql_user ${CONF_FILE}  | cut -d '=' -f2)
MYSQL_PASSWORD=$(grep mysql_password ${CONF_FILE} | cut -d '=' -f2)

IS_TIDB=$(grep is_TIDB ${CONF_FILE} | cut -d '=' -f2)

if [[ -z ${IS_TIDB} ]]; then
    PASSWORD="-pHzgc@123"
fi

mysql -h ${MYSQL_IP} -u ${MYSQL_USER} -P ${MYSQL_PORT} ${PASSWORD} << EOF
source ${SQL_DIR}/peopleDatabase.sql;
EOF


#--------------------------------------------------------------------------#
#                                  执行流程                                #
#--------------------------------------------------------------------------#
##打印时间
echo ""
echo "=========================================================="
echo "$(date "+%Y-%m-%d  %H:%M:%S")"

set +x


