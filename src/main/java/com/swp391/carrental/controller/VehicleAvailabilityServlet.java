package com.swp391.carrental.controller;

import com.swp391.carrental.service.AvailabilityService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VehicleAvailabilityServlet", urlPatterns = {"/vehicles/availability"})
public class VehicleAvailabilityServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Parse date range and show available cars
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-availability.jsp").forward(request, response);
    }
}

