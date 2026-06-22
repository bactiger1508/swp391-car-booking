package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;
import java.util.List;

/*
 * Name: VehicleDetailServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleDetailServlet.
 */



@WebServlet(name = "VehicleDetailServlet", urlPatterns = {"/vehicles/detail"})
public class VehicleDetailServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String carIdStr = request.getParameter("id");
        if (carIdStr != null) {
            int carId = Integer.parseInt(carIdStr);
            Car car = vehicleService.getCarById(carId);
            request.setAttribute("car", car);
            request.setAttribute("images", vehicleService.getCarImages(carId));
            
            // Query active bookings of the car to display in a modal calendar/schedule
            com.swp391.carrental.booking.service.BookingService bookingService = new com.swp391.carrental.booking.service.BookingService();
            List<com.swp391.carrental.booking.model.Booking> activeBookings = bookingService.getActiveBookingsByCar(carId);
            request.setAttribute("activeBookings", activeBookings);
            
            // Query maintenance schedules of the car
            com.swp391.carrental.vehicle.dao.MaintenanceDAO maintenanceDAO = new com.swp391.carrental.vehicle.dao.MaintenanceDAO();
            try {
                List<com.swp391.carrental.vehicle.model.MaintenanceSchedule> maintenances = maintenanceDAO.getMaintenanceByVehicle(carId);
                java.util.List<com.swp391.carrental.vehicle.model.MaintenanceSchedule> scheduledMaintenances = new java.util.ArrayList<>();
                if (maintenances != null) {
                    for (com.swp391.carrental.vehicle.model.MaintenanceSchedule ms : maintenances) {
                        if ("SCHEDULED".equalsIgnoreCase(ms.getStatus())) {
                            scheduledMaintenances.add(ms);
                        }
                    }
                }
                request.setAttribute("maintenances", scheduledMaintenances);
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // Deposit configuration context
            request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
            if (car != null) {
                request.setAttribute("depositAmount", vehicleService.calculateOneDayDeposit(car.getDailyRate()));
            }
        }
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail.jsp").forward(request, response);
    }
}

