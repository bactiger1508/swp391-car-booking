/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.carrental.auth.controller;

import com.swp391.carrental.user.dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import com.swp391.carrental.user.model.User;
/*
 * Name: ChangePasswordServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for ChangePasswordServlet.
 */



/**
 * Handles user change password .
 * URL: /change-password
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Redirect unauthenticated users to login page
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Validate user permissions for changing password
        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "CHANGE_PASSWORD")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thay đổi mật khẩu.");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Redirect unauthenticated users to login page
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Validate user permissions for changing password
        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "CHANGE_PASSWORD")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thay đổi mật khẩu.");
            return;
        }

        // Retrieve form input parameters
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            User dbUser = userDAO.findByEmail(currentUser.getEmail());

            if (!BCrypt.checkpw( currentPassword,dbUser.getPasswordHash())) {
                request.setAttribute( "error","Mật khẩu hiện tại không đúng.");
                doGet(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error","Xác nhận mật khẩu không khớp.");
                doGet(request, response);
                return;
            }

            if (newPassword.length() < 6) {
                request.setAttribute("error","Mật khẩu phải có ít nhất 6 ký tự.");
                doGet(request, response);
                return;
            }

            String hashPassword = BCrypt.hashpw(newPassword,BCrypt.gensalt());
            userDAO.updatePassword(currentUser.getUserId(),hashPassword);
            request.setAttribute("success","Đổi mật khẩu thành công.");
            doGet(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error","Lỗi hệ thống.");
            doGet(request, response);
        }
    }
}
