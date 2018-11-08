#!/bin/bash
################################################################################
## Copyright:   HZGOSUN Tech. Co, BigData
## Filename:    delete_env_variable_extended_.sh
## Description: 删除扩展节点的/etc/profile中的Java环境变量
## Version:     2.4
## Author:      yinhang
## Created:     2018-07-06
################################################################################
## set -x  ## 用于调试用，不用的时候可以注释掉
#set -e
#---------------------------------------------------------------------#
#                              定义变量                                #
#---------------------------------------------------------------------#
cd `dirname $0`
## 脚本所在目录
BIN_DIR=`pwd`
cd ../..
## ClusterBuildScripts 目录
CLUSTER_BUILD_SCRIPTS_DIR=`pwd`
## 配置文件目录
CONF_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/expand/conf
## 日记目录
LOG_DIR=${CLUSTER_BUILD_SCRIPTS_DIR}/logs
## 日记文件
LOG_FILE=${LOG_DIR}/delete_env_variable_extended.log
##etc所在目录
ETC_FILE=/opt/source
## 集群所有节点主机名，放入数组中
CLUSTER_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties | cut -d '=' -f2)
HOSTNAMES=(${CLUSTER_HOST//;/ })

echo "-------------------------------------" | tee  -a $LOG_FILE
echo "准备进行 删除各个节点上/etc/profile中的Java环境变量操作 ing~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE

mkdir -p ${LOG_DIR}

#####################################################################
# 函数名: delete_java_variable
# 描述: 删除各个节点上/etc/profile中的Java环境变量
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function delete_java_variable
{
	echo ""  | tee -a $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE
	echo "please waitinng, 删除java环境变量........"  | tee -a $LOG_FILE
	# 从配置文件中获取jdk安装节点
	for jdk_host in ${HOSTNAMES[@]}
	do
		# java变量的注释行“#JAVA_HOME”是否存在，存在则删除
		javaComments_exists=$(ssh root@${jdk_host} 'grep "#JAVA_HOME" /etc/profile')
		if [ "${javaComments_exists}" != "" ];then
			ssh root@${jdk_host} "sed -i '/#JAVA_HOME/d' /etc/profile"
		fi
		# java变量的“export JAVA_HOME=”行是否存在，存在则删除
		javahome_exists=$(ssh root@${jdk_host} 'grep "export JAVA_HOME=" /etc/profile')
		if [ "${javahome_exists}" != "" ];then
			ssh root@${jdk_host} "sed -i '/export JAVA_HOME=/d' /etc/profile"
		fi
		# java变量的“export PATH=$JAVA_HOME”行是否存在，存在则删除
		javapath_exists=$(ssh root@${jdk_host} 'grep "export PATH=\$JAVA_HOME" /etc/profile')
		if [ "${javapath_exists}" != "" ];then
			ssh root@${jdk_host} "sed -i '/export PATH=\$JAVA_HOME/d' /etc/profile"
		fi
	done
	echo "删除java环境变量完成........"  | tee -a $LOG_FILE
}

#####################################################################
# 函数名: delete_namesrv_variable
# 描述: 删除各个节点上/etc/profile中的NAMESRV_ADDR环境变量
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function delete_namesrv_variable
{
	echo ""  | tee -a $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE
	echo "please waitinng, 删除namesrv环境变量........"  | tee -a $LOG_FILE
	## 拼接安装了Rocketmq的节点IP
	Broker_Hosts=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
	Broker_Hostarr=(${Broker_Hosts//;/ })

	for insName in ${Broker_Hostarr[@]}
	do
		# 判断是否存在export NAMESRV_ADDR=172.18.18.108:9876这一行，若存在删除
		namesrv_exists=$(ssh root@${insName} 'grep "export NAMESRV_ADDR=" /etc/profile')
		if [ "${namesrv_exists}" != "" ];then
			ssh root@${insName} "sed -i '/export NAMESRV_ADDR=/d' /etc/profile"
		fi
	done
	echo "删除namesrv环境变量完成........"  | tee -a $LOG_FILE
}

#####################################################################
# 函数名: delete_openblas_num_variable
# 描述: 删除各个节点上/etc/profile中的OPENBLAS_NUM_THREADS环境变量
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function delete_openblas_num_variable
{
	echo ""  | tee -a $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE
	echo "please waitinng, 删除openblas_num环境变量........"  | tee -a $LOG_FILE
	## 获取配置算法节点IP
	GsFaceLib_Host=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
	gsFaceLib_arr=(${GsFaceLib_Host//;/ })
	for gsFaceLib_host in ${HOSTNAMES[@]}
	do
		# 判断是否存在export OPENBLAS_NUM_THREADS=1这一行，若存在删除
		openblas_num_exists=$(ssh root@${gsFaceLib_host} 'grep "export OPENBLAS_NUM_THREADS=" /etc/profile')
		if [ "${openblas_num_exists}" != "" ];then
			ssh root@${insName} "sed -i '/export OPENBLAS_NUM_THREADS=/d' /etc/profile"
		fi
	done
	echo "删除openblas_num环境变量完成........"  | tee -a $LOG_FILE
}


#####################################################################
# 函数名: delete_gsfacelib_variable
# 描述: 删除各个节点上/etc/profile中的gsfacelib环境变量
# 参数: N/A
# 返回值: N/A
# 其他: N/A
#####################################################################
function delete_gsfacelib_variable
{
	echo ""  | tee -a $LOG_FILE
	echo "**********************************************" | tee -a $LOG_FILE
	echo "please waitinng, 删除gsfacelib环境变量........"  | tee -a $LOG_FILE
	# 从配置文件中获取gsfacelib算法安装节点
	GSFACELIB_HOST=$(grep Node_HostName ${CONF_DIR}/expand_conf.properties|cut -d '=' -f2)
	gsfacelibhost_arr=(${GSFACELIB_HOST//;/ })
	for gsfacelib_host in ${gsfacelibhost_arr[@]}
	do
		# gsfacelib算法的注释行“#LD_LIBRARY_PATH”是否存在，存在则删除
		facelibComments_exists=$(ssh root@${gsfacelib_host} 'grep "#LD_LIBRARY_PATH" /etc/profile')
		if [ "${facelibComments_exists}" != "" ];then
			ssh root@${gsfacelib_host} "sed -i '/#LD_LIBRARY_PATH/d' /etc/profile"
		fi
		# gsfacelib算法的“export LD_LIBRARY_PATH=”行是否存在，存在则删除
		facelibpath_exists=$(ssh root@${gsfacelib_host} 'grep "export LD_LIBRARY_PATH=" /etc/profile')
		if [ "${facelibpath_exists}" != "" ];then
			ssh root@${gsfacelib_host} "sed -i '/export LD_LIBRARY_PATH=/d' /etc/profile"
		fi
	done
	echo "删除gsfacelib环境变量完成........"  | tee -a $LOG_FILE
}

function main ()
{
	delete_java_variable
	delete_namesrv_variable
	delete_gsfacelib_variable
	delete_openblas_num_variable
}

echo ""  | tee  -a  $LOG_FILE
echo ""  | tee  -a  $LOG_FILE
echo "==================================================="  | tee -a $LOG_FILE
echo "$(date "+%Y-%m-%d  %H:%M:%S")"   | tee -a $LOG_FILE

main
echo "-------------------------------------" | tee  -a $LOG_FILE
echo "删除各个节点上/etc/profile中的Java环境变量操作完成 zzZ~" | tee  -a $LOG_FILE
echo "-------------------------------------" | tee  -a $LOG_FILE