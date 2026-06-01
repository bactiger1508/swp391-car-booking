/*
 * Name: ForgotPasswordServlet
 * @Author: AnhNNHE160896
 * Date: 01/06/2026
 * Version: 1.0
 * Description: Handles password recovery requests.
 */
package com.swp391.carrental.controller.auth;

import java.io.IOException;
import java.sql.SQLException;

import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Handles forgot password recovery.
 * URL: /forgot-password
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If already logged in, redirect to home
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");

        try {
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập email của bạn.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            if (!email.contains("@") || !email.contains(".")) {
                request.setAttribute("error", "Định dạng email không hợp lệ.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            User user = userDAO.findByEmail(email);
            if (user == null) {
                request.setAttribute("error", "Email không tồn tại trong hệ thống.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            // Mock reset password to "123456" for ease of testing
            String defaultPassword = "123456";
            String passwordHash = org.mindrot.jbcrypt.BCrypt.hashpw(defaultPassword, org.mindrot.jbcrypt.BCrypt.gensalt());
            userDAO.updatePassword(user.getUserId(), passwordHash);

            request.setAttribute("success", "Đặt lại mật khẩu thành công! Mật khẩu mới là: <strong>" + defaultPassword + "</strong>. Vui lòng đăng nhập lại và đổi mật khẩu ngay.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi hệ thống khi đặt lại mật khẩu: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
