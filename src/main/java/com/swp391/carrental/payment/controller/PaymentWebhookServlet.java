package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.payment.service.PaymentWebhookService;
import com.swp391.carrental.payment.service.WebhookTransaction;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: PaymentWebhookServlet
 * @Author: TungNLHE186756
 * Created: 16/07/2026 
 * Description: API Controller servlet handling HTTP POST requests to receive and process automated bank transfer webhook notifications.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (16/07/2026): fix(auth): allow payment webhook to bypass authentication...
 * - v1.2 (23/07/2026): Added Javadoc and method comments.
 */
@WebServlet(name = "PaymentWebhookServlet", urlPatterns = { "/api/payment/webhook" })
public class PaymentWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentWebhookServlet.class.getName());
    private final PaymentWebhookService webhookService = new PaymentWebhookService();
    private final PaymentService paymentService = new PaymentService();
    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserService userService = new UserService();
    private final NotificationService notificationService = new NotificationService();

    /**
     * Handles HTTP GET requests to check webhook endpoint status.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write("{\"success\":true,\"message\":\"Payment Webhook endpoint is active (Use POST to send webhook payloads)\"}");
    }

    /**
     * Handles HTTP POST webhook payloads, verifying authorization, and processing bank transactions.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        StringBuilder buffer = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
        }

        String payload = buffer.toString();

        // Log the incoming webhook request payload for troubleshooting
        LOGGER.log(Level.INFO, "Incoming Webhook API call. Payload: {0}", payload);

        // 1. Verify Authenticity
        if (!webhookService.verifyWebhook(request, payload)) {
            LOGGER.log(Level.WARNING, "Webhook authorization/signature verification failed.");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter()
                    .write("{\"success\":false,\"message\":\"Unauthorized: Invalid API Key or Signature\"}");
            return;
        }

        // 2. Parse Transactions
        List<WebhookTransaction> transactions = webhookService.parseWebhook(request, payload);
        if (transactions.isEmpty()) {
            LOGGER.log(Level.WARNING, "Webhook parsed successfully but contains no valid transaction objects.");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"Bad Request: No transaction data parsed\"}");
            return;
        }

        // 3. Process each parsed transaction
        boolean allProcessed = true;
        for (WebhookTransaction tx : transactions) {
            boolean success = paymentService.verifyBankTransfer(
                    tx.getTransferDescription(),
                    tx.getAmount(),
                    tx.getTransactionRef(),
                    tx.getPaymentTime());
            if (!success) {
                allProcessed = false;
                LOGGER.log(Level.SEVERE, "Failed to verify or record transfer: Description={0}, Amount={1}, Ref={2}",
                        new Object[] { tx.getTransferDescription(), tx.getAmount(), tx.getTransactionRef() });
            } else {
                LOGGER.log(Level.INFO, "Successfully verified bank transfer: Description={0}, Amount={1}, Ref={2}",
                        new Object[] { tx.getTransferDescription(), tx.getAmount(), tx.getTransactionRef() });
                notifyIfPaymentCompleted(tx.getTransferDescription());
            }
        }

        response.setContentType("application/json; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);

        if (allProcessed) {
            response.getWriter().write(
                    "{\"success\":true,\"message\":\"Webhook processed and payment(s) updated successfully\"}");
        } else {
            response.getWriter().write(
                    "{\"success\":true,\"message\":\"Parsed but payment update skipped/failed (payment not found or invalid description)\"}");
        }
    }

    /**
     * Parses the payment id out of a verified transfer description (format {TYPE}-PAY{paymentId})
     * and, if the payment is now fully COMPLETED, notifies the customer and every STAFF/ADMIN account.
     * This is the online bank-transfer counterpart of the manual-record notification in PaymentRecordServlet.
     */
    private void notifyIfPaymentCompleted(String transferDescription) {
        try {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("PAY(\\d+)")
                    .matcher(transferDescription == null ? "" : transferDescription.toUpperCase());
            if (!m.find()) {
                return;
            }
            int paymentId = Integer.parseInt(m.group(1));

            Payment payment = paymentService.getPaymentById(paymentId);
            if (payment == null || !"COMPLETED".equalsIgnoreCase(payment.getStatus())) {
                return;
            }
            Booking booking = bookingService.getBookingById(payment.getBookingId());
            if (booking == null) {
                return;
            }

            Vehicle vehicle = vehicleService.getVehicleById(booking.getVehicleId());
            String vehicleInfo = vehicle != null ? "biển số " + vehicle.getLicensePlate() : "xe #" + booking.getVehicleId();
            String message = "Chuyển khoản " + payment.getAmount() + " VNĐ cho booking #" + payment.getBookingId()
                    + " (" + vehicleInfo + ") đã được xác nhận tự động qua ngân hàng.";

            Notification customerNotif = new Notification(booking.getCustomerId(),
                    "Thanh toán chuyển khoản thành công", message, "PAYMENT");
            customerNotif.setReferenceType("PAYMENT");
            customerNotif.setReferenceId(paymentId);
            notificationService.createNotification(customerNotif);

            for (String staffRole : new String[]{"STAFF", "ADMIN"}) {
                for (User staffUser : userService.getUsersByRole(staffRole)) {
                    Notification staffNotif = new Notification(staffUser.getUserId(),
                            "Nhận được chuyển khoản tự động", message, "PAYMENT");
                    staffNotif.setReferenceType("PAYMENT");
                    staffNotif.setReferenceId(paymentId);
                    notificationService.createNotification(staffNotif);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to send payment-completed webhook notification: {0}", e.getMessage());
        }
    }
}
