package com.furkantokgoz.managementservice.application.command;

import java.io.File;
import java.time.ZonedDateTime;

public class WorkOrderServiceCommand {
    private final String id;
    private final String serviceCustomerDescription;
    private final String serviceDescription;
    private final String serviceDataPath;
    private final File serviceMultipartFile;
    private final ZonedDateTime serviceStartDate;//current time
    private final ZonedDateTime serviceEndDate;

    public WorkOrderServiceCommand(String id, String serviceCustomerDescription, String serviceDescription, String serviceDataPath, File serviceMultipartFile) {
        this.id = id;
        this.serviceCustomerDescription = serviceCustomerDescription;
        this.serviceDescription = serviceDescription;
        this.serviceDataPath = serviceDataPath;
        this.serviceMultipartFile = serviceMultipartFile;
        this.serviceStartDate = ZonedDateTime.now();
        this.serviceEndDate = this.serviceStartDate;
    }
}
