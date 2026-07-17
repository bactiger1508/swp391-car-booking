package com.swp391.carrental.audit.model;

import java.time.LocalDateTime;

public class AuditLog {
    private int auditId;
    private int userId;
    private String action;  // CREATE, READ, UPDATE, DELETE, etc.
    private String entityType;  // USER, CAR, BOOKING, CONTRACT, PAYMENT, etc.
    private Integer entityId;
    private String details;
    private String ipAddress;
    private LocalDateTime createdAt;

    public AuditLog() {}

    public AuditLog(int userId, String action, String entityType, Integer entityId, String details) {
        this.userId = userId;
        this.action = action;
        this.entityType = entityType;
        this.entityId = entityId;
        this.details = details;
        this.createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public int getAuditId() { return auditId; }
    public void setAuditId(int auditId) { this.auditId = auditId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public Integer getEntityId() { return entityId; }
    public void setEntityId(Integer entityId) { this.entityId = entityId; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "AuditLog{" + "auditId=" + auditId + ", userId=" + userId + ", action='" + action +
                '\'' + ", entityType='" + entityType + '\'' + ", createdAt=" + createdAt + '}';
    }
}
