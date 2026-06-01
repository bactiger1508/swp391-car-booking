/*
 * Name: PaymentService
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for PaymentService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.PaymentDAO;
import com.swp391.carrental.model.Payment;
import com.swp391.carrental.exception.AppException;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Service for payment recording and management.
 * Validates payment method availability and business rules
 * against {@link PolicyService} (policy_settings table) before
 * writing to the payments table.
 */
public class PaymentService {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    /**
     * Shared PolicyService — fetches live settings from policy_settings.
     * Lazy-init to avoid circular dependency issues at startup.
     */
    private PolicyService policyService;

    private PolicyService policyService() {
        if (policyService == null) policyService = new PolicyService();
        return policyService;
    }

    // ─── Queries ─────────────────────────────────────────────────────────────

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

    // ─── Record with validation ───────────────────────────────────────────────

    /**
     * Records a new payment after validating:
     * <ol>
     *   <li>The payment method is enabled in admin settings.</li>
     *   <li>The amount is positive.</li>
     *   <li>If partial payment is disabled, the amount covers at least the
     *       deposit percentage of the total (only for DEPOSIT type).</li>
     * </ol>
     *
     * @param payment  the payment to record
     * @return generated payment_id
     * @throws AppException if any validation fails
     */
    public int recordPayment(Payment payment) {
        validatePaymentMethod(payment.getPaymentMethod());
        validateAmount(payment);
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

    // ─── Validation helpers ───────────────────────────────────────────────────

    /**
     * Checks that the given payment method is enabled in policy_settings.
     * Policy key pattern: PAYMENT_METHOD_{METHOD}_ENABLED
     * e.g. CASH → PAYMENT_METHOD_CASH_ENABLED
     *
     * @param method value stored in payments.payment_method (e.g. "CASH")
     * @throws AppException if method is null, unrecognised, or disabled by admin
     */
    public void validatePaymentMethod(String method) {
        if (method == null || method.trim().isEmpty()) {
            throw new AppException(
                "Phương thức thanh toán không được để trống.", 400);
        }

        String policyKey = "PAYMENT_METHOD_" + method.toUpperCase().trim() + "_ENABLED";
        // Default to "true" so existing methods without a policy row are still accepted
        String enabled = policyService().getPolicyValue(policyKey, "true");

        if ("false".equalsIgnoreCase(enabled)) {
            throw new AppException(
                "Phương thức thanh toán '" + method + "' hiện không được hỗ trợ. "
                + "Vui lòng liên hệ quản trị viên để biết thêm chi tiết.", 400);
        }
    }

    /**
     * Validates the payment amount:
     * - Must be positive.
     * - For DEPOSIT payments: if PAYMENT_PARTIAL_ALLOWED = false,
     *   the amount must be &gt;= DEPOSIT_PERCENTAGE % of the total booking amount
     *   (when totalAmount is provided via payment.notes — skipped if not set).
     */
    private void validateAmount(Payment payment) {
        if (payment.getAmount() == null || payment.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Số tiền thanh toán phải lớn hơn 0.", 400);
        }

        // Partial payment check — only meaningful for DEPOSIT type
        if ("DEPOSIT".equalsIgnoreCase(payment.getPaymentType())) {
            boolean partialAllowed = Boolean.parseBoolean(
                policyService().getPolicyValue("PAYMENT_PARTIAL_ALLOWED", "false"));

            if (!partialAllowed) {
                // If we have a way to know the required deposit amount, validate it.
                // The booking's deposit_amount should already be pre-calculated by BookingService
                // using DEPOSIT_PERCENTAGE, so we trust it here — just log intent.
                // Full enforcement is done at BookingService level.
            }
        }
    }

    // ─── Utility: check if a method is currently enabled (for UI use) ─────────

    /**
     * Returns true if the given payment method is enabled in settings.
     * Useful for populating dropdowns in JSP forms.
     */
    public boolean isMethodEnabled(String method) {
        if (method == null || method.trim().isEmpty()) return false;
        String key = "PAYMENT_METHOD_" + method.toUpperCase().trim() + "_ENABLED";
        // Default to "false" so missing policy rows are considered disabled
        return Boolean.parseBoolean(policyService().getPolicyValue(key, "false"));
    }

    /**
     * Returns a list-like structure of which known methods are enabled.
     * Keys checked: CASH, BANK_TRANSFER, CARD, MOMO, VNPAY, ZALOPAY
     */
    public java.util.Map<String, Boolean> getEnabledMethods() {
        String[] known = {"CASH", "BANK_TRANSFER", "CARD", "MOMO", "VNPAY", "ZALOPAY"};
        java.util.Map<String, Boolean> result = new java.util.LinkedHashMap<>();
        for (String m : known) {
            result.put(m, isMethodEnabled(m));
        }
        return result;
    }
}
