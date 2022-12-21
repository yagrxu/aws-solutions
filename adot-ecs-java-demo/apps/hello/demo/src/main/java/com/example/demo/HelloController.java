package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("health")
    String getHealth(){
        return "OK";
    }

    @GetMapping
    String sayHello(){
        return "hello";
    }
}
