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

    // Finds all audit logs for a specific entity (e.g. VEHICLE #5), joined with the acting user's name, newest first.
    public List<AuditLog> findByEntity(String entityType, int entityId) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name AS user_full_name FROM audit_logs a "
                   + "LEFT JOIN users u ON a.user_id = u.user_id "
                   + "WHERE a.entity_type = ? AND a.entity_id = ? ORDER BY a.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = mapRow(rs);
                    log.setUserName(rs.getString("user_full_name"));
                    logs.add(log);
                }
            }
        }
        return logs;
    }

    // Inserts an audit log entry (user, action, entity, old/new values, IP, description) and returns the generated log_id.
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

    // Maps an audit_logs table row to an AuditLog object (handles nullable user_id/entity_id fields).
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
