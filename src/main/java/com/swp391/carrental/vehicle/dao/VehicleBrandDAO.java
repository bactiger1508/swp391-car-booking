package com.swp391.carrental.vehicle.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.VehicleBrand;

public class VehicleBrandDAO {

    public List<VehicleBrand> findAll() throws SQLException {
        List<VehicleBrand> brands = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_brands WHERE is_active = 1 ORDER BY brand_name ASC";
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                brands.add(mapRow(rs));
            }
        }
        return brands;
    }

    public List<VehicleBrand> findAllIncludingInactive() throws SQLException {
        List<VehicleBrand> brands = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_brands ORDER BY brand_name ASC";
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                brands.add(mapRow(rs));
            }
        }
        return brands;
    }

    public VehicleBrand findById(int brandId) throws SQLException {
        String sql = "SELECT * FROM vehicle_brands WHERE brand_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public VehicleBrand findByName(String brandName) throws SQLException {
        String sql = "SELECT * FROM vehicle_brands WHERE brand_name = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brandName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public int insert(String brandName) throws SQLException {
        String sql = "INSERT INTO vehicle_brands (brand_name) VALUES (?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, brandName);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean updateActive(int brandId, boolean active) throws SQLException {
        String sql = "UPDATE vehicle_brands SET is_active = ?, updated_at = SYSDATETIME() WHERE brand_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, brandId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateName(int brandId, String brandName) throws SQLException {
        String sql = "UPDATE vehicle_brands SET brand_name = ?, updated_at = SYSDATETIME() WHERE brand_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brandName);
            ps.setInt(2, brandId);
            return ps.executeUpdate() > 0;
        }
    }

    private VehicleBrand mapRow(ResultSet rs) throws SQLException {
        VehicleBrand brand = new VehicleBrand();
        brand.setBrandId(rs.getInt("brand_id"));
        brand.setBrandName(rs.getString("brand_name"));
        brand.setActive(rs.getBoolean("is_active"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) brand.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) brand.setUpdatedAt(updatedAt.toLocalDateTime());
        return brand;
    }
}
