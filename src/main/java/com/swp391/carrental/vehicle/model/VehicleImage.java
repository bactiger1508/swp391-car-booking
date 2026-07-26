package com.swp391.carrental.vehicle.model;

import java.time.LocalDateTime;

/*
 * Name: VehicleImage
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 2.0
 * Description: Represents an image associated with a vehicle.
 */

/**
 * Represents an image associated with a vehicle.
 * Maps to the 'vehicle_images' table.
 */
public class VehicleImage {

    private int imageId;
    private int vehicleId;
    private String imageUrl;
    private String caption;
    private boolean isPrimary;
    private int sortOrder;
    private LocalDateTime createdAt;

    public VehicleImage() {
    }

    public int getImageId() { return imageId; }
    public void setImageId(int imageId) { this.imageId = imageId; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getCaption() { return caption; }
    public void setCaption(String caption) { this.caption = caption; }

    public boolean isPrimary() { return isPrimary; }
    public void setPrimary(boolean primary) { isPrimary = primary; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
