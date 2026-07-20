package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: BookingApprovalServlet
 * @Author: BacBui
 * @Author: TungNLHE186756
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Handles booking approval/rejection by Staff/Admin. GET shows pending list, POST processes actions.
 */

/**
 * Staff/Admin booking approval page.
 * URL: /bookings/approval
 */
@WebServlet(name = "BookingApprovalServlet", urlPatterns = { "/bookings/approval" })
public class BookingApprovalServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Booking> pendingBookings = bookingService.getBookingsByStatus(BookingStatus.PENDING);
        request.setAttribute("pendingBookings", pendingBookings);

        // Build user and car maps
        Map<Integer, User> userMap = new HashMap<>();
        Map<Integer, Car> carMap = new HashMap<>();
        for (Booking b : pendingBookings) {
            if (!userMap.containsKey(b.getCustomerId())) {
                try {
                    User u = userDAO.findById(b.getCustomerId());
                    if (u != null) {
                        userMap.put(b.getCustomerId(), u);
                    }
                } catch (Exception e) {
                    // Skip
                }
            }
            if (!carMap.containsKey(b.getCarId())) {
                Car car = vehicleService.getCarById(b.getCarId());
                if (car != null) {
                    carMap.put(b.getCarId(), car);
                }
            }
        }
        request.setAttribute("userMap", userMap);
        request.setAttribute("carMap", carMap);

        // Transfer session messages
        String successMessage = (String) request.getSession().getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("success", successMessage);
            request.getSession().removeAttribute("successMessage");
        }
        String errorMessage = (String) request.getSession().getAttribute("errorMessage");
        if (errorMessage != null) {
            request.setAttribute("error", errorMessage);
            request.getSession().removeAttribute("errorMessage");
        }

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-approval.jsp")
                .forward(request, response);
    }

    /**
     * Process approve/reject actions.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_BOOKING_REQUEST")) {
            request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                    .forward(request, response);
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String action = request.getParameter("action");

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingService.getBookingById(bookingId);

            if ("approve".equals(action)) {
                bookingService.approveBooking(bookingId, currentUser.getUserId());
                request.getSession().setAttribute("successMessage",
                        "Đã duyệt booking #" + bookingId + " thành công.");
                notifyBookingDecision(booking, bookingId, true, null);
            } else if ("reject".equals(action)) {
                String reason = request.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Không đạt yêu cầu";
                }
                bookingService.rejectBooking(bookingId, currentUser.getUserId(), reason.trim());
                request.getSession().setAttribute("successMessage",
                        "Đã từ chối booking #" + bookingId + ".");
                notifyBookingDecision(booking, bookingId, false, reason.trim());
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Mã booking không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/bookings/approval");
    }

    /**
     * Notifies the customer whether their booking request was approved or rejected.
     */
    private void notifyBookingDecision(Booking booking, int bookingId, boolean approved, String reason) {
        if (booking == null) {
            return;
        }
        try {
            String title = approved ? "Đặt xe đã được duyệt" : "Đặt xe bị từ chối";
            String message = approved
                    ? "Booking #" + bookingId + " của bạn đã được duyệt. Vui lòng chờ chuẩn bị hợp đồng."
                    : "Booking #" + bookingId + " của bạn đã bị từ chối. Lý do: " + reason;

            Notification notif = new Notification(booking.getCustomerId(), title, message, "BOOKING");
            notif.setReferenceType("BOOKING");
            notif.setReferenceId(bookingId);
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send booking-decision notification: " + e.getMessage());
        }
    }
}
