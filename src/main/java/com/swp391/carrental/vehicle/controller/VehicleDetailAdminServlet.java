package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;
import com.swp391.carrental.vehicle.dao.ReviewDAO;
import com.swp391.carrental.vehicle.model.Review;
import com.swp391.carrental.core.model.AuditLog;
import com.swp391.carrental.core.dao.AuditLogDAO;
import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;

/*
 * Name: VehicleDetailAdminServlet
 * @Author: TinhHNHE172394
 * Date: 26/07/2026
 * Version: 1.0
 * Description: Admin/Staff vehicle detail page with audit logs, maintenance history, and review management.
 */

@WebServlet(name = "VehicleDetailAdminServlet", urlPatterns = {"/vehicles/admin/detail"})
public class VehicleDetailAdminServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    // Loads vehicle detail, audit logs, reviews and maintenance schedules for the admin/staff-only detail page.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authorization: only ADMIN and STAFF can access
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null || (!Role.ADMIN.equals(currentUser.getRole()) && !Role.STAFF.equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String vehicleIdStr = request.getParameter("id");
        if (vehicleIdStr == null || vehicleIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/vehicles/manage");
            return;
        }

        try {
            int vehicleId = Integer.parseInt(vehicleIdStr);
            Vehicle vehicle = vehicleService.getVehicleById(vehicleId);

            if (vehicle == null) {
                response.sendRedirect(request.getContextPath() + "/vehicles/manage");
                return;
            }

            // Load vehicle details
            request.setAttribute("vehicle", vehicle);
            request.setAttribute("images", vehicleService.getVehicleImages(vehicleId));
            request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
            request.setAttribute("depositAmount", vehicleService.calculateOneDayDeposit(vehicle.getDailyRate()));

            // Load audit logs (change history)
            AuditLogDAO auditLogDAO = new AuditLogDAO();
            List<AuditLog> auditLogs = auditLogDAO.findByEntity("VEHICLE", vehicleId);
            request.setAttribute("auditLogs", auditLogs);

            // Load review management
            ReviewDAO reviewDAO = new ReviewDAO();
            List<Review> allReviews = reviewDAO.findByVehicleId(vehicleId);
            int reviewCount = reviewDAO.countByVehicleId(vehicleId);
            double avgRating = reviewDAO.getAverageRating(vehicleId);
            request.setAttribute("reviews", allReviews);
            request.setAttribute("reviewCount", reviewCount);
            request.setAttribute("avgRating", String.format(java.util.Locale.US, "%.1f", avgRating));

            // Load maintenance schedules
            MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
            List<MaintenanceSchedule> maintenances = maintenanceDAO.getMaintenanceByVehicle(vehicleId);
            request.setAttribute("maintenances", maintenances);

            // Set admin context
            request.setAttribute("isAdminDetail", true);
            request.setAttribute("userRole", currentUser.getRole());

            request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail-admin.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/vehicles/manage");
        } catch (Exception e) {
            request.setAttribute("error", "Error loading vehicle details: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-management.jsp").forward(request, response);
        }
    }

    // Routes ADMIN-only POST actions: update vehicle status, hide/show a review.
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authorization
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null || !Role.ADMIN.equals(currentUser.getRole())) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"Only ADMIN can perform this action\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("updateStatus".equals(action)) {
                handleUpdateStatus(request, response, currentUser);
            } else if ("hideReview".equals(action)) {
                handleHideReview(request, response);
            } else if ("showReview".equals(action)) {
                handleShowReview(request, response);
            } else {
                sendJsonResponse(response, false, "Unknown action: " + action);
            }
        } catch (Exception e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // Updates vehicle status (AVAILABLE, RENTED, MAINTENANCE, INACTIVE) and logs audit entry.
    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
        String newStatus = request.getParameter("status");

        Vehicle vehicle = vehicleService.getVehicleById(vehicleId);
        if (vehicle == null) {
            sendJsonResponse(response, false, "Vehicle not found");
            return;
        }

        boolean success = vehicleService.updateVehicleStatus(vehicleId, newStatus);
        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + success + "}");
    }

    // Hides review by setting is_visible flag to false (admin moderation).
    private void handleHideReview(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int reviewId = Integer.parseInt(request.getParameter("reviewId"));
            ReviewDAO reviewDAO = new ReviewDAO();
            reviewDAO.updateReviewVisibility(reviewId, false);
            sendJsonResponse(response, true, "Review hidden successfully");
        } catch (Exception e) {
            sendJsonResponse(response, false, e.getMessage());
        }
    }

    // Shows hidden review by setting is_visible flag to true (undo moderation).
    private void handleShowReview(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int reviewId = Integer.parseInt(request.getParameter("reviewId"));
            ReviewDAO reviewDAO = new ReviewDAO();
            reviewDAO.updateReviewVisibility(reviewId, true);
            sendJsonResponse(response, true, "Review shown successfully");
        } catch (Exception e) {
            sendJsonResponse(response, false, e.getMessage());
        }
    }

    // Escapes special characters in text for safe JSON response output (prevents XSS attacks).
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    // Sends JSON response with success flag and message/error field (used for AJAX operations).
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        String json = "{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}";
        response.getWriter().write(json);
    }
}
