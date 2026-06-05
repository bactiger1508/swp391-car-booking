/*
 * Name: BookingApprovalServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for BookingApprovalServlet.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.constant.BookingStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BookingApprovalServlet", urlPatterns = {"/bookings/approval"})
public class BookingApprovalServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("pendingBookings", bookingService.getBookingsByStatus(BookingStatus.PENDING));
        request.getRequestDispatcher("/WEB-INF/views/booking/booking-approval.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Handle approve/reject actions (BR-04)
        response.sendRedirect(request.getContextPath() + "/bookings/approval");
    }
}

