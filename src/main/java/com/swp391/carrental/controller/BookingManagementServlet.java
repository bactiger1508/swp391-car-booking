package com.swp391.carrental.controller;

import com.swp391.carrental.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BookingManagementServlet", urlPatterns = {"/bookings/manage"})
public class BookingManagementServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("bookings", bookingService.getAllBookings());
        request.getRequestDispatcher("/WEB-INF/views/booking/booking-management.jsp").forward(request, response);
    }
}

