package com.swp391.carrental.dao;

import com.swp391.carrental.model.CarImage;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for CarImage entities.
 */
public class CarImageDAO {

    public List<CarImage> findByCarId(int carId) throws SQLException {
        List<CarImage> images = new ArrayList<>();
        String sql = "SELECT * FROM car_images WHERE car_id = ? ORDER BY sort_order";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) images.add(mapRow(rs));
            }
        }
        return images;
    }

    public int insert(CarImage image) throws SQLException {
        String sql = "INSERT INTO car_images (car_id, image_url, caption, is_primary, sort_order) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, image.getCarId());
            ps.setString(2, image.getImageUrl());
            ps.setString(3, image.getCaption());
            ps.setBoolean(4, image.isPrimary());
            ps.setInt(5, image.getSortOrder());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean delete(int imageId) throws SQLException {
        String sql = "DELETE FROM car_images WHERE image_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteByCarId(int carId) throws SQLException {
        String sql = "DELETE FROM car_images WHERE car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            return ps.executeUpdate() > 0;
        }
    }

    private CarImage mapRow(ResultSet rs) throws SQLException {
        CarImage img = new CarImage();
        img.setImageId(rs.getInt("image_id"));
        img.setCarId(rs.getInt("car_id"));
        img.setImageUrl(rs.getString("image_url"));
        img.setCaption(rs.getString("caption"));
        img.setPrimary(rs.getBoolean("is_primary"));
        img.setSortOrder(rs.getInt("sort_order"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) img.setCreatedAt(createdAt.toLocalDateTime());
        return img;
    }
}
