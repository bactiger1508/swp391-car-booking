package com.swp391.carrental.handover.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.service.HandoverService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
@WebServlet(name = "VehicleHandoverViewServlet", urlPatterns = {"/handover/view"})
public class VehicleHandoverViewServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_HANDOVER");
        boolean isCustomer = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "VIEW_BOOKING");

        if (!isStaffOrAdmin && !isCustomer) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");
            if (bookingIdStr != null && carIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                if (booking != null) {
                    if (!isStaffOrAdmin && booking.getCustomerId() != currentUser.getUserId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                        return;
                    }
                }
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
        String action = request.getParameter("action");
        String carIdStr = request.getParameter("carId");
        int carId = Integer.parseInt(carIdStr);

        if ("requiredUpdate".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));

                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (handover != null) {
                    handoverService.updateStatusRequired(handover.getHandoverId());
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
                    Car car = carDAO.findById(carId);
                    if (car != null) {
                        car.setMileage(handover.getMileageAtHandover());
                        carDAO.update(car);
                    }
                    
                    // Send notifications & session message
                    notifyHandoverSigned(handover, bookingId);
                    if (request.getSession() != null) {
                        request.getSession().setAttribute("successMessage", "Ký nhận biên bản bàn giao xe thành công!");
                    }
                }

                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }
    }

    private void notifyHandoverSigned(VehicleHandover handover, int bookingId) {
        try {
            com.swp391.carrental.notification.service.NotificationService notificationService = new com.swp391.carrental.notification.service.NotificationService();
            // Notify customer
            com.swp391.carrental.notification.model.Notification notifCustomer = new com.swp391.carrental.notification.model.Notification(
                    handover.getReceivedBy(),
                    "Ký nhận bàn giao xe thành công",
                    "Bạn đã ký nhận thành công biên bản bàn giao xe cho đơn đặt xe #" + bookingId + ". Chúc bạn có chuyến đi an toàn!",
                    "HANDOVER");
            notifCustomer.setReferenceType("HANDOVER");
            notifCustomer.setReferenceId(handover.getHandoverId());
            notificationService.createNotification(notifCustomer);

            // Notify staff who handed over the vehicle
            if (handover.getHandedBy() > 0) {
                com.swp391.carrental.notification.model.Notification notifStaff = new com.swp391.carrental.notification.model.Notification(
                        handover.getHandedBy(),
                        "Khách hàng đã ký nhận bàn giao xe",
                        "Khách hàng đã ký nhận thành công biên bản bàn giao xe cho đơn đặt xe #" + bookingId + ".",
                        "HANDOVER");
                notifStaff.setReferenceType("HANDOVER");
                notifStaff.setReferenceId(handover.getHandoverId());
                notificationService.createNotification(notifStaff);
            }
        } catch (Exception e) {
            System.err.println("Failed to send handover signed notification: " + e.getMessage());
        }
    }
}
