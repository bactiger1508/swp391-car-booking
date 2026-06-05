/*
 * Name: VehicleManagementServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleManagementServlet.
 */
package com.swp391.carrental.controller.vehicle;

import com.swp391.carrental.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VehicleManagementServlet", urlPatterns = {"/vehicles/manage"})
public class VehicleManagementServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("cars", vehicleService.getAllCars());
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Handle add/edit/delete car
        response.sendRedirect(request.getContextPath() + "/vehicles/manage");
    }
}

