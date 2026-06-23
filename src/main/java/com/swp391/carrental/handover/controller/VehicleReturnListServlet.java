package com.swp391.carrental.handover.controller;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.handover.model.VehicleReturn;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.handover.service.ReturnService;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * Name: VehicleReturnListServlet
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleReturnListServlet.
 */
@WebServlet(name = "VehicleReturnListServlet", urlPatterns = {"/returns"})
public class VehicleReturnListServlet extends HttpServlet {

    private final ReturnService returnService = new ReturnService();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<VehicleReturn> returns = returnService.getAllReturns();

            Map<Integer, BigDecimal> deposits = new HashMap<>();
            Map<Integer, Booking> bookings = new HashMap<>();

            for (VehicleReturn r : returns) {
                Booking booking = bookingDAO.findById(r.getBookingId());

                if (booking != null) {
                    deposits.put(r.getBookingId(), booking.getDepositAmount());
                    bookings.put(r.getBookingId(), booking);
                }
            }

            request.setAttribute("returns", returns);
            request.setAttribute("deposits", deposits);
            request.setAttribute("bookings", bookings);

            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Record return (BR-07, BR-08)
        response.sendRedirect(request.getContextPath() + "/returns");
    }
}
