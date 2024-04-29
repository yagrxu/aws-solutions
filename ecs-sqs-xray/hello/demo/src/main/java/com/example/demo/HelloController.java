package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.*;

import java.util.UUID;

@RestController
public class HelloController {

    @Autowired
    private SqsClient sqsClient;

    @GetMapping("health")
    String getHealth(){
        return "OK";
    }

    @GetMapping("message/{info}")
    String sayHello(@PathVariable String info){
        SendMessageResponse response = sendMessage(sqsClient, System.getenv("QUEUE_URL"), info);
        if(response != null){
            System.out.println("Message sent to FIFO queue: " + response.messageId());
        }
        return "hello";
    }

    public SendMessageResponse sendMessage(SqsClient sqsClient, String queueUrl, String message) {
        try {
            SendMessageRequest sendMsgRequest = SendMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .messageBody(message)
                    .messageGroupId("hello")
                    .build();

            return sqsClient.sendMessage(sendMsgRequest);

        } catch (SqsException e) {
            System.err.println(e.awsErrorDetails().errorMessage());
            return null;
        }
    }
}
