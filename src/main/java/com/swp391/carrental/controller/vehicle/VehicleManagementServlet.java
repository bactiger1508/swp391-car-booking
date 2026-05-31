/*
 * Name: VehicleManagementServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Internal vehicle list for staff and admin.
 */
package com.swp391.carrental.controller.vehicle;

import com.swp391.carrental.model.Car;
import com.swp391.carrental.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "VehicleManagementServlet", urlPatterns = {"/vehicles/manage"})
public class VehicleManagementServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String status = request.getParameter("status");
        List<Car> cars;
        if (status != null && !status.isBlank()) {
            cars = vehicleService.getCarsByStatus(status);
            request.setAttribute("selectedStatus", status);
        } else {
            cars = vehicleService.getAllCars();
        }

        Map<Integer, BigDecimal> depositAmounts = new HashMap<>();
        for (Car car : cars) {
            depositAmounts.put(car.getCarId(), vehicleService.calculateOneDayDeposit(car.getDailyRate()));
        }

        request.setAttribute("cars", cars);
        request.setAttribute("depositAmounts", depositAmounts);
        request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
        request.setAttribute("nextMaintenance", vehicleService.getNextScheduledMaintenanceByCar());
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/vehicles/manage");
    }
}
