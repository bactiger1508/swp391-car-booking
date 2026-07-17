package com.swp391.carrental.vehicle.dao;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.Car;

/*
 * Name: CarDAO
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for CarDAO.
 */



/**
 * Data Access Object for Car entities.
 */
public class CarDAO {

    private static final String BASE_SELECT =
            "SELECT c.*, m.model_name AS model, b.brand_name AS brand, b.brand_id AS brand_id "
          + "FROM cars c "
          + "JOIN vehicle_models m ON c.model_id = m.model_id "
          + "JOIN vehicle_brands b ON m.brand_id = b.brand_id ";

    public Car findById(int carId) throws SQLException {
        String sql = BASE_SELECT + "WHERE c.car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<Car> findAll() throws SQLException {
        List<Car> cars = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY c.created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) cars.add(mapRow(rs));
        }
        return cars;
    }

    public List<Car> findByStatus(String status) throws SQLException {
        List<Car> cars = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE c.status = ? ORDER BY brand, model";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cars.add(mapRow(rs));
            }
        }
        return cars;
    }

    public Car findByLicensePlate(String licensePlate) throws SQLException {
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

    /**
     * Find cars available for a given date range (no overlapping CONFIRMED/IN_PROGRESS bookings).
     */
    public List<Car> findAvailable(Timestamp startDate, Timestamp endDate) throws SQLException {
        List<Car> cars = new ArrayList<>();
        String sql = BASE_SELECT
                   + "WHERE c.status = 'AVAILABLE' "
                   + "AND c.car_id NOT IN ("
                   + "  SELECT bk.car_id FROM bookings bk "
                   + "  WHERE bk.status IN ('CONFIRMED', 'IN_PROGRESS') "
                   + "  AND bk.start_date < ? AND bk.end_date > ?"
                   + ") ORDER BY c.daily_rate";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, endDate);
            ps.setTimestamp(2, startDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) cars.add(mapRow(rs));
            }
        }
        return cars;
    }

    public int insert(Car car) throws SQLException {
        String sql = "INSERT INTO cars (license_plate, model_id, year, color, seats, transmission, "
                   + "fuel_type, daily_rate, description, status, mileage, location, features) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, car.getLicensePlate());
            ps.setInt(2, car.getModelId());
            ps.setInt(3, car.getYear());
            ps.setString(4, car.getColor());
            ps.setInt(5, car.getSeats());
            ps.setString(6, car.getTransmission());
            ps.setString(7, car.getFuelType());
            ps.setBigDecimal(8, car.getDailyRate());
            ps.setString(9, car.getDescription());
            ps.setString(10, car.getStatus());
            ps.setInt(11, car.getMileage());
            ps.setString(12, car.getLocation());
            ps.setString(13, car.getFeatures());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean update(Car car) throws SQLException {
        String sql = "UPDATE cars SET license_plate = ?, model_id = ?, year = ?, color = ?, "
                   + "seats = ?, transmission = ?, fuel_type = ?, daily_rate = ?, description = ?, "
                   + "status = ?, mileage = ?, location = ?, features = ?, updated_at = GETDATE() "
                   + "WHERE car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, car.getLicensePlate());
            ps.setInt(2, car.getModelId());
            ps.setInt(3, car.getYear());
            ps.setString(4, car.getColor());
            ps.setInt(5, car.getSeats());
            ps.setString(6, car.getTransmission());
            ps.setString(7, car.getFuelType());
            ps.setBigDecimal(8, car.getDailyRate());
            ps.setString(9, car.getDescription());
            ps.setString(10, car.getStatus());
            ps.setInt(11, car.getMileage());
            ps.setString(12, car.getLocation());
            ps.setString(13, car.getFeatures());
            ps.setInt(14, car.getCarId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int carId, String status) throws SQLException {
        String sql = "UPDATE cars SET status = ?, updated_at = GETDATE() WHERE car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, carId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int carId) throws SQLException {
        String sql = "DELETE FROM cars WHERE car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            return ps.executeUpdate() > 0;
        }
    }

    private Car mapRow(ResultSet rs) throws SQLException {
        Car car = new Car();
        car.setCarId(rs.getInt("car_id"));
        car.setLicensePlate(rs.getString("license_plate"));
        car.setModelId(rs.getInt("model_id"));
        car.setBrandId(rs.getInt("brand_id"));
        car.setBrand(rs.getString("brand"));
        car.setModel(rs.getString("model"));
        car.setYear(rs.getInt("year"));
        car.setColor(rs.getString("color"));
        car.setSeats(rs.getInt("seats"));
        car.setTransmission(rs.getString("transmission"));
        car.setFuelType(rs.getString("fuel_type"));
        car.setDailyRate(rs.getBigDecimal("daily_rate"));
        car.setDescription(rs.getString("description"));
        car.setStatus(rs.getString("status"));
        car.setMileage(rs.getInt("mileage"));
        car.setLocation(rs.getString("location"));
        car.setFeatures(rs.getString("features"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) car.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) car.setUpdatedAt(updatedAt.toLocalDateTime());
        return car;
    }
}
