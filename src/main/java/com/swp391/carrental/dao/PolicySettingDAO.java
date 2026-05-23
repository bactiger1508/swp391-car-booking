package com.swp391.carrental.dao;

import com.swp391.carrental.model.PolicySetting;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
        String sql = "UPDATE policy_settings SET policy_value = ?, updated_by = ?, updated_at = GETDATE() WHERE policy_key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, policyValue);
            ps.setInt(2, updatedBy);
            ps.setString(3, policyKey);
            return ps.executeUpdate() > 0;
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
