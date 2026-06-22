package com.swp391.carrental.booking.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.Car;

/*
 * Name: BookingDAO
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Data access layer for Booking entity. Handles CRUD, overlap checks, approval/rejection.
 */



/**
 * Data Access Object for Booking entities.
 */
public class BookingDAO {

    /** Find a booking by its ID */
    public Booking findById(int bookingId) throws SQLException {
        String sql = "SELECT * FROM bookings WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Get all bookings ordered by creation date */
    public List<Booking> findAll() throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) bookings.add(mapRow(rs));
        }
        return bookings;
    }

    /** Get bookings for a specific customer ID */
    public List<Booking> findByCustomerId(int customerId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE customer_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) bookings.add(mapRow(rs));
            }
        }
        return bookings;
    }

    /** Get active bookings (PENDING, CONFIRMED, IN_PROGRESS) for a specific car */
    public List<Booking> findActiveBookingsByCarId(int carId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE car_id = ? "
                   + "AND status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS') "
                   + "ORDER BY start_date ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) bookings.add(mapRow(rs));
            }
        }
        return bookings;
    }

    /** Get bookings filtered by status */
    public List<Booking> findByStatus(String status) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE status = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) bookings.add(mapRow(rs));
            }
        }
        return bookings;
    }

    /** Check if a car has any overlapping active bookings in a given time range */
    public boolean hasOverlappingBooking(int carId, Timestamp startDate, Timestamp endDate, Integer excludeBookingId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE car_id = ? "
                   + "AND status IN ('PENDING', 'CONFIRMED', 'IN_PROGRESS') "
                   + "AND start_date < ? AND end_date > ?";
        if (excludeBookingId != null) {
            sql += " AND booking_id != ?";
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, carId);
            ps.setTimestamp(2, endDate);
            ps.setTimestamp(3, startDate);
            if (excludeBookingId != null) {
                ps.setInt(4, excludeBookingId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    /** Insert a new booking into the database and return the generated ID */
    public int insert(Booking booking) throws SQLException {
        String sql = "INSERT INTO bookings (customer_id, car_id, start_date, end_date, pickup_location, "
                   + "return_location, total_amount, deposit_amount, status, notes, "
                   + "rental_mode, pricing_package, delivery_method, delivery_address, delivery_distance, "
                   + "delivery_fee, km_limit, estimated_km, base_amount, discount_amount, tax_amount) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, booking.getCustomerId());
            ps.setInt(2, booking.getCarId());
            ps.setTimestamp(3, Timestamp.valueOf(booking.getStartDate()));
            ps.setTimestamp(4, Timestamp.valueOf(booking.getEndDate()));
            ps.setString(5, booking.getPickupLocation());
            ps.setString(6, booking.getReturnLocation());
            ps.setBigDecimal(7, booking.getTotalAmount());
            ps.setBigDecimal(8, booking.getDepositAmount());
            ps.setString(9, booking.getStatus());
            ps.setString(10, booking.getNotes());
            ps.setString(11, booking.getRentalMode());
            ps.setString(12, booking.getPricingPackage());
            ps.setString(13, booking.getDeliveryMethod());
            ps.setString(14, booking.getDeliveryAddress());
            ps.setBigDecimal(15, booking.getDeliveryDistance());
            ps.setBigDecimal(16, booking.getDeliveryFee());
            if (booking.getKmLimit() != null) {
                ps.setInt(17, booking.getKmLimit());
            } else {
                ps.setNull(17, Types.INTEGER);
            }
            if (booking.getEstimatedKm() != null) {
                ps.setInt(18, booking.getEstimatedKm());
            } else {
                ps.setNull(18, Types.INTEGER);
            }
            ps.setBigDecimal(19, booking.getBaseAmount());
            ps.setBigDecimal(20, booking.getDiscountAmount());
            ps.setBigDecimal(21, booking.getTaxAmount());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Update an existing booking in the database.
     */
    public boolean update(Booking booking) throws SQLException {
        String sql = "UPDATE bookings SET car_id = ?, start_date = ?, end_date = ?, pickup_location = ?, "
                   + "return_location = ?, total_amount = ?, deposit_amount = ?, status = ?, notes = ?, "
                   + "rental_mode = ?, pricing_package = ?, delivery_method = ?, delivery_address = ?, "
                   + "delivery_distance = ?, delivery_fee = ?, km_limit = ?, estimated_km = ?, "
                   + "base_amount = ?, discount_amount = ?, tax_amount = ?, "
                   + "updated_at = GETDATE() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, booking.getCarId());
            ps.setTimestamp(2, Timestamp.valueOf(booking.getStartDate()));
            ps.setTimestamp(3, Timestamp.valueOf(booking.getEndDate()));
            ps.setString(4, booking.getPickupLocation());
            ps.setString(5, booking.getReturnLocation());
            ps.setBigDecimal(6, booking.getTotalAmount());
            ps.setBigDecimal(7, booking.getDepositAmount());
            ps.setString(8, booking.getStatus());
            ps.setString(9, booking.getNotes());
            ps.setString(10, booking.getRentalMode());
            ps.setString(11, booking.getPricingPackage());
            ps.setString(12, booking.getDeliveryMethod());
            ps.setString(13, booking.getDeliveryAddress());
            ps.setBigDecimal(14, booking.getDeliveryDistance());
            ps.setBigDecimal(15, booking.getDeliveryFee());
            if (booking.getKmLimit() != null) {
                ps.setInt(16, booking.getKmLimit());
            } else {
                ps.setNull(16, Types.INTEGER);
            }
            if (booking.getEstimatedKm() != null) {
                ps.setInt(17, booking.getEstimatedKm());
            } else {
                ps.setNull(17, Types.INTEGER);
            }
            ps.setBigDecimal(18, booking.getBaseAmount());
            ps.setBigDecimal(19, booking.getDiscountAmount());
            ps.setBigDecimal(20, booking.getTaxAmount());
            ps.setInt(21, booking.getBookingId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update the status of a specific booking.
     */
    public boolean updateStatus(int bookingId, String status) throws SQLException {
        String sql = "UPDATE bookings SET status = ?, updated_at = GETDATE() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Approve a booking and record the staff member ID.
     */
    public boolean approve(int bookingId, int approvedBy) throws SQLException {
        String sql = "UPDATE bookings SET status = 'CONFIRMED', approved_by = ?, approved_at = GETDATE(), "
                   + "updated_at = GETDATE() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, approvedBy);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Reject a booking with a reason and the staff member ID.
     */
    public boolean reject(int bookingId, int rejectedBy, String reason) throws SQLException {
        String sql = "UPDATE bookings SET status = 'REJECTED', approved_by = ?, cancel_reason = ?, "
                   + "updated_at = GETDATE() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, rejectedBy);
            ps.setString(2, reason);
            ps.setInt(3, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Cancel a booking with reason and timestamp.
     */
    public boolean cancel(int bookingId, String cancelReason) throws SQLException {
        String sql = "UPDATE bookings SET status = 'CANCELLED', cancel_reason = ?, "
                   + "cancelled_at = GETDATE(), updated_at = GETDATE() WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cancelReason);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a booking by its ID.
     */
    public boolean delete(int bookingId) throws SQLException {
        String sql = "DELETE FROM bookings WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Map a ResultSet row to a Booking object.
     */
    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("booking_id"));
        b.setCustomerId(rs.getInt("customer_id"));
        b.setCarId(rs.getInt("car_id"));
        Timestamp sd = rs.getTimestamp("start_date");
        if (sd != null) b.setStartDate(sd.toLocalDateTime());
        Timestamp ed = rs.getTimestamp("end_date");
        if (ed != null) b.setEndDate(ed.toLocalDateTime());
        b.setPickupLocation(rs.getString("pickup_location"));
        b.setReturnLocation(rs.getString("return_location"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        b.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        b.setStatus(rs.getString("status"));
        b.setNotes(rs.getString("notes"));
        int approvedBy = rs.getInt("approved_by");
        if (!rs.wasNull()) b.setApprovedBy(approvedBy);
        Timestamp aa = rs.getTimestamp("approved_at");
        if (aa != null) b.setApprovedAt(aa.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("cancelled_at");
        if (ca != null) b.setCancelledAt(ca.toLocalDateTime());
        b.setCancelReason(rs.getString("cancel_reason"));
        Timestamp crAt = rs.getTimestamp("created_at");
        if (crAt != null) b.setCreatedAt(crAt.toLocalDateTime());
        Timestamp upAt = rs.getTimestamp("updated_at");
        if (upAt != null) b.setUpdatedAt(upAt.toLocalDateTime());

        // Redesign mappings
        b.setRentalMode(rs.getString("rental_mode"));
        b.setPricingPackage(rs.getString("pricing_package"));
        b.setDeliveryMethod(rs.getString("delivery_method"));
        b.setDeliveryAddress(rs.getString("delivery_address"));
        b.setDeliveryDistance(rs.getBigDecimal("delivery_distance"));
        b.setDeliveryFee(rs.getBigDecimal("delivery_fee"));
        
        int kmLimit = rs.getInt("km_limit");
        if (!rs.wasNull()) {
            b.setKmLimit(kmLimit);
        }
        int estKm = rs.getInt("estimated_km");
        if (!rs.wasNull()) {
            b.setEstimatedKm(estKm);
        }
        
        b.setBaseAmount(rs.getBigDecimal("base_amount"));
        b.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        b.setTaxAmount(rs.getBigDecimal("tax_amount"));

        return b;
    }
}
