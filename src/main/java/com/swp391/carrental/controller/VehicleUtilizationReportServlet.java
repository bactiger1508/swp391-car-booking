package com.swp391.carrental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VehicleUtilizationReportServlet", urlPatterns = {"/reports/vehicle-utilization"})
public class VehicleUtilizationReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Generate vehicle utilization report
        request.getRequestDispatcher("/WEB-INF/views/report/vehicle-utilization-report.jsp").forward(request, response);
    }
}

