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
            throw new AppException("Không thể tải hồ sơ khách hàng.", e);
        }
    }

    // Get profiles by status
    public List<CustomerProfile> getProfilesByStatus(String status) {
        try {
            return profileDAO.findByStatus(status);
        } catch (SQLException e) {
            throw new AppException("Không thể tải hồ sơ khách hàng.", e);
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
            throw new AppException("Tìm kiếm hồ sơ không thành công.", e);
        }
    }

    // Get profile detail by profile ID
    public CustomerProfile getProfile(int profileId) {
        try {
            CustomerProfile profile = profileDAO.findById(profileId);
            if (profile == null) {
                throw new AppException("Không tìm thấy hồ sơ khách hàng..");
            }
            return profile;
        } catch (SQLException e) {
            throw new AppException("Không thể tải hồ sơ khách hàng.", e);
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
            throw new AppException("Xác minh hồ sơ không thành công.", e);
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
            throw new AppException("Hồ sơ bị từ chối không thành công.", e);
        }
    }

    // Validation rules for verifying a profile
    private void validateVerify(CustomerProfile profile) {
        if (profile == null) {
            throw new AppException("Không tìm thấy hồ sơ khách hàng.");
        }

        if (!ProfileVerificationStatus.PENDING.equals(profile.getVerificationStatus())) {
            throw new AppException("Chỉ những hồ sơ đang chờ xử lý mới có thể được xác minh.");
        }

        if (isBlank(profile.getIdCardNumber())) {
            throw new AppException("Thiếu số thẻ căn cước.");
        }

        if (isBlank(profile.getIdCardImageFront())) {
            throw new AppException("Ảnh mặt trước thẻ căn cước bị thiếu.");
        }

        if (isBlank(profile.getIdCardImageBack())) {
            throw new AppException("Hình ảnh mặt sau thẻ căn cước bị thiếu.");
        }

        if (isBlank(profile.getDriverLicenseNumber())) {
            throw new AppException("Thiếu số giấy phép lái xe.");
        }

        if (isBlank(profile.getDriverLicenseImage())) {
            throw new AppException("Thiếu ảnh giấy phép lái xe.");
        }

        if (profile.getDriverLicenseExpiry() != null && profile.getDriverLicenseExpiry().isBefore(LocalDate.now())) {
            throw new AppException("Giấy phép lái xe đã hết hạn.");
        }
    }

    // Validation rules for rejecting a profile
    private void validateReject(CustomerProfile profile) {
        if (profile == null) {
            throw new AppException("Không tìm thấy hồ sơ khách hàng.");
        }

        if (!ProfileVerificationStatus.PENDING.equals(profile.getVerificationStatus())) {
            throw new AppException("Chỉ những hồ sơ đang ở trạng thái CHỜ XỬ LÝ mới có thể bị từ chối.");
        }
    }

    // Get customer name by user ID
    public String getCustomerName(int userId) {
        try {
            return profileDAO.getCustomerName(userId);
        } catch (SQLException e) {
            throw new AppException("Không thể tải tên khách hàng.", e);
        }
    }

    // Get customer email by user ID
    public String getCustomerEmail(int userId) {
        try {
            return profileDAO.getCustomerEmail(userId);
        } catch (SQLException e) {
            throw new AppException("Không thể tải email khách hàng.", e);
        }
    }

    // Helper method to check if string is null or empty
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
