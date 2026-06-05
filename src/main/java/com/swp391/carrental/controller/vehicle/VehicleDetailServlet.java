/*
 * Name: VehicleDetailServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleDetailServlet.
 */
package com.swp391.carrental.controller.vehicle;

import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.model.Car;
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
        if (carIdStr != null) {
            int carId = Integer.parseInt(carIdStr);
            Car car = vehicleService.getCarById(carId);
            request.setAttribute("car", car);
            request.setAttribute("images", vehicleService.getCarImages(carId));
        }
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail.jsp").forward(request, response);
    }
}

