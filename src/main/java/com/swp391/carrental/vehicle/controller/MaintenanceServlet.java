package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: MaintenanceServlet
 * @Author: TinhHNHE172394
 * Date: 27/07/2026
 * Version: 1.0
 * Description: Staff/Admin screen for recording vehicle maintenance jobs and updating their status.
 */

/**
 * Records maintenance jobs for vehicles and tracks their lifecycle
 * (SCHEDULED -> IN_PROGRESS -> COMPLETED/CANCELLED).
 */
@WebServlet(name = "MaintenanceServlet", urlPatterns = {"/vehicles/maintenance"})
public class MaintenanceServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    /** Routes GET requests to the maintenance schedule JSON lookup, the per-vehicle list, or the full vehicle list. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "RECORD_VEHICLE_MAINTENANCE")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String vehicleIdStr = request.getParameter("vehicleId");

        try {
            if ("getSchedule".equals(action) && vehicleIdStr != null) {
                handleGetMaintenanceSchedule(request, response, Integer.parseInt(vehicleIdStr));
            } else if ("list".equals(action) && vehicleIdStr != null) {
                handleViewMaintenanceList(request, response, Integer.parseInt(vehicleIdStr));
            } else {
                handleViewAllVehiclesWithMaintenance(request, response);
            }
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
        }
    }

    /** Routes POST requests to record a new maintenance job or update an existing job's status. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "RECORD_VEHICLE_MAINTENANCE")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        boolean isAjax = "recordMaintenance".equals(action) || "updateStatus".equals(action);

        try {
            if ("recordMaintenance".equals(action)) {
                handleRecordMaintenance(request, response, currentUser);
                if (isAjax) {
                    sendJsonResponse(response, true, "Bản ghi bảo trì đã lưu thành công! Xe đã chuyển sang trạng thái Bảo trì.");
                }
            } else if ("updateStatus".equals(action)) {
                String newStatus = handleUpdateStatus(request, response, currentUser);
                String message;
                switch (newStatus) {
                    case "IN_PROGRESS": message = "Đã bắt đầu sửa chữa."; break;
                    case "COMPLETED": message = "Đã xác nhận hoàn tất bảo trì. Xe chuyển lại trạng thái Có sẵn."; break;
                    case "CANCELLED": message = "Đã hủy lịch bảo trì."; break;
                    default: message = "Đã cập nhật trạng thái bảo trì.";
                }
                sendJsonResponse(response, true, message);
            } else {
                response.sendRedirect(request.getContextPath() + "/vehicles/maintenance");
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

    /** Displays every vehicle on the maintenance overview page. */
    private void handleViewAllVehiclesWithMaintenance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Vehicle> cars = vehicleService.getAllVehicles();
        request.setAttribute("vehicles", cars);
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
    }

    /** Displays the maintenance history of a single selected vehicle. */
    private void handleViewMaintenanceList(HttpServletRequest request, HttpServletResponse response, int vehicleId)
            throws ServletException, IOException {
        Vehicle car = vehicleService.getVehicleById(vehicleId);
        if (car == null) {
            throw new AppException("Xe không tồn tại");
        }

        List<MaintenanceSchedule> maintenanceList = vehicleService.getMaintenanceByVehicleId(vehicleId);
        List<Vehicle> cars = vehicleService.getAllVehicles();

        request.setAttribute("vehicles", cars);
        request.setAttribute("selectedVehicle", car);
        request.setAttribute("maintenanceList", maintenanceList);
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
    }

    /** Returns a vehicle's maintenance schedules as JSON, for AJAX modal display. */
    private void handleGetMaintenanceSchedule(HttpServletRequest request, HttpServletResponse response, int vehicleId)
            throws IOException {
        Vehicle car = vehicleService.getVehicleById(vehicleId);
        if (car == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Xe không tồn tại\"}");
            return;
        }

        List<MaintenanceSchedule> schedules = vehicleService.getMaintenanceByVehicleId(vehicleId);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < schedules.size(); i++) {
            MaintenanceSchedule m = schedules.get(i);
            json.append("{")
                .append("\"maintenanceId\":").append(m.getMaintenanceId()).append(",")
                .append("\"maintenanceType\":\"").append(m.getMaintenanceType()).append("\",")
                .append("\"description\":\"").append(escapeJson(m.getDescription())).append("\",")
                .append("\"scheduledDate\":\"").append(m.getScheduledDate()).append("\",")
                .append("\"status\":\"").append(m.getStatus()).append("\",")
                .append("\"cost\":").append(m.getCost()).append(",")
                .append("\"createdAt\":\"").append(m.getCreatedAt()).append("\"")
                .append("}");
            if (i < schedules.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    /** Validates and creates a new maintenance job for a vehicle from submitted form data. */
    private void handleRecordMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String vehicleIdStr = request.getParameter("vehicleId");
        String maintenanceType = request.getParameter("maintenanceType");
        String description = request.getParameter("description");
        String scheduledDateStr = request.getParameter("scheduledDate");
        String costStr = request.getParameter("cost");
        String notes = request.getParameter("notes");

        if (vehicleIdStr == null || vehicleIdStr.isEmpty()) {
            throw new AppException("Vui lòng chọn xe");
        }
        if (maintenanceType == null || maintenanceType.isEmpty()) {
            throw new AppException("Vui lòng chọn loại bảo trì");
        }
        if (description == null || description.isEmpty()) {
            throw new AppException("Vui lòng nhập mô tả");
        }
        if (scheduledDateStr == null || scheduledDateStr.isEmpty()) {
            throw new AppException("Vui lòng chọn ngày bảo trì");
        }

        int vehicleId = Integer.parseInt(vehicleIdStr);
        Vehicle car = vehicleService.getVehicleById(vehicleId);
        if (car == null) {
            throw new AppException("Xe không tồn tại");
        }

        MaintenanceSchedule schedule = new MaintenanceSchedule();
        schedule.setVehicleId(vehicleId);
        schedule.setMaintenanceType(maintenanceType);
        schedule.setDescription(description);
        schedule.setScheduledDate(LocalDate.parse(scheduledDateStr));
        schedule.setStatus("SCHEDULED");
        schedule.setNotes(notes);

        if (costStr != null && !costStr.isEmpty()) {
            try {
                schedule.setCost(Double.parseDouble(costStr));
            } catch (NumberFormatException e) {
                throw new AppException("Chi phí không hợp lệ");
            }
        }

        int scheduleId = vehicleService.addMaintenanceSchedule(schedule);
        if (scheduleId < 0) {
            throw new AppException("Lỗi khi lưu bản ghi bảo trì");
        }
    }

    /** Validates and applies a maintenance job's new status, returning the applied status string. */
    private String handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, User currentUser) {
        String maintenanceIdStr = request.getParameter("maintenanceId");
        String status = request.getParameter("status");

        if (maintenanceIdStr == null || maintenanceIdStr.isEmpty()) {
            throw new AppException("Thiếu mã bảo trì.");
        }
        if (status == null || !(status.equals("IN_PROGRESS") || status.equals("COMPLETED") || status.equals("CANCELLED"))) {
            throw new AppException("Trạng thái không hợp lệ.");
        }

        int maintenanceId = Integer.parseInt(maintenanceIdStr);
        vehicleService.updateMaintenanceStatus(maintenanceId, status, currentUser.getFullName());
        return status;
    }

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
