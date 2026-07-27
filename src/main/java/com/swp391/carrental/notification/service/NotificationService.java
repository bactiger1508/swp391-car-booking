/*
 * Name: NotificationService
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Business logic layer for creating, retrieving and updating user notifications.
 */
package com.swp391.carrental.notification.service;

import java.sql.SQLException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.dao.NotificationDAO;
import com.swp391.carrental.notification.model.Notification;

/**
 * Provides notification operations to controllers, wrapping DAO/SQL failures
 * into {@link AppException} so callers do not need to handle checked SQL exceptions.
 */
public class NotificationService {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    /** Returns all notifications for a user, newest first. */
    public List<Notification> getNotificationsByUserId(int userId) {
        try {
            return notificationDAO.findByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notifications.", e);
        }
    }

    /** Returns only the unread notifications for a user, newest first. */
    public List<Notification> getUnreadNotifications(int userId) {
        try {
            return notificationDAO.findUnreadByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get unread notifications.", e);
        }
    }

    /** Returns the number of unread notifications for a user (for the header badge). */
    public int getUnreadCount(int userId) {
        try {
            return notificationDAO.getUnreadCount(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to count unread notifications.", e);
        }
    }

    /** Returns a single notification by id, or {@code null} if it does not exist. */
    public Notification getNotificationById(int notificationId) {
        try {
            return notificationDAO.findById(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notification.", e);
        }
    }

    /** Persists a new notification and returns its generated id. */
    public int createNotification(Notification notification) {
        try {
            return notificationDAO.insert(notification);
        } catch (SQLException e) {
            throw new AppException("Failed to create notification.", e);
        }
    }

    /** Marks a single notification as read. Caller is responsible for ownership checks. */
    public boolean markNotificationAsRead(int notificationId) {
        try {
            return notificationDAO.markAsRead(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark notification as read.", e);
        }
    }

    /** Marks every unread notification of a user as read in one bulk update. */
    public boolean markAllNotificationsAsRead(int userId) {
        try {
            return notificationDAO.markAllAsRead(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark all notifications as read.", e);
        }
    }

    /** Deletes a single notification by id. */
    public boolean deleteNotification(int notificationId) {
        try {
            return notificationDAO.delete(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete notification.", e);
        }
    }
}
