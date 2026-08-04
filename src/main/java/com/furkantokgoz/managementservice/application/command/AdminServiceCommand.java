package com.furkantokgoz.managementservice.application.command;

import com.furkantokgoz.managementservice.application.usecase.AdminService;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public class AdminServiceCommand {
    private final String id;
    private final String username;
    private final String password;

    public AdminServiceCommand(String username, String password, String id) {
        this.username = username;
        this.password = password;
        this.id = id;
    }
}
