package com.swp391.carrental.vehicle.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.VehicleModel;

public class VehicleModelDAO {

    public List<VehicleModel> findByBrandId(int brandId) throws SQLException {
        List<VehicleModel> models = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_models WHERE brand_id = ? AND is_active = 1 ORDER BY model_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    models.add(mapRow(rs));
                }
            }
        }
        return models;
    }

    public List<VehicleModel> findByBrandIdIncludingInactive(int brandId) throws SQLException {
        List<VehicleModel> models = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_models WHERE brand_id = ? ORDER BY model_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    models.add(mapRow(rs));
                }
            }
        }
        return models;
    }

    public VehicleModel findById(int modelId) throws SQLException {
        String sql = "SELECT * FROM vehicle_models WHERE model_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, modelId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public VehicleModel findByBrandAndName(int brandId, String modelName) throws SQLException {
        String sql = "SELECT * FROM vehicle_models WHERE brand_id = ? AND model_name = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            ps.setString(2, modelName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public int insert(int brandId, String modelName) throws SQLException {
        String sql = "INSERT INTO vehicle_models (brand_id, model_name) VALUES (?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, brandId);
            ps.setString(2, modelName);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean updateActive(int modelId, boolean active) throws SQLException {
        String sql = "UPDATE vehicle_models SET is_active = ?, updated_at = SYSDATETIME() WHERE model_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, modelId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateName(int modelId, String modelName) throws SQLException {
        String sql = "UPDATE vehicle_models SET model_name = ?, updated_at = SYSDATETIME() WHERE model_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, modelName);
            ps.setInt(2, modelId);
            return ps.executeUpdate() > 0;
        }
    }

    private VehicleModel mapRow(ResultSet rs) throws SQLException {
        VehicleModel model = new VehicleModel();
        model.setModelId(rs.getInt("model_id"));
        model.setBrandId(rs.getInt("brand_id"));
        model.setModelName(rs.getString("model_name"));
        model.setActive(rs.getBoolean("is_active"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) model.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) model.setUpdatedAt(updatedAt.toLocalDateTime());
        return model;
    }
}
