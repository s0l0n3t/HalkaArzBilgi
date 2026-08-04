package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.controller;

import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.WorkOrderServiceRequest;
import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.WorkOrderServiceResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

//Schema implementation will replace.

@Tag(name = "WorkOrderService API", description = "Operations related to workflow")
@RequestMapping("/api/workorders")
public interface IWorkOrderController {
    @Operation(summary = "Get a work order by ID",description = "Retrieve a work order using its unique identifier")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",description = "work order found"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"Work order not found\"}")
            ))
    })
    @GetMapping("/{id}")
    public EntityModel<WorkOrderServiceResponse> get(@PathVariable String id);

    @Operation(summary = "Get work order list",description = "Retrieve all work order")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",description = "work order list found"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"Work order not found\"}")
            ))
    })
    @GetMapping
    public CollectionModel<EntityModel<WorkOrderServiceResponse>> list();

    @Operation(summary = "Create work order",description = "Creates a work order")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",description = "work order list found"),
            @ApiResponse(responseCode = "400",description = "Invalid work order data",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = {
                            @ExampleObject(name = "Invalid name",value = "{\"error\": \"Work order must not be empty\"}"),
                            @ExampleObject(name = "Invalid work order description",value = "{\"error\": \"work order description must not be empty\"}")
                    }
            ))
    })
    @PostMapping
    public ResponseEntity<EntityModel<WorkOrderServiceResponse>> create(@RequestBody WorkOrderServiceRequest workOrderServiceRequest);

    @Operation(summary = "Update work order",description = "Updates a work order")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",description = "work order updated"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"Work order not found\"}")
            )),
            @ApiResponse(responseCode = "400",description = "Invalid work order data",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = {
                            @ExampleObject(name = "Invalid name",value = "{\"error\": \"Work order must not be empty\"}"),
                            @ExampleObject(name = "Invalid work order description",value = "{\"error\": \"work order description must not be empty\"}")
                    }
            ))
    })
    @PutMapping("/{id}")
    public EntityModel<WorkOrderServiceResponse> update(@PathVariable String id, @RequestBody WorkOrderServiceRequest workOrderServiceRequest);

    @Operation(summary = "Delete work order list",description = "Deletes work order using unique identifier")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204",description = "work order deleted"),
            @ApiResponse(responseCode = "404",description = "not found",content = @Content(
                    mediaType = "application/json",
                    schema = @Schema(implementation = WorkOrderServiceResponse.class),
                    examples = @ExampleObject(value = "{\"error\": \"Work order not found\"}")
            ))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id);
}
