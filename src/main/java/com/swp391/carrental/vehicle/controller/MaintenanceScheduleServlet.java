package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;

/*
 * Name: MaintenanceScheduleServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for MaintenanceScheduleServlet.
 */

@WebServlet(name = "MaintenanceScheduleServlet", urlPatterns = {"/maintenance"})
public class MaintenanceScheduleServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            CarDAO carDAO = new CarDAO();
            MaintenanceDAO maintenanceDAO = new MaintenanceDAO();

            List<Car> maintenanceCars = carDAO.findByStatus("MAINTENANCE");
            List<MaintenanceSchedule> schedules = maintenanceDAO.getAllMaintenanceSchedules();

            request.setAttribute("maintenanceCars", maintenanceCars);
            request.setAttribute("schedules", schedules);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String carIdStr = request.getParameter("carId");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String notes = request.getParameter("notes");

        try {
            if (carIdStr == null || carIdStr.trim().isEmpty() ||
                startDateStr == null || startDateStr.trim().isEmpty() ||
                endDateStr == null || endDateStr.trim().isEmpty()) {
                throw new AppException("Vui lòng nhập đầy đủ thông tin.");
            }

            LocalDate start = LocalDate.parse(startDateStr.trim());
            LocalDate end = LocalDate.parse(endDateStr.trim());

            if (end.isBefore(start)) {
                throw new AppException("Ngày kết thúc bảo trì phải sau ngày bắt đầu.");
            }

            MaintenanceSchedule m = new MaintenanceSchedule();
            m.setVehicleId(Integer.parseInt(carIdStr.trim()));
            m.setMaintenanceType("INSPECTION");
            m.setScheduledDate(start);
            m.setCompletedDate(end);
            m.setStatus("SCHEDULED");
            m.setDescription("Lịch bảo trì định kỳ");
            m.setNotes(notes);
            m.setCreatedBy("Staff");

            new MaintenanceDAO().createMaintenance(m);
            response.sendRedirect(request.getContextPath() + "/maintenance");
        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi lưu lịch bảo trì: " + e.getMessage());
            doGet(request, response);
        }
    }
}
