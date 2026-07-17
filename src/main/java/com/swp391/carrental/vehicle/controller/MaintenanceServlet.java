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
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;
import com.swp391.carrental.vehicle.service.VehicleService;

@WebServlet(name = "MaintenanceServlet", urlPatterns = {"/vehicles/maintenance"})
public class MaintenanceServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!("STAFF".equals(currentUser.getRole()) || "ADMIN".equals(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String carIdStr = request.getParameter("carId");

        try {
            if ("getSchedule".equals(action) && carIdStr != null) {
                handleGetMaintenanceSchedule(request, response, Integer.parseInt(carIdStr));
            } else if ("list".equals(action) && carIdStr != null) {
                handleViewMaintenanceList(request, response, Integer.parseInt(carIdStr));
            } else {
                handleViewAllCarsWithMaintenance(request, response);
            }
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
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

        if (!("STAFF".equals(currentUser.getRole()) || "ADMIN".equals(currentUser.getRole()))) {
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

    private void handleViewAllCarsWithMaintenance(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Car> cars = vehicleService.getAllCars();
        request.setAttribute("cars", cars);
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
    }

    private void handleViewMaintenanceList(HttpServletRequest request, HttpServletResponse response, int carId)
            throws ServletException, IOException {
        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            throw new AppException("Xe không tồn tại");
        }

        List<MaintenanceSchedule> maintenanceList = vehicleService.getMaintenanceByCarId(carId);
        List<Car> cars = vehicleService.getAllCars();

        request.setAttribute("cars", cars);
        request.setAttribute("selectedCar", car);
        request.setAttribute("maintenanceList", maintenanceList);
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance.jsp").forward(request, response);
    }

    private void handleGetMaintenanceSchedule(HttpServletRequest request, HttpServletResponse response, int carId)
            throws IOException {
        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Xe không tồn tại\"}");
            return;
        }

        List<MaintenanceSchedule> schedules = vehicleService.getMaintenanceByCarId(carId);

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

    private void handleRecordMaintenance(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String carIdStr = request.getParameter("carId");
        String maintenanceType = request.getParameter("maintenanceType");
        String description = request.getParameter("description");
        String scheduledDateStr = request.getParameter("scheduledDate");
        String costStr = request.getParameter("cost");
        String notes = request.getParameter("notes");

        if (carIdStr == null || carIdStr.isEmpty()) {
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

        int carId = Integer.parseInt(carIdStr);
        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            throw new AppException("Xe không tồn tại");
        }

        MaintenanceSchedule schedule = new MaintenanceSchedule();
        schedule.setVehicleId(carId);
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
