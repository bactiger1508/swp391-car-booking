package com.swp391.carrental.user.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.user.model.CustomerProfile;

/**
 * Data Access Object for CustomerProfile entities.
 */
public class CustomerProfileDAO {

    public CustomerProfile findByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM customer_profiles WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public int insert(CustomerProfile profile) throws SQLException {
        String sql = "INSERT INTO customer_profiles (user_id, date_of_birth, address, id_card_number, "
                + "id_card_image_front, id_card_image_back, driver_license_number, driver_license_image, "
                + "driver_license_expiry, verification_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, profile.getUserId());
            ps.setDate(2, profile.getDateOfBirth() != null ? Date.valueOf(profile.getDateOfBirth()) : null);
            ps.setString(3, profile.getAddress());
            ps.setString(4, profile.getIdCardNumber());
            ps.setString(5, profile.getIdCardImageFront());
            ps.setString(6, profile.getIdCardImageBack());
            ps.setString(7, profile.getDriverLicenseNumber());
            ps.setString(8, profile.getDriverLicenseImage());
            ps.setDate(9, profile.getDriverLicenseExpiry() != null ? Date.valueOf(profile.getDriverLicenseExpiry()) : null);
            ps.setString(10, profile.getVerificationStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    public boolean update(CustomerProfile profile) throws SQLException {
        String sql = "UPDATE customer_profiles SET date_of_birth = ?, address = ?, id_card_number = ?, "
                + "id_card_image_front = ?, id_card_image_back = ?, driver_license_number = ?, "
                + "driver_license_image = ?, driver_license_expiry = ?, verification_status = ?, updated_at = GETDATE() "
                + "WHERE profile_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, profile.getDateOfBirth() != null ? Date.valueOf(profile.getDateOfBirth()) : null);
            ps.setString(2, profile.getAddress());
            ps.setString(3, profile.getIdCardNumber());
            ps.setString(4, profile.getIdCardImageFront());
            ps.setString(5, profile.getIdCardImageBack());
            ps.setString(6, profile.getDriverLicenseNumber());
            ps.setString(7, profile.getDriverLicenseImage());
            ps.setDate(8, profile.getDriverLicenseExpiry() != null ? Date.valueOf(profile.getDriverLicenseExpiry()) : null);
            ps.setString(9, profile.getVerificationStatus());
            ps.setInt(10, profile.getProfileId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateVerificationStatus(int profileId, String status, int verifiedBy) throws SQLException {
        String sql = "UPDATE customer_profiles SET verification_status = ?, verified_by = ?, "
                + "verified_at = GETDATE(), updated_at = GETDATE() WHERE profile_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, verifiedBy);
            ps.setInt(3, profileId);
            return ps.executeUpdate() > 0;
        }
    }

    public List<CustomerProfile> findAll() throws SQLException {

        List<CustomerProfile> list = new ArrayList<>();

        String sql = "SELECT cp.*, u.full_name, u.email " +
                 "FROM customer_profiles cp " +
                 "JOIN users u ON cp.user_id = u.user_id " +
                 "ORDER BY cp.created_at DESC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                list.add(mapRow(rs));

            }

        }

        return list;

    }

    public CustomerProfile findById(int profileId)
            throws SQLException {

        String sql
                = "SELECT * "
                + "FROM customer_profiles "
                + "WHERE profile_id=?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, profileId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return mapRow(rs);

            }

        }

        return null;

    }

    public List<CustomerProfile> findByStatus(String status)
            throws SQLException {

        List<CustomerProfile> list = new ArrayList<>();

        String sql
                = "SELECT * "
                + "FROM customer_profiles "
                + "WHERE verification_status=? "
                + "ORDER BY created_at DESC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                list.add(mapRow(rs));

            }

        }

        return list;

    }

    public List<CustomerProfile> search(String keyword)
            throws SQLException {

        List<CustomerProfile> list = new ArrayList<>();

        String sql
                = "SELECT cp.* "
                + "FROM customer_profiles cp "
                + "JOIN users u ON cp.user_id=u.user_id "
                + "WHERE "
                + "u.full_name LIKE ? "
                + "OR u.email LIKE ? "
                + "OR cp.id_card_number LIKE ? "
                + "OR cp.driver_license_number LIKE ? "
                + "ORDER BY cp.created_at DESC";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            String key = "%" + keyword + "%";

            ps.setString(1, key);
            ps.setString(2, key);
            ps.setString(3, key);
            ps.setString(4, key);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                list.add(mapRow(rs));

            }

        }

        return list;

    }

    public String getCustomerName(int userId)
            throws SQLException {

        String sql
                = "SELECT full_name "
                + "FROM users "
                + "WHERE user_id=?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getString("full_name");

            }

        }

        return "";

    }

    public String getCustomerEmail(int userId)
            throws SQLException {

        String sql
                = "SELECT email "
                + "FROM users "
                + "WHERE user_id=?";

        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                return rs.getString("email");

            }

        }

        return "";

    }

    private CustomerProfile mapRow(ResultSet rs) throws SQLException {
        CustomerProfile p = new CustomerProfile();
        p.setProfileId(rs.getInt("profile_id"));
        p.setUserId(rs.getInt("user_id"));
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) {
            p.setDateOfBirth(dob.toLocalDate());
        }
        p.setAddress(rs.getString("address"));
        p.setIdCardNumber(rs.getString("id_card_number"));
        p.setIdCardImageFront(rs.getString("id_card_image_front"));
        p.setIdCardImageBack(rs.getString("id_card_image_back"));
        p.setDriverLicenseNumber(rs.getString("driver_license_number"));
        p.setDriverLicenseImage(rs.getString("driver_license_image"));
        Date dle = rs.getDate("driver_license_expiry");
        if (dle != null) {
            p.setDriverLicenseExpiry(dle.toLocalDate());
        }
        p.setVerificationStatus(rs.getString("verification_status"));
        int verifiedBy = rs.getInt("verified_by");
        if (!rs.wasNull()) {
            p.setVerifiedBy(verifiedBy);
        }
        Timestamp verifiedAt = rs.getTimestamp("verified_at");
        if (verifiedAt != null) {
            p.setVerifiedAt(verifiedAt.toLocalDateTime());
        }
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            p.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            p.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        return p;
    }
}
