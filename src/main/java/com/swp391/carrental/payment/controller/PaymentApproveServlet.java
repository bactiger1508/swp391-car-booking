package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: PaymentApproveServlet
 * @Author: TungNLHE186756
 * Created: 16/07/2026 
 * Description: Controller handling HTTP POST requests for approving pending cash/transfer payments.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (23/07/2026): Added Javadoc and method comments.
 */
@WebServlet(name = "PaymentApproveServlet", urlPatterns = {"/payments/approve"})
public class PaymentApproveServlet extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();
    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final NotificationService notificationService = new NotificationService();

    /**
     * Handles HTTP POST requests for cash payment approvals by Staff or Admin.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null || (!"STAFF".equals(currentUser.getRole()) && !"ADMIN".equals(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String paymentIdStr = request.getParameter("paymentId");
        String bookingIdStr = request.getParameter("bookingId");

        if (paymentIdStr == null || bookingIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu thông tin phê duyệt thanh toán.");
            return;
        }

        try {
            int paymentId = Integer.parseInt(paymentIdStr);
            boolean success = paymentService.approvePendingPayment(paymentId, currentUser.getUserId());

            if (success) {
                request.getSession().setAttribute("paymentSuccess", "Xác nhận nhận tiền thành công!");
                notifyPaymentApproved(paymentId);
            } else {
                request.getSession().setAttribute("paymentError", "Giao dịch không tồn tại hoặc đã được xử lý trước đó.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("paymentError", "Lỗi phê duyệt thanh toán: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingIdStr);
    }

    /** Notifies the customer that their cash/transfer payment has been confirmed by staff. */
    private void notifyPaymentApproved(int paymentId) {
        try {
            Payment payment = paymentService.getPaymentById(paymentId);
            if (payment == null) {
                return;
            }
            Booking booking = bookingService.getBookingById(payment.getBookingId());
            if (booking == null) {
                return;
            }

            String vehicleInfo;
            Vehicle vehicle = vehicleService.getVehicleById(booking.getVehicleId());
            vehicleInfo = vehicle != null ? "biển số " + vehicle.getLicensePlate() : "xe #" + booking.getVehicleId();

            String message = "Khoản thanh toán " + payment.getAmount() + " VNĐ cho booking #" + payment.getBookingId()
                    + " (" + vehicleInfo + ") đã được nhân viên xác nhận.";

            Notification notif = new Notification(booking.getCustomerId(), "Thanh toán đã được xác nhận", message, "PAYMENT");
            notif.setReferenceType("PAYMENT");
            notif.setReferenceId(paymentId);
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send payment-approved notification: " + e.getMessage());
        }
    }
}
