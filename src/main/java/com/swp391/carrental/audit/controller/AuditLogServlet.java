package com.swp391.carrental.audit.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.audit.model.AuditLog;
import com.swp391.carrental.audit.service.AuditLogService;
import com.swp391.carrental.audit.util.AuditLabels;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;

@WebServlet(name = "AuditLogServlet", urlPatterns = {"/audit-logs"})
public class AuditLogServlet extends HttpServlet {
    private final AuditLogService auditLogService = new AuditLogService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "VIEW_ACTIVITY_HISTORY")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        request.setAttribute("actionLabels", AuditLabels.ACTION_LABELS);
        request.setAttribute("entityLabels", AuditLabels.ENTITY_LABELS);

        String action = request.getParameter("action");

        try {
            if ("filter".equals(action)) {
                handleFilterLogs(request, response);
            } else {
                handleViewAllLogs(request, response);
            }
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            handleViewAllLogs(request, response);
        }
    }

    private void handleViewAllLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<AuditLog> logs = auditLogService.getAllLogs();
        request.setAttribute("logs", logs);
        request.setAttribute("userMap", buildUserMap(logs));
        request.getRequestDispatcher("/WEB-INF/views/audit/audit-logs.jsp").forward(request, response);
    }

    /**
     * Resolves the actual actor names for the "Người dùng" column instead of showing raw IDs.
     */
    private Map<Integer, User> buildUserMap(List<AuditLog> logs) {
        Map<Integer, User> userMap = new HashMap<>();
        for (AuditLog log : logs) {
            int userId = log.getUserId();
            if (!userMap.containsKey(userId)) {
                User user = userService.getUserById(userId);
                if (user != null) {
                    userMap.put(userId, user);
                }
            }
        }
        return userMap;
    }

    private void handleFilterLogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdStr = request.getParameter("userId");
        String action = request.getParameter("action_filter");
        String entityType = request.getParameter("entityType");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        Integer userId = null;
        LocalDateTime startDate = null;
        LocalDateTime endDate = null;

        try {
            if (userIdStr != null && !userIdStr.isEmpty()) {
                userId = Integer.parseInt(userIdStr);
            }

            if (startDateStr != null && !startDateStr.isEmpty()) {
                startDate = LocalDateTime.parse(startDateStr + " 00:00:00",
                        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            }

            if (endDateStr != null && !endDateStr.isEmpty()) {
                endDate = LocalDateTime.parse(endDateStr + " 23:59:59",
                        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            }
        } catch (Exception e) {
            request.setAttribute("error", "Invalid filter parameters");
            handleViewAllLogs(request, response);
            return;
        }

        List<AuditLog> logs = auditLogService.getLogsByFilters(userId, action, entityType, startDate, endDate);
        request.setAttribute("logs", logs);
        request.setAttribute("userMap", buildUserMap(logs));
        request.setAttribute("userIdFilter", userIdStr);
        request.setAttribute("actionFilter", action);
        request.setAttribute("entityTypeFilter", entityType);
        request.setAttribute("startDateFilter", startDateStr);
        request.setAttribute("endDateFilter", endDateStr);
        request.getRequestDispatcher("/WEB-INF/views/audit/audit-logs.jsp").forward(request, response);
    }
}
