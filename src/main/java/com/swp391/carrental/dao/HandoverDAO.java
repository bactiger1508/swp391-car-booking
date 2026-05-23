package com.swp391.carrental.dao;

import com.swp391.carrental.model.VehicleHandover;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for VehicleHandover entities.
 */
public class HandoverDAO {

    public VehicleHandover findById(int handoverId) throws SQLException {
        String sql = "SELECT * FROM vehicle_handovers WHERE handover_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, handoverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public VehicleHandover findByBookingId(int bookingId) throws SQLException {
        String sql = "SELECT * FROM vehicle_handovers WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<VehicleHandover> findAll() throws SQLException {
        List<VehicleHandover> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_handovers ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public int insert(VehicleHandover h) throws SQLException {
        String sql = "INSERT INTO vehicle_handovers (booking_id, contract_id, car_id, handover_date, "
                   + "mileage_at_handover, fuel_level, exterior_condition, interior_condition, "
                   + "accessories_checklist, photos_url, notes, handed_by, received_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, h.getBookingId());
            if (h.getContractId() != null) ps.setInt(2, h.getContractId()); else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, h.getCarId());
            ps.setTimestamp(4, Timestamp.valueOf(h.getHandoverDate()));
            ps.setInt(5, h.getMileageAtHandover());
            ps.setString(6, h.getFuelLevel());
            ps.setString(7, h.getExteriorCondition());
            ps.setString(8, h.getInteriorCondition());
            ps.setString(9, h.getAccessoriesChecklist());
            ps.setString(10, h.getPhotosUrl());
            ps.setString(11, h.getNotes());
            ps.setInt(12, h.getHandedBy());
            ps.setInt(13, h.getReceivedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        return -1;
    }

    public boolean delete(int handoverId) throws SQLException {
        String sql = "DELETE FROM vehicle_handovers WHERE handover_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, handoverId);
            return ps.executeUpdate() > 0;
        }
    }

    private VehicleHandover mapRow(ResultSet rs) throws SQLException {
        VehicleHandover h = new VehicleHandover();
        h.setHandoverId(rs.getInt("handover_id"));
        h.setBookingId(rs.getInt("booking_id"));
        int cid = rs.getInt("contract_id"); if (!rs.wasNull()) h.setContractId(cid);
        h.setCarId(rs.getInt("car_id"));
        Timestamp hd = rs.getTimestamp("handover_date"); if (hd != null) h.setHandoverDate(hd.toLocalDateTime());
        h.setMileageAtHandover(rs.getInt("mileage_at_handover"));
        h.setFuelLevel(rs.getString("fuel_level"));
        h.setExteriorCondition(rs.getString("exterior_condition"));
        h.setInteriorCondition(rs.getString("interior_condition"));
        h.setAccessoriesChecklist(rs.getString("accessories_checklist"));
        h.setPhotosUrl(rs.getString("photos_url"));
        h.setNotes(rs.getString("notes"));
        h.setHandedBy(rs.getInt("handed_by"));
        h.setReceivedBy(rs.getInt("received_by"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) h.setCreatedAt(ca.toLocalDateTime());
        return h;
    }
}
