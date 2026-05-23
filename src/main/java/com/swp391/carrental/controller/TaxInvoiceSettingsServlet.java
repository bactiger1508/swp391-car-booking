package com.swp391.carrental.controller;

import com.swp391.carrental.service.PolicyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "TaxInvoiceSettingsServlet", urlPatterns = {"/tax-invoice-settings"})
public class TaxInvoiceSettingsServlet extends HttpServlet {
    private final PolicyService policyService = new PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // BR-10: Tax/invoice fields are stored internally only
        request.setAttribute("taxPolicies", policyService.getPoliciesByCategory("TAX"));
        request.getRequestDispatcher("/WEB-INF/views/payment/tax-invoice-settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Update tax/invoice settings
        response.sendRedirect(request.getContextPath() + "/tax-invoice-settings");
    }
}

