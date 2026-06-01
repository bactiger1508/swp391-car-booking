/*
 * Name: LoginServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for LoginServlet.
 */
package com.swp391.carrental.controller.auth;

import java.io.IOException;

import com.swp391.carrental.exception.AppException;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Handles user login.
 * URL: /login
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If already logged in, redirect to home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            if (email.isEmpty() || password == null || password.isEmpty()) {
                throw new AppException("Please enter your email and password completely.");
            }

            if (!email.contains("@") || !email.contains(".")) {
                throw new AppException("The email address is not in the correct format.");
            }
            User user = authService.login(email, password);

            // Store user in session
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            // Redirect to saved URL or home
            String redirectUrl = (String) session.getAttribute("redirectUrl");
            session.removeAttribute("redirectUrl");
            
            if (redirectUrl != null && !redirectUrl.endsWith("index.html") && !redirectUrl.equals("/")) {
                response.sendRedirect(request.getContextPath() + redirectUrl);
            } else {
                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/users"); 
                } else if ("STAFF".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/bookings/manage");
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
            }
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }
}

