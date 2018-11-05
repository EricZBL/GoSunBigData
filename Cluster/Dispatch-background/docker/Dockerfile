#指定镜像
FROM 172.18.18.122/hzgc/java:8

#设置环境变量
ENV PATH /usr/local/bin:$PATH
ENV JAR_VERSION 2.3.0

#操作文件
COPY docker-entrypoint.sh /usr/local/bin/
COPY dispatch-background-${JAR_VERSION}.jar /app.jar

#执行命令
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

#初始化参数并启动Springboot应用
ENTRYPOINT ["/bin/sh","-c","docker-entrypoint.sh"]
