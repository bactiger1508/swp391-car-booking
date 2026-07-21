package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.model.User;

/**
 * Servlet handling checkout page generation for customers.
 * Displays VietQR information and triggers client-side polling.
 */
@WebServlet(name = "PaymentCheckoutServlet", urlPatterns = {"/payments/checkout"})
public class PaymentCheckoutServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();
    private final PolicyService policyService = new PolicyService();

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

        String paymentIdStr = request.getParameter("paymentId");
        if (paymentIdStr == null || paymentIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã thanh toán (paymentId).");
            return;
        }

        try {
            int paymentId = Integer.parseInt(paymentIdStr);
            Payment payment = paymentService.getPaymentById(paymentId);

            if (payment == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy giao dịch thanh toán.");
                return;
            }

            com.swp391.carrental.booking.model.Booking booking = 
                    new com.swp391.carrental.booking.service.BookingService().getBookingById(payment.getBookingId());
            if (booking != null && ("CANCELLED".equalsIgnoreCase(booking.getStatus()) || "REJECTED".equalsIgnoreCase(booking.getStatus()))) {
                request.getSession().setAttribute("errorMessage", "Đơn đặt xe đã bị hủy hoặc từ chối. Giao dịch thanh toán không thể thực hiện.");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + booking.getBookingId());
                return;
            }

            // Security Check: Customers can only view their own booking payments
            if ("CUSTOMER".equals(currentUser.getRole())) {
                if (booking == null || booking.getCustomerId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập thông tin thanh toán này.");
                    return;
                }
            }

            // If already completed, redirect to booking detail immediately
            if ("COMPLETED".equalsIgnoreCase(payment.getStatus())) {
                request.getSession().setAttribute("successMessage", "Giao dịch thanh toán đã hoàn thành!");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + payment.getBookingId());
                return;
            }

            // Fetch Bank Account configs
            String bankName    = policyService.getPolicyValue("BANK_NAME", "");
            String bankBranch  = policyService.getPolicyValue("BANK_BRANCH", "");
            String bankAccNum  = policyService.getPolicyValue("BANK_ACCOUNT_NUMBER", "");
            String bankAccName = policyService.getPolicyValue("BANK_ACCOUNT_NAME", "");
            String bankBin     = resolveBankBin(bankName);

            request.setAttribute("payment",           payment);
            request.setAttribute("bankName",          bankName);
            request.setAttribute("bankBranch",        bankBranch);
            request.setAttribute("bankAccountNumber", bankAccNum);
            request.setAttribute("bankAccountName",   bankAccName);
            request.setAttribute("bankBin",           bankBin);

            // Generate unique transfer description — standard format: {SHORTTYPE}-PAY{paymentId}
            // Webhook parser (verifyBankTransfer) uses PAY{paymentId} to look up the payment record.
            String shortType;
            switch (payment.getPaymentType() == null ? "" : payment.getPaymentType().toUpperCase()) {
                case "DEPOSIT":        shortType = "DEPOSIT"; break;
                case "RENTAL":         shortType = "RENT";    break;
                case "ADDITIONAL_FEE": shortType = "FEE";     break;
                default:               shortType = "PAY";     break;
            }
            String transferDesc = shortType + "-PAY" + payment.getPaymentId();
            request.setAttribute("transferDesc", transferDesc);

            request.getRequestDispatcher("/WEB-INF/views/payment/checkout.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Định dạng mã thanh toán không đúng.");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý checkout: " + e.getMessage());
        }
    }

    private String resolveBankBin(String bankName) {
        if (bankName == null || bankName.trim().isEmpty()) return "";
        String upper = bankName.toUpperCase();
        if (upper.contains("VIETCOMBANK") || upper.contains("VCB")) return "970436";
        if (upper.contains("TECHCOMBANK") || upper.contains("TCB")) return "970407";
        if (upper.contains("VIETINBANK") || upper.contains("CTG")) return "970415";
        if (upper.contains("BIDV")) return "970418";
        if (upper.contains("AGRIBANK") || upper.contains("VARB")) return "970405";
        if (upper.contains("MB") || upper.contains("MILITARY")) return "970422";
        if (upper.contains("TPBANK") || upper.contains("TIENPHONG")) return "970423";
        if (upper.contains("VPBANK") || upper.contains("VIETNAM THUONG TIN")) return "970432";
        if (upper.contains("ACB")) return "970416";
        if (upper.contains("SACOMBANK") || upper.contains("STB")) return "970403";
        
        for (Map.Entry<String, String> entry : BANK_BIN_MAP.entrySet()) {
            if (upper.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return "";
    }
}
