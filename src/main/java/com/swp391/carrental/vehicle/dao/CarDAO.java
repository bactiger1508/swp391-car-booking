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

    public Car findById(int carId) throws SQLException {
        String sql = "SELECT * FROM cars WHERE car_id = ?";
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
        String sql = "SELECT * FROM cars ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) cars.add(mapRow(rs));
        }
        return cars;
    }

    public List<Car> findByStatus(String status) throws SQLException {
        List<Car> cars = new ArrayList<>();
        String sql = "SELECT * FROM cars WHERE status = ? ORDER BY brand, model";
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
        String sql = "SELECT * FROM cars WHERE license_plate = ?";
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
        String sql = "SELECT c.* FROM cars c "
                   + "WHERE c.status = 'AVAILABLE' "
                   + "AND c.car_id NOT IN ("
                   + "  SELECT b.car_id FROM bookings b "
                   + "  WHERE b.status IN ('CONFIRMED', 'IN_PROGRESS') "
                   + "  AND b.start_date < ? AND b.end_date > ?"
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
        String sql = "INSERT INTO cars (license_plate, brand, model, year, color, seats, transmission, "
                   + "fuel_type, daily_rate, description, status, mileage, location, features) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, car.getLicensePlate());
            ps.setString(2, car.getBrand());
            ps.setString(3, car.getModel());
            ps.setInt(4, car.getYear());
            ps.setString(5, car.getColor());
            ps.setInt(6, car.getSeats());
            ps.setString(7, car.getTransmission());
            ps.setString(8, car.getFuelType());
            ps.setBigDecimal(9, car.getDailyRate());
            ps.setString(10, car.getDescription());
            ps.setString(11, car.getStatus());
            ps.setInt(12, car.getMileage());
            ps.setString(13, car.getLocation());
            ps.setString(14, car.getFeatures());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean update(Car car) throws SQLException {
        String sql = "UPDATE cars SET license_plate = ?, brand = ?, model = ?, year = ?, color = ?, "
                   + "seats = ?, transmission = ?, fuel_type = ?, daily_rate = ?, description = ?, "
                   + "status = ?, mileage = ?, location = ?, features = ?, updated_at = GETDATE() "
                   + "WHERE car_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, car.getLicensePlate());
            ps.setString(2, car.getBrand());
            ps.setString(3, car.getModel());
            ps.setInt(4, car.getYear());
            ps.setString(5, car.getColor());
            ps.setInt(6, car.getSeats());
            ps.setString(7, car.getTransmission());
            ps.setString(8, car.getFuelType());
            ps.setBigDecimal(9, car.getDailyRate());
            ps.setString(10, car.getDescription());
            ps.setString(11, car.getStatus());
            ps.setInt(12, car.getMileage());
            ps.setString(13, car.getLocation());
            ps.setString(14, car.getFeatures());
            ps.setInt(15, car.getCarId());
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
