package demo.aws.devx.springcloud.sample.world.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.apache.logging.log4j.Logger;

import java.util.Random;

import org.apache.logging.log4j.LogManager;

@RestController
public class WorldController {

    private static final Logger logger = LogManager.getLogger(WorldController.class);

    @GetMapping("hello")
    public String sayHello(){
        Random random = new Random();
        int upperbound = 10;
        int int_random = random.nextInt(upperbound); 
        if (int_random > 5){
            throw new RuntimeException("sorry!");
        }
        logger.info("hello world");
        return "world";
    }

    @GetMapping("health")
    public String health(){
        return "world is healthy";
    }
}
