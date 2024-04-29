package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;

@Configuration
public class DbConfig {
    @Bean
    public DynamoDbClient getDynamoDBClient(){
        return DynamoDbClient.builder()
                .region(Region.of(System.getenv("AWS_REGION")))
                .build();

    }

}
