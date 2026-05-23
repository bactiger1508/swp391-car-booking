package com.swp391.carrental.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Extended profile for customers (ID card, driver license).
 * Maps to the 'customer_profiles' table.
 */
public class CustomerProfile {

    private int profileId;
    private int userId;
    private LocalDate dateOfBirth;
    private String address;
    private String idCardNumber;
    private String idCardImageFront;
    private String idCardImageBack;
    private String driverLicenseNumber;
    private String driverLicenseImage;
    private LocalDate driverLicenseExpiry;
    private String verificationStatus;
    private Integer verifiedBy;
    private LocalDateTime verifiedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public CustomerProfile() {
    }

    // --- Getters and Setters ---

    public int getProfileId() {
        return profileId;
    }

    public void setProfileId(int profileId) {
        this.profileId = profileId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getIdCardNumber() {
        return idCardNumber;
    }

    public void setIdCardNumber(String idCardNumber) {
        this.idCardNumber = idCardNumber;
    }

    public String getIdCardImageFront() {
        return idCardImageFront;
    }

    public void setIdCardImageFront(String idCardImageFront) {
        this.idCardImageFront = idCardImageFront;
    }

    public String getIdCardImageBack() {
        return idCardImageBack;
    }

    public void setIdCardImageBack(String idCardImageBack) {
        this.idCardImageBack = idCardImageBack;
    }

    public String getDriverLicenseNumber() {
        return driverLicenseNumber;
    }

    public void setDriverLicenseNumber(String driverLicenseNumber) {
        this.driverLicenseNumber = driverLicenseNumber;
    }

    public String getDriverLicenseImage() {
        return driverLicenseImage;
    }

    public void setDriverLicenseImage(String driverLicenseImage) {
        this.driverLicenseImage = driverLicenseImage;
    }

    public LocalDate getDriverLicenseExpiry() {
        return driverLicenseExpiry;
    }

    public void setDriverLicenseExpiry(LocalDate driverLicenseExpiry) {
        this.driverLicenseExpiry = driverLicenseExpiry;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public Integer getVerifiedBy() {
        return verifiedBy;
    }

    public void setVerifiedBy(Integer verifiedBy) {
        this.verifiedBy = verifiedBy;
    }

    public LocalDateTime getVerifiedAt() {
        return verifiedAt;
    }

    public void setVerifiedAt(LocalDateTime verifiedAt) {
        this.verifiedAt = verifiedAt;
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
}
