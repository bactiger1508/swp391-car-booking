package com.swp391.carrental.notification.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.user.model.User;

@WebServlet(name = "NotificationServlet", urlPatterns = {"/notifications"})
public class NotificationServlet extends HttpServlet {
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("getUnreadCount".equals(action)) {
                handleGetUnreadCount(request, response, currentUser);
            } else if ("getAll".equals(action)) {
                handleGetAllNotifications(request, response, currentUser);
            } else {
                handleViewNotifications(request, response, currentUser);
            }
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/notification/notifications.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        boolean isAjax = "markAsRead".equals(action) || "markAllAsRead".equals(action);

        try {
            if ("markAsRead".equals(action)) {
                handleMarkAsRead(request, response, currentUser);
                if (isAjax) {
                    sendJsonResponse(response, true, "Notification marked as read");
                }
            } else if ("markAllAsRead".equals(action)) {
                handleMarkAllAsRead(request, response, currentUser);
                if (isAjax) {
                    sendJsonResponse(response, true, "All notifications marked as read");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/notifications");
            }
        } catch (AppException e) {
            if (isAjax) {
                sendJsonResponse(response, false, e.getMessage());
            } else {
                request.setAttribute("error", e.getMessage());
                doGet(request, response);
            }
        }
    }

    // Displays notification list page with all user notifications and unread count.
    private void handleViewNotifications(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        List<Notification> notifications = notificationService.getNotificationsByUserId(currentUser.getUserId());
        int unreadCount = notificationService.getUnreadCount(currentUser.getUserId());

        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", unreadCount);
        request.getRequestDispatcher("/WEB-INF/views/notification/notifications.jsp").forward(request, response);
    }

    // Returns all user notifications as JSON for header dropdown real-time polling.
    private void handleGetAllNotifications(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        List<Notification> notifications = notificationService.getNotificationsByUserId(currentUser.getUserId());
        int unreadCount = notificationService.getUnreadCount(currentUser.getUserId());

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < notifications.size(); i++) {
            Notification n = notifications.get(i);
            json.append("{")
                .append("\"notificationId\":").append(n.getNotificationId()).append(",")
                .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                .append("\"notificationType\":\"").append(n.getNotificationType()).append("\",")
                .append("\"referenceType\":").append(n.getReferenceType() != null ? "\"" + n.getReferenceType() + "\"" : "null").append(",")
                .append("\"referenceId\":").append(n.getReferenceId() != null ? n.getReferenceId() : "null").append(",")
                .append("\"isRead\":").append(n.isRead()).append(",")
                .append("\"createdAt\":\"").append(n.getCreatedAt()).append("\"")
                .append("}");
            if (i < notifications.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    // Returns unread notification count as JSON for header badge display.
    private void handleGetUnreadCount(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        int unreadCount = notificationService.getUnreadCount(currentUser.getUserId());

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write("{\"unreadCount\":" + unreadCount + "}");
    }

    // Marks single notification as read (validates ownership before updating).
    private void handleMarkAsRead(HttpServletRequest request, HttpServletResponse response, User currentUser) {
        String notificationIdStr = request.getParameter("notificationId");
        if (notificationIdStr == null || notificationIdStr.isEmpty()) {
            throw new AppException("Notification ID is required");
        }

        int notificationId = Integer.parseInt(notificationIdStr);
        Notification notification = notificationService.getNotificationById(notificationId);

        if (notification == null) {
            throw new AppException("Notification not found");
        }

        if (notification.getUserId() != currentUser.getUserId()) {
            throw new AppException("Access denied");
        }

        notificationService.markNotificationAsRead(notificationId);
    }

    // Marks all user notifications as read in one bulk operation.
    private void handleMarkAllAsRead(HttpServletRequest request, HttpServletResponse response, User currentUser) {
        notificationService.markAllNotificationsAsRead(currentUser.getUserId());
    }

    // Escapes special characters in text for safe JSON response output (prevents XSS).
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        String json = "{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}";
        if (!success) {
            json = json.replace("\"message\"", "\"error\"");
        }
        response.getWriter().write(json);
    }
}
