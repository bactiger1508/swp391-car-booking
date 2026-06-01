/*
 * Name: MaintenanceSchedule
 * @Author: TinhNVHE160000 (Vehicle Module)
 * Date: 31/05/2026
 * Version: 1.0
 * Description: Model class for Maintenance Schedule entity
 */
package com.swp391.carrental.model;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Represents a maintenance schedule for a vehicle.
 */
public class MaintenanceSchedule implements Serializable {
    private static final long serialVersionUID = 1L;

    private int maintenanceId;
    private int vehicleId;
    private String maintenanceType;  // OIL_CHANGE, TIRE_CHANGE, INSPECTION, REPAIR, etc.
    private LocalDate scheduledDate;
    private LocalDate completedDate;
    private String status;  // SCHEDULED, COMPLETED, CANCELLED
    private String description;
    private double cost;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String createdBy;
    private String updatedBy;

    // Constructors
    public MaintenanceSchedule() {}

    public MaintenanceSchedule(int maintenanceId, int vehicleId, String maintenanceType, 
                              LocalDate scheduledDate, String status) {
        this.maintenanceId = maintenanceId;
        this.vehicleId = vehicleId;
        this.maintenanceType = maintenanceType;
        this.scheduledDate = scheduledDate;
        this.status = status;
    }

    // Getters and Setters
    public int getMaintenanceId() {
        return maintenanceId;
    }

    public void setMaintenanceId(int maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getMaintenanceType() {
        return maintenanceType;
    }

    public void setMaintenanceType(String maintenanceType) {
        this.maintenanceType = maintenanceType;
    }

    public LocalDate getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDate scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public LocalDate getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(LocalDate completedDate) {
        this.completedDate = completedDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    @Override
    public String toString() {
        return "MaintenanceSchedule{" +
                "maintenanceId=" + maintenanceId +
                ", vehicleId=" + vehicleId +
                ", maintenanceType='" + maintenanceType + '\'' +
                ", scheduledDate=" + scheduledDate +
                ", status='" + status + '\'' +
                '}';
    }
}
