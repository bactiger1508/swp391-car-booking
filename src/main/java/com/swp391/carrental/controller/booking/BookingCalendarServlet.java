/*
 * Name: BookingCalendarServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Displays a simple booking calendar for Staff/Admin. Shows active bookings on a monthly grid.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.service.UserService;
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
 * Booking calendar view for Staff/Admin.
 * URL: /bookings/calendar
 */
@WebServlet(name = "BookingCalendarServlet", urlPatterns = {"/bookings/calendar"})
public class BookingCalendarServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Load all bookings for calendar display
            List<Booking> allBookings = bookingService.getAllBookings();
            request.setAttribute("bookings", allBookings != null ? allBookings : new java.util.ArrayList<>());

            // Load all cars for visual scheduling row layout
            List<Car> allCars = vehicleService.getAllCars();
            request.setAttribute("cars", allCars != null ? allCars : new java.util.ArrayList<>());

            // Build car map for backward compatibility and fast lookup
            Map<Integer, Car> carMap = new HashMap<>();
            if (allCars != null) {
                for (Car car : allCars) {
                    carMap.put(car.getCarId(), car);
                }
            }
            request.setAttribute("carMap", carMap);

            // Build user map for fast lookup
            List<User> allUsers = userService.getAllUsers();
            Map<Integer, User> userMap = new HashMap<>();
            if (allUsers != null) {
                for (User u : allUsers) {
                    userMap.put(u.getUserId(), u);
                }
            }
            request.setAttribute("userMap", userMap);

        } catch (Exception e) {
            System.err.println("[BookingCalendarServlet] Error loading calendar data: " + e.getMessage());
            e.printStackTrace();
            // Set empty defaults so the JSP can still render without crashing
            if (request.getAttribute("bookings") == null) request.setAttribute("bookings", new java.util.ArrayList<>());
            if (request.getAttribute("cars") == null) request.setAttribute("cars", new java.util.ArrayList<>());
            if (request.getAttribute("carMap") == null) request.setAttribute("carMap", new HashMap<>());
            if (request.getAttribute("userMap") == null) request.setAttribute("userMap", new HashMap<>());
            request.setAttribute("errorMessage", "Không thể tải dữ liệu lịch. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-calendar.jsp")
                .forward(request, response);
    }
}
