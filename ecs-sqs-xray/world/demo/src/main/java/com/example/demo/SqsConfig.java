package com.example.demo;

import io.awspring.cloud.sqs.config.SqsMessageListenerContainerFactory;
import io.awspring.cloud.sqs.listener.MessageListenerContainer;
import io.awspring.cloud.sqs.listener.SqsMessageListenerContainer;
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

    @Bean
    MessageListenerContainer<Object> listenerContainer(SqsAsyncClient sqsAsyncClient) {
        SqsMessageListenerContainer<Object> container = new SqsMessageListenerContainer<>(sqsAsyncClient);
        container.setMessageListener(System.out::println);
        container.setQueueNames("demo.fifo");
        return container;
    }

    @Bean
    SqsMessageListenerContainerFactory<Object> defaultSqsListenerContainerFactory(SqsAsyncClient sqsAsyncClient) {
        SqsMessageListenerContainerFactory<Object> factory = new SqsMessageListenerContainerFactory<>();
        factory.setSqsAsyncClient(sqsAsyncClient);
        return factory;
    }

}
