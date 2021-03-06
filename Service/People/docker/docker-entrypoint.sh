#!/bin/bash

exec java -jar app.jar \
--spring.profiles.active=pro \
--spring.cloud.config.enabled=false \
--eureka.ip=${EUREKA_IP} \
--eureka.port=${EUREKA_PORT} \
--mysql.host=${MYSQL_HOST} \
--mysql.username=${MYSQL_USERNAME} \
--mysql.password=${MYSQL_PASSWORD} \
--kafka.host=${KAFKA_HOST}

