package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AdminServiceResponse {
    private String id; //creating UUID
    private String username;
    private String password;
}
