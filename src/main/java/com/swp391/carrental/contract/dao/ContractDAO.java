package com.swp391.carrental.contract.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.core.util.DBContext;

/*
 * Name: ContractDAO
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Data Access Object for handling database operations on Rental Contracts.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (04/06/2026): refactor: apply coding conventions and improve code docum...
 * - v1.3 (09/06/2026): docs(contract): add simple english comments to contract m...
 * - v1.4 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.5 (21/06/2026): feat: standard combo packages, dynamic tet surcharge and ...
 * - v1.6 (21/06/2026): feat: implement booking workflow with contract creation a...
 * - v1.7 (08/07/2026): feat: implement update contract
 * - v1.8 (21/07/2026): feat: update rental contract workflow to require customer...
 * - v1.9 (23/07/2026): Added Javadoc and method comments.
 */



/**
 * Data Access Object for RentalContract entities.
 */
public class ContractDAO {

    /**
     * Query a contract from database by primary key ID.
     */
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

    /**
     * Query a contract associated with a booking ID.
     */
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

    /**
     * Query all contracts ordered by creation date descending.
     */
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

    /**
     * Insert a new contract record into database with auto-generated keys.
     */
    public int insert(RentalContract contract) throws SQLException {
        String sql = "INSERT INTO rental_contracts (booking_id, contract_number, customer_id, car_id, "
                 + "start_date, end_date, daily_rate, total_amount, deposit_amount, status, "
                 + "terms_and_conditions, created_by, "
                 + "rental_mode, pricing_package, delivery_method, delivery_address, delivery_distance, "
                 + "delivery_fee, km_limit, estimated_km, base_amount, discount_amount, tax_amount) "
                 + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
            
            ps.setString(13, contract.getRentalMode());
            ps.setString(14, contract.getPricingPackage());
            ps.setString(15, contract.getDeliveryMethod());
            ps.setString(16, contract.getDeliveryAddress());
            ps.setBigDecimal(17, contract.getDeliveryDistance());
            ps.setBigDecimal(18, contract.getDeliveryFee());
            if (contract.getKmLimit() != null) {
                ps.setInt(19, contract.getKmLimit());
            } else {
                ps.setNull(19, Types.INTEGER);
            }
            if (contract.getEstimatedKm() != null) {
                ps.setInt(20, contract.getEstimatedKm());
            } else {
                ps.setNull(20, Types.INTEGER);
            }
            ps.setBigDecimal(21, contract.getBaseAmount());
            ps.setBigDecimal(22, contract.getDiscountAmount());
            ps.setBigDecimal(23, contract.getTaxAmount());

            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Update mutable fields of an existing contract draft in the database.
     */
    public boolean update(RentalContract contract) throws SQLException {
        String sql = "UPDATE rental_contracts SET start_date = ?, end_date = ?, daily_rate = ?, total_amount = ?, deposit_amount = ?, terms_and_conditions = ?, base_amount = ?, discount_amount = ?, updated_at = GETDATE() WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, Timestamp.valueOf(contract.getStartDate()));
            ps.setTimestamp(2, Timestamp.valueOf(contract.getEndDate()));
            ps.setBigDecimal(3, contract.getDailyRate());
            ps.setBigDecimal(4, contract.getTotalAmount());
            ps.setBigDecimal(5, contract.getDepositAmount());
            ps.setString(6, contract.getTermsAndConditions());
            ps.setBigDecimal(7, contract.getBaseAmount());
            ps.setBigDecimal(8, contract.getDiscountAmount());
            ps.setInt(9, contract.getContractId());
            return ps.executeUpdate() > 0;
        }
    }

    private static boolean columnsChecked = false;

    /**
     * Check and create signature columns in database if not present.
     */
    private static synchronized void ensureSignatureColumns(Connection conn) {
        if (columnsChecked) return;
        try {
            DatabaseMetaData md = conn.getMetaData();
            try (ResultSet rs = md.getColumns(null, null, "rental_contracts", "staff_signed_at")) {
                if (!rs.next()) {
                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate("ALTER TABLE rental_contracts ADD staff_signed_at DATETIME2 NULL");
                    }
                }
            }
            try (ResultSet rs = md.getColumns(null, null, "rental_contracts", "customer_signed_at")) {
                if (!rs.next()) {
                    try (Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate("ALTER TABLE rental_contracts ADD customer_signed_at DATETIME2 NULL");
                    }
                }
            }
            columnsChecked = true;
        } catch (Exception e) {
            // Ignore if metadata check is unpermitted or column exists
        }
    }

    /**
     * Record staff signature timestamp in database and update status.
     */
    public boolean signContractByStaff(int contractId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            ensureSignatureColumns(conn);
            String sql = "UPDATE rental_contracts SET staff_signed_at = GETDATE(), updated_at = GETDATE() WHERE contract_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    checkAndUpdateActiveStatus(conn, contractId);
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Record customer signature timestamp in database and update status.
     */
    public boolean signContractByCustomer(int contractId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            ensureSignatureColumns(conn);
            String sql = "UPDATE rental_contracts SET customer_signed_at = GETDATE(), updated_at = GETDATE() WHERE contract_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, contractId);
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    checkAndUpdateActiveStatus(conn, contractId);
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Check if both staff and customer signatures are present to transition status to ACTIVE.
     */
    public boolean checkAndUpdateActiveStatus(Connection conn, int contractId) throws SQLException {
        String sql = "SELECT staff_signed_at, customer_signed_at, status FROM rental_contracts WHERE contract_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Timestamp staffSigned = rs.getTimestamp("staff_signed_at");
                    Timestamp customerSigned = rs.getTimestamp("customer_signed_at");
                    String currentStatus = rs.getString("status");

                    if (staffSigned != null && customerSigned != null && "DRAFT".equals(currentStatus)) {
                        String updateSql = "UPDATE rental_contracts SET status = 'ACTIVE', signed_at = GETDATE(), updated_at = GETDATE() WHERE contract_id = ?";
                        try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                            ups.setInt(1, contractId);
                            return ups.executeUpdate() > 0;
                        }
                    }
                }
            }
        }
        return false;
    }

    /**
     * Update status and set signed_at date if transitioning to ACTIVE.
     */
    public boolean updateStatus(int contractId, String status) throws SQLException {
        String sql = "UPDATE rental_contracts SET status = ?, signed_at = CASE WHEN ? = 'ACTIVE' AND signed_at IS NULL THEN GETDATE() ELSE signed_at END, updated_at = GETDATE() WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt(3, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a contract by ID.
     */
    public boolean delete(int contractId) throws SQLException {
        String sql = "DELETE FROM rental_contracts WHERE contract_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, contractId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Query all contracts associated with a customer ID.
     */
    public List<RentalContract> findByCustomerId(int customerId) throws SQLException {
        List<RentalContract> contracts = new ArrayList<>();
        String sql = "SELECT * FROM rental_contracts WHERE customer_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    contracts.add(mapRow(rs));
                }
            }
        }
        return contracts;
    }

    /**
     * Map a JDBC ResultSet row to a RentalContract model object.
     */
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
        try {
            Timestamp ssa = rs.getTimestamp("staff_signed_at");
            if (ssa != null) {
                c.setStaffSignedAt(ssa.toLocalDateTime());
            }
            Timestamp csa = rs.getTimestamp("customer_signed_at");
            if (csa != null) {
                c.setCustomerSignedAt(csa.toLocalDateTime());
            }
        } catch (SQLException ignore) {
            // Column may not exist yet in legacy DB queries
        }
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) {
            c.setCreatedAt(ca.toLocalDateTime());
        }
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) {
            c.setUpdatedAt(ua.toLocalDateTime());
        }

        // Redesign mappings
        c.setRentalMode(rs.getString("rental_mode"));
        c.setPricingPackage(rs.getString("pricing_package"));
        c.setDeliveryMethod(rs.getString("delivery_method"));
        c.setDeliveryAddress(rs.getString("delivery_address"));
        c.setDeliveryDistance(rs.getBigDecimal("delivery_distance"));
        c.setDeliveryFee(rs.getBigDecimal("delivery_fee"));
        
        int kmLimit = rs.getInt("km_limit");
        if (!rs.wasNull()) {
            c.setKmLimit(kmLimit);
        }
        int estKm = rs.getInt("estimated_km");
        if (!rs.wasNull()) {
            c.setEstimatedKm(estKm);
        }
        
        c.setBaseAmount(rs.getBigDecimal("base_amount"));
        c.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        c.setTaxAmount(rs.getBigDecimal("tax_amount"));

        return c;
    }
}
