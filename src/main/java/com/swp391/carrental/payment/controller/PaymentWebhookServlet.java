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
