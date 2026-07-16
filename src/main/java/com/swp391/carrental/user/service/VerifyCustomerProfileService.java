package com.swp391.carrental.user.service;

import com.swp391.carrental.user.constant.ProfileVerificationStatus;
import com.swp391.carrental.user.dao.CustomerProfileDAO;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.CustomerProfile;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/*
 * Name: VerifyCustomerProfileService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for VerifyCustomerProfileService.
 */

// Business logic for Verify Customer Profile
public class VerifyCustomerProfileService {

    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();

    // Get all profiles
    public List<CustomerProfile> getAllProfiles() {
        try {
            return profileDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Cannot load customer profiles.", e);
        }
    }

    // Get profiles by status
    public List<CustomerProfile> getProfilesByStatus(String status) {
        try {
            return profileDAO.findByStatus(status);
        } catch (SQLException e) {
            throw new AppException("Cannot load customer profiles.", e);
        }
    }

    // Search profiles by keyword
    public List<CustomerProfile> searchProfiles(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllProfiles();
        }

        try {
            return profileDAO.search(keyword.trim());
        } catch (SQLException e) {
            throw new AppException("Search profile failed.", e);
        }
    }

    // Get profile detail by profile ID
    public CustomerProfile getProfile(int profileId) {
        try {
            CustomerProfile profile = profileDAO.findById(profileId);
            if (profile == null) {
                throw new AppException("Customer profile not found.");
            }
            return profile;
        } catch (SQLException e) {
            throw new AppException("Cannot load customer profile.", e);
        }
    }

    // Verify profile status
    public void verifyProfile(int profileId, int staffId) {
        CustomerProfile profile = getProfile(profileId);
        validateVerify(profile);

        try {
            profileDAO.updateVerificationStatus(
                    profileId,
                    ProfileVerificationStatus.VERIFIED,
                    staffId);
        } catch (SQLException e) {
            throw new AppException("Verify profile failed.", e);
        }
    }

    // Reject profile status
    public void rejectProfile(int profileId, int staffId) {
        CustomerProfile profile = getProfile(profileId);
        validateReject(profile);

        try {
            profileDAO.updateVerificationStatus(
                    profileId,
                    ProfileVerificationStatus.REJECTED,
                    staffId);
        } catch (SQLException e) {
            throw new AppException("Reject profile failed.", e);
        }
    }

    // Validation rules for verifying a profile
    private void validateVerify(CustomerProfile profile) {
        if (profile == null) {
            throw new AppException("Customer profile not found.");
        }

        if (!ProfileVerificationStatus.PENDING.equals(profile.getVerificationStatus())) {
            throw new AppException("Only PENDING profile can be verified.");
        }

        if (isBlank(profile.getIdCardNumber())) {
            throw new AppException("Missing ID Card Number.");
        }

        if (isBlank(profile.getIdCardImageFront())) {
            throw new AppException("Missing ID Card Front Image.");
        }

        if (isBlank(profile.getIdCardImageBack())) {
            throw new AppException("Missing ID Card Back Image.");
        }

        if (isBlank(profile.getDriverLicenseNumber())) {
            throw new AppException("Missing Driver License Number.");
        }

        if (isBlank(profile.getDriverLicenseImage())) {
            throw new AppException("Missing Driver License Image.");
        }

        if (profile.getDriverLicenseExpiry() != null && profile.getDriverLicenseExpiry().isBefore(LocalDate.now())) {
            throw new AppException("Driver License has expired.");
        }
    }

    // Validation rules for rejecting a profile
    private void validateReject(CustomerProfile profile) {
        if (profile == null) {
            throw new AppException("Customer profile not found.");
        }

        if (!ProfileVerificationStatus.PENDING.equals(profile.getVerificationStatus())) {
            throw new AppException("Only PENDING profile can be rejected.");
        }
    }

    // Get customer name by user ID
    public String getCustomerName(int userId) {
        try {
            return profileDAO.getCustomerName(userId);
        } catch (SQLException e) {
            throw new AppException("Cannot load customer name.", e);
        }
    }

    // Get customer email by user ID
    public String getCustomerEmail(int userId) {
        try {
            return profileDAO.getCustomerEmail(userId);
        } catch (SQLException e) {
            throw new AppException("Cannot load customer email.", e);
        }
    }

    // Helper method to check if string is null or empty
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
