package demo.aws.devax.springcloud.sample.hello.service;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(value = "scg")
@Component
public interface WorldService {
    @GetMapping(value = "/health")
    String getHealth();

    @GetMapping(value = "/hello")
    String sayHello();
}
