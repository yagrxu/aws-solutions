package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WorldController {

    @Autowired
    SQSMessageReceiver receiver;

    @GetMapping("health")
    String getHealth(){
        return "OK";
    }

    @GetMapping("message")
    String sayHello(){
        receiver.receiveMessage();
        return "hello";
    }
}
