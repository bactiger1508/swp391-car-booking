package com.swp391.carrental.model;

import java.time.LocalDateTime;

/**
 * Records when a vehicle is handed over to a customer.
 * Maps to the 'vehicle_handovers' table.
 */
public class VehicleHandover {

    private int handoverId;
    private int bookingId;
    private Integer contractId;
    private int carId;
    private LocalDateTime handoverDate;
    private int mileageAtHandover;
    private String fuelLevel;
    private String exteriorCondition;
    private String interiorCondition;
    private String accessoriesChecklist;
    private String photosUrl;
    private String notes;
    private int handedBy;
    private int receivedBy;
    private LocalDateTime createdAt;

    public VehicleHandover() {
    }

    // --- Getters and Setters ---

    public int getHandoverId() { return handoverId; }
    public void setHandoverId(int handoverId) { this.handoverId = handoverId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public Integer getContractId() { return contractId; }
    public void setContractId(Integer contractId) { this.contractId = contractId; }

    public int getCarId() { return carId; }
    public void setCarId(int carId) { this.carId = carId; }

    public LocalDateTime getHandoverDate() { return handoverDate; }
    public void setHandoverDate(LocalDateTime handoverDate) { this.handoverDate = handoverDate; }

    public int getMileageAtHandover() { return mileageAtHandover; }
    public void setMileageAtHandover(int mileageAtHandover) { this.mileageAtHandover = mileageAtHandover; }

    public String getFuelLevel() { return fuelLevel; }
    public void setFuelLevel(String fuelLevel) { this.fuelLevel = fuelLevel; }

    public String getExteriorCondition() { return exteriorCondition; }
    public void setExteriorCondition(String exteriorCondition) { this.exteriorCondition = exteriorCondition; }

    public String getInteriorCondition() { return interiorCondition; }
    public void setInteriorCondition(String interiorCondition) { this.interiorCondition = interiorCondition; }

    public String getAccessoriesChecklist() { return accessoriesChecklist; }
    public void setAccessoriesChecklist(String accessoriesChecklist) { this.accessoriesChecklist = accessoriesChecklist; }

    public String getPhotosUrl() { return photosUrl; }
    public void setPhotosUrl(String photosUrl) { this.photosUrl = photosUrl; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public int getHandedBy() { return handedBy; }
    public void setHandedBy(int handedBy) { this.handedBy = handedBy; }

    public int getReceivedBy() { return receivedBy; }
    public void setReceivedBy(int receivedBy) { this.receivedBy = receivedBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
