/*
 * Name: VehicleBrand
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Represents a vehicle brand lookup entry (e.g. Toyota, Honda), used by Vehicle.
 */
package com.swp391.carrental.vehicle.model;

import java.time.LocalDateTime;

/**
 * Represents a vehicle brand in the {@code vehicle_brands} lookup table.
 */
public class VehicleBrand {
    private int brandId;
    private String brandName;
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** Creates an empty vehicle brand (used when mapping from a database row). */
    public VehicleBrand() {}

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
