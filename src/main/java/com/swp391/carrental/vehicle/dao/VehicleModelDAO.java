/*
 * Name: VehicleModelDAO
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Data Access Object for VehicleModel entities (vehicle_models lookup table).
 */
package com.swp391.carrental.vehicle.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.VehicleModel;

/**
 * Executes raw SQL against the {@code vehicle_models} table using plain JDBC.
 */
public class VehicleModelDAO {

    /** Returns every active model of a brand, ordered by name. */
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

    /** Returns every model of a brand, active or not, ordered by name (for admin management screens). */
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

    /** Returns a vehicle model by id, or {@code null} if not found. */
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

    /** Returns a model by brand id and exact name, or {@code null} if not found (used for uniqueness checks). */
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

    /** Inserts a new vehicle model under a brand and returns its generated id, or -1 if generation failed. */
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

    /** Activates or deactivates (hides) a vehicle model. */
    public boolean updateActive(int modelId, boolean active) throws SQLException {
        String sql = "UPDATE vehicle_models SET is_active = ?, updated_at = SYSDATETIME() WHERE model_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, modelId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Maps a single {@code vehicle_models} result set row into a {@link VehicleModel}. */
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
