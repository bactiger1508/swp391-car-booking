/*
 * Name: AuditLogService
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Business logic layer for creating and retrieving system audit logs.
 */
package com.swp391.carrental.audit.service;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.audit.dao.AuditLogDAO;
import com.swp391.carrental.audit.model.AuditLog;

/**
 * Service for managing system audit logs and tracking user actions on resources.
 */
public class AuditLogService {
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    /** Retrieves all audit logs in reverse chronological order. */
    public List<AuditLog> getAllLogs() {
        try {
            return auditLogDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get audit logs.", e);
        }
    }

    /** Filters audit logs by user, action, entity type, and date range (any parameter can be null). */
    public List<AuditLog> getLogsByFilters(Integer userId, String action, String entityType,
                                            LocalDateTime startDate, LocalDateTime endDate) {
        try {
            return auditLogDAO.findByFilters(userId, action, entityType, startDate, endDate);
        } catch (SQLException e) {
            throw new AppException("Failed to filter audit logs.", e);
        }
    }

    /** Creates new audit log entry and returns the generated audit log ID. */
    public int createLog(AuditLog auditLog) {
        try {
            return auditLogDAO.insert(auditLog);
        } catch (SQLException e) {
            throw new AppException("Failed to create audit log.", e);
        }
    }

    /** Logs a system action with user, action type, entity type, entity ID, and rich description details. */
    public void logAction(int userId, String action, String entityType, Integer entityId, String details) {
        AuditLog log = new AuditLog(userId, action, entityType, entityId, details);
        createLog(log);
    }
}
