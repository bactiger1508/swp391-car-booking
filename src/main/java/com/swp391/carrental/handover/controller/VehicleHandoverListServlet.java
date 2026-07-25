package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import com.swp391.carrental.handover.service.HandoverService;

/**
 * Name: VehicleHandoverListServlet
 * @Author: TamTTMHE190340
 * Date: 21/06/2026
 * Version: 1.0
 * Description: Controller for displaying the list of all vehicle handover records.
 */
@WebServlet(name = "VehicleHandoverListServlet", urlPatterns = {"/handovers"})
public class VehicleHandoverListServlet extends HttpServlet {

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
