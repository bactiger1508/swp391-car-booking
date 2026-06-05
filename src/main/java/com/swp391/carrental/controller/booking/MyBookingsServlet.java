/*
 * Name: MyBookingsServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Displays bookings for the currently logged-in customer with car details.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.VehicleService;
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
 * Shows the current customer's bookings.
 * URL: /bookings/my
 */
@WebServlet(name = "MyBookingsServlet", urlPatterns = {"/bookings/my"})
public class MyBookingsServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("currentUser");
        if (user != null) {
            List<Booking> bookings = bookingService.getBookingsByCustomer(user.getUserId());
            request.setAttribute("bookings", bookings);

            // Build car info map for display
            Map<Integer, Car> carMap = new HashMap<>();
            for (Booking b : bookings) {
                if (!carMap.containsKey(b.getCarId())) {
                    Car car = vehicleService.getCarById(b.getCarId());
                    if (car != null) {
                        carMap.put(b.getCarId(), car);
                    }
                }
            }
            request.setAttribute("carMap", carMap);
        }

        // Transfer session success message to request attribute
        String successMessage = (String) request.getSession().getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("success", successMessage);
            request.getSession().removeAttribute("successMessage");
        }

        request.getRequestDispatcher("/WEB-INF/views/booking/my-bookings.jsp")
                .forward(request, response);
    }
}
