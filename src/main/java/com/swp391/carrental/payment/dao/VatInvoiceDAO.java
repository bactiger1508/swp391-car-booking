package com.swp391.carrental.payment.dao;

import java.sql.*;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.payment.model.VatInvoice;

public class VatInvoiceDAO {

    public VatInvoice findByContractId(int contractId) throws SQLException {
        String sql = "SELECT * FROM vat_invoices WHERE contract_id = ?";
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

    public int insert(VatInvoice invoice) throws SQLException {
        String sql = "INSERT INTO vat_invoices (contract_id, invoice_code, invoice_date, invoice_status, "
                + "amount_before_tax, tax_rate, tax_amount, total_amount, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invoice.getContractId());
            ps.setString(2, invoice.getInvoiceCode());
            if (invoice.getInvoiceDate() != null) {
                ps.setTimestamp(3, Timestamp.valueOf(invoice.getInvoiceDate()));
            } else {
                ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
            }
            ps.setString(4, invoice.getInvoiceStatus());
            ps.setBigDecimal(5, invoice.getAmountBeforeTax());
            ps.setBigDecimal(6, invoice.getTaxRate());
            ps.setBigDecimal(7, invoice.getTaxAmount());
            ps.setBigDecimal(8, invoice.getTotalAmount());

            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    private VatInvoice mapRow(ResultSet rs) throws SQLException {
        VatInvoice invoice = new VatInvoice();
        invoice.setInvoiceId(rs.getInt("invoice_id"));
        invoice.setContractId(rs.getInt("contract_id"));
        invoice.setInvoiceCode(rs.getString("invoice_code"));
        Timestamp date = rs.getTimestamp("invoice_date");
        if (date != null) {
            invoice.setInvoiceDate(date.toLocalDateTime());
        }
        invoice.setInvoiceStatus(rs.getString("invoice_status"));
        invoice.setAmountBeforeTax(rs.getBigDecimal("amount_before_tax"));
        invoice.setTaxRate(rs.getBigDecimal("tax_rate"));
        invoice.setTaxAmount(rs.getBigDecimal("tax_amount"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            invoice.setCreatedAt(created.toLocalDateTime());
        }
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) {
            invoice.setUpdatedAt(updated.toLocalDateTime());
        }
        return invoice;
    }
}
