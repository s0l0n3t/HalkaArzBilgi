package com.furkantokgoz.managementservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


//http://localhost:8080/swagger-ui/index.html swagger endpoint
//Clean architecture:
//domain: COntains the core business logic, entities and domain services.
//application: use cases, application services and interfaces
//infrastructure: implementations of external depencies like repositories, frameworks and database logic
//web: controllers

@SpringBootApplication
public class TaemApplication {

    public static void main(String[] args) {
        SpringApplication.run(TaemApplication.class, args);
    }

}
