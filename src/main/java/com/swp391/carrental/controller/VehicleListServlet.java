package com.swp391.carrental.controller;

import com.swp391.carrental.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "VehicleListServlet", urlPatterns = {"/vehicles"})
public class VehicleListServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("cars", vehicleService.getAllCars());
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-list.jsp").forward(request, response);
    }
}

