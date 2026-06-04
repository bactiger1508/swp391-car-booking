/*
 * Name: PaymentRecordServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for PaymentRecordServlet.
 */
package com.swp391.carrental.controller.payment;

import com.swp391.carrental.exception.AppException;
import com.swp391.carrental.model.Payment;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@WebServlet(name = "PaymentRecordServlet", urlPatterns = {"/payments/record"})
public class PaymentRecordServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    /**
     * Handles GET requests.
     *
     * Loads:
     * - All recorded payments
     * - Enabled payment methods configured in the system
     *
     * Forwards data to the payment record management page.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Pass all payments + which methods are enabled (for dropdown filtering)
        request.setAttribute("payments",       paymentService.getAllPayments());
        request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
        request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
               .forward(request, response);
    }

    /**
     * Handles POST requests.
     *
     * Records a new payment transaction submitted by staff/admin.
     * Validation is performed by PaymentService before saving.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        
        // Require authentication
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Payment payment = buildPaymentFromRequest(request, currentUser.getUserId());
            // recordPayment() now calls validatePaymentMethod() + validateAmount() internally
            paymentService.recordPayment(payment);
            request.getSession().setAttribute("paymentSuccess", "Ghi nhận thanh toán thành công!");
            response.sendRedirect(request.getContextPath() + "/payments/record");

        } catch (AppException e) {
            // Validation error — send user back with error message
            request.setAttribute("errorMsg",      e.getMessage());
            request.setAttribute("payments",       paymentService.getAllPayments());
            request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
            request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
                   .forward(request, response);
        }
    }

    //Builds a Payment object from request parameters.
    private Payment buildPaymentFromRequest(HttpServletRequest req, int userId) {
        Payment p = new Payment();
        p.setBookingId(Integer.parseInt(req.getParameter("bookingId")));

        String contractIdStr = req.getParameter("contractId");
        // Contract exist
        if (contractIdStr != null && !contractIdStr.isEmpty()) {
            p.setContractId(Integer.parseInt(contractIdStr));
        }

        p.setAmount(new BigDecimal(req.getParameter("amount")));
        p.setPaymentType(req.getParameter("paymentType"));
        p.setPaymentMethod(req.getParameter("paymentMethod"));
        p.setStatus("COMPLETED");
        p.setTransactionRef(req.getParameter("transactionRef"));
        p.setNotes(req.getParameter("notes"));
        p.setPaidAt(LocalDateTime.now());
        p.setRecordedBy(userId);
        return p;
    }
}

