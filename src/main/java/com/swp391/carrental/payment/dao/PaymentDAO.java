package com.swp391.carrental.payment.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.payment.model.Payment;

/*
 * Name: PaymentDAO
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Data Access Object for handling database operations on Payments.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (04/06/2026): refactor: apply coding conventions and improve code docum...
 * - v1.3 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.4 (16/07/2026): feat: implement automated VietQR payment processing syste...
 * - v1.5 (23/07/2026): Added Javadoc and method comments.
 */



/**
 * Data Access Object for Payment entities.
 */
public class PaymentDAO {

    /**
     * Query a payment record from the database by primary ID.
     */
    public Payment findById(int paymentId) throws SQLException {
        String sql = "SELECT * FROM payments WHERE payment_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Query all payment records associated with a specific booking.
     */
    public List<Payment> findByBookingId(int bookingId) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments WHERE booking_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapRow(rs));
                }
            }
        }
        return payments;
    }

    /**
     * Retrieve all payments for a specific customer by joining with booking details.
     */
    public List<Payment> findByCustomerId(int customerId) throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.* FROM payments p "
                   + "INNER JOIN bookings b ON p.booking_id = b.booking_id "
                   + "WHERE b.customer_id = ? "
                   + "ORDER BY p.created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapRow(rs));
                }
            }
        }
        return payments;
    }

    /**
     * Query all payments in the database.
     */
    public List<Payment> findAll() throws SQLException {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM payments ORDER BY created_at DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                payments.add(mapRow(rs));
            }
        }
        return payments;
    }

    /**
     * Insert a new payment record into the database, handling auto-generated keys.
     */
    public int insert(Payment payment) throws SQLException {
        String sql = "INSERT INTO payments (booking_id, contract_id, amount, amount_paid, payment_type, payment_method, "
                + "status, transaction_ref, notes, paid_at, recorded_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, payment.getBookingId());
            if (payment.getContractId() != null) {
                ps.setInt(2, payment.getContractId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setBigDecimal(3, payment.getAmount());
            if (payment.getAmountPaid() != null) {
                ps.setBigDecimal(4, payment.getAmountPaid());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            ps.setString(5, payment.getPaymentType());
            ps.setString(6, payment.getPaymentMethod());
            ps.setString(7, payment.getStatus());
            ps.setString(8, payment.getTransactionRef());
            ps.setString(9, payment.getNotes());
            if (payment.getPaidAt() != null) {
                ps.setTimestamp(10, Timestamp.valueOf(payment.getPaidAt()));
            } else {
                ps.setNull(10, Types.TIMESTAMP);
            }
            if (payment.getRecordedBy() != null) {
                ps.setInt(11, payment.getRecordedBy());
            } else {
                ps.setNull(11, Types.INTEGER);
            }
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
     * Update status field of an existing payment record.
     */
    public boolean updateStatus(int paymentId, String status) throws SQLException {
        String sql = "UPDATE payments SET status = ?, updated_at = GETDATE() WHERE payment_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, paymentId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a payment record by ID.
     */
    public boolean delete(int paymentId) throws SQLException {
        String sql = "DELETE FROM payments WHERE payment_id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Query a payment record using database row locking (UPDLOCK) within a transaction.
     */
    public Payment findByIdWithLock(Connection conn, int paymentId) throws SQLException {
        String sql = "SELECT * FROM payments WITH (UPDLOCK) WHERE payment_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Update a payment record using an active transaction connection.
     */
    public boolean updatePaymentTransactional(Connection conn, Payment payment) throws SQLException {
        String sql = "UPDATE payments SET status = ?, payment_method = ?, amount = ?, amount_paid = ?, transaction_ref = ?, notes = ?, paid_at = ?, recorded_by = ?, updated_at = GETDATE() WHERE payment_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, payment.getStatus());
            ps.setString(2, payment.getPaymentMethod());
            ps.setBigDecimal(3, payment.getAmount());
            if (payment.getAmountPaid() != null) {
                ps.setBigDecimal(4, payment.getAmountPaid());
            } else {
                ps.setNull(4, Types.DECIMAL);
            }
            ps.setString(5, payment.getTransactionRef());
            ps.setString(6, payment.getNotes());
            if (payment.getPaidAt() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(payment.getPaidAt()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            if (payment.getRecordedBy() != null) {
                ps.setInt(8, payment.getRecordedBy());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            ps.setInt(9, payment.getPaymentId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Map a JDBC ResultSet row to a Payment model object, with self-healing check for amount_paid column.
     */
    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setBookingId(rs.getInt("booking_id"));
        int cid = rs.getInt("contract_id");
        if (!rs.wasNull()) {
            p.setContractId(cid);
        }
        p.setAmount(rs.getBigDecimal("amount"));

        // amount_paid — nullable, only present after schema migration
        try {
            java.math.BigDecimal amountPaid = rs.getBigDecimal("amount_paid");
            if (!rs.wasNull()) {
                p.setAmountPaid(amountPaid);
            }
        } catch (SQLException ignore) {
            // column may not exist in older DB versions — gracefully skip
        }

        p.setPaymentType(rs.getString("payment_type"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setStatus(rs.getString("status"));
        p.setTransactionRef(rs.getString("transaction_ref"));
        p.setNotes(rs.getString("notes"));
        Timestamp pa = rs.getTimestamp("paid_at");
        if (pa != null) {
            p.setPaidAt(pa.toLocalDateTime());
        }
        int rb = rs.getInt("recorded_by");
        if (!rs.wasNull()) {
            p.setRecordedBy(rb);
        }
        Timestamp ca = rs.getTimestamp("created_at");
        if (ca != null) {
            p.setCreatedAt(ca.toLocalDateTime());
        }
        Timestamp ua = rs.getTimestamp("updated_at");
        if (ua != null) {
            p.setUpdatedAt(ua.toLocalDateTime());
        }
        return p;
    }
}
