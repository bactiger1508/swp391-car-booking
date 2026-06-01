/*
 * Name: VehicleDAO
 * @Author: TinhNVHE160000 (Vehicle Module)
 * Date: 31/05/2026
 * Version: 1.0
 * Description: Data Access Object for Vehicle entity
 */
package com.swp391.carrental.dao;

import com.swp391.carrental.model.Vehicle;
import com.swp391.carrental.model.VehicleImage;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Vehicle operations.
 * Handles all database operations related to vehicles.
 */
public class VehicleDAO {

    /**
     * Get all vehicles with optional filters.
     */
    public List<Vehicle> getAllVehicles() throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM cars ORDER BY created_at DESC";
        
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    /**
     * Get available vehicles (status = AVAILABLE).
     */
    public List<Vehicle> getAvailableVehicles() throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM cars WHERE status = 'AVAILABLE' ORDER BY brand ASC";
        
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    /**
     * Get vehicles by status.
     */
    public List<Vehicle> getVehiclesByStatus(String status) throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM cars WHERE status = ? ORDER BY brand ASC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    vehicles.add(mapRow(rs));
                }
            }
        }
        return vehicles;
    }

    /**
     * Get vehicle by ID.
     */
    public Vehicle getVehicleById(int vehicleId) throws SQLException {
        String sql = "SELECT * FROM cars WHERE car_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Vehicle vehicle = mapRow(rs);
                    // Load images
                    vehicle.setImages(getVehicleImages(vehicleId, conn));
                    return vehicle;
                }
            }
        }
        return null;
    }

    /**
     * Get vehicle by license plate.
     */
    public Vehicle getVehicleByLicensePlate(String licensePlate) throws SQLException {
        String sql = "SELECT * FROM cars WHERE license_plate = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, licensePlate);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Add new vehicle.
     */
    public int addVehicle(Vehicle vehicle) throws SQLException {
        String sql = "INSERT INTO cars (license_plate, brand, model, year, color, fuel_type, " +
                    "transmission, seats, daily_rate, status, location, description, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, vehicle.getLicensePlate());
            ps.setString(2, vehicle.getBrand());
            ps.setString(3, vehicle.getModel());
            ps.setInt(4, vehicle.getYear());
            ps.setString(5, vehicle.getColor());
            ps.setString(6, vehicle.getFuelType());
            ps.setString(7, vehicle.getTransmission());
            ps.setInt(8, vehicle.getSeats());
            ps.setDouble(9, vehicle.getDailyRate());
            ps.setString(10, vehicle.getStatus() != null ? vehicle.getStatus() : "AVAILABLE");
            ps.setString(11, vehicle.getLocation());
            ps.setString(12, vehicle.getDescription());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Update vehicle information.
     */
    public boolean updateVehicle(Vehicle vehicle) throws SQLException {
        String sql = "UPDATE cars SET brand = ?, model = ?, year = ?, color = ?, " +
                    "fuel_type = ?, transmission = ?, seats = ?, daily_rate = ?, " +
                    "location = ?, description = ?, updated_at = GETDATE() WHERE car_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, vehicle.getBrand());
            ps.setString(2, vehicle.getModel());
            ps.setInt(3, vehicle.getYear());
            ps.setString(4, vehicle.getColor());
            ps.setString(5, vehicle.getFuelType());
            ps.setString(6, vehicle.getTransmission());
            ps.setInt(7, vehicle.getSeats());
            ps.setDouble(8, vehicle.getDailyRate());
            ps.setString(9, vehicle.getLocation());
            ps.setString(10, vehicle.getDescription());
            ps.setInt(11, vehicle.getVehicleId());
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Change vehicle status.
     */
    public boolean changeVehicleStatus(int vehicleId, String status) throws SQLException {
        String sql = "UPDATE cars SET status = ?, updated_at = GETDATE() WHERE car_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, vehicleId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update vehicle daily rate.
     */
    public boolean updateDailyRate(int vehicleId, double newRate) throws SQLException {
        String sql = "UPDATE cars SET daily_rate = ?, updated_at = GETDATE() WHERE car_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDouble(1, newRate);
            ps.setInt(2, vehicleId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete vehicle (soft delete - mark as INACTIVE).
     */
    public boolean deleteVehicle(int vehicleId) throws SQLException {
        return changeVehicleStatus(vehicleId, "INACTIVE");
    }

    /**
     * Get vehicle images.
     */
    public List<VehicleImage> getVehicleImages(int vehicleId) throws SQLException {
        String sql = "SELECT * FROM car_images WHERE car_id = ? ORDER BY is_primary DESC, uploaded_at DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            
            try (ResultSet rs = ps.executeQuery()) {
                return getVehicleImages(vehicleId, rs);
            }
        }
    }

    /**
     * Get vehicle images using existing connection.
     */
    private List<VehicleImage> getVehicleImages(int vehicleId, Connection conn) throws SQLException {
        List<VehicleImage> images = new ArrayList<>();
        String sql = "SELECT * FROM car_images WHERE car_id = ? ORDER BY is_primary DESC, uploaded_at DESC";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VehicleImage image = new VehicleImage();
                    image.setImageId(rs.getInt("image_id"));
                    image.setVehicleId(rs.getInt("car_id"));
                    image.setImageUrl(rs.getString("image_url"));
                    image.setDescription(rs.getString("description"));
                    image.setPrimary(rs.getBoolean("is_primary"));
                    image.setUploadedAt(rs.getTimestamp("uploaded_at").toLocalDateTime());
                    images.add(image);
                }
            }
        }
        return images;
    }

    /**
     * Get vehicle images from ResultSet.
     */
    private List<VehicleImage> getVehicleImages(int vehicleId, ResultSet rs) throws SQLException {
        List<VehicleImage> images = new ArrayList<>();
        
        while (rs.next()) {
            VehicleImage image = new VehicleImage();
            image.setImageId(rs.getInt("image_id"));
            image.setVehicleId(rs.getInt("car_id"));
            image.setImageUrl(rs.getString("image_url"));
            image.setDescription(rs.getString("description"));
            image.setPrimary(rs.getBoolean("is_primary"));
            image.setUploadedAt(rs.getTimestamp("uploaded_at").toLocalDateTime());
            images.add(image);
        }
        return images;
    }

    /**
     * Add vehicle image.
     */
    public boolean addVehicleImage(VehicleImage image) throws SQLException {
        String sql = "INSERT INTO car_images (car_id, image_url, description, is_primary, uploaded_at) " +
                    "VALUES (?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, image.getVehicleId());
            ps.setString(2, image.getImageUrl());
            ps.setString(3, image.getDescription());
            ps.setBoolean(4, image.isPrimary());
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete vehicle image.
     */
    public boolean deleteVehicleImage(int imageId) throws SQLException {
        String sql = "DELETE FROM car_images WHERE image_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, imageId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Map ResultSet row to Vehicle object.
     */
    private Vehicle mapRow(ResultSet rs) throws SQLException {
        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleId(rs.getInt("car_id"));
        vehicle.setLicensePlate(rs.getString("license_plate"));
        vehicle.setBrand(rs.getString("brand"));
        vehicle.setModel(rs.getString("model"));
        vehicle.setYear(rs.getInt("year"));
        vehicle.setColor(rs.getString("color"));
        vehicle.setFuelType(rs.getString("fuel_type"));
        vehicle.setTransmission(rs.getString("transmission"));
        vehicle.setSeats(rs.getInt("seats"));
        vehicle.setDailyRate(rs.getDouble("daily_rate"));
        vehicle.setStatus(rs.getString("status"));
        vehicle.setLocation(rs.getString("location"));
        vehicle.setDescription(rs.getString("description"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            vehicle.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            vehicle.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return vehicle;
    }
}
