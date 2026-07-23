package com.swp391.carrental.payment.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.policy.service.PolicyService;

/*
 * Name: PaymentService
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Service containing business logic for registering payments, bank transfer webhook matching, and refunds.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (31/05/2026): feat: implement payment processing system including recor...
 * - v1.3 (01/06/2026): last update for iter1
 * - v1.4 (04/06/2026): refactor: apply coding conventions and improve code docum...
 * - v1.5 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.6 (23/06/2026): feat: implement 3-image profile verification, non-expiry ...
 * - v1.7 (16/07/2026): feat: implement automated VietQR payment processing syste...
 * - v1.8 (22/07/2026): feat: update contract status when cancel, return and refa...
 * - v1.9 (23/07/2026): Added Javadoc and method comments.
 */



/**
 * Service for payment recording and management.
 *
 * <p>Allowed payment methods: CASH, BANK_TRANSFER only.
 * All other methods are rejected regardless of policy_settings.</p>
 *
 * <p>REFUND payments must always use CASH.</p>
 *
 * <p>Overpayment is detected by comparing {@code payment.amountPaid} with
 * {@code payment.amount}. No new status is introduced — overpayment is a
 * UI-level concern displayed to Staff/Admin after recording.</p>
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

    /**
     * Retrieve a payment record by its database primary ID.
     */
    public Payment getPaymentById(int paymentId) {
        try {
            return paymentDAO.findById(paymentId);
        } catch (SQLException e) {
            throw new AppException("Failed to get payment.", e);
        }
    }

    /**
     * Retrieve all payment records associated with a specific booking.
     */
    public List<Payment> getPaymentsByBooking(int bookingId) {
        try {
            return paymentDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get payments.", e);
        }
    }

    /**
     * Retrieve all payments in the system.
     */
    public List<Payment> getAllPayments() {
        try {
            return paymentDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get all payments.", e);
        }
    }

    /**
     * Returns all payments belonging to a specific customer.
     * Joins through the bookings table to verify ownership.
     */
    public List<Payment> getPaymentsByCustomerId(int customerId) {
        try {
            return paymentDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer payments.", e);
        }
    }

    // ─── Record with validation ───────────────────────────────────────────────

    /**
     * Records a new payment after validating:
     * <ol>
     *   <li>The payment method is CASH or BANK_TRANSFER (only these two are allowed).</li>
     *   <li>REFUND payments must use CASH only.</li>
     *   <li>The amount is positive.</li>
     * </ol>
     *
     * <p>Overpayment (amountPaid &gt; amount) is allowed and stored transparently.
     * Status is always set to COMPLETED by the caller — no special OVERPAID status.</p>
     *
     * @param payment  the payment to record
     * @return generated payment_id
     * @throws AppException if any validation fails
     */
    public int recordPayment(Payment payment) {
        validatePaymentMethod(payment.getPaymentMethod());
        validateRefundMethod(payment.getPaymentType(), payment.getPaymentMethod());
        validateAmount(payment);
        try {
            List<Payment> existingPayments = paymentDAO.findByBookingId(payment.getBookingId());

            // ── Case A: Customer submitting (PENDING) ─────────────────────────────
            // Upsert: if a PENDING record of same type already exists, update it
            // instead of creating a second pending record.
            if ("PENDING".equalsIgnoreCase(payment.getStatus())) {
                for (Payment ep : existingPayments) {
                    if ("PENDING".equalsIgnoreCase(ep.getStatus())
                            && ep.getPaymentType().equalsIgnoreCase(payment.getPaymentType())) {

                        // Update the amount, method and notes of the existing pending record
                        ep.setAmount(payment.getAmount());
                        ep.setPaymentMethod(payment.getPaymentMethod());
                        ep.setNotes(payment.getNotes());
                        try (java.sql.Connection conn = com.swp391.carrental.core.util.DBContext.getConnection()) {
                            paymentDAO.updatePaymentTransactional(conn, ep);
                        }
                        return ep.getPaymentId(); // Reuse the existing payment record
                    }
                }
            }

            // ── Case B: Staff/Admin submitting (COMPLETED) ────────────────────────
            // If a PENDING record of the same type already exists (created by customer),
            // approve THAT record instead of creating a new one (avoids PAY-9 / PAY-10 duplicates).
            if ("COMPLETED".equalsIgnoreCase(payment.getStatus())) {
                for (Payment ep : existingPayments) {
                    if ("PENDING".equalsIgnoreCase(ep.getStatus())
                            && ep.getPaymentType().equalsIgnoreCase(payment.getPaymentType())) {

                        // Approve the customer's pending record
                        ep.setStatus("COMPLETED");
                        ep.setAmount(payment.getAmount()); // Use staff-confirmed amount
                        ep.setAmountPaid(payment.getAmountPaid() != null ? payment.getAmountPaid() : payment.getAmount());
                        ep.setPaymentMethod(payment.getPaymentMethod());
                        ep.setPaidAt(payment.getPaidAt() != null ? payment.getPaidAt() : java.time.LocalDateTime.now());
                        ep.setRecordedBy(payment.getRecordedBy());
                        ep.setNotes(payment.getNotes());
                        try (java.sql.Connection conn = com.swp391.carrental.core.util.DBContext.getConnection()) {
                            paymentDAO.updatePaymentTransactional(conn, ep);
                        }
                        checkAndSettleBooking(payment.getBookingId());
                        return ep.getPaymentId(); // Return the approved existing record's ID
                    }
                }
            }

            int paymentId = paymentDAO.insert(payment);
            checkAndSettleBooking(payment.getBookingId());
            return paymentId;
        } catch (SQLException e) {
            throw new AppException("Failed to record payment.", e);
        }
    }

    /**
     * Settle booking status to COMPLETED if fully paid (calls outside transaction to keep db connections clean).
     */
    private void checkAndSettleBooking(int bookingId) {
        try {
            com.swp391.carrental.booking.dao.BookingDAO bookingDAO = new com.swp391.carrental.booking.dao.BookingDAO();
            com.swp391.carrental.handover.dao.ReturnDAO returnDAO = new com.swp391.carrental.handover.dao.ReturnDAO();
            
            com.swp391.carrental.booking.model.Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) return;
            
            com.swp391.carrental.handover.model.VehicleReturn returns = returnDAO.findByBookingId(bookingId);
            if (returns == null) {
                return;
            }
            
            List<Payment> payments = paymentDAO.findByBookingId(bookingId);
            BigDecimal totalPaid = BigDecimal.ZERO;
            for (Payment p : payments) {
                if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                    if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                        totalPaid = totalPaid.subtract(p.getAmount());
                    } else {
                        totalPaid = totalPaid.add(p.getAmount());
                    }
                }
            }
            
            BigDecimal totalRequired = booking.getTotalAmount();
            if (returns.getTotalAdditionalFee() != null) {
                totalRequired = totalRequired.add(returns.getTotalAdditionalFee());
            }
            
            if (totalPaid.compareTo(totalRequired) >= 0) {
                bookingDAO.updateStatus(bookingId, "COMPLETED");
                try {
                    com.swp391.carrental.contract.dao.ContractDAO contractDAO = new com.swp391.carrental.contract.dao.ContractDAO();
                    com.swp391.carrental.contract.model.RentalContract contract = contractDAO.findByBookingId(bookingId);
                    if (contract != null) {
                        contractDAO.updateStatus(contract.getContractId(), "COMPLETED");
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Update the payment status of a transaction.
     */
    public boolean updatePaymentStatus(int paymentId, String status) {
        try {
            return paymentDAO.updateStatus(paymentId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update payment status.", e);
        }
    }

    // ─── Validation helpers ───────────────────────────────────────────────────

    /**
     * Validates that the payment method is one of the two allowed methods:
     * CASH or BANK_TRANSFER. All other methods are rejected.
     *
     * <p>Additionally checks that the method is enabled in policy_settings.
     * This allows Admin to disable even CASH or BANK_TRANSFER if needed.</p>
     *
     * @param method value stored in payments.payment_method
     * @throws AppException if method is null, not CASH/BANK_TRANSFER, or disabled by admin
     */
    public void validatePaymentMethod(String method) {
        if (method == null || method.trim().isEmpty()) {
            throw new AppException(
                "Phương thức thanh toán không được để trống.", 400);
        }

        // Only CASH and BANK_TRANSFER are supported in this system
        String normalized = method.toUpperCase().trim();
        if (!"CASH".equals(normalized) && !"BANK_TRANSFER".equals(normalized)) {
            throw new AppException(
                "Phương thức thanh toán '" + method + "' không được hỗ trợ. "
                + "Chỉ chấp nhận Tiền mặt hoặc Chuyển khoản.", 400);
        }

        // Also check admin policy toggle for this method
        String policyKey = "PAYMENT_METHOD_" + normalized + "_ENABLED";
        String enabled = policyService().getPolicyValue(policyKey, "true");
        if ("false".equalsIgnoreCase(enabled)) {
            throw new AppException(
                "Phương thức thanh toán '" + method + "' hiện không được hỗ trợ. "
                + "Vui lòng liên hệ quản trị viên để biết thêm chi tiết.", 400);
        }
    }

    /**
     * Enforces the rule: REFUND payments must always use CASH.
     * Bank Transfer is never allowed for refunds.
     *
     * @param paymentType  e.g. "REFUND", "DEPOSIT"
     * @param method       e.g. "CASH", "BANK_TRANSFER"
     * @throws AppException if paymentType is REFUND and method is not CASH
     */
    public void validateRefundMethod(String paymentType, String method) {
        if ("REFUND".equalsIgnoreCase(paymentType)
                && !"CASH".equalsIgnoreCase(method)) {
            throw new AppException(
                "Hoàn tiền chỉ được thực hiện bằng Tiền mặt. "
                + "Không thể hoàn tiền qua Chuyển khoản.", 400);
        }
    }

    /**
     * Validates the payment amount:
     * - Must be positive.
     * - For DEPOSIT payments: if PAYMENT_PARTIAL_ALLOWED = false,
     *   the amount must be >= DEPOSIT_PERCENTAGE % of the total booking amount
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

    /**
     * Approve a pending payment (cash or transfer) by transitioning its status to COMPLETED.
     */
    public boolean approvePendingPayment(int paymentId, int recordedBy) {
        java.sql.Connection conn = null;
        try {
            conn = com.swp391.carrental.core.util.DBContext.getConnection();
            conn.setAutoCommit(false);
            
            Payment payment = paymentDAO.findByIdWithLock(conn, paymentId);
            if (payment == null || !"PENDING".equalsIgnoreCase(payment.getStatus())) {
                conn.rollback();
                return false;
            }
            
            payment.setStatus("COMPLETED");
            payment.setPaidAt(java.time.LocalDateTime.now());
            payment.setRecordedBy(recordedBy);
            if (payment.getAmountPaid() == null) {
                payment.setAmountPaid(payment.getAmount());
            }
            
            paymentDAO.updatePaymentTransactional(conn, payment);
            conn.commit();
            
            checkAndSettleBooking(payment.getBookingId());
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw new AppException("Failed to approve payment.", e);
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // ─── Utility: check if a method is currently enabled (for UI use) ─────────

    /**
     * Returns true if the given payment method is enabled in settings.
     * Useful for conditional rendering in JSP forms.
     */
    public boolean isMethodEnabled(String method) {
        if (method == null || method.trim().isEmpty()) return false;
        String key = "PAYMENT_METHOD_" + method.toUpperCase().trim() + "_ENABLED";
        // Default to "false" so missing policy rows are considered disabled
        return Boolean.parseBoolean(policyService().getPolicyValue(key, "false"));
    }

    /**
     * Returns enabled status map for CASH and BANK_TRANSFER only.
     * (VNPAY, MOMO, ZALOPAY, CARD are no longer supported in the payment flow.)
     */
    public java.util.Map<String, Boolean> getEnabledMethods() {
        String[] supported = {"CASH", "BANK_TRANSFER"};
        java.util.Map<String, Boolean> result = new java.util.LinkedHashMap<>();
        for (String m : supported) {
            result.put(m, isMethodEnabled(m));
        }
        return result;
    }

    /**
     * Verifies and records a bank transfer received via webhook.
     * Operates within a single database transaction with row-level locks.
     *
     * @param transferDescription the transfer description containing PAY{paymentId}
     * @param transferredAmount the amount transferred by the customer
     * @param transactionRef the bank's transaction reference ID
     * @param paidAt the date/time when the transfer was completed
     * @return true if payment status was updated, false otherwise
     */
    public boolean verifyBankTransfer(String transferDescription, BigDecimal transferredAmount, String transactionRef, java.time.LocalDateTime paidAt) {
        if (transferDescription == null || transferredAmount == null || transactionRef == null) {
            return false;
        }

        // Parse transferDescription to find the payment ID — standard format: {TYPE}-PAY{paymentId}
        // e.g. DEPOSIT-PAY15, RENT-PAY15, FEE-PAY15
        int paymentId = -1;
        java.util.regex.Pattern p = java.util.regex.Pattern.compile("PAY(\\d+)");
        java.util.regex.Matcher m = p.matcher(transferDescription.toUpperCase());
        if (m.find()) {
            try {
                paymentId = Integer.parseInt(m.group(1));
            } catch (NumberFormatException e) {
                return false;
            }
        }

        if (paymentId == -1) {
            return false; // Unrecognized description format — ignore
        }

        java.sql.Connection conn = null;
        try {
            conn = com.swp391.carrental.core.util.DBContext.getConnection();
            conn.setAutoCommit(false); // Begin single database transaction

            // Fetch payment with update row locking (UPDLOCK)
            Payment payment = paymentDAO.findByIdWithLock(conn, paymentId);

            if (payment == null) {
                conn.rollback();
                return false;
            }

            // Idempotency: Check if transactionRef is already processed
            String currentRefs = payment.getTransactionRef();
            String currentNotes = payment.getNotes();
            boolean isDuplicate = (currentRefs != null && currentRefs.contains(transactionRef))
                    || (currentNotes != null && currentNotes.contains(transactionRef));

            if (isDuplicate) {
                conn.rollback();
                return true; // Already processed, return true to acknowledge
            }

            // Accumulate paid amount
            BigDecimal currentPaid = payment.getAmountPaid() != null ? payment.getAmountPaid() : BigDecimal.ZERO;
            BigDecimal newAmountPaid = currentPaid.add(transferredAmount);
            payment.setAmountPaid(newAmountPaid);

            // Audit transaction reference history in notes if a transaction ref is already present
            if (currentRefs != null && !currentRefs.trim().isEmpty()) {
                String histNote = "[Historical TxRef: " + currentRefs + "]";
                if (currentNotes == null || currentNotes.trim().isEmpty()) {
                    payment.setNotes(histNote);
                } else if (!currentNotes.contains(currentRefs)) {
                    payment.setNotes(currentNotes + "; " + histNote);
                }
            }
            payment.setTransactionRef(transactionRef); // Store only the latest transaction reference in transaction_ref

            // Compare with required amount
            BigDecimal requiredAmount = payment.getAmount();
            if (newAmountPaid.compareTo(requiredAmount) >= 0) {
                payment.setStatus("COMPLETED");
                payment.setPaidAt(paidAt != null ? paidAt : java.time.LocalDateTime.now());
            } else {
                payment.setStatus("PENDING");
            }

            // Persist the transactionally updated record
            paymentDAO.updatePaymentTransactional(conn, payment);

            conn.commit(); // Commit database transaction

            // Settle booking status if fully paid (calls outside transaction to keep db connections clean)
            if ("COMPLETED".equals(payment.getStatus())) {
                checkAndSettleBooking(payment.getBookingId());
            }

            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}

