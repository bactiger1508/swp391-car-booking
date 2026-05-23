package com.swp391.carrental.dao;

import com.swp391.carrental.model.Review;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Review entities.
 */
public class ReviewDAO {

    public Review findById(int reviewId) throws SQLException {
        String sql = "SELECT * FROM reviews WHERE review_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<Review> findByCarId(int carId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT * FROM reviews WHERE car_id = ? AND is_visible = 1 ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) reviews.add(mapRow(rs));
            }
        }
        return reviews;
    }

    public int insert(Review review) throws SQLException {
        String sql = "INSERT INTO reviews (booking_id, customer_id, car_id, rating, comment) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, review.getBookingId());
            ps.setInt(2, review.getCustomerId());
            ps.setInt(3, review.getCarId());
            ps.setInt(4, review.getRating());
            ps.setString(5, review.getComment());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean delete(int reviewId) throws SQLException {
        String sql = "DELETE FROM reviews WHERE review_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        }
    }

    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setBookingId(rs.getInt("booking_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setCarId(rs.getInt("car_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        r.setVisible(rs.getBoolean("is_visible"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) r.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) r.setUpdatedAt(ua.toLocalDateTime());
        return r;
    }
}
