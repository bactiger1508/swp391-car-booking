/*
 * Name: BookingManagementServlet
 * @Author: BacBui
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Staff/Admin booking management page with user/car info and optional status filter.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Displays all bookings for Staff/Admin management.
 * URL: /bookings/manage
 */
@WebServlet(name = "BookingManagementServlet", urlPatterns = {"/bookings/manage"})
public class BookingManagementServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Booking> bookings = bookingService.getAllBookings();
        request.setAttribute("bookings", bookings);

        // Count for stats grid dynamically
        int pendingCount = 0;
        int confirmedCount = 0;
        int inProgressCount = 0;
        int completedCount = 0;

        for (Booking b : bookings) {
            if ("PENDING".equals(b.getStatus())) {
                pendingCount++;
            } else if ("CONFIRMED".equals(b.getStatus())) {
                confirmedCount++;
            } else if ("IN_PROGRESS".equals(b.getStatus())) {
                inProgressCount++;
            } else if ("COMPLETED".equals(b.getStatus())) {
                completedCount++;
            }
        }

        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("confirmedCount", confirmedCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("completedCount", completedCount);

        // Build user and car info maps for all bookings for display
        Map<Integer, User> userMap = new HashMap<>();
        Map<Integer, Car> carMap = new HashMap<>();

        for (Booking b : bookings) {
            if (!userMap.containsKey(b.getCustomerId())) {
                try {
                    User u = userDAO.findById(b.getCustomerId());
                    if (u != null) {
                        userMap.put(b.getCustomerId(), u);
                    }
                } catch (Exception e) {
                    // Skip if user lookup fails
                }
            }
            if (!carMap.containsKey(b.getCarId())) {
                Car car = vehicleService.getCarById(b.getCarId());
                if (car != null) {
                    carMap.put(b.getCarId(), car);
                }
            }
        }

        request.setAttribute("userMap", userMap);
        request.setAttribute("carMap", carMap);

        // Transfer session success message
        String successMessage = (String) request.getSession().getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("success", successMessage);
            request.getSession().removeAttribute("successMessage");
        }

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-management.jsp")
                .forward(request, response);
    }
}
