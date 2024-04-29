package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsAsyncClient;
import software.amazon.awssdk.services.sqs.SqsClient;

@Configuration
public class SqsConfig {
    @Bean
    public SqsClient getSqsClient() {
        return SqsClient.builder()
                .region(Region.of(System.getenv("AWS_REGION")))
                .build();
    }
}
