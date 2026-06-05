/*
 * Name: BookingEditServlet
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for BookingEditServlet.
 */
package com.swp391.carrental.controller.booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BookingEditServlet", urlPatterns = {"/bookings/edit"})
public class BookingEditServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Load booking by ID for editing
        request.getRequestDispatcher("/WEB-INF/views/booking/booking-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Update booking via BookingService
        response.sendRedirect(request.getContextPath() + "/bookings/my");
    }
}

