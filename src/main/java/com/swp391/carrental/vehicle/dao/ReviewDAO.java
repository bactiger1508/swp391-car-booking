package com.swp391.carrental.vehicle.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.Review;

/*
 * Name: ReviewDAO
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for ReviewDAO.
 */



/**
 * Data Access Object for Review entities.
 */
public class ReviewDAO {

    // Finds up to 100 visible reviews for a vehicle (delegates to the paginated overload).
    public List<Review> findByVehicleId(int vehicleId) throws SQLException {
        return findByVehicleId(vehicleId, 0, 100);
    }

    // Finds visible reviews for a vehicle with pagination, ordered by newest first.
    public List<Review> findByVehicleId(int vehicleId, int offset, int limit) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT review_id, booking_id, vehicle_id, customer_id, rating, comment, is_visible, created_at, updated_at "
                   + "FROM reviews WHERE vehicle_id = ? AND is_visible = 1 ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reviews.add(mapRow(rs));
                }
            }
        }
        return reviews;
    }

    // Counts visible reviews for a vehicle (used for pagination and rating summary).
    public int countByVehicleId(int vehicleId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reviews WHERE vehicle_id = ? AND is_visible = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // Computes average rating across visible reviews for a vehicle (0.0 if none).
    public double getAverageRating(int vehicleId) throws SQLException {
        String sql = "SELECT AVG(CAST(rating AS FLOAT)) FROM reviews WHERE vehicle_id = ? AND is_visible = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        }
        return 0.0;
    }

    // Inserts a new review as visible and returns the generated review_id.
    public int insert(Review review) throws SQLException {
        String sql = "INSERT INTO reviews (booking_id, customer_id, vehicle_id, rating, comment, is_visible) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, review.getBookingId());
            ps.setInt(2, review.getCustomerId());
            ps.setInt(3, review.getVehicleId());
            ps.setInt(4, review.getRating());
            ps.setString(5, review.getComment());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    // Updates review visibility flag (true=show, false=hide) for admin moderation.
    public boolean updateReviewVisibility(int reviewId, boolean isVisible) throws SQLException {
        String sql = "UPDATE reviews SET is_visible = ? WHERE review_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isVisible);
            ps.setInt(2, reviewId);
            return ps.executeUpdate() > 0;
        }
    }

    // Maps a reviews table row to a Review object.
    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setVehicleId(rs.getInt("vehicle_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setVisible(rs.getBoolean("is_visible"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) r.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) r.setUpdatedAt(ua.toLocalDateTime());
        return r;
    }
}
