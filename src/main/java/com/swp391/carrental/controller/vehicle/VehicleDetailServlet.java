/*
 * Name: VehicleDetailServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Public vehicle detail for guest and customer browsing.
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

@WebServlet(name = "VehicleDetailServlet", urlPatterns = {"/vehicles/detail"})
public class VehicleDetailServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String carIdStr = request.getParameter("id");
        if (carIdStr == null || carIdStr.isBlank()) {
            request.setAttribute("error", "Vehicle ID is required.");
            request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail.jsp").forward(request, response);
            return;
        }

        try {
            int carId = Integer.parseInt(carIdStr);
            Car car = vehicleService.getCarById(carId);
            if (car == null) {
                request.setAttribute("error", "Vehicle not found.");
            } else {
                request.setAttribute("car", car);
                request.setAttribute("images", vehicleService.getCarImages(carId));
                request.setAttribute("depositAmount", vehicleService.calculateOneDayDeposit(car.getDailyRate()));
                request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid vehicle ID.");
        }

        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail.jsp").forward(request, response);
    }
}
