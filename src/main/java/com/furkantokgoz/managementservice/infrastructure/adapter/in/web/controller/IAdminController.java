package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.controller;

import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.AdminServiceRequest;
import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.AdminServiceResponse;
import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.WorkOrderServiceResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "AdminService API", description = "Admin user operations")
@RequestMapping("/api/admin")
public interface IAdminController {
    @Operation(summary = "Get admin by ID",description = "Retrieve an admin using its unique identifier")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",description = "admin found"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"Work order not found\"}")
            ))
    })
    @GetMapping("/{id}")
    public EntityModel<AdminServiceResponse> get(@PathVariable String id);

    @Operation(summary = "Create admin",description = "Creates an admin")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",description = "admin list found"),
            @ApiResponse(responseCode = "400",description = "Invalid admin data",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = {
                            @ExampleObject(name = "Invalid username",value = "{\"error\": \"username must not be empty\"}"),
                            @ExampleObject(name = "Invalid password",value = "{\"error\": \"password must not be empty\"}")
                    }
            ))
    })
    @PostMapping
    public ResponseEntity<EntityModel<AdminServiceResponse>> create(@RequestBody AdminServiceRequest adminServiceRequest);

    @Operation(summary = "Delete admin by ID",description = "Deletes an admin using its unique identifier")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204",description = "admin deleted"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"admin not found\"}")
            ))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?>  delete(@PathVariable String id);

    @Operation(summary = "Update admin",description = "Updates admin credentials")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",description = "admin credentials updated"),
            @ApiResponse(responseCode = "404",description = "Invalid admin credentials",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = {
                            @ExampleObject(name = "Invalid username",value = "{\"error\": \"username must not be empty\"}"),
                            @ExampleObject(name = "Invalid password",value = "{\"error\": \"password must not be empty\"}")
                    }
            ))
    })
    @PutMapping("/{id}")
    public ResponseEntity<EntityModel<AdminServiceResponse>> update(@PathVariable String id,@RequestBody AdminServiceRequest adminServiceRequest);

    @PostMapping("/login")
    public EntityModel<AdminServiceResponse> login(@RequestBody AdminServiceRequest adminServiceRequest);
}
