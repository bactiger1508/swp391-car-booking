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
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.payment.service.PaymentWebhookService;
import com.swp391.carrental.payment.service.WebhookTransaction;

/**
 * Servlet endpoint to receive and process webhook payment notifications.
 * Maps to /api/payment/webhook (POST).
 */
@WebServlet(name = "PaymentWebhookServlet", urlPatterns = { "/api/payment/webhook" })
public class PaymentWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PaymentWebhookServlet.class.getName());
    private final PaymentWebhookService webhookService = new PaymentWebhookService();
    private final PaymentService paymentService = new PaymentService();

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
}
