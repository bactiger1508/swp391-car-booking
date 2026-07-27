/*
 * Name: NotificationDAO
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: JDBC data access for the notifications table (CRUD, unread queries, read-state updates).
 */
package com.swp391.carrental.notification.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.notification.model.Notification;

/**
 * Executes raw SQL against the {@code notifications} table using plain JDBC
 * (no ORM), following the project's DAO layering convention.
 */
public class NotificationDAO {

    /** Returns every notification of a user, most recent first. */
    public List<Notification> findByUserId(int userId) throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapRow(rs));
                }
            }
        }
        return notifications;
    }

    /** Returns only the unread notifications of a user, most recent first. */
    public List<Notification> findUnreadByUserId(int userId) throws SQLException {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? AND is_read = 0 ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapRow(rs));
                }
            }
        }
        return notifications;
    }

    /** Counts unread notifications of a user. */
    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /** Returns a notification by id, or {@code null} if not found. */
    public Notification findById(int notificationId) throws SQLException {
        String sql = "SELECT * FROM notifications WHERE notification_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /** Inserts a new notification row and returns the generated notification id, or -1 if generation failed. */
    public int insert(Notification notification) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, title, message, notification_type, reference_type, reference_id, is_read, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, notification.getUserId());
            ps.setString(2, notification.getTitle());
            ps.setString(3, notification.getMessage());
            ps.setString(4, notification.getNotificationType());
            ps.setString(5, notification.getReferenceType());
            ps.setObject(6, notification.getReferenceId());
            ps.setBoolean(7, notification.isRead());
            ps.setTimestamp(8, Timestamp.valueOf(notification.getCreatedAt() != null ? notification.getCreatedAt() : LocalDateTime.now()));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    /** Marks a notification as read and stamps the current read time. */
    public boolean markAsRead(int notificationId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1, read_at = ? WHERE notification_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, notificationId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Marks every currently unread notification of a user as read. */
    public boolean markAllAsRead(int userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1, read_at = ? WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Deletes a single notification by id. */
    public boolean delete(int notificationId) throws SQLException {
        String sql = "DELETE FROM notifications WHERE notification_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Deletes every notification belonging to a user. */
    public boolean deleteAllByUserId(int userId) throws SQLException {
        String sql = "DELETE FROM notifications WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Maps a single {@code notifications} result set row into a {@link Notification}. */
    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getInt("notification_id"));
        n.setUserId(rs.getInt("user_id"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setNotificationType(rs.getString("notification_type"));
        n.setReferenceType(rs.getString("reference_type"));
        n.setReferenceId((Integer) rs.getObject("reference_id"));
        n.setRead(rs.getBoolean("is_read"));
        Timestamp readAt = rs.getTimestamp("read_at");
        if (readAt != null) {
            n.setReadAt(readAt.toLocalDateTime());
        }
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            n.setCreatedAt(createdAt.toLocalDateTime());
        }
        return n;
    }
}
