package com.swp391.carrental.booking.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * Name: Booking
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 2.0
 * Description: Handles business logic and operations for Booking.
 */

/**
 * Represents a rental booking.
 * Maps to the 'bookings' table.
 */
public class Booking {

    private int bookingId;
    private int customerId;
    private int carId;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String pickupLocation;
    private String returnLocation;
    private BigDecimal totalAmount;
    private BigDecimal depositAmount;
    private String status;
    private String notes;
    private Integer approvedBy;
    private LocalDateTime approvedAt;
    private LocalDateTime cancelledAt;
    private String cancelReason;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Redesign Fields
    private String rentalMode;
    private String pricingPackage;
    private String deliveryMethod;
    private String deliveryAddress;
    private BigDecimal deliveryDistance;
    private BigDecimal deliveryFee;
    private Integer kmLimit;
    private Integer estimatedKm;
    private BigDecimal baseAmount;
    private BigDecimal discountAmount;
    private BigDecimal taxAmount;

    public Booking() {
    }

    // --- Getters and Setters ---

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getCarId() { return carId; }
    public void setCarId(int carId) { this.carId = carId; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public String getPickupLocation() { return pickupLocation; }
    public void setPickupLocation(String pickupLocation) { this.pickupLocation = pickupLocation; }

    public String getReturnLocation() { return returnLocation; }
    public void setReturnLocation(String returnLocation) { this.returnLocation = returnLocation; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getDepositAmount() { return depositAmount; }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Integer getApprovedBy() { return approvedBy; }
    public void setApprovedBy(Integer approvedBy) { this.approvedBy = approvedBy; }

    public LocalDateTime getApprovedAt() { return approvedAt; }
    public void setApprovedAt(LocalDateTime approvedAt) { this.approvedAt = approvedAt; }

    public LocalDateTime getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(LocalDateTime cancelledAt) { this.cancelledAt = cancelledAt; }

    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Redesign Getters and Setters

    public String getRentalMode() { return rentalMode; }
    public void setRentalMode(String rentalMode) { this.rentalMode = rentalMode; }

    public String getPricingPackage() { return pricingPackage; }
    public void setPricingPackage(String pricingPackage) { this.pricingPackage = pricingPackage; }

    public String getDeliveryMethod() { return deliveryMethod; }
    public void setDeliveryMethod(String deliveryMethod) { this.deliveryMethod = deliveryMethod; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public BigDecimal getDeliveryDistance() { return deliveryDistance; }
    public void setDeliveryDistance(BigDecimal deliveryDistance) { this.deliveryDistance = deliveryDistance; }

    public BigDecimal getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(BigDecimal deliveryFee) { this.deliveryFee = deliveryFee; }

    public Integer getKmLimit() { return kmLimit; }
    public void setKmLimit(Integer kmLimit) { this.kmLimit = kmLimit; }

    public Integer getEstimatedKm() { return estimatedKm; }
    public void setEstimatedKm(Integer estimatedKm) { this.estimatedKm = estimatedKm; }

    public BigDecimal getBaseAmount() { return baseAmount; }
    public void setBaseAmount(BigDecimal baseAmount) { this.baseAmount = baseAmount; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
}

