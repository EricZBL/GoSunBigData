package com.hzgc.service.dynrepo.config;

import com.hzgc.common.service.faceattribute.service.AttributeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class BeanConfig {
    @Autowired
    @SuppressWarnings("unused")
    private Environment environment;

    @Bean
    AttributeService attributeService() {
        return new AttributeService();
    }
}
