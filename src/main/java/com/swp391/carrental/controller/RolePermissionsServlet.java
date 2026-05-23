package com.swp391.carrental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Handles role permissions management (Admin only).
 * URL: /roles
 */
@WebServlet(name = "RolePermissionsServlet", urlPatterns = {"/roles"})
public class RolePermissionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Load role permissions data
        request.getRequestDispatcher("/WEB-INF/views/user/role-permissions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: Update role permissions
        response.sendRedirect(request.getContextPath() + "/roles");
    }
}

