package com.hzgc.service;

import com.hzgc.common.service.api.config.EnableInnerService;
import com.hzgc.common.service.api.config.EnablePlatformService;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableEurekaClient
@EnablePlatformService
@EnableTransactionManagement
@EnableInnerService
@MapperScan(basePackages = {"com.hzgc.service.people.dao", "com.hzgc.service.community.dao"})
public class PeopleApplication {
    public static void main(String[] args) {
        SpringApplication.run(PeopleApplication.class, args);
    }
}

