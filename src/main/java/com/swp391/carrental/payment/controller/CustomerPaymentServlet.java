package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.model.User;

/*
 * Name: CustomerPaymentServlet
 * @Author: TungNLHE186756
 * Date: 15/07/2026
 * Version: 1.0
 * Description: Displays payment history for the currently logged-in Customer.
 *              Customers may only view payments belonging to their own bookings.
 */

/**
 * Serves the Customer Payment History page at /payments/my.
 * Access is restricted to users with role CUSTOMER.
 * Staff and Admin should use /payments/record for the full transaction log.
 */
@WebServlet(name = "CustomerPaymentServlet", urlPatterns = {"/payments/my"})
public class CustomerPaymentServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");

        // Must be logged in
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Staff/Admin should use the global log — redirect them there
        if (!"CUSTOMER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/payments/record");
            return;
        }

        try {
            List<Payment> myPayments = paymentService.getPaymentsByCustomerId(currentUser.getUserId());
            request.setAttribute("myPayments", myPayments);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Không thể tải lịch sử thanh toán: " + e.getMessage());
        }

        request.setAttribute("dateTimeFormatter",
            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        request.getRequestDispatcher("/WEB-INF/views/payment/my-payments.jsp")
               .forward(request, response);
    }
}
