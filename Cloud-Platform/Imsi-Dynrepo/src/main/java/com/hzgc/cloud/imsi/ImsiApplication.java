package com.hzgc.cloud.imsi;

import com.hzgc.common.service.api.config.EnablePlatformService;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@EnableEurekaClient
@EnableSwagger2
@SpringBootApplication
@MapperScan(value = "com.hzgc.cloud.imsi.dao")
@EnableTransactionManagement
@EnableKafka
@EnablePlatformService
public class ImsiApplication {

    public static void main(String[] args) {
        SpringApplication.run(ImsiApplication.class, args);
    }
}
