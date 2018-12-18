package com.hzgc.cluster.dispatch;

import com.hzgc.common.service.api.config.EnableInnerService;
import com.hzgc.common.service.api.config.EnablePlatformService;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//import org.springframework.cloud.netflix.eureka.EnableEurekaClient;


@SpringBootApplication
@EnablePlatformService
@EnableAutoConfiguration
//@EnableEurekaClient
@EnableInnerService
@MapperScan("com.hzgc.cluster.dispatch.dao")
public class DispatchApplication {
    public static void main(String[] args) {
        SpringApplication.run(DispatchApplication.class, args);

    }
}
