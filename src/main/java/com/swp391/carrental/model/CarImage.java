package com.swp391.carrental.model;

import java.time.LocalDateTime;

/**
 * Represents an image associated with a car.
 * Maps to the 'car_images' table.
 */
public class CarImage {

    private int imageId;
    private int carId;
    private String imageUrl;
    private String caption;
    private boolean isPrimary;
    private int sortOrder;
    private LocalDateTime createdAt;

    public CarImage() {
    }

    public int getImageId() { return imageId; }
    public void setImageId(int imageId) { this.imageId = imageId; }

    public int getCarId() { return carId; }
    public void setCarId(int carId) { this.carId = carId; }

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
