package com.swp391.carrental.controller;

import com.swp391.carrental.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "PaymentRecordServlet", urlPatterns = {"/payments/record"})
public class PaymentRecordServlet extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("payments", paymentService.getAllPayments());
        request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Record new payment
        response.sendRedirect(request.getContextPath() + "/payments/record");
    }
}

