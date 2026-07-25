package com.swp391.carrental.vehicle.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.VehicleImage;

/*
 * Name: VehicleImageDAO
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 2.0
 * Description: Data Access Object for VehicleImage entities.
 */

public class VehicleImageDAO {

    public List<VehicleImage> findByVehicleId(int vehicleId) throws SQLException {
        List<VehicleImage> images = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_images WHERE vehicle_id = ? ORDER BY is_primary DESC, sort_order ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) images.add(mapRow(rs));
            }
        }
        return images;
    }



    public int insert(VehicleImage image) throws SQLException {
        String sql = "INSERT INTO vehicle_images (vehicle_id, image_url, caption, is_primary, sort_order) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, image.getVehicleId());
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
        String sql = "DELETE FROM vehicle_images WHERE image_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, imageId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteByVehicleId(int vehicleId) throws SQLException {
        String sql = "DELETE FROM vehicle_images WHERE vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            return ps.executeUpdate() > 0;
        }
    }



    public boolean setPrimary(int imageId, boolean isPrimary) throws SQLException {
        String sql = "UPDATE vehicle_images SET is_primary = ? WHERE image_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isPrimary);
            ps.setInt(2, imageId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean clearPrimaryByVehicleId(int vehicleId) throws SQLException {
        String sql = "UPDATE vehicle_images SET is_primary = 0 WHERE vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            return ps.executeUpdate() > 0;
        }
    }



    public boolean update(VehicleImage image) throws SQLException {
        String sql = "UPDATE vehicle_images SET caption = ?, sort_order = ? WHERE image_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, image.getCaption());
            ps.setInt(2, image.getSortOrder());
            ps.setInt(3, image.getImageId());
            return ps.executeUpdate() > 0;
        }
    }

    private VehicleImage mapRow(ResultSet rs) throws SQLException {
        VehicleImage img = new VehicleImage();
        img.setImageId(rs.getInt("image_id"));
        img.setVehicleId(rs.getInt("vehicle_id"));
        img.setImageUrl(rs.getString("image_url"));
        img.setCaption(rs.getString("caption"));
        img.setPrimary(rs.getBoolean("is_primary"));
        img.setSortOrder(rs.getInt("sort_order"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) img.setCreatedAt(ca.toLocalDateTime());
        return img;
    }
}
