/*
 * Name: PolicySettingDAO
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for PolicySettingDAO.
 */
package com.swp391.carrental.dao;

import com.swp391.carrental.model.PolicySetting;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for PolicySetting entities.
 */
public class PolicySettingDAO {

    public PolicySetting findByKey(String policyKey) throws SQLException {
        String sql = "SELECT * FROM policy_settings WHERE policy_key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, policyKey);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<PolicySetting> findAll() throws SQLException {
        List<PolicySetting> list = new ArrayList<>();
        String sql = "SELECT * FROM policy_settings ORDER BY category, policy_key";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<PolicySetting> findByCategory(String category) throws SQLException {
        List<PolicySetting> list = new ArrayList<>();
        String sql = "SELECT * FROM policy_settings WHERE category = ? ORDER BY policy_key";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean updateValue(String policyKey, String policyValue, int updatedBy) throws SQLException {
        String selectSql = "SELECT 1 FROM policy_settings WHERE policy_key = ?";
        String updateSql = "UPDATE policy_settings SET policy_value = ?, updated_by = ?, updated_at = GETDATE() WHERE policy_key = ?";
        String insertSql = "INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
            selectPs.setString(1, policyKey);
            boolean exists = false;
            try (ResultSet rs = selectPs.executeQuery()) {
                if (rs.next()) exists = true;
            }
            if (exists) {
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setString(1, policyValue);
                    updatePs.setInt(2, updatedBy);
                    updatePs.setString(3, policyKey);
                    return updatePs.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setString(1, policyKey);
                    insertPs.setString(2, policyValue);
                    insertPs.setString(3, getDescriptionForKey(policyKey));
                    insertPs.setString(4, getCategoryForKey(policyKey));
                    insertPs.setInt(5, updatedBy);
                    return insertPs.executeUpdate() > 0;
                }
            }
        }
    }

    public int insert(PolicySetting ps2) throws SQLException {
        String sql = "INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, ps2.getPolicyKey());
            ps.setString(2, ps2.getPolicyValue());
            ps.setString(3, ps2.getDescription());
            ps.setString(4, ps2.getCategory());
            if (ps2.getUpdatedBy() != null) ps.setInt(5, ps2.getUpdatedBy()); else ps.setNull(5, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean delete(int policyId) throws SQLException {
        String sql = "DELETE FROM policy_settings WHERE policy_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, policyId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Updates multiple policy values in a single transaction.
     * @param updates map of policyKey -> newValue
     * @param updatedBy user performing the update
     */
    public int batchUpdateValues(Map<String, String> updates, int updatedBy) throws SQLException {
        String selectSql = "SELECT 1 FROM policy_settings WHERE policy_key = ?";
        String updateSql = "UPDATE policy_settings SET policy_value = ?, updated_by = ?, updated_at = GETDATE() WHERE policy_key = ?";
        String insertSql = "INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) VALUES (?, ?, ?, ?, ?)";
        int count = 0;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement selectPs = conn.prepareStatement(selectSql);
                 PreparedStatement updatePs = conn.prepareStatement(updateSql);
                 PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                for (Map.Entry<String, String> entry : updates.entrySet()) {
                    String key = entry.getKey();
                    String value = entry.getValue();
                    
                    selectPs.setString(1, key);
                    boolean exists = false;
                    try (ResultSet rs = selectPs.executeQuery()) {
                        if (rs.next()) {
                            exists = true;
                        }
                    }
                    
                    if (exists) {
                        updatePs.setString(1, value);
                        updatePs.setInt(2, updatedBy);
                        updatePs.setString(3, key);
                        count += updatePs.executeUpdate();
                    } else {
                        insertPs.setString(1, key);
                        insertPs.setString(2, value);
                        insertPs.setString(3, getDescriptionForKey(key));
                        insertPs.setString(4, getCategoryForKey(key));
                        insertPs.setInt(5, updatedBy);
                        count += insertPs.executeUpdate();
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
        return count;
    }

    private String getCategoryForKey(String key) {
        if ("DEPOSIT_PERCENTAGE".equals(key)) {
            return "PRICING";
        }
        return "PAYMENT";
    }

    private String getDescriptionForKey(String key) {
        switch (key) {
            case "PAYMENT_METHOD_CASH_ENABLED":
                return "Cho phép thanh toán tiền mặt";
            case "PAYMENT_METHOD_BANK_TRANSFER_ENABLED":
                return "Cho phép thanh toán chuyển khoản ngân hàng";
            case "PAYMENT_METHOD_CARD_ENABLED":
                return "Cho phép thanh toán thẻ tín dụng/ghi nợ";
            case "PAYMENT_METHOD_MOMO_ENABLED":
                return "Cho phép thanh toán qua ví MoMo";
            case "PAYMENT_METHOD_VNPAY_ENABLED":
                return "Cho phép thanh toán qua VNPay";
            case "PAYMENT_METHOD_ZALOPAY_ENABLED":
                return "Cho phép thanh toán qua ZaloPay";
            case "PAYMENT_GRACE_PERIOD_HOURS":
                return "Số giờ gia hạn thanh toán trước khi hủy đặt xe";
            case "PAYMENT_CURRENCY":
                return "Đơn vị tiền tệ sử dụng trong hệ thống";
            case "PAYMENT_PARTIAL_ALLOWED":
                return "Cho phép thanh toán từng phần (không đủ 100%)";
            case "PAYMENT_AUTO_CONFIRM_AMOUNT":
                return "Ngưỡng tự động xác nhận thanh toán (0 = tắt)";
            case "BANK_ACCOUNT_NAME":
                return "Tên tài khoản ngân hàng";
            case "BANK_ACCOUNT_NUMBER":
                return "Số tài khoản ngân hàng";
            case "BANK_NAME":
                return "Tên ngân hàng";
            case "BANK_BRANCH":
                return "Chi nhánh ngân hàng";
            case "DEPOSIT_PERCENTAGE":
                return "Phần trăm đặt cọc (%)";
            default:
                return "Cài đặt thanh toán " + key;
        }
    }

    private PolicySetting mapRow(ResultSet rs) throws SQLException {
        PolicySetting p = new PolicySetting();
        p.setPolicyId(rs.getInt("policy_id"));
        p.setPolicyKey(rs.getString("policy_key"));
        p.setPolicyValue(rs.getString("policy_value"));
        p.setDescription(rs.getString("description"));
        p.setCategory(rs.getString("category"));
        int ub = rs.getInt("updated_by"); if (!rs.wasNull()) p.setUpdatedBy(ub);
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) p.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());
        return p;
    }
}
