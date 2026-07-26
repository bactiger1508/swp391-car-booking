package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.model.VehicleBrand;
import com.swp391.carrental.vehicle.model.VehicleModel;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: VehicleListServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Public vehicle catalog for guest and customer browsing.
 */



@WebServlet(name = "VehicleListServlet", urlPatterns = {"/vehicles"})
public class VehicleListServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String startParam = request.getParameter("startDate");
        String endParam = request.getParameter("endDate");
        List<Vehicle> cars;

        if (startParam != null && !startParam.isEmpty() && endParam != null && !endParam.isEmpty()) {
            try {
                java.time.LocalDate startDate = java.time.LocalDate.parse(startParam);
                java.time.LocalDate endDate = java.time.LocalDate.parse(endParam);
                
                com.swp391.carrental.vehicle.service.AvailabilityService availabilityService = 
                    new com.swp391.carrental.vehicle.service.AvailabilityService();
                
                // Fetch cars available in this period
                cars = availabilityService.getAvailableVehicles(startDate.atStartOfDay(), endDate.atTime(23, 59, 59));
                
                request.setAttribute("startDate", startParam);
                request.setAttribute("endDate", endParam);
            } catch (Exception e) {
                cars = vehicleService.getVehiclesByStatus("AVAILABLE");
            }
        } else {
            cars = vehicleService.getVehiclesByStatus("AVAILABLE");
        }

        request.setAttribute("cars", cars);
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(cars));

        // Two-level brand -> model filter, sourced directly from the vehicle_brands/vehicle_models tables
        // (not scanned from the currently rendered cars), so every model of a brand is selectable.
        List<VehicleBrand> brands = vehicleService.getAllBrands();
        Map<Integer, List<VehicleModel>> modelsByBrand = new HashMap<>();
        for (VehicleBrand brand : brands) {
            modelsByBrand.put(brand.getBrandId(), vehicleService.getModelsByBrandId(brand.getBrandId()));
        }
        request.setAttribute("brands", brands);
        request.setAttribute("modelsByBrand", modelsByBrand);

        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-list.jsp").forward(request, response);
    }
}
