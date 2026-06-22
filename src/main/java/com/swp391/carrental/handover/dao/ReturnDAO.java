package com.swp391.carrental.handover.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.handover.model.VehicleReturn;

/*
 * Name: ReturnDAO
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for ReturnDAO.
 */
/**
 * Data Access Object for VehicleReturn entities.
 */
public class ReturnDAO {

    public VehicleReturn findById(int returnId) throws SQLException {
        String sql = "SELECT * FROM vehicle_returns WHERE return_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, returnId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public VehicleReturn findByBookingId(int bookingId) throws SQLException {
        String sql = "SELECT * FROM vehicle_returns WHERE booking_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<VehicleReturn> findAll() throws SQLException {
        List<VehicleReturn> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicle_returns ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int insert(VehicleReturn vr) throws SQLException {
        String sql = "INSERT INTO vehicle_returns (booking_id, contract_id, car_id, handover_id, return_date, "
                + "mileage_at_return, fuel_level, exterior_condition, interior_condition, mechanical_condition, "
                + " damage_description, photos_url, late_fee, extra_km_fee, damage_fee, cleaning_fee, lost_item_fee, "
                + "total_additional_fee, notes, received_by, returned_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, vr.getBookingId());
            if (vr.getContractId() != null) {
                ps.setInt(2, vr.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setInt(3, vr.getCarId());
            if (vr.getHandoverId() != null) {
                ps.setInt(4, vr.getHandoverId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setTimestamp(5, Timestamp.valueOf(vr.getReturnDate()));
            ps.setInt(6, vr.getMileageAtReturn());
            ps.setString(7, vr.getFuelLevel());
            ps.setString(8, vr.getExteriorCondition());
            ps.setString(9, vr.getInteriorCondition());
            ps.setString(10, vr.getMechanicalCondition());
            ps.setString(11, vr.getDamageDescription());
            ps.setString(12, vr.getPhotosUrl());
            ps.setBigDecimal(13, vr.getLateHours() != null ? vr.getLateHours() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(14, vr.getExtraKmFee() != null ? vr.getExtraKmFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(15, vr.getDamageFee() != null ? vr.getDamageFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(16, vr.getCleaningFee() != null ? vr.getCleaningFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(17, vr.getLostItemFee() != null ? vr.getLostItemFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(18, vr.getTotalAdditionalFee() != null ? vr.getTotalAdditionalFee() : java.math.BigDecimal.ZERO);
            ps.setString(19, vr.getNotes());
            ps.setInt(20, vr.getReceivedBy());
            ps.setInt(21, vr.getReturnedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    public int update(VehicleReturn vr) throws SQLException {
        String sql = "UPDATE vehicle_returns SET booking_id = ?, contract_id = ?, car_id = ?, "
                + "handover_id = ?, return_date = ?, mileage_at_return = ?, fuel_level = ?, "
                + "exterior_condition = ?, interior_condition = ?, mechanical_condition = ?, "
                + "damage_description = ?, photos_url = ?, late_fee = ?, "
                + "extra_km_fee = ?, damage_fee = ?, cleaning_fee = ?, lost_item_fee = ?, "
                + "total_additional_fee = ?, notes = ?, received_by = ?, returned_by = ? "
                + "WHERE return_id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vr.getBookingId());

            if (vr.getContractId() != null) {
                ps.setInt(2, vr.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setInt(3, vr.getCarId());

            if (vr.getHandoverId() != null) {
                ps.setInt(4, vr.getHandoverId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }

            ps.setTimestamp(5, Timestamp.valueOf(vr.getReturnDate()));
            ps.setInt(6, vr.getMileageAtReturn());
            ps.setString(7, vr.getFuelLevel());
            ps.setString(8, vr.getExteriorCondition());
            ps.setString(9, vr.getInteriorCondition());
            ps.setString(10, vr.getMechanicalCondition());
            ps.setString(11, vr.getDamageDescription());
            ps.setString(12, vr.getPhotosUrl());

            ps.setBigDecimal(13, vr.getLateHours() != null ? vr.getLateHours() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(14, vr.getExtraKmFee() != null ? vr.getExtraKmFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(15, vr.getDamageFee() != null ? vr.getDamageFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(16, vr.getCleaningFee() != null ? vr.getCleaningFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(17, vr.getLostItemFee() != null ? vr.getLostItemFee() : java.math.BigDecimal.ZERO);
            ps.setBigDecimal(18, vr.getTotalAdditionalFee() != null ? vr.getTotalAdditionalFee() : java.math.BigDecimal.ZERO);

            ps.setString(19, vr.getNotes());
            ps.setInt(20, vr.getReceivedBy());
            ps.setInt(21, vr.getReturnedBy());

            ps.setInt(22, vr.getReturnId());

            return ps.executeUpdate();
        }
    }

    public boolean delete(int returnId) throws SQLException {
        String sql = "DELETE FROM vehicle_returns WHERE return_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, returnId);
            return ps.executeUpdate() > 0;
        }
    }

    private VehicleReturn mapRow(ResultSet rs) throws SQLException {
        VehicleReturn v = new VehicleReturn();
        v.setReturnId(rs.getInt("return_id"));
        v.setBookingId(rs.getInt("booking_id"));
        int cid = rs.getInt("contract_id");
        if (!rs.wasNull()) {
            v.setContractId(cid);
        }
        v.setCarId(rs.getInt("car_id"));
        int hid = rs.getInt("handover_id");
        if (!rs.wasNull()) {
            v.setHandoverId(hid);
        }
        Timestamp rd = rs.getTimestamp("return_date");
        if (rd != null) {
            v.setReturnDate(rd.toLocalDateTime());
        }
        v.setMileageAtReturn(rs.getInt("mileage_at_return"));
        v.setFuelLevel(rs.getString("fuel_level"));
        v.setExteriorCondition(rs.getString("exterior_condition"));
        v.setInteriorCondition(rs.getString("interior_condition"));
        v.setMechanicalCondition(rs.getString("mechanical_condition"));
        v.setDamageDescription(rs.getString("damage_description"));
        v.setPhotosUrl(rs.getString("photos_url"));
        v.setLateHours(rs.getBigDecimal("late_fee"));
        v.setExtraKmFee(rs.getBigDecimal("extra_km_fee"));
        v.setDamageFee(rs.getBigDecimal("damage_fee"));
        v.setCleaningFee(rs.getBigDecimal("cleaning_fee"));
        v.setLostItemFee(rs.getBigDecimal("lost_item_fee"));
        v.setTotalAdditionalFee(rs.getBigDecimal("total_additional_fee"));
        v.setNotes(rs.getString("notes"));
        v.setReceivedBy(rs.getInt("received_by"));
        v.setReturnedBy(rs.getInt("returned_by"));
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) {
            v.setCreatedAt(ca.toLocalDateTime());
        }
        return v;
    }
}
