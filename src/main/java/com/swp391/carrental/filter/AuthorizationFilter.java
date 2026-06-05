/*
 * Name: AuthorizationFilter
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles business logic and operations for AuthorizationFilter.
 */
package com.swp391.carrental.filter;

import com.swp391.carrental.model.User;
import com.swp391.carrental.constant.Role;
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

/**
 * Authorization filter.
 * Checks if the logged-in user's role is allowed to access certain URLs.
 * Redirects to access-denied page if role is insufficient.
 */
@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/*"})
public class AuthorizationFilter implements Filter {

    /**
     * Maps URL prefixes to the list of allowed roles.
     */
    private static final Map<String, List<String>> ROLE_RESTRICTIONS = new HashMap<>();

    static {
        // Admin-only pages
        ROLE_RESTRICTIONS.put("/users", Arrays.asList(Role.ADMIN));
        ROLE_RESTRICTIONS.put("/roles", Arrays.asList(Role.ADMIN));

        // Staff and Admin pages
        ROLE_RESTRICTIONS.put("/vehicles/manage", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/maintenance", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/bookings/manage", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/bookings/approval", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/contracts", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/payments/record", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/policies", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/tax-invoice-settings", Arrays.asList(Role.ADMIN));
        ROLE_RESTRICTIONS.put("/admin/payment-settings", Arrays.asList(Role.ADMIN));
        ROLE_RESTRICTIONS.put("/handovers", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/returns", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/additional-fees", Arrays.asList(Role.ADMIN, Role.STAFF));
        ROLE_RESTRICTIONS.put("/reports", Arrays.asList(Role.ADMIN, Role.STAFF));
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

        // Check if this path has role restrictions
        for (Map.Entry<String, List<String>> entry : ROLE_RESTRICTIONS.entrySet()) {
            if (path.startsWith(entry.getKey())) {
                HttpSession session = httpRequest.getSession(false);
                if (session != null) {
                    User user = (User) session.getAttribute("currentUser");
                    if (user != null && !entry.getValue().contains(user.getRole())) {
                        // User doesn't have the required role
                        httpRequest.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                                .forward(httpRequest, httpResponse);
                        return;
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
