package com.swp391.carrental.contract.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * Name: RentalContract
 * @Author: TungNLHE186756
 * Date: 21/06/2026
 * Version: 2.0
 * Description: Handles business logic and operations for RentalContract.
 */

/**
 * Represents a rental contract.
 * Maps to the 'rental_contracts' table.
 */
public class RentalContract {

    private int contractId;
    private int bookingId;
    private String contractNumber;
    private int customerId;
    private int carId;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private BigDecimal dailyRate;
    private BigDecimal totalAmount;
    private BigDecimal depositAmount;
    private String status;
    private String termsAndConditions;
    private int createdBy;
    private LocalDateTime signedAt;
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

    public RentalContract() {
    }

    // --- Getters and Setters ---

    public int getContractId() { return contractId; }
    public void setContractId(int contractId) { this.contractId = contractId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public String getContractNumber() { return contractNumber; }
    public void setContractNumber(String contractNumber) { this.contractNumber = contractNumber; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getCarId() { return carId; }
    public void setCarId(int carId) { this.carId = carId; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public BigDecimal getDailyRate() { return dailyRate; }
    public void setDailyRate(BigDecimal dailyRate) { this.dailyRate = dailyRate; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getDepositAmount() { return depositAmount; }
    public void setDepositAmount(BigDecimal depositAmount) { this.depositAmount = depositAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTermsAndConditions() { return termsAndConditions; }
    public void setTermsAndConditions(String termsAndConditions) { this.termsAndConditions = termsAndConditions; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getSignedAt() { return signedAt; }
    public void setSignedAt(LocalDateTime signedAt) { this.signedAt = signedAt; }

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

