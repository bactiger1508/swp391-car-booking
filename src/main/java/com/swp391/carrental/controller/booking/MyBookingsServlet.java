/*
 * Name: MyBookingsServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Displays bookings for the currently logged-in customer with car details.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MyBookingsServlet", urlPatterns = {"/bookings/my"})
public class MyBookingsServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user != null) {
            request.setAttribute("bookings", bookingService.getBookingsByCustomer(user.getUserId()));
        }
        request.getRequestDispatcher("/WEB-INF/views/booking/my-bookings.jsp").forward(request, response);
    }
}

