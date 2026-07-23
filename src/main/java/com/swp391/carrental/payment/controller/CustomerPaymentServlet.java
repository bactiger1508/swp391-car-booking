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
 * Created: 16/07/2026 
 * Description: Controller handling HTTP GET request to display payment history for the currently logged-in Customer.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (21/07/2026): feat: redesign payment management UI and refactor payment...
 * - v1.2 (23/07/2026): Added Javadoc and method comments.
 */
@WebServlet(name = "CustomerPaymentServlet", urlPatterns = {"/payments/history"})
public class CustomerPaymentServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    /**
     * Handles HTTP GET requests to list payment records for the logged-in customer.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");

        // Must be logged in
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<Payment> myPayments;
            if ("CUSTOMER".equals(currentUser.getRole())) {
                myPayments = paymentService.getPaymentsByCustomerId(currentUser.getUserId());
            } else {
                myPayments = paymentService.getAllPayments();
            }
            request.setAttribute("myPayments", myPayments);
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Không thể tải lịch sử thanh toán: " + e.getMessage());
        }

        request.setAttribute("dateTimeFormatter",
            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        request.getRequestDispatcher("/WEB-INF/views/payment/payments-history.jsp")
               .forward(request, response);
    }
}
