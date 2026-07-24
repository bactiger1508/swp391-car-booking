package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.notification.model.Notification;

/*
 * Name: BookingCancelServlet
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 1.0
 * Description: Controller to handle booking cancellation requests.
 */
@WebServlet(name = "BookingCancelServlet", urlPatterns = {"/bookings/cancel"})
public class BookingCancelServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();
    private final UserService userService = new UserService();
    private final NotificationService notificationService = new NotificationService();

    /** Handles booking cancellation requests from customers or staff */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "CANCEL_BOOKING")
                && !com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_BOOKING_REQUEST")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String reason = request.getParameter("reason");

        if (reason == null || reason.trim().isEmpty()) {
            reason = "Khách hàng tự hủy";
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            com.swp391.carrental.booking.model.Booking booking = bookingService.getBookingById(bookingId);
            if (booking == null) {
                request.getSession().setAttribute("errorMessage", "Đơn đặt xe không tồn tại.");
            } else {
                boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_BOOKING_REQUEST");
                
                if (!isStaffOrAdmin) {
                    if (booking.getCustomerId() != currentUser.getUserId()) {
                        request.getSession().setAttribute("errorMessage", "Bạn không có quyền hủy đơn đặt xe này.");
                    } else if ("CONFIRMED".equalsIgnoreCase(booking.getStatus())) {
                        request.getSession().setAttribute("errorMessage", "Đơn hàng đã xác nhận (đã đóng cọc) không thể tự hủy. Vui lòng liên hệ nhân viên để hỗ trợ.");
                    } else {
                        bookingService.cancelBooking(bookingId, reason.trim());
                        notifyBookingCancelled(bookingId, reason.trim());
                        request.getSession().setAttribute("successMessage", "Hủy đơn thuê #" + bookingId + " thành công.");
                    }
                } else {
                    bookingService.cancelBooking(bookingId, reason.trim());
                    notifyBookingCancelled(bookingId, reason.trim());
                    request.getSession().setAttribute("successMessage", "Hủy đơn thuê #" + bookingId + " thành công.");
                }
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Mã booking không hợp lệ.");
        }

        if (bookingIdStr != null) {
            response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingIdStr);
        } else {
            response.sendRedirect(request.getContextPath() + "/bookings/my");
        }
    }

    private void notifyBookingCancelled(int bookingId, String cancelReason) {
        try {
            com.swp391.carrental.booking.model.Booking booking = bookingService.getBookingById(bookingId);
            if (booking != null) {
                int customerId = booking.getCustomerId();

                Notification customerNotif = new Notification(customerId,
                    "Đặt xe bị hủy",
                    "Booking #" + bookingId + " của bạn đã bị hủy. Lý do: " + cancelReason,
                    "BOOKING");
                customerNotif.setReferenceType("BOOKING");
                customerNotif.setReferenceId(bookingId);
                notificationService.createNotification(customerNotif);

                for (String staffRole : new String[]{"STAFF", "ADMIN"}) {
                    for (User staffUser : userService.getUsersByRole(staffRole)) {
                        Notification staffNotif = new Notification(staffUser.getUserId(),
                            "Booking bị hủy",
                            "Khách hàng vừa hủy booking #" + bookingId + ". Lý do: " + cancelReason,
                            "BOOKING");
                        staffNotif.setReferenceType("BOOKING");
                        staffNotif.setReferenceId(bookingId);
                        notificationService.createNotification(staffNotif);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Failed to send booking-cancelled notification: " + e.getMessage());
        }
    }
}
