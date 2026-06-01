/*
 * Name: BookingPolicyServlet
 * @Author: BacBui
 * Date: 29/05/2026
 * Version: 1.0
 * Description: Displays booking-related policies (read-only). Accessible by all logged-in users.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.service.PolicyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Displays booking policies.
 * URL: /bookings/policy
 */
@WebServlet(name = "BookingPolicyServlet", urlPatterns = {"/bookings/policy"})
public class BookingPolicyServlet extends HttpServlet {

    private final PolicyService policyService = new PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Load booking-related policies
        request.setAttribute("bookingPolicies", policyService.getPoliciesByCategory("BOOKING"));
        request.setAttribute("pricingPolicies", policyService.getPoliciesByCategory("PRICING"));
        request.setAttribute("penaltyPolicies", policyService.getPoliciesByCategory("PENALTY"));

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-policy.jsp")
                .forward(request, response);
    }
}
