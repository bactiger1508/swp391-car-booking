/*
 * Name: CreateBookingServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Handles GET (load form) and POST (submit booking) for customer booking creation.
 */
package com.swp391.carrental.controller.booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CreateBookingServlet", urlPatterns = {"/bookings/create"})
public class CreateBookingServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Load available cars and pre-fill form
        request.getRequestDispatcher("/WEB-INF/views/booking/create-booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Create booking via BookingService (BR-01, BR-02, BR-03, BR-09)
        response.sendRedirect(request.getContextPath() + "/bookings/my");
    }
}

