package com.swp391.carrental.audit.service;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.audit.dao.AuditLogDAO;
import com.swp391.carrental.audit.model.AuditLog;

public class AuditLogService {
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    public List<AuditLog> getAllLogs() {
        try {
            return auditLogDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get audit logs.", e);
        }
    }

    public List<AuditLog> getLogsByFilters(Integer userId, String action, String entityType,
                                            LocalDateTime startDate, LocalDateTime endDate) {
        try {
            return auditLogDAO.findByFilters(userId, action, entityType, startDate, endDate);
        } catch (SQLException e) {
            throw new AppException("Failed to filter audit logs.", e);
        }
    }

    public List<AuditLog> getLogsByUserId(int userId) {
        try {
            return auditLogDAO.findByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get logs for user.", e);
        }
    }

    public List<AuditLog> getLogsByEntityType(String entityType) {
        try {
            return auditLogDAO.findByEntityType(entityType);
        } catch (SQLException e) {
            throw new AppException("Failed to get logs by entity type.", e);
        }
    }

    public AuditLog getLogById(int auditId) {
        try {
            return auditLogDAO.findById(auditId);
        } catch (SQLException e) {
            throw new AppException("Failed to get audit log.", e);
        }
    }

    public int createLog(AuditLog auditLog) {
        try {
            return auditLogDAO.insert(auditLog);
        } catch (SQLException e) {
            throw new AppException("Failed to create audit log.", e);
        }
    }

    public void logAction(int userId, String action, String entityType, Integer entityId, String details) {
        AuditLog log = new AuditLog(userId, action, entityType, entityId, details);
        createLog(log);
    }
}
