package com.example.jedisdemo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPooled;

@RestController
public class DemoController {

    @GetMapping("/")
    String hello(){
        return "hello world";
    }

    @PostMapping("/{key}/{value}")
    String set(@PathVariable String key, @PathVariable String value){
        Jedis jedis = new Jedis(String.format("%s://%s:%s", System.getenv("REDIS_PROTOCOL"),System.getenv("REDIS_HOST"),System.getenv("REDIS_PORT")));
        try{

            jedis.auth(System.getenv("REDIS_USER"), System.getenv("REDIS_PASS"));
            // System.out.println(jedis.ping());
            jedis.set(key, value);
            return jedis.get(key);
        }
        finally {
            jedis.close();
        }
    }

    @GetMapping("/{key}")
    String get(@PathVariable String key){
        Jedis jedis = new Jedis(String.format("%s://%s:%s", System.getenv("REDIS_PROTOCOL"),System.getenv("REDIS_HOST"),System.getenv("REDIS_PORT")));
        try{

            jedis.auth(System.getenv("REDIS_USER"), System.getenv("REDIS_PASS"));
            // System.out.println(jedis.ping());
            return jedis.get(key);
        }
        finally {
            jedis.close();
        }

    }


}
