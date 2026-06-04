/*
 * Name: VehicleListServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Public vehicle catalog for guest and customer browsing.
 */
package com.swp391.carrental.controller.vehicle;

import com.swp391.carrental.model.Car;
import com.swp391.carrental.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "VehicleListServlet", urlPatterns = {"/vehicles"})
public class VehicleListServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Car> cars = vehicleService.getAllCars();
        request.setAttribute("cars", cars);
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(cars));
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-list.jsp").forward(request, response);
    }
}
