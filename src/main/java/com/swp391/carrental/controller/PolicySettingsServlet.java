package com.swp391.carrental.controller;

import com.swp391.carrental.service.PolicyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "PolicySettingsServlet", urlPatterns = {"/policies"})
public class PolicySettingsServlet extends HttpServlet {
    private final PolicyService policyService = new PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("policies", policyService.getAllPolicies());
        request.getRequestDispatcher("/WEB-INF/views/policy/policy-settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Update policy values
        response.sendRedirect(request.getContextPath() + "/policies");
    }
}

