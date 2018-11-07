package com.hzgc.service.collect.config;

import com.hzgc.common.collect.facedis.FtpRegisterClient;
import com.hzgc.common.collect.facesub.FtpSubscribeClient;
import com.hzgc.common.service.carattribute.service.CarAttributeService;
import com.hzgc.service.collect.model.FtpInfo;
import com.hzgc.common.service.faceattribute.service.AttributeService;
import com.hzgc.common.service.personattribute.service.PersonAttributeService;
import com.hzgc.service.collect.model.FtpInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class BeanConfig {
    @Autowired
    private Environment environment;

    @Bean
    public FtpRegisterClient register() {
        return new FtpRegisterClient(environment.getProperty("zk.address"));
    }

    @Bean
    public FtpSubscribeClient subscribe() {
        return new FtpSubscribeClient(environment.getProperty("zk.address"));
    }

    @Bean
    AttributeService attributeService() {
        return new AttributeService();
    }

    @Bean
    PersonAttributeService personAttributeService() {
        return new PersonAttributeService();
    }

    @Bean
    CarAttributeService carAttributeService() {
        return new CarAttributeService();
    }

    @Bean
    FtpInfo ftpInfo() {return new FtpInfo();}
}

