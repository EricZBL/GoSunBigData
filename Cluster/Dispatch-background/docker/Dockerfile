#指定镜像
FROM 172.18.18.122/hzgc/java:8

#操作文件
COPY docker-entrypoint.sh /usr/local/bin/
COPY dispatch-background.jar /app.jar

#执行命令
RUN chmod +x /docker-entrypoint.sh

#初始化参数并启动Springboot应用
ENTRYPOINT ["/bin/sh","/docker-entrypoint.sh"]