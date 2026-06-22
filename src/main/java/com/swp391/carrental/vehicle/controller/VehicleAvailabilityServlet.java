/*
 * Name: VehicleAvailabilityServlet
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 2.0
 * Description: Handles checking of vehicle availability for a selected date range.
 */

package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.AvailabilityService;
import com.swp391.carrental.vehicle.service.VehicleService;

@WebServlet(name = "VehicleAvailabilityServlet", urlPatterns = {"/vehicles/availability"})
public class VehicleAvailabilityServlet extends HttpServlet {

    private final AvailabilityService availabilityService = new AvailabilityService();
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        LocalDateTime start = null;
        LocalDateTime end = null;
        String error = null;

        try {
            if (startDateStr != null && !startDateStr.trim().isEmpty() 
                    && endDateStr != null && !endDateStr.trim().isEmpty()) {
                
                // Form date-picker inputs usually come as yyyy-MM-dd
                LocalDate sDate = LocalDate.parse(startDateStr);
                LocalDate eDate = LocalDate.parse(endDateStr);

                // Default check times: 08:00 AM standard handover/return
                start = LocalDateTime.of(sDate, LocalTime.of(8, 0));
                end = LocalDateTime.of(eDate, LocalTime.of(8, 0));

                if (end.isBefore(start) || end.isEqual(start)) {
                    error = "Ngày trả xe phải sau ngày nhận xe.";
                } else if (sDate.isBefore(LocalDate.now())) {
                    error = "Ngày nhận xe không được trước ngày hiện tại.";
                } else {
                    List<Car> availableCars = availabilityService.getAvailableCars(start, end);
                    Map<Integer, String> primaryImages = vehicleService.getPrimaryImageUrls(availableCars);
                    
                    request.setAttribute("availableCars", availableCars);
                    request.setAttribute("primaryImages", primaryImages);
                    request.setAttribute("searched", true);
                }
            }
        } catch (Exception e) {
            error = "Định dạng ngày tháng không hợp lệ.";
        }

        request.setAttribute("error", error);
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);

        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-availability.jsp")
                .forward(request, response);
    }
}
