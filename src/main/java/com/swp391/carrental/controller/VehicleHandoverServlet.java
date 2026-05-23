package com.swp391.carrental.controller;

import com.swp391.carrental.service.HandoverService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VehicleHandoverServlet", urlPatterns = {"/handovers"})
public class VehicleHandoverServlet extends HttpServlet {
    private final HandoverService handoverService = new HandoverService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("handovers", handoverService.getAllHandovers());
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Record handover (BR-06)
        response.sendRedirect(request.getContextPath() + "/handovers");
    }
}

