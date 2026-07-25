package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.sql.SQLException;
import java.io.IOException;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.service.HandoverService;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

/**
 * Name: VehicleHandoverViewServlet
 * 
 * @Author: TamTTMHE190340
 *          Date: 21/06/2026
 *          Version: 1.0
 *          Description: Controller for viewing read-only vehicle handover
 *          inspection details.
 */
@WebServlet(name = "VehicleHandoverViewServlet", urlPatterns = { "/handover/view" })
public class VehicleHandoverViewServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");
            if (bookingIdStr != null && carIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Vehicle car = vehicleDAO.findById(carId);
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

                User staff = null;
                if (handover != null && handover.getHandedBy() > 0) {
                    staff = userDAO.findById(handover.getHandedBy());
                }
                if (staff == null) {
                    staff = currentUser;
                }
                request.setAttribute("staff", staff);
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
                    Vehicle car = vehicleDAO.findById(carId);
                    if (car != null) {
                        car.setMileage(handover.getMileageAtHandover());
                        vehicleDAO.update(car);
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
            NotificationService notificationService = new NotificationService();
            // Notify customer
            Notification notifCustomer = new Notification(
                    handover.getReceivedBy(),
                    "Ký nhận bàn giao xe thành công",
                    "Bạn đã ký nhận thành công biên bản bàn giao xe cho đơn đặt xe #" + bookingId
                            + ". Chúc bạn có chuyến đi an toàn!",
                    "HANDOVER");
            notifCustomer.setReferenceType("HANDOVER");
            notifCustomer.setReferenceId(handover.getHandoverId());
            notificationService.createNotification(notifCustomer);

            // Notify staff who handed over the vehicle
            if (handover.getHandedBy() > 0) {
                Notification notifStaff = new Notification(
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
