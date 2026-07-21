package com.swp391.carrental.core.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.util.SecurityUtils;
import com.swp391.carrental.user.model.User;

/*
 * Name: AuthorizationFilter
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles business logic and operations for AuthorizationFilter.
 */

/**
 * Authorization filter.
 * Checks if the logged-in user has the required permission to access certain
 * URLs.
 * Redirects to access-denied page if permission is insufficient.
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = { "/*" })
public class AuthorizationFilter implements Filter {

    /**
     * Maps URL prefixes to the required permission key.
     */
    private static final Map<String, String> PATH_PERMISSIONS = new HashMap<>();

    static {
        PATH_PERMISSIONS.put("/users", "VIEW_USER_LIST");
        PATH_PERMISSIONS.put("/roles", "VIEW_USER_LIST"); // only admins can manage roles
        PATH_PERMISSIONS.put("/user/customer-profiles", "VERIFY_CUSTOMER_PROFILE");

        PATH_PERMISSIONS.put("/vehicles/manage", "VIEW_VEHICLE_DETAIL_STAFF");
        PATH_PERMISSIONS.put("/vehicles/availability", "CHECK_VEHICLE_AVAILABILITY");
        PATH_PERMISSIONS.put("/maintenance", "RECORD_VEHICLE_MAINTENANCE");
        PATH_PERMISSIONS.put("/bookings/manage", "PROCESS_BOOKING_REQUEST");
        PATH_PERMISSIONS.put("/bookings/approval", "PROCESS_BOOKING_REQUEST");
        PATH_PERMISSIONS.put("/bookings/calendar", "VIEW_BOOKINGS_CALENDAR");
        // PATH_PERMISSIONS.put("/bookings/create", "CREATE_BOOKING"); // Bypassed for Guest-to-Customer flow
        PATH_PERMISSIONS.put("/bookings/edit", "UPDATE_BOOKING");
        PATH_PERMISSIONS.put("/contracts", "VIEW_CONTRACT");
        PATH_PERMISSIONS.put("/payments/record", "RECORD_PAYMENT");
        PATH_PERMISSIONS.put("/policies", "CONFIGURE_RENTAL_POLICY");
        PATH_PERMISSIONS.put("/tax-invoice-settings", "EXPORT_VAT_INVOICE");
        PATH_PERMISSIONS.put("/admin/payment-settings", "CONFIGURE_PAYMENT_METHOD");
        PATH_PERMISSIONS.put("/handovers", "PROCESS_HANDOVER");
        PATH_PERMISSIONS.put("/handover/view", "VIEW_BOOKING");
        PATH_PERMISSIONS.put("/returns", "PROCESS_RETURN");
        PATH_PERMISSIONS.put("/return/view", "VIEW_BOOKING");
        PATH_PERMISSIONS.put("/additional-fees", "RECORD_ADDITIONAL_FEE");
        PATH_PERMISSIONS.put("/reports", "VIEW_REVENUE_REPORT");
        PATH_PERMISSIONS.put("/change-password", "CHANGE_PASSWORD");
        PATH_PERMISSIONS.put("/vehicles/brands", "MANAGE_VEHICLE_BRANDS");
        PATH_PERMISSIONS.put("/payments/approve", "APPROVE_PAYMENT");
        PATH_PERMISSIONS.put("/payments/checkout", "INITIATE_PAYMENT");
        PATH_PERMISSIONS.put("/audit-logs", "VIEW_AUDIT_LOGS");
        PATH_PERMISSIONS.put("/vat-invoice", "CREATE_VAT_INVOICE");
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();

        // Sort prefixes by length descending to match most specific prefix first
        java.util.List<String> sortedPrefixes = PATH_PERMISSIONS.keySet().stream()
                .sorted((a, b) -> Integer.compare(b.length(), a.length()))
                .toList();

        // Check if this path has permission restrictions
        for (String prefix : sortedPrefixes) {
            if (path.startsWith(prefix)) {
                String requiredPerm = PATH_PERMISSIONS.get(prefix);
                HttpSession session = httpRequest.getSession(false);
                if (session != null) {
                    User user = (User) session.getAttribute("currentUser");
                    if (user != null) {
                        // Bypass /payments/record restriction for CUSTOMER role (servlet handles ownership check)
                        if ("/payments/record".equals(prefix) && "CUSTOMER".equals(user.getRole())) {
                            break;
                        }
                        // Bypass /vehicles/availability restriction for realtime checkCarAvailability action
                        if ("/vehicles/availability".equals(prefix) && "checkCarAvailability".equals(httpRequest.getParameter("action"))) {
                            break;
                        }
                        if (!SecurityUtils.hasPermission(httpRequest, requiredPerm)) {
                            // User doesn't have the required permission
                            httpRequest.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                                    .forward(httpRequest, httpResponse);
                            return;
                        }
                    }
                }
                break;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
