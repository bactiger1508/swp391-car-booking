/*
 * Name: VehicleModel
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Represents a vehicle model lookup entry (e.g. Vios, City) belonging to a brand, used by Vehicle.
 */
package com.swp391.carrental.vehicle.model;

import java.time.LocalDateTime;

/**
 * Represents a vehicle model in the {@code vehicle_models} lookup table.
 */
public class VehicleModel {
    private int modelId;
    private int brandId;
    private String modelName;
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** Creates an empty vehicle model (used when mapping from a database row). */
    public VehicleModel() {}

    public int getModelId() { return modelId; }
    public void setModelId(int modelId) { this.modelId = modelId; }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
