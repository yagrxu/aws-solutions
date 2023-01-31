package demo.aws.devax.springcloud.sample.hello.service;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;

@FeignClient(name = "world", url = "ad7758ccc58ba47cb979dd70ea734b7e-1e84e34c0e0abdec.elb.ap-southeast-1.amazonaws.com")
@Component
public interface WorldService {
    @GetMapping(value = "/health")
    String getHealth();

    @GetMapping(value = "/hello")
    String sayHello();
}
