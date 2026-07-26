package com.swp391.carrental.notification.service;

import java.sql.SQLException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.dao.NotificationDAO;
import com.swp391.carrental.notification.model.Notification;

public class NotificationService {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    // Retrieves all notifications belonging to a user, newest first.
    public List<Notification> getNotificationsByUserId(int userId) {
        try {
            return notificationDAO.findByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notifications.", e);
        }
    }

    // Counts unread notifications for a user (used for the header badge).
    public int getUnreadCount(int userId) {
        try {
            return notificationDAO.getUnreadCount(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to count unread notifications.", e);
        }
    }

    // Retrieves a single notification by its ID.
    public Notification getNotificationById(int notificationId) {
        try {
            return notificationDAO.findById(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notification.", e);
        }
    }

    // Creates a new notification and returns its generated ID.
    public int createNotification(Notification notification) {
        try {
            return notificationDAO.insert(notification);
        } catch (SQLException e) {
            throw new AppException("Failed to create notification.", e);
        }
    }

    // Marks a single notification as read.
    public boolean markNotificationAsRead(int notificationId) {
        try {
            return notificationDAO.markAsRead(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark notification as read.", e);
        }
    }

    // Marks all notifications belonging to a user as read.
    public boolean markAllNotificationsAsRead(int userId) {
        try {
            return notificationDAO.markAllAsRead(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark all notifications as read.", e);
        }
    }
}
