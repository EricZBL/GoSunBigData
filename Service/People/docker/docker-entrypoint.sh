#!/usr/bin/env bash

exec java -jar app.jar --spring.profiles.active=pro --spring.cloud.config.enabled=false --eureka.ip=${EUREKA_IP} --zookeeper.host=${ZOOKEEPER_HOST} --eureka.port=${EUREKA_PORT} --mysql.host=${MYSQL_HOST} --mysql.username=${MYSQL_USERNAME}
