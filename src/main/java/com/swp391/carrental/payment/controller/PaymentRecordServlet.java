package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.model.User;

/*
 * Name: PaymentRecordServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.1
 * Description: Handles HTTP requests and responses for PaymentRecordServlet.
 *              v1.1 — loads bank config from PolicyService for QR generation;
 *                     reads amountPaid from form for overpayment tracking;
 *                     enforces REFUND=CASH rule before service call.
 */



/**
 * Handles the payment record page and payment form submission.
 *
 * <p>GET /payments/record — shows payment form for a specific booking (any logged-in user)
 * or global transaction log (Staff/Admin only).</p>
 *
 * <p>POST /payments/record — records a payment. Any authenticated user
 * may submit a payment for their own booking. Staff/Admin may also enter
 * the actual received amount (amountPaid) for overpayment tracking.</p>
 */
@WebServlet(name = "PaymentRecordServlet", urlPatterns = {"/payments/record"})
public class PaymentRecordServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();
    private final com.swp391.carrental.booking.service.BookingService bookingService
            = new com.swp391.carrental.booking.service.BookingService();
    private final com.swp391.carrental.vehicle.service.VehicleService vehicleService
            = new com.swp391.carrental.vehicle.service.VehicleService();
    private final com.swp391.carrental.user.service.UserService userService
            = new com.swp391.carrental.user.service.UserService();
    private final com.swp391.carrental.contract.service.ContractService contractService
            = new com.swp391.carrental.contract.service.ContractService();
    private final PolicyService policyService = new PolicyService();

    // ─── Static bank BIN map for VietQR ──────────────────────────────────────
    // Maps upper-cased bank name keywords → VietQR BIN code.
    // Used to build the VietQR image URL without requiring a DB column.
    private static final Map<String, String> BANK_BIN_MAP = new HashMap<>();
    static {
        BANK_BIN_MAP.put("TECHCOMBANK",  "970407");
        BANK_BIN_MAP.put("VIETCOMBANK",  "970436");
        BANK_BIN_MAP.put("VIETINBANK",   "970415");
        BANK_BIN_MAP.put("BIDV",         "970418");
        BANK_BIN_MAP.put("AGRIBANK",     "970405");
        BANK_BIN_MAP.put("MBBANK",       "970422");
        BANK_BIN_MAP.put("MB",           "970422");
        BANK_BIN_MAP.put("TPBANK",       "970423");
        BANK_BIN_MAP.put("VPBANK",       "970432");
        BANK_BIN_MAP.put("ACB",          "970416");
        BANK_BIN_MAP.put("SACOMBANK",    "970403");
        BANK_BIN_MAP.put("HDBANK",       "970437");
        BANK_BIN_MAP.put("OCB",          "970448");
        BANK_BIN_MAP.put("SEABANK",      "970440");
        BANK_BIN_MAP.put("VIB",          "970441");
        BANK_BIN_MAP.put("EXIMBANK",     "970431");
        BANK_BIN_MAP.put("SHB",          "970443");
        BANK_BIN_MAP.put("LPB",          "970449");
        BANK_BIN_MAP.put("LIENVIETBANK", "970449");
        BANK_BIN_MAP.put("NCBBANK",      "970419");
        BANK_BIN_MAP.put("MSBANK",       "970426");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr);
                com.swp391.carrental.booking.model.Booking booking = bookingService.getBookingById(bookingId);

                if (booking == null) {
                    request.setAttribute("errorMsg", "Không tìm thấy đơn đặt xe.");
                } else {
                    boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "RECORD_PAYMENT");
                    if (!isStaffOrAdmin && booking.getCustomerId() != currentUser.getUserId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập thanh toán cho đơn thuê này.");
                        return;
                    }
                    request.setAttribute("isStaffOrAdmin", isStaffOrAdmin);

                    request.setAttribute("booking", booking);
                    com.swp391.carrental.vehicle.model.Car car = vehicleService.getCarById(booking.getCarId());
                    request.setAttribute("car", car);
                    if (car != null) {
                        request.setAttribute("carImageUrl", vehicleService.resolvePrimaryImageUrl(car.getCarId()));
                    }
                    request.setAttribute("customer", userService.getUserById(booking.getCustomerId()));

                    // Contract Info
                    com.swp391.carrental.contract.model.RentalContract contract = contractService.getContractByBookingId(bookingId);
                    request.setAttribute("contract", contract);

                    // Compute payment metrics
                    java.util.List<Payment> payments = paymentService.getPaymentsByBooking(bookingId);
                    BigDecimal totalPaid = BigDecimal.ZERO;
                    BigDecimal depositPaidAmt = BigDecimal.ZERO;
                    BigDecimal rentalPaidAmt = BigDecimal.ZERO;

                    for (Payment p : payments) {
                        BigDecimal actualAmt = p.getAmountPaid() != null ? p.getAmountPaid() : BigDecimal.ZERO;
                        if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                            BigDecimal completedAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                            if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                                totalPaid = totalPaid.subtract(completedAmt);
                            } else {
                                totalPaid = totalPaid.add(completedAmt);
                                if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                                    depositPaidAmt = depositPaidAmt.add(completedAmt);
                                } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                                    rentalPaidAmt = rentalPaidAmt.add(completedAmt);
                                }
                            }
                        } else if ("PENDING".equalsIgnoreCase(p.getStatus())) {
                            if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                                totalPaid = totalPaid.subtract(actualAmt);
                            } else {
                                totalPaid = totalPaid.add(actualAmt);
                                if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                                    depositPaidAmt = depositPaidAmt.add(actualAmt);
                                } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                                    rentalPaidAmt = rentalPaidAmt.add(actualAmt);
                                }
                            }
                        }
                    }

                    boolean depositPaid = depositPaidAmt.compareTo(booking.getDepositAmount()) >= 0;
                    BigDecimal rentalRequired = booking.getTotalAmount().subtract(booking.getDepositAmount());
                    boolean rentalPaid = rentalPaidAmt.compareTo(rentalRequired) >= 0;

                    BigDecimal remainingDeposit = booking.getDepositAmount().subtract(depositPaidAmt);
                    if (remainingDeposit.compareTo(BigDecimal.ZERO) < 0) {
                        remainingDeposit = BigDecimal.ZERO;
                    }

                    request.setAttribute("totalPaid", totalPaid);
                    request.setAttribute("depositPaid", depositPaid);
                    request.setAttribute("rentalPaid", rentalPaid);
                    request.setAttribute("remainingDeposit", remainingDeposit);

                    // Fetch vehicle return and include its totalAdditionalFee in totalAmount
                    com.swp391.carrental.handover.model.VehicleReturn vehicleReturn = null;
                    try {
                        vehicleReturn = new com.swp391.carrental.handover.dao.ReturnDAO().findByBookingId(bookingId);
                    } catch (Exception e) {
                        // ignore error
                    }
                    BigDecimal totalAmount = booking.getTotalAmount();
                    if (vehicleReturn != null && vehicleReturn.getTotalAdditionalFee() != null) {
                        totalAmount = totalAmount.add(vehicleReturn.getTotalAdditionalFee());
                    }
                    request.setAttribute("totalAmount", totalAmount);
                    request.setAttribute("returns", vehicleReturn);

                    BigDecimal remainingAmount = totalAmount.subtract(totalPaid);
                    BigDecimal excessAmount = BigDecimal.ZERO;
                    if (totalPaid.compareTo(totalAmount) > 0) {
                        excessAmount = totalPaid.subtract(totalAmount);
                    }
                    request.setAttribute("excessAmount", excessAmount);

                    if (remainingAmount.compareTo(BigDecimal.ZERO) < 0) {
                        remainingAmount = BigDecimal.ZERO;
                    }
                    request.setAttribute("remainingAmount", remainingAmount);

                    // Pre-select payment type based on current payment status
                    String defaultPaymentType = "DEPOSIT";
                    if (depositPaid) defaultPaymentType = "RENTAL";
                    if (rentalPaid)  defaultPaymentType = "ADDITIONAL_FEE";
                    if (excessAmount.compareTo(BigDecimal.ZERO) > 0 && !"CUSTOMER".equals(currentUser.getRole())) {
                        defaultPaymentType = "REFUND";
                    }
                    request.setAttribute("defaultPaymentType", defaultPaymentType);

                    // Financial breakdown for "Booking Summary" on the right
                    long days = java.time.Duration.between(booking.getStartDate(), booking.getEndDate()).toDays();
                    if (days <= 0) days = 1;
                    request.setAttribute("rentalDays", days);

                    // ─── Bank account info for QR code generation ────────────────
                    String bankName    = policyService.getPolicyValue("BANK_NAME", "");
                    String bankBranch  = policyService.getPolicyValue("BANK_BRANCH", "");
                    String bankAccNum  = policyService.getPolicyValue("BANK_ACCOUNT_NUMBER", "");
                    String bankAccName = policyService.getPolicyValue("BANK_ACCOUNT_NAME", "");

                    // Resolve BIN from bank name (for VietQR URL)
                    String bankBin = resolveBankBin(bankName);

                    request.setAttribute("bankName",          bankName);
                    request.setAttribute("bankBranch",        bankBranch);
                    request.setAttribute("bankAccountNumber", bankAccNum);
                    request.setAttribute("bankAccountName",   bankAccName);
                    request.setAttribute("bankBin",           bankBin);

                    // ─── Transfer description for QR ─────────────────────────────
                    // Format: {TYPE}-PAY{paymentId}  (matches checkout page and webhook parser)
                    // If there is already a PENDING payment of this type, use its ID so the QR is
                    // immediately scannable.  Otherwise we can't know the ID yet — use 0 as placeholder;
                    // the customer is redirected to /payments/checkout after submit where the real ID is used.
                    int existingPendingId = 0;
                    for (Payment ep : payments) {
                        if ("PENDING".equalsIgnoreCase(ep.getStatus())
                                && ep.getPaymentType().equalsIgnoreCase(defaultPaymentType)) {
                            existingPendingId = ep.getPaymentId();
                            break;
                        }
                    }
                    String transferDesc = buildTransferDescription(defaultPaymentType, existingPendingId);
                    request.setAttribute("transferDesc", transferDesc);
                }
            } catch (Exception e) {
                request.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            }
            // Pass enabled methods (CASH + BANK_TRANSFER) for UI rendering
            request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
            request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
                   .forward(request, response);
            return;
        }

        boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "RECORD_PAYMENT");
        // No bookingId: Customer is not allowed to view the global transactions log
        if (!isStaffOrAdmin) {
            response.sendRedirect(request.getContextPath() + "/payments/my");
            return;
        }

        // Staff/Admin: show global payment log
        request.setAttribute("payments",       paymentService.getAllPayments());
        request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
        request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "RECORD_PAYMENT")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        try {
            Payment payment = buildPaymentFromRequest(request, currentUser.getUserId());

            // Security check: CUSTOMER cannot create REFUND payments
            if ("CUSTOMER".equals(currentUser.getRole()) && "REFUND".equalsIgnoreCase(payment.getPaymentType())) {
                throw new AppException("Khách hàng không được quyền tạo giao dịch hoặc yêu cầu hoàn tiền.", 403);
            }

            // recordPayment() calls validatePaymentMethod() + validateRefundMethod() + validateAmount()
            int paymentId = paymentService.recordPayment(payment);

            // Redirect customer bank transfer payments to the awaiting checkout page
            if ("CUSTOMER".equals(currentUser.getRole()) && "BANK_TRANSFER".equalsIgnoreCase(payment.getPaymentMethod())) {
                response.sendRedirect(request.getContextPath() + "/payments/checkout?paymentId=" + paymentId);
                return;
            }

            String redirectParam = request.getParameter("redirect");
            if ("booking".equals(redirectParam)) {
                request.getSession().setAttribute("successMessage", "Ghi nhận thanh toán thành công!");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + payment.getBookingId());
            } else {
                request.getSession().setAttribute("paymentSuccess", "Ghi nhận thanh toán thành công!");
                response.sendRedirect(request.getContextPath() + "/payments/record?bookingId=" + payment.getBookingId());
            }

        } catch (AppException e) {
            // Validation error — reload the payment form for the booking
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam != null && !bookingIdParam.isEmpty()) {
                request.getSession().setAttribute("paymentError", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/payments/record?bookingId=" + bookingIdParam);
            } else {
                request.setAttribute("errorMsg", e.getMessage());
                request.setAttribute("payments", paymentService.getAllPayments());
                request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
                request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
                       .forward(request, response);
            }
        }
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private Payment buildPaymentFromRequest(HttpServletRequest req, int userId) {
        Payment p = new Payment();
        p.setBookingId(Integer.parseInt(req.getParameter("bookingId")));

        String contractIdStr = req.getParameter("contractId");
        if (contractIdStr != null && !contractIdStr.isEmpty()) {
            p.setContractId(Integer.parseInt(contractIdStr));
        }

        // Required amount (the amount that is owed)
        p.setAmount(new BigDecimal(req.getParameter("amount")));

        // Actual paid amount — entered by Staff/Admin after verifying receipt.
        // Customers submit the same value as amount (no amountPaid field on customer UI).
        String amountPaidStr = req.getParameter("amountPaid");
        if (amountPaidStr != null && !amountPaidStr.trim().isEmpty()) {
            try {
                BigDecimal amountPaid = new BigDecimal(amountPaidStr.trim());
                if (amountPaid.compareTo(BigDecimal.ZERO) > 0) {
                    p.setAmountPaid(amountPaid);
                }
            } catch (NumberFormatException ignore) {
                // If unparseable, leave amountPaid null
            }
        }

        p.setPaymentType(req.getParameter("paymentType"));
        p.setPaymentMethod(req.getParameter("paymentMethod"));
        
        // Resolve role from session to determine status
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser != null && "CUSTOMER".equals(currentUser.getRole())) {
            p.setStatus("PENDING"); // Customer needs staff to confirm receipt
            p.setPaidAt(null);
            p.setRecordedBy(null);
        } else {
            p.setStatus("COMPLETED"); // Staff logs payment as completed directly
            p.setPaidAt(LocalDateTime.now());
            p.setRecordedBy(userId);
        }
        
        // transaction_ref is reserved for actual bank transaction IDs (future webhook integration)
        // The QR transfer description is NOT stored here — it's only inside the QR image URL.
        p.setTransactionRef(req.getParameter("transactionRef"));
        p.setNotes(req.getParameter("notes"));
        return p;
    }


    /**
     * Resolves the VietQR BIN code from a bank name string.
     * Searches the BANK_BIN_MAP using upper-cased keywords from the bank name.
     *
     * @param bankName configured bank name (e.g. "Ngân hàng Techcombank")
     * @return VietQR BIN string (e.g. "970407"), or empty string if not found
     */
    private String resolveBankBin(String bankName) {
        if (bankName == null || bankName.trim().isEmpty()) return "";
        String upper = bankName.toUpperCase();
        if (upper.contains("VIETCOMBANK") || upper.contains("VCB")) {
            return "970436";
        }
        if (upper.contains("TECHCOMBANK") || upper.contains("TCB")) {
            return "970407";
        }
        if (upper.contains("VIETINBANK") || upper.contains("CTG")) {
            return "970415";
        }
        if (upper.contains("BIDV")) {
            return "970418";
        }
        if (upper.contains("AGRIBANK") || upper.contains("VARB")) {
            return "970405";
        }
        if (upper.contains("MB") || upper.contains("MILITARY")) {
            return "970422";
        }
        if (upper.contains("TPBANK") || upper.contains("TIENPHONG")) {
            return "970423";
        }
        if (upper.contains("VPBANK") || upper.contains("VIETNAM THUONG TIN")) {
            return "970432";
        }
        if (upper.contains("ACB")) {
            return "970416";
        }
        if (upper.contains("SACOMBANK") || upper.contains("STB")) {
            return "970403";
        }
        for (Map.Entry<String, String> entry : BANK_BIN_MAP.entrySet()) {
            if (upper.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return "";
    }

    /**
     * Builds a compact transfer description for the QR code addInfo parameter.
     *
     * <p>Standard format: {SHORTTYPE}-PAY{paymentId} (e.g. DEPOSIT-PAY15, RENT-PAY15, FEE-PAY15).
     * On the payment-record page (before submission), paymentId is unknown, so we generate
     * a booking-scoped placeholder. After the customer submits, they are redirected to
     * /payments/checkout?paymentId=X which regenerates the QR with the real paymentId.</p>
     *
     * @param paymentType  e.g. "DEPOSIT", "RENTAL"
     * @param paymentId    actual payment ID if known (-1 for unknown/pre-submit)
     */
    private String buildTransferDescription(String paymentType, int paymentId) {
        String shortType;
        switch (paymentType == null ? "" : paymentType.toUpperCase()) {
            case "DEPOSIT":        shortType = "DEPOSIT"; break;
            case "RENTAL":         shortType = "RENT";    break;
            case "ADDITIONAL_FEE": shortType = "FEE";     break;
            default:               shortType = "PAY";     break;
        }
        return shortType + "-PAY" + paymentId;
    }
}
