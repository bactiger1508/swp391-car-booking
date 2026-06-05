/*
 * Name: UserManagementServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for UserManagementServlet.
 */
package com.swp391.carrental.controller.user;

import java.io.IOException;
import java.util.List;

import com.swp391.carrental.exception.AppException;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Handles user management (Admin only). URL: /users
 */
@WebServlet(name = "UserManagementServlet", urlPatterns = {"/users"})
public class UserManagementServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");
            String search = request.getParameter("search");
            String role = request.getParameter("role");
            String status = request.getParameter("status");
            int page = parsePage(request.getParameter("page"));

            if ("edit".equals(action)) {
                int userId = parseUserId(request.getParameter("userId"));
                if (userId > 0) {
                    User user = userService.getUserById(userId);
                    if (user != null) {
                        request.setAttribute("formUser", user);
                    } else {
                        request.setAttribute("error", "No found user to edit.");
                    }
                }
            }

            List<User> userList = userService.getFilteredUsers(search, role, status, page, PAGE_SIZE);
            int totalRecords = userService.countFilteredUsers(search, role, status);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);

            request.setAttribute("userList", userList);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("searchParam", search);
            request.setAttribute("roleParam", role);
            request.setAttribute("statusParam", status);
            String success = request.getParameter("success");
            if (success != null && !success.isEmpty()) {
                request.setAttribute("success", success);
            }
            request.getRequestDispatcher("/WEB-INF/views/user/user-management.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String contextPath = request.getContextPath();
        try {
            if ("create".equals(action)) {
                User user = buildUserFromRequest(request);
                userService.createUser(user, request.getParameter("password"));
                request.setAttribute("success", "New user created successfully.");
                doGet(request, response);
                return;
            }
            if ("edit".equals(action)) {
                User user = buildUserFromRequest(request);
                int userId = parseUserId(request.getParameter("userId"));
                if (userId <= 0) {
                    throw new AppException("Invalid user id.");
                }
                user.setUserId(userId);
                userService.updateUser(user);
                response.sendRedirect(contextPath + "/users?success= Update user successfully.");
                return;
            }
            if ("toggleActive".equals(action)) {
                int userId = parseUserId(request.getParameter("userId"));
                userService.toggleUserActive(userId);
                response.sendRedirect(contextPath + "/users");
                return;
            }
            response.sendRedirect(contextPath + "/users");
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("formUser", buildUserFromRequest(request));
            doGet(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while processing the request.");
            request.setAttribute("formUser", buildUserFromRequest(request));
            doGet(request, response);
        }
    }

    private int parsePage(String pageParam) {
        try {
            if (pageParam != null && !pageParam.isEmpty()) {
                int value = Integer.parseInt(pageParam);
                return Math.max(value, 1);
            }
        } catch (NumberFormatException ignored) {
        }
        return 1;
    }

    private int parseUserId(String idParam) {
        try {
            return Integer.parseInt(idParam);
        } catch (NumberFormatException ignored) {
            return -1;
        }
    }

    private User buildUserFromRequest(HttpServletRequest request) {
        User user = new User();
        user.setEmail(trimParameter(request.getParameter("email")));
        user.setFullName(trimParameter(request.getParameter("fullName")));
        user.setPhone(trimParameter(request.getParameter("phone")));
        String role = trimParameter(request.getParameter("role"));
        user.setRole(role != null && !role.isEmpty() ? role : "CUSTOMER");
        String active = request.getParameter("isActive");
        user.setActive("on".equals(active) || "1".equals(active) || Boolean.parseBoolean(active));
        return user;
    }

    private String trimParameter(String value) {
        return value == null ? null : value.trim();
    }
}
