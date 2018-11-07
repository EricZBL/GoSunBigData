#!/usr/bin/env bash

cd `dirname $0`
HOME_DIR=`pwd`
VERSION_INFO=2.3.0
IMAGE_NAME=dispatch-background
DOCKER_REPO=172.18.18.122
DATE_YMD=`date +%Y-%m-%d`
DATE_HMS=`date +%H:%m:%S`
DATE_YMD_HMS="$DATE_YMD  $DATE_HMS"
if [ -n "$VERSION_INFO" ]; then
    exec docker build -t $DOCKER_REPO/hzgc/$IMAGE_NAME:$VERSION_INFO -f Dockerfile ./
else
    echo "$DATE_YMD_HMS version info is null, please check"
fi