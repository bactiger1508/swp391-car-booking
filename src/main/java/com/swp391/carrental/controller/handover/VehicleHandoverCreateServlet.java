/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.swp391.carrental.controller.handover;

import com.swp391.carrental.model.VehicleHandover;
import com.swp391.carrental.service.HandoverService;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;

/**
 *
 * @author lenovo
 */
@WebServlet(name = "VehicleHandoverCreateServlet", urlPatterns = {"/handovers/create"})
public class VehicleHandoverCreateServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookingId = request.getParameter("bookingId");
        String carId = request.getParameter("carId");
        request.setAttribute("bookingId", bookingId);
        request.setAttribute("carId", carId);
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int carId = Integer.parseInt(request.getParameter("carId"));
            int mileage = Integer.parseInt(request.getParameter("currentOdo"));
            String fuelLevel = request.getParameter("fuel");
            String exterior = (request.getParameter("chkExteriorScratch") != null) ? "Checked" : "Unchecked";
            String interior = (request.getParameter("chkCleanliness") != null) ? "Checked" : "Unchecked";

            VehicleHandover handover = new VehicleHandover();
            handover.setBookingId(bookingId);
            handover.setCarId(carId);
            handover.setMileageAtHandover(mileage);
            handover.setFuelLevel(fuelLevel);
            handover.setExteriorCondition(exterior);
            handover.setInteriorCondition(interior);
            handover.setHandedBy(1);
            handoverService.handoverVehicle(handover);
            response.sendRedirect(request.getContextPath() + "/handovers");

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi: " + e.getMessage());
            request.setAttribute("currentOdo", request.getParameter("currentOdo"));
            request.setAttribute("fuel", request.getParameter("fuel"));
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request, response);
        }
    }
}
