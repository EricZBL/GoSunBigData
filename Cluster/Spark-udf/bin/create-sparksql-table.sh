#!/bin/bash
################################################################################
## Copyright:    HZGOSUN Tech. Co, BigData
## Filename:     create-sparksql-table.sh
## Description:  创建动态库表的所有索引
## Author:       chenke
## Created:      2017-11-28
################################################################################

#set -x
#---------------------------------------------------------------------#
#                              定义变量                               #
#---------------------------------------------------------------------#
cd `dirname $0`
BIN_DIR=`pwd`                                   ### bin 目录

cd ../..
SCRIPT_DIR=`pwd`
CONF_FILE=${SCRIPT_DIR}/conf/project-conf.properties
## bigdata cluster path
BIGDATA_CLUSTER_PATH=$(grep install_homedir ${CONF_FILE} |cut -d '=' -f2)
## bigdata hive path
SPARK_PATH=${BIGDATA_CLUSTER_PATH}/Spark/spark

#####################################################################
# 函数名: create_person_table_mid_table
# 描述: 创建person表， mid_table 表格
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function create_person_table_mid_table() {
    ${SPARK_PATH}/bin/spark-sql -e "CREATE EXTERNAL TABLE IF NOT EXISTS default.person_table( \
                                    ftpurl        string, \
                                    ipcid         string, \
                                    feature       array<float>, \
                                    eyeglasses    int, \
                                    gender        int, \
                                    haircolor     int, \
                                    hairstyle     int, \
                                    hat           int, \
                                    huzi          int, \
                                    tie           int, \
                                    timeslot      int, \
                                    exacttime     Timestamp, \
                                    searchtype    string, \
                                    sharpness     int) \
                                    partitioned by (date string) \
                                    STORED AS PARQUET \
                                    LOCATION '/user/hive/warehouse/person_table';
                                    CREATE EXTERNAL TABLE IF NOT EXISTS default.mid_table( \
                                    ftpurl        string, \
                                    feature       array<float>, \
                                    eyeglasses    int, \
                                    gender        int, \
                                    haircolor     int, \
                                    hairstyle     int, \
                                    hat           int, \
                                    huzi          int, \
                                    tie           int, \
                                    timeslot      int, \
                                    exacttime     Timestamp, \
                                    searchtype    string, \
                                    date          string, \
                                    ipcid         string, \
                                    sharpness     int) \
                                    STORED AS PARQUET \
                                    LOCATION '/user/hive/warehouse/mid_table';
                                    show tables"

    if [ $? == 0 ];then
            echo "===================================="
            echo "创建person_table,mid_table成功"
            echo "===================================="
    else
            echo "========================================================="
            echo "创建person_table,mid_table失败,请看日志查找失败原因......"
            echo "========================================================="
    fi
}

function main() {
    create_person_table_mid_table
}

main