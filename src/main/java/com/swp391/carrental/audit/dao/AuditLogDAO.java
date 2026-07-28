/*
 * Name: AuditLogDAO
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Data Access Object for AuditLog entities (audit_logs table).
 */
package com.swp391.carrental.audit.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.audit.model.AuditLog;

/**
 * Executes raw SQL against the {@code audit_logs} table using plain JDBC (no ORM).
 */
public class AuditLogDAO {

    /** Returns every audit log entry, most recent first. */
    public List<AuditLog> findAll() throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM audit_logs ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                logs.add(mapRow(rs));
            }
        }
        return logs;
    }

    /** Returns audit log entries matching all provided filters (any parameter may be null to skip it), most recent first. */
    public List<AuditLog> findByFilters(Integer userId, String action, String entityType,
                                        LocalDateTime startDate, LocalDateTime endDate) throws SQLException {
        List<AuditLog> logs = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM audit_logs WHERE 1=1");

        if (userId != null) sql.append(" AND user_id = ?");
        if (action != null && !action.isEmpty()) sql.append(" AND action = ?");
        if (entityType != null && !entityType.isEmpty()) sql.append(" AND entity_type = ?");
        if (startDate != null) sql.append(" AND created_at >= ?");
        if (endDate != null) sql.append(" AND created_at <= ?");

        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (userId != null) ps.setInt(index++, userId);
            if (action != null && !action.isEmpty()) ps.setString(index++, action);
            if (entityType != null && !entityType.isEmpty()) ps.setString(index++, entityType);
            if (startDate != null) ps.setTimestamp(index++, Timestamp.valueOf(startDate));
            if (endDate != null) ps.setTimestamp(index++, Timestamp.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(mapRow(rs));
                }
            }
        }
        return logs;
    }

    /** Inserts a new audit log entry and returns its generated id, or -1 if generation failed. */
    public int insert(AuditLog auditLog) throws SQLException {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, description, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, auditLog.getUserId());
            ps.setString(2, auditLog.getAction());
            ps.setString(3, auditLog.getEntityType());
            ps.setObject(4, auditLog.getEntityId());
            ps.setString(5, auditLog.getDetails());
            ps.setTimestamp(6, Timestamp.valueOf(auditLog.getCreatedAt() != null ? auditLog.getCreatedAt() : LocalDateTime.now()));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    /** Maps a single {@code audit_logs} result set row into an {@link AuditLog}. */
    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setAuditId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        log.setAction(rs.getString("action"));
        log.setEntityType(rs.getString("entity_type"));
        log.setEntityId((Integer) rs.getObject("entity_id"));
        log.setDetails(rs.getString("description"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) log.setCreatedAt(createdAt.toLocalDateTime());
        return log;
    }
}
