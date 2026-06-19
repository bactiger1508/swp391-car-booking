/*
 * Name: VehicleReturn
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles business logic and operations for VehicleReturn.
 */
package com.swp391.carrental.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Records when a vehicle is returned by a customer. Maps to the
 * 'vehicle_returns' table.
 */
public class VehicleReturn {

    private int returnId;
    private int bookingId;
    private Integer contractId;
    private int carId;
    private Integer handoverId;
    private LocalDateTime returnDate;
    private int mileageAtReturn;
    private String fuelLevel;
    private String exteriorCondition;
    private String interiorCondition;
    private String damageDescription;
    private String photosUrl;
    private BigDecimal lateFee;
    private BigDecimal extraKmFee;
    private BigDecimal damageFee;
    private BigDecimal cleaningFee;
    private BigDecimal lostItemFee;
    private BigDecimal totalAdditionalFee;
    private String notes;
    private int receivedBy;
    private int returnedBy;
    private String status;
    private LocalDateTime createdAt;

    public VehicleReturn() {
    }

    // --- Getters and Setters ---
    public int getReturnId() {
        return returnId;
    }

    public void setReturnId(int returnId) {
        this.returnId = returnId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public Integer getContractId() {
        return contractId;
    }

    public void setContractId(Integer contractId) {
        this.contractId = contractId;
    }

    public int getCarId() {
        return carId;
    }

    public void setCarId(int carId) {
        this.carId = carId;
    }

    public Integer getHandoverId() {
        return handoverId;
    }

    public void setHandoverId(Integer handoverId) {
        this.handoverId = handoverId;
    }

    public LocalDateTime getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDateTime returnDate) {
        this.returnDate = returnDate;
    }

    public int getMileageAtReturn() {
        return mileageAtReturn;
    }

    public void setMileageAtReturn(int mileageAtReturn) {
        this.mileageAtReturn = mileageAtReturn;
    }

    public String getFuelLevel() {
        return fuelLevel;
    }

    public void setFuelLevel(String fuelLevel) {
        this.fuelLevel = fuelLevel;
    }

    public String getExteriorCondition() {
        return exteriorCondition;
    }

    public void setExteriorCondition(String exteriorCondition) {
        this.exteriorCondition = exteriorCondition;
    }

    public String getInteriorCondition() {
        return interiorCondition;
    }

    public void setInteriorCondition(String interiorCondition) {
        this.interiorCondition = interiorCondition;
    }

    public String getDamageDescription() {
        return damageDescription;
    }

    public void setDamageDescription(String damageDescription) {
        this.damageDescription = damageDescription;
    }

    public String getPhotosUrl() {
        return photosUrl;
    }

    public void setPhotosUrl(String photosUrl) {
        this.photosUrl = photosUrl;
    }

    public BigDecimal getLateFee() {
        return lateFee;
    }

    public void setLateFee(BigDecimal lateFee) {
        this.lateFee = lateFee;
    }

    public BigDecimal getExtraKmFee() {
        return extraKmFee;
    }

    public void setExtraKmFee(BigDecimal extraKmFee) {
        this.extraKmFee = extraKmFee;
    }

    public BigDecimal getDamageFee() {
        return damageFee;
    }

    public void setDamageFee(BigDecimal damageFee) {
        this.damageFee = damageFee;
    }

    public BigDecimal getCleaningFee() {
        return cleaningFee;
    }

    public void setCleaningFee(BigDecimal cleaningFee) {
        this.cleaningFee = cleaningFee;
    }

    public BigDecimal getLostItemFee() {
        return lostItemFee;
    }

    public void setLostItemFee(BigDecimal lostItemFee) {
        this.lostItemFee = lostItemFee;
    }

    public BigDecimal getTotalAdditionalFee() {
        return totalAdditionalFee;
    }

    public void setTotalAdditionalFee(BigDecimal totalAdditionalFee) {
        this.totalAdditionalFee = totalAdditionalFee;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public int getReceivedBy() {
        return receivedBy;
    }

    public void setReceivedBy(int receivedBy) {
        this.receivedBy = receivedBy;
    }

    public int getReturnedBy() {
        return returnedBy;
    }

    public void setReturnedBy(int returnedBy) {
        this.returnedBy = returnedBy;
    }

    public String getStatus() {
        return fuelLevel;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
