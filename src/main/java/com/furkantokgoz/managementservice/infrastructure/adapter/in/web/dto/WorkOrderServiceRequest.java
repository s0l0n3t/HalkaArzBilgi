package com.furkantokgoz.managementservice.infrastructure.adapter.in.web.dto;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.io.File;
import java.time.ZonedDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkOrderServiceRequest {
    // Validation will be on business layer.
    @NotBlank (message = "Customer name is needed") private String serviceCustomerDescription;
    private String serviceDescription; //Includes workflow like color.
    @NotBlank (message = "Path is needed") private String serviceDataPath;
    @NotNull(message = "File is needed") private File serviceMultipartFile;
    @NotNull(message = "EndDate is needed") private ZonedDateTime serviceEndDate;
    private ZonedDateTime serviceStartDate;//Current date
}