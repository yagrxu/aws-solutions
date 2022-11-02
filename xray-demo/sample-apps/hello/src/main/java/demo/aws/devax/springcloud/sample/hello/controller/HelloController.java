package demo.aws.devax.springcloud.sample.hello.controller;

import demo.aws.devax.springcloud.sample.hello.service.WorldService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

@RestController
public class HelloController {

    private static final Logger logger = LogManager.getLogger(HelloController.class);

    @Autowired
    WorldService worldService;

    @GetMapping("hello")
    public String sayHello(){
        logger.info("world service is triggered");
        return "hello" + worldService.sayHello();
    }
    @GetMapping("health")
    public String health(){
        return "hello is healthy";
    }
}
