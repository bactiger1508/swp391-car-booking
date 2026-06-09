/*
 * Name: RegisterServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for RegisterServlet.
 */
package com.swp391.carrental.controller.auth;

import com.swp391.carrental.model.User;
import com.swp391.carrental.service.AuthService;
import com.swp391.carrental.exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Handles user registration.
 * URL: /register
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    private static final java.util.regex.Pattern EMAIL_PATTERN = 
            java.util.regex.Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    
    private static final java.util.regex.Pattern PHONE_PATTERN = 
            java.util.regex.Pattern.compile("^(0|\\+84)[3|5|7|8|9][0-9]{8}$");

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
            // Basic validation
            if (fullName == null || fullName.trim().isEmpty()) {
                throw new AppException("Vui lòng nhập họ và tên.");
            }
            if (email == null || email.trim().isEmpty()) {
                throw new AppException("Vui lòng nhập địa chỉ email.");
            }
            if (!EMAIL_PATTERN.matcher(email.trim()).matches()) {
                throw new AppException("Email không đúng định dạng.");
            }
            if (phone != null && !phone.trim().isEmpty()) {
                String cleanedPhone = phone.trim().replaceAll("\\s+", "");
                if (!PHONE_PATTERN.matcher(cleanedPhone).matches()) {
                    throw new AppException("Số điện thoại không đúng định dạng (phải có 10 chữ số).");
                }
            }
            if (password == null || password.isEmpty()) {
                throw new AppException("Vui lòng nhập mật khẩu.");
            }
            if (password.length() < 6) {
                throw new AppException("Mật khẩu phải từ 6 ký tự trở lên.");
            }
            if (!password.equals(confirmPassword)) {
                throw new AppException("Mật khẩu xác nhận không khớp.");
            }

            User user = authService.register(email.trim(), fullName.trim(), phone != null && !phone.trim().isEmpty() ? phone.trim() : null, password);
            request.setAttribute("success", "Đăng ký thành công! Vui lòng đăng nhập.");
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

