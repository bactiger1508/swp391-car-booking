/*
 * Name: Notification
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Entity representing an in-app notification sent to a user (booking, payment, contract, handover or system events).
 */
package com.swp391.carrental.notification.model;

import java.time.LocalDateTime;

/**
 * Represents a single notification record delivered to a user, optionally
 * linked to a source entity (booking, contract, payment, handover, ...) via
 * {@code referenceType}/{@code referenceId}.
 */
public class Notification {
    private int notificationId;
    private int userId;
    private String title;
    private String message;
    private String notificationType;
    private String referenceType;
    private Integer referenceId;
    private boolean isRead;
    private LocalDateTime readAt;
    private LocalDateTime createdAt;

    /** Creates an empty notification (used when mapping from a database row). */
    public Notification() {}

    /**
     * Creates a new unread notification for a user, timestamped at creation.
     *
     * @param userId           id of the recipient user
     * @param title            short notification headline
     * @param message          full notification message body
     * @param notificationType category of the event (e.g. BOOKING, PAYMENT, CONTRACT, HANDOVER, RETURN)
     */
    public Notification(int userId, String title, String message, String notificationType) {
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.notificationType = notificationType;
        this.isRead = false;
        this.createdAt = LocalDateTime.now();
    }

    // Getters & Setters
    public int getNotificationId() { return notificationId; }
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getNotificationType() { return notificationType; }
    public void setNotificationType(String notificationType) { this.notificationType = notificationType; }

    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }

    public Integer getReferenceId() { return referenceId; }
    public void setReferenceId(Integer referenceId) { this.referenceId = referenceId; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Notification{" + "notificationId=" + notificationId + ", userId=" + userId +
                ", title='" + title + '\'' + ", notificationType='" + notificationType + '\'' +
                ", isRead=" + isRead + ", createdAt=" + createdAt + '}';
    }
}
