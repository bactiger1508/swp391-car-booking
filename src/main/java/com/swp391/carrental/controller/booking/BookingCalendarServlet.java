/*
 * Name: BookingCalendarServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Displays a simple booking calendar for Staff/Admin. Shows active bookings on a monthly grid.
 */
package com.swp391.carrental.controller.booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BookingCalendarServlet", urlPatterns = {"/bookings/calendar"})
public class BookingCalendarServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Load bookings for calendar view
        request.getRequestDispatcher("/WEB-INF/views/booking/booking-calendar.jsp").forward(request, response);
    }
}

