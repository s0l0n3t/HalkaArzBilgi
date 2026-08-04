package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.controller;

import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.AdminServiceRequest;
import com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto.AdminServiceResponse;
import org.springframework.hateoas.EntityModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.UUID;


import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
public class AdminController implements IAdminController {
    //add admincommand mapping, use command classes by usecase

    private final Map<String, AdminServiceResponse> serviceResponseMap = new HashMap<>();//demo db

    @Override
    public EntityModel<AdminServiceResponse> get(@PathVariable String id) {
        return toModel(serviceResponseMap.get(id)).add(linkTo(methodOn(AdminController.class).get(id)).withSelfRel());
    }
    @Override
    public ResponseEntity<EntityModel<AdminServiceResponse>> create(@RequestBody AdminServiceRequest adminServiceRequest) {
        String id = UUID.randomUUID().toString();
        AdminServiceResponse adminServiceResponse = new AdminServiceResponse(id, adminServiceRequest.getUsername(), adminServiceRequest.getPassword());
        serviceResponseMap.put(id, adminServiceResponse);
        return ResponseEntity.created(linkTo(methodOn((AdminController.class)).get(id)).toUri()).body(toModel(adminServiceResponse));
    }

    @Override
    public ResponseEntity<?>  delete(@PathVariable String id) {
        if(!serviceResponseMap.containsKey(id)) {
            throw new NoSuchElementException(HttpStatus.NOT_FOUND.toString());
        }
        serviceResponseMap.remove(id);
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<EntityModel<AdminServiceResponse>> update(@PathVariable String id,@RequestBody AdminServiceRequest adminServiceRequest) {
        if(!serviceResponseMap.containsKey(id)) {
            throw new NoSuchElementException(HttpStatus.NOT_FOUND.toString());
        }
        AdminServiceResponse adminServiceResponse = new AdminServiceResponse(UUID.randomUUID().toString(), adminServiceRequest.getUsername(), adminServiceRequest.getPassword());
        serviceResponseMap.put(adminServiceResponse.getId(), adminServiceResponse);
        return ResponseEntity.ok(toModel(adminServiceResponse).add(linkTo(methodOn(AdminController.class).get(id)).withSelfRel()));
    }

    @Override
    public EntityModel<AdminServiceResponse> login(@RequestBody AdminServiceRequest adminServiceRequest) { //Option 1
//        AdminServiceResponse adminServiceResponse = serviceResponseMap.values().stream()
//                .filter(admin -> admin.getUsername().equals(adminServiceRequest.getUsername()))
//                .filter(admin -> admin.getPassword().equals(adminServiceRequest.getPassword()))
//                .findFirst()
//                .orElseThrow(() -> new NoSuchElementException(HttpStatus.NOT_FOUND.toString()));
//        return toModel(adminServiceResponse).add(linkTo(methodOn(AdminServiceController.class).get(adminServiceResponse.getId())).withSelfRel());
        String id = UUID.randomUUID().toString();
        serviceResponseMap.put(id,new AdminServiceResponse(id, adminServiceRequest.getUsername(), adminServiceRequest.getPassword()));
        for(AdminServiceResponse adminServiceResponse : serviceResponseMap.values()) {
            if(adminServiceResponse.getUsername().equals(adminServiceRequest.getUsername()) && adminServiceResponse.getPassword().equals(adminServiceRequest.getPassword())) {
                return toModel(adminServiceResponse).add(linkTo(methodOn(AdminController.class).get(adminServiceResponse.getId())).withSelfRel());
            }
        }

        throw new NoSuchElementException(HttpStatus.NOT_FOUND.toString());//Option 2
    }


    private EntityModel<AdminServiceResponse> toModel(AdminServiceResponse adminServiceResponse) {
        //toModel link references
        return EntityModel.of(adminServiceResponse,
                linkTo(methodOn(AdminController.class).get(adminServiceResponse.getId())).withSelfRel(),
                linkTo(methodOn(AdminController.class).get(adminServiceResponse.getId())).withRel("create"));
    }
}
