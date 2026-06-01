/*
 * Name: RegisterServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for RegisterServlet.
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

/**
 * Handles user registration.
 * URL: /register
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            if (email.isEmpty() || fullName.isEmpty() || password == null || password.isEmpty() || confirmPassword == null || confirmPassword.isEmpty()) {
                throw new AppException("All fields marked with an asterisk (*) must not be left blank.");
            }

            String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
            if (!email.matches(emailRegex)) {
                throw new AppException("Invalid email format(Ex: abc@gmail.com).");
            }

            if (fullName.length() < 2 || fullName.length() > 50) {
                throw new AppException("The full name must be between 2 and 50 characters long.");
            }

            if (!phone.isEmpty()) {
                String phoneRegex = "^(0|\\+84)(\\s|\\.)?[3|5|7|8|9][0-9]{8}$";
                if (!phone.matches(phoneRegex)) {
                    throw new AppException("The phone number is not in the correct format(It must consist of 10 digits).");
                }
            }

            if (password.length() < 6 || password.length() > 32) {
                throw new AppException("Passwords must be between 6 and 32 characters long.");
            }

            if (!password.equals(confirmPassword)) {
                throw new AppException("The verification password does not match.");
            }

            User user = authService.register(email, fullName, phone, password);
            request.setAttribute("success", "Registration successful! Please login.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email);
            request.setAttribute("fullName", fullName);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        }
    }
}

