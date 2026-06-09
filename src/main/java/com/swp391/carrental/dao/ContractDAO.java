/*
 * Name: ContractDAO
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles database operations for ContractDAO.
 */
package com.swp391.carrental.dao;

import com.swp391.carrental.model.RentalContract;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for RentalContract entities.
 */
public class ContractDAO {

    // Find contract by ID
    public RentalContract findById(int contractId) throws SQLException {
        String sql = "SELECT * FROM rental_contracts WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    // Find contract by booking ID
    public RentalContract findByBookingId(int bookingId) throws SQLException {
        String sql = "SELECT * FROM rental_contracts WHERE booking_id = ?";
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

    // Get all contracts
    public List<RentalContract> findAll() throws SQLException {
        List<RentalContract> contracts = new ArrayList<>();
        String sql = "SELECT * FROM rental_contracts ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                contracts.add(mapRow(rs));
            }
        }
        return contracts;
    }

    // Insert new contract
    public int insert(RentalContract contract) throws SQLException {
        String sql = "INSERT INTO rental_contracts (booking_id, contract_number, customer_id, car_id, "
                + "start_date, end_date, daily_rate, total_amount, deposit_amount, status, "
                + "terms_and_conditions, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, contract.getBookingId());
            ps.setString(2, contract.getContractNumber());
            ps.setInt(3, contract.getCustomerId());
            ps.setInt(4, contract.getCarId());
            ps.setTimestamp(5, Timestamp.valueOf(contract.getStartDate()));
            ps.setTimestamp(6, Timestamp.valueOf(contract.getEndDate()));
            ps.setBigDecimal(7, contract.getDailyRate());
            ps.setBigDecimal(8, contract.getTotalAmount());
            ps.setBigDecimal(9, contract.getDepositAmount());
            ps.setString(10, contract.getStatus());
            ps.setString(11, contract.getTermsAndConditions());
            ps.setInt(12, contract.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    // Update contract status
    public boolean updateStatus(int contractId, String status) throws SQLException {
        String sql = "UPDATE rental_contracts SET status = ?, updated_at = GETDATE() WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    // Delete contract by ID
    public boolean delete(int contractId) throws SQLException {
        String sql = "DELETE FROM rental_contracts WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    // Map result set to contract object
    private RentalContract mapRow(ResultSet rs) throws SQLException {
        RentalContract c = new RentalContract();
        c.setContractId(rs.getInt("contract_id"));
        c.setBookingId(rs.getInt("booking_id"));
        c.setContractNumber(rs.getString("contract_number"));
        c.setCustomerId(rs.getInt("customer_id"));
        c.setCarId(rs.getInt("car_id"));
        Timestamp sd = rs.getTimestamp("start_date");
        if (sd != null) {
            c.setStartDate(sd.toLocalDateTime());
        }
        Timestamp ed = rs.getTimestamp("end_date");
        if (ed != null) {
            c.setEndDate(ed.toLocalDateTime());
        }
        c.setDailyRate(rs.getBigDecimal("daily_rate"));
        c.setTotalAmount(rs.getBigDecimal("total_amount"));
        c.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        c.setStatus(rs.getString("status"));
        c.setTermsAndConditions(rs.getString("terms_and_conditions"));
        c.setCreatedBy(rs.getInt("created_by"));
        Timestamp sa = rs.getTimestamp("signed_at");
        if (sa != null) {
            c.setSignedAt(sa.toLocalDateTime());
        }
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) {
            c.setCreatedAt(ca.toLocalDateTime());
        }
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) {
            c.setUpdatedAt(ua.toLocalDateTime());
        }
        return c;
    }
}
