package com.furkantokgoz.managementservice.domain.port;

public interface ImageStoragePort {
    public void uploadPhoto(String filePath);
    public void downloadPhoto(String filePath);//return value will change
}
