package demo.aws.devax.springcloud.sample;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;

@SpringBootApplication
@EnableDiscoveryClient
@EnableZuulProxy
public class ScgApplication {

    public static void main(String[] args) {
        SpringApplication.run(ScgApplication.class, args);
    }

}
