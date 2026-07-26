package com.swp391.carrental.core.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.model.AuditLog;
import com.swp391.carrental.core.util.DBContext;

/*
 * Name: AuditLogDAO
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for AuditLogDAO.
 */



/**
 * Data Access Object for AuditLog entities.
 */
public class AuditLogDAO {

    public List<AuditLog> findAll() throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT TOP 200 * FROM audit_logs ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) logs.add(mapRow(rs));
        }
        return logs;
    }

    public List<AuditLog> findByEntity(String entityType, int entityId) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM audit_logs WHERE entity_type = ? AND entity_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) logs.add(mapRow(rs));
            }
        }
        return logs;
    }

    public int insert(AuditLog log) throws SQLException {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_value, new_value, ip_address, description) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (log.getUserId() != null) ps.setInt(1, log.getUserId()); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, log.getAction());
            ps.setString(3, log.getEntityType());
            if (log.getEntityId() != null) ps.setInt(4, log.getEntityId()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, log.getOldValue());
            ps.setString(6, log.getNewValue());
            ps.setString(7, log.getIpAddress());
            ps.setString(8, log.getDescription());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog l = new AuditLog();
        l.setLogId(rs.getInt("log_id"));
        int uid = rs.getInt("user_id"); if (!rs.wasNull()) l.setUserId(uid);
        l.setAction(rs.getString("action"));
        l.setEntityType(rs.getString("entity_type"));
        int eid = rs.getInt("entity_id"); if (!rs.wasNull()) l.setEntityId(eid);
        l.setOldValue(rs.getString("old_value"));
        l.setNewValue(rs.getString("new_value"));
        l.setIpAddress(rs.getString("ip_address"));
        l.setDescription(rs.getString("description"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) l.setCreatedAt(ca.toLocalDateTime());
        return l;
    }
}
