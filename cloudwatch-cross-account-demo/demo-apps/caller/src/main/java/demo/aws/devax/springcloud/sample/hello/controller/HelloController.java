package demo.aws.devax.springcloud.sample.hello.controller;

import demo.aws.devax.springcloud.sample.hello.service.WorldService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @Autowired
    WorldService worldService;

    @GetMapping("hello")
    public String sayHello(){

        return "hello" + worldService.sayHello();
    }
    @GetMapping("health")
    public String health(){
        return "hello is healthy";
    }
}
