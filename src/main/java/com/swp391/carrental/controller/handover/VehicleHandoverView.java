/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.swp391.carrental.controller.handover;

import com.swp391.carrental.dao.BookingDAO;
import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.dao.ContractDAO;
import com.swp391.carrental.dao.HandoverDAO;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.RentalContract;
import com.swp391.carrental.model.User;
import com.swp391.carrental.model.VehicleHandover;
import com.swp391.carrental.service.HandoverService;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;

/**
 *
 * @author lenovo
 */
@WebServlet(name = "VehicleHandoverView", urlPatterns = {"/handover/view"})
public class VehicleHandoverView extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("action = " + request.getParameter("action"));
        System.out.println("bookingId = " + request.getParameter("bookingId"));
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");
            if (bookingIdStr != null && carIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Car car = carDAO.findById(carId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("handover", handover);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-view.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Do Post");
        System.out.println("action = " + request.getParameter("action"));
        System.out.println("bookingId = " + request.getParameter("bookingId"));
        String action = request.getParameter("action");

        if ("requiredUpdate".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));

                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (handover != null) {
                    handoverService.updateStatusRequiredUpdate(handover.getHandoverId());
                }

                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        if ("confirm".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));

                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (handover != null) {
                    handoverService.updateStatusConfirm(handover.getHandoverId());
                }

                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }
    }
}
