/*
 * Name: VehicleImage
 * @Author: TinhNVHE160000 (Vehicle Module)
 * Date: 31/05/2026
 * Version: 1.0
 * Description: Model class for Vehicle Image entity
 */
package com.swp391.carrental.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Represents an image associated with a vehicle.
 */
public class VehicleImage implements Serializable {
    private static final long serialVersionUID = 1L;

    private int imageId;
    private int vehicleId;
    private String imageUrl;
    private String description;
    private boolean isPrimary;
    private LocalDateTime uploadedAt;

    // Constructors
    public VehicleImage() {}

    public VehicleImage(int imageId, int vehicleId, String imageUrl) {
        this.imageId = imageId;
        this.vehicleId = vehicleId;
        this.imageUrl = imageUrl;
    }

    // Getters and Setters
    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isPrimary() {
        return isPrimary;
    }

    public void setPrimary(boolean primary) {
        isPrimary = primary;
    }

    public LocalDateTime getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(LocalDateTime uploadedAt) {
        this.uploadedAt = uploadedAt;
    }

    @Override
    public String toString() {
        return "VehicleImage{" +
                "imageId=" + imageId +
                ", vehicleId=" + vehicleId +
                ", imageUrl='" + imageUrl + '\'' +
                ", isPrimary=" + isPrimary +
                '}';
    }
}
