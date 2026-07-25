package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.model.User;

/*
 * Name: PaymentStatusServlet
 * @Author: TungNLHE186756
 * Created: 16/07/2026 
 * Description: Controller handling HTTP GET requests to retrieve payment transaction statuses as JSON.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (23/07/2026): Added Javadoc and method comments.
 */
@WebServlet(name = "PaymentStatusServlet", urlPatterns = {"/payments/status"})
public class PaymentStatusServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    /**
     * Handles HTTP GET requests to retrieve payment status information (JSON endpoint).
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json; charset=UTF-8");
        
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        String paymentIdStr = request.getParameter("paymentId");
        if (paymentIdStr == null || paymentIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing paymentId\"}");
            return;
        }

        try {
            int paymentId = Integer.parseInt(paymentIdStr);
            Payment payment = paymentService.getPaymentById(paymentId);
            
            if (payment == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"Payment not found\"}");
                return;
            }

            // Security check: Customers can only query their own payments
            if ("CUSTOMER".equals(currentUser.getRole())) {
                com.swp391.carrental.booking.model.Booking booking = 
                        new com.swp391.carrental.booking.service.BookingService().getBookingById(payment.getBookingId());
                if (booking == null || booking.getCustomerId() != currentUser.getUserId()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.getWriter().write("{\"error\":\"Forbidden\"}");
                    return;
                }
            }

            String json = String.format(
                    "{\"status\":\"%s\",\"amount\":%s,\"amountPaid\":%s}",
                    payment.getStatus(),
                    payment.getAmount() != null ? payment.getAmount().toString() : "0",
                    payment.getAmountPaid() != null ? payment.getAmountPaid().toString() : "0"
            );
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(json);

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid paymentId format\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
