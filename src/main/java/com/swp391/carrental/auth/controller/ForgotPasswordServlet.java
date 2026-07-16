package com.swp391.carrental.auth.controller;

import com.swp391.carrental.auth.service.EmailService;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import org.mindrot.jbcrypt.BCrypt;
import java.util.Random;

/*
 * Name: ForgotPasswordServlet
 * @Author: AnhNNHE160896
 * Date: 01/06/2026
 * Version: 1.0
 * Description: Handles password recovery requests.
 */
/**
 * Handles forgot password recovery. URL: /forgot-password
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final Random RANDOM = new Random();

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
            email = email.trim();

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
            String newPassword = generateRandomPassword();
            String passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            userDAO.updatePassword(user.getUserId(), passwordHash);
            try {
                EmailService.sendForgotPasswordEmail(email,newPassword);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error","Không thể gửi email đặt lại mật khẩu.");
                request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }
            request.setAttribute("success","Mật khẩu mới đã được gửi tới email của bạn. " + "Vui lòng kiểm tra hộp thư để đăng nhập.");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "Lỗi hệ thống khi đặt lại mật khẩu: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        }
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "abcdefghijklmnopqrstuvwxyz" + "0123456789";
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            password.append(chars.charAt(RANDOM.nextInt(chars.length())));
        }
        return password.toString();
    }
}
