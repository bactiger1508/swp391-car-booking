package com.swp391.carrental.user.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.dao.PermissionDAO;
import com.swp391.carrental.user.model.Permission;
import com.swp391.carrental.user.model.User;

/**
 * Handles role permissions management (Admin only). URL: /roles
 */
@WebServlet(name = "RolePermissionsServlet", urlPatterns = { "/roles" })
public class RolePermissionsServlet extends HttpServlet {

    private final PermissionDAO permissionDAO = new PermissionDAO();

    /**
     * Display Role Permission page
     */
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // ==============================
        // 1. CHECK LOGIN
        // ==============================
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ==============================
        // 2. CHECK ADMIN ROLE
        // ==============================
        if (!isAdmin(currentUser)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền truy cập trang này.");
            return;
        }

        // ==============================
        // 3. LOAD ROLES, PERMISSIONS & MAPPINGS FROM DATABASE
        // ==============================
        try {
            List<com.swp391.carrental.user.model.Role> roles = permissionDAO.getAllRoles();
            List<Permission> permissions = permissionDAO.getAllPermissions();

            Map<String, Set<String>> rolePermissions = new HashMap<>();
            for (com.swp391.carrental.user.model.Role r : roles) {
                List<String> keys = permissionDAO.getPermissionsByRole(r.getRole());
                rolePermissions.put(r.getRole(), new HashSet<>(keys));
            }

            request.setAttribute("roles", roles);
            request.setAttribute("permissions", permissions);
            request.setAttribute("rolePermissions", rolePermissions);

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Lỗi hệ thống khi tải quyền hạn", e);
        }

        // ==============================
        // 4. FORWARD JSP
        // ==============================
        request.getRequestDispatcher("/WEB-INF/views/user/role-permissions.jsp")
                .forward(request, response);
    }

    /**
     * Save permission changes
     */
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // ==============================
        // 1. CHECK LOGIN
        // ==============================
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // ==============================
        // 2. ONLY ADMIN
        // ==============================
        if (!isAdmin(currentUser)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền thay đổi quyền.");
            return;
        }

        // ==============================
        // 3. GET ROLES & PERMISSIONS, UPDATE DATABASE
        // ==============================
        try {
            List<com.swp391.carrental.user.model.Role> roles = permissionDAO.getAllRoles();
            List<Permission> permissions = permissionDAO.getAllPermissions();

            for (com.swp391.carrental.user.model.Role r : roles) {
                // Admin has all permissions, skipped updating to prevent lockout
                if (Role.ADMIN.equals(r.getRole())) {
                    continue;
                }

                List<String> selectedKeys = new ArrayList<>();
                for (Permission p : permissions) {
                    String param = request.getParameter("role_perm_" + r.getRole() + "_" + p.getPermissionKey());
                    if ("true".equals(param)) {
                        selectedKeys.add(p.getPermissionKey());
                    }
                }

                permissionDAO.updateRolePermissions(r.getRole(), selectedKeys);
            }

            // Sync/update current logged-in user's permissions in session in case admin's
            // role was affected
            List<String> currentPermKeys = permissionDAO.getPermissionsByRole(currentUser.getRole());
            request.getSession().setAttribute("userPermissions", new HashSet<>(currentPermKeys));

            request.getSession().setAttribute("success", "Lưu quyền thành công.");

        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lưu quyền thất bại do lỗi hệ thống.");
        }

        response.sendRedirect(request.getContextPath() + "/roles");
    }

    /**
     * Get logged-in user from session
     */
    private User getCurrentUser(
            HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("currentUser");
    }

    /**
     * Check admin permission
     */
    private boolean isAdmin(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        return user.getRole().equals(Role.ADMIN);
    }
}
