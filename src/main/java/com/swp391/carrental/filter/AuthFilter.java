/*
 * Name: AuthFilter
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles business logic and operations for AuthFilter.
 */
package com.swp391.carrental.filter;

import com.swp391.carrental.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

/**
 * Authentication filter.
 * Checks if user is logged in for protected URLs.
 * Allows public URLs to pass through without authentication.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {

    /**
     * URLs that do not require authentication.
     */
    private static final List<String> PUBLIC_URLS = Arrays.asList(
            "/login",
            "/register",
            "/logout",
            "/test-db",
            "/home",
            "/",
            "",
            "/index.jsp",
            "/index.html",
            "/vehicles",
            "/vehicles/detail",
            "/bookings/policy",
            "/forgot-password"
    );

    /**
     * Static resource prefixes that should bypass the filter.
     */
    private static final List<String> STATIC_PREFIXES = Arrays.asList(
            "/assets/",
            "/favicon.ico"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();

        // Allow static resources
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Allow public URLs
        if (PUBLIC_URLS.contains(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        HttpSession session = httpRequest.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }

        if (currentUser == null) {
            // Save the requested URL for redirect after login
            httpRequest.getSession().setAttribute("redirectUrl", path);
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        // User is authenticated, continue
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
