package com.swp391.carrental.notification.service;

import java.sql.SQLException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.dao.NotificationDAO;
import com.swp391.carrental.notification.model.Notification;

public class NotificationService {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    public List<Notification> getNotificationsByUserId(int userId) {
        try {
            return notificationDAO.findByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notifications.", e);
        }
    }

    public List<Notification> getUnreadNotifications(int userId) {
        try {
            return notificationDAO.findUnreadByUserId(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get unread notifications.", e);
        }
    }

    public int getUnreadCount(int userId) {
        try {
            return notificationDAO.getUnreadCount(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to count unread notifications.", e);
        }
    }

    public Notification getNotificationById(int notificationId) {
        try {
            return notificationDAO.findById(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to get notification.", e);
        }
    }

    public int createNotification(Notification notification) {
        try {
            return notificationDAO.insert(notification);
        } catch (SQLException e) {
            throw new AppException("Failed to create notification.", e);
        }
    }

    public boolean markNotificationAsRead(int notificationId) {
        try {
            return notificationDAO.markAsRead(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark notification as read.", e);
        }
    }

    public boolean markAllNotificationsAsRead(int userId) {
        try {
            return notificationDAO.markAllAsRead(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to mark all notifications as read.", e);
        }
    }

    public boolean deleteNotification(int notificationId) {
        try {
            return notificationDAO.delete(notificationId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete notification.", e);
        }
    }
}
