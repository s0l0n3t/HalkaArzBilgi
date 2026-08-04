package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.controller;


import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.WorkOrderServiceRequest;
import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.WorkOrderServiceResponse;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;

@RestController
public class WorkOrderController implements IWorkOrderController {

    private final Map<String, WorkOrderServiceResponse> serviceResponseMap = new HashMap<>(); //demo db

    @Override
    public EntityModel<WorkOrderServiceResponse> get(@PathVariable String id) {
        //business layer needed
        return toModel(WorkOrderServiceResponse.builder().id(id).build()); //demo object defined
    };

    @Override
    public EntityModel<WorkOrderServiceResponse> update(@PathVariable String id, @RequestBody WorkOrderServiceRequest workOrderServiceRequest) {
        if(!serviceResponseMap.containsKey(id)) {
            throw new NoSuchElementException("Service not found");
        }
        WorkOrderServiceResponse workOrderServiceResponse = WorkOrderServiceResponse.builder().id(id)
                .serviceDataPath(workOrderServiceRequest.getServiceDataPath())
                .serviceDescription(workOrderServiceRequest.getServiceDescription())
                .serviceEndDate(workOrderServiceRequest.getServiceEndDate())
                .serviceCustomerDescription(workOrderServiceRequest.getServiceCustomerDescription())
                .serviceStartDate(workOrderServiceRequest.getServiceStartDate())
                .build();
        serviceResponseMap.put(id, workOrderServiceResponse);

        return EntityModel.of(workOrderServiceResponse, linkTo(methodOn(WorkOrderController.class).get(id)).withSelfRel());
        //I'm not sure for output.
    }

    @Override
    public ResponseEntity<?> delete(@PathVariable String id) {
        if(!serviceResponseMap.containsKey(id)) {
            throw new NoSuchElementException("Service not found");
        }
        serviceResponseMap.remove(id);
        //return ResponseEntity.ok(linkTo(methodOn(ServiceController.class).delete(id)).withSelfRel());
        return ResponseEntity.notFound().build();//Enterprise approach
    }

    @Override
    public CollectionModel<EntityModel<WorkOrderServiceResponse>> list() {
        List<EntityModel<WorkOrderServiceResponse>> entityModelList = serviceResponseMap.values().stream()
                .map(this::toModel)
                .toList();

        return CollectionModel.of(entityModelList,
                linkTo(methodOn(WorkOrderController.class).list()).withSelfRel());
    }

    @Override
    public ResponseEntity<EntityModel<WorkOrderServiceResponse>> create(@RequestBody WorkOrderServiceRequest workOrderServiceRequest) {
        String id = UUID.randomUUID().toString();

        serviceResponseMap.put(id, WorkOrderServiceResponse.builder().id(id)
                .serviceCustomerDescription("demoCompany")
                .serviceDataPath("demoCompany"+ LocalDateTime.now().toString())
                .serviceStartDate(ZonedDateTime.now())
                .serviceEndDate(LocalDateTime.now().plusDays(2).atZone(ZoneId.systemDefault()))
                .build());

        EntityModel<WorkOrderServiceResponse> entityResponseModel = toModel(serviceResponseMap.get(id));
        return ResponseEntity.created(linkTo(methodOn(WorkOrderController.class).get(id)).toUri())
                .body(entityResponseModel);
    }


    // Converting to EntityModel Class
    private EntityModel<WorkOrderServiceResponse> toModel(WorkOrderServiceResponse workOrderServiceResponse) {
        return EntityModel.of(workOrderServiceResponse,
                linkTo(methodOn(WorkOrderController.class).get(workOrderServiceResponse.getId())).withSelfRel(),
                linkTo(methodOn(WorkOrderController.class).delete(workOrderServiceResponse.getId())).withRel("delete"),
                linkTo(methodOn(WorkOrderController.class).update(workOrderServiceResponse.getId(),new WorkOrderServiceRequest())).withRel("update"),
                linkTo(methodOn(WorkOrderController.class).list()).withRel("getAll"));
    };
}
