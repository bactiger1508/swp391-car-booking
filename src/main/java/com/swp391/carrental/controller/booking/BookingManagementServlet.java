/*
 * Name: BookingManagementServlet
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for BookingManagementServlet.
 */
package com.swp391.carrental.controller.booking;

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
    private final com.swp391.carrental.service.ContractService contractService = new com.swp391.carrental.service.ContractService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("bookings", bookingService.getAllBookings());
        
        java.util.List<com.swp391.carrental.model.RentalContract> contracts = contractService.getAllContracts();
        java.util.Set<Integer> contractedBookingIds = new java.util.HashSet<>();
        if (contracts != null) {
            for (com.swp391.carrental.model.RentalContract c : contracts) {
                contractedBookingIds.add(c.getBookingId());
            }
        }
        request.setAttribute("contractedBookingIds", contractedBookingIds);
        
        request.getRequestDispatcher("/WEB-INF/views/booking/booking-management.jsp").forward(request, response);
    }
}

