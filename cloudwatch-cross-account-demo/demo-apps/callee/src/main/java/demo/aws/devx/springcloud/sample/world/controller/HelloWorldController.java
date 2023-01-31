package demo.aws.devx.springcloud.sample.world.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

@RestController
public class HelloWorldController {
    private static final Logger logger = LogManager.getLogger(HelloWorldController.class);
    @GetMapping("hello")
    public String sayHello(){
        logger.info("hello world");
        return "world";
    }

    @GetMapping("health")
    public String health(){
        return "world is healthy";
    }
}
