package com.swp391.carrental.service;

import com.swp391.carrental.dao.PaymentDAO;
import com.swp391.carrental.model.Payment;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;

/**
 * Service for payment recording and management.
 */
public class PaymentService {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    public Payment getPaymentById(int paymentId) {
        try {
            return paymentDAO.findById(paymentId);
        } catch (SQLException e) {
            throw new AppException("Failed to get payment.", e);
        }
    }

    public List<Payment> getPaymentsByBooking(int bookingId) {
        try {
            return paymentDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get payments.", e);
        }
    }

    public List<Payment> getAllPayments() {
        try {
            return paymentDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get all payments.", e);
        }
    }

    /**
     * Record a new payment.
     */
    public int recordPayment(Payment payment) {
        try {
            return paymentDAO.insert(payment);
        } catch (SQLException e) {
            throw new AppException("Failed to record payment.", e);
        }
    }

    public boolean updatePaymentStatus(int paymentId, String status) {
        try {
            return paymentDAO.updateStatus(paymentId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update payment status.", e);
        }
    }
}
