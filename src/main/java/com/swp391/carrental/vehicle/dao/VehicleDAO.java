package com.swp391.carrental.vehicle.dao;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.Vehicle;

/*
 * Name: VehicleDAO
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 2.0
 * Description: Data Access Object for Vehicle entities.
 */

/**
 * Executes raw SQL against the {@code vehicles} table (joined with brand/model lookups) using plain JDBC.
 */
public class VehicleDAO {

    private static final String BASE_SELECT =
            "SELECT c.*, m.model_name AS model, b.brand_name AS brand, b.brand_id AS brand_id "
          + "FROM vehicles c "
          + "JOIN vehicle_models m ON c.model_id = m.model_id "
          + "JOIN vehicle_brands b ON m.brand_id = b.brand_id ";

    /** Returns a vehicle by id, or {@code null} if not found. */
    public Vehicle findById(int vehicleId) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Returns every vehicle, most recently created first. */
    public List<Vehicle> findAll() throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY c.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) vehicles.add(mapRow(rs));
        }
        return vehicles;
    }

    /** Returns every vehicle with the given status, ordered by brand and model. */
    public List<Vehicle> findByStatus(String status) throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE c.status = ? ORDER BY brand, model";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    /** Returns a vehicle by its license plate, or {@code null} if not found. */
    public Vehicle findByLicensePlate(String licensePlate) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.license_plate = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, licensePlate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Returns AVAILABLE vehicles with no confirmed/in-progress booking overlapping the given date range (including 60-minute buffer time). */
    public List<Vehicle> findAvailable(Timestamp startDate, Timestamp endDate) throws SQLException {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = BASE_SELECT
                   + "WHERE c.status = 'AVAILABLE' "
                   + "AND c.vehicle_id NOT IN ("
                   + "  SELECT bk.vehicle_id FROM bookings bk "
                   + "  WHERE bk.status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS') "
                   + "  AND bk.start_date < DATEADD(minute, 60, ?) AND DATEADD(minute, 60, bk.end_date) > ?"
                   + ") ORDER BY c.daily_rate";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, endDate);
            ps.setTimestamp(2, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) vehicles.add(mapRow(rs));
            }
        }
        return vehicles;
    }

    /** Inserts a new vehicle and returns its generated id, or -1 if generation failed. */
    public int insert(Vehicle vehicle) throws SQLException {
        String sql = "INSERT INTO vehicles (license_plate, model_id, year, color, seats, transmission, "
                   + "fuel_type, daily_rate, description, status, mileage, location, features) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, vehicle.getLicensePlate());
            ps.setInt(2, vehicle.getModelId());
            ps.setInt(3, vehicle.getYear());
            ps.setString(4, vehicle.getColor());
            ps.setInt(5, vehicle.getSeats());
            ps.setString(6, vehicle.getTransmission());
            ps.setString(7, vehicle.getFuelType());
            ps.setBigDecimal(8, vehicle.getDailyRate());
            ps.setString(9, vehicle.getDescription());
            ps.setString(10, vehicle.getStatus());
            ps.setInt(11, vehicle.getMileage());
            ps.setString(12, vehicle.getLocation());
            ps.setString(13, vehicle.getFeatures());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /** Updates every editable field of an existing vehicle by id. */
    public boolean update(Vehicle vehicle) throws SQLException {
        String sql = "UPDATE vehicles SET license_plate = ?, model_id = ?, year = ?, color = ?, "
                   + "seats = ?, transmission = ?, fuel_type = ?, daily_rate = ?, description = ?, "
                   + "status = ?, mileage = ?, location = ?, features = ?, updated_at = GETDATE() "
                   + "WHERE vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicle.getLicensePlate());
            ps.setInt(2, vehicle.getModelId());
            ps.setInt(3, vehicle.getYear());
            ps.setString(4, vehicle.getColor());
            ps.setInt(5, vehicle.getSeats());
            ps.setString(6, vehicle.getTransmission());
            ps.setString(7, vehicle.getFuelType());
            ps.setBigDecimal(8, vehicle.getDailyRate());
            ps.setString(9, vehicle.getDescription());
            ps.setString(10, vehicle.getStatus());
            ps.setInt(11, vehicle.getMileage());
            ps.setString(12, vehicle.getLocation());
            ps.setString(13, vehicle.getFeatures());
            ps.setInt(14, vehicle.getVehicleId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Updates only a vehicle's status (AVAILABLE, RENTED, MAINTENANCE, INACTIVE). */
    public boolean updateStatus(int vehicleId, String status) throws SQLException {
        String sql = "UPDATE vehicles SET status = ?, updated_at = GETDATE() WHERE vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, vehicleId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Permanently deletes a vehicle by id; fails with a FK-violation SQLException if it is still referenced. */
    public boolean delete(int vehicleId) throws SQLException {
        String sql = "DELETE FROM vehicles WHERE vehicle_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Maps a single {@code vehicles} (joined) result set row into a {@link Vehicle}. */
    private Vehicle mapRow(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setVehicleId(rs.getInt("vehicle_id"));
        v.setLicensePlate(rs.getString("license_plate"));
        v.setModelId(rs.getInt("model_id"));
        v.setBrandId(rs.getInt("brand_id"));
        v.setBrand(rs.getString("brand"));
        v.setModel(rs.getString("model"));
        v.setYear(rs.getInt("year"));
        v.setColor(rs.getString("color"));
        v.setSeats(rs.getInt("seats"));
        v.setTransmission(rs.getString("transmission"));
        v.setFuelType(rs.getString("fuel_type"));
        v.setDailyRate(rs.getBigDecimal("daily_rate"));
        v.setDescription(rs.getString("description"));
        v.setStatus(rs.getString("status"));
        v.setMileage(rs.getInt("mileage"));
        v.setLocation(rs.getString("location"));
        v.setFeatures(rs.getString("features"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) v.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) v.setUpdatedAt(updatedAt.toLocalDateTime());
        return v;
    }
}
