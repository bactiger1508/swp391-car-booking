package com.swp391.carrental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MaintenanceScheduleServlet", urlPatterns = {"/maintenance"})
public class MaintenanceScheduleServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Load cars with MAINTENANCE status and schedule
        request.getRequestDispatcher("/WEB-INF/views/vehicle/maintenance-schedule.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Update maintenance schedule
        response.sendRedirect(request.getContextPath() + "/maintenance");
    }
}

