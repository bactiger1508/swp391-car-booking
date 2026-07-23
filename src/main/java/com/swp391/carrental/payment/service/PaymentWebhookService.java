package com.swp391.carrental.payment.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import jakarta.servlet.http.HttpServletRequest;
import com.swp391.carrental.policy.service.PolicyService;

/*
 * Name: PaymentWebhookService
 * @Author: TungNLHE186756
 * Created: 16/07/2026 
 * Description: Service for verifying and parsing incoming payment webhook notifications from payment providers like SePay.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (17/07/2026): feat: refine payment and policy settings configuration
 * - v1.2 (23/07/2026): Added Javadoc and method comments.
 */
public class PaymentWebhookService {

    private final PolicyService policyService = new PolicyService();

    /**
     * Verifies that the webhook request is authentic and comes from SePay.
     *
     * @param request the http request
     * @param payload the request payload body
     * @return true if verified, false otherwise
     */
    public boolean verifyWebhook(HttpServletRequest request, String payload) {
        String configuredSecret = policyService.getPolicyValue("WEBHOOK_SECRET", "");

        // Deny verification if secret is not set
        if (configuredSecret == null || configuredSecret.trim().isEmpty()) {
            return false;
        }

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.contains(configuredSecret)) {
            return true;
        }
        String apiKeyHeader = request.getHeader("x-api-key");
        return configuredSecret.equals(apiKeyHeader);
    }

    /**
     * Parses the SePay webhook request body and maps it to unified WebhookTransaction objects.
     *
     * @param request the http request
     * @param payload the request payload body
     * @return a list of parsed transactions
     */
    public List<WebhookTransaction> parseWebhook(HttpServletRequest request, String payload) {
        List<WebhookTransaction> txs = new ArrayList<>();

        try {
            BigDecimal amount = getJsonNumericValue(payload, "transferAmount");
            if (amount == null) amount = getJsonNumericValue(payload, "amount");
            String content = getJsonStringValue(payload, "content");
            if (content == null) content = getJsonStringValue(payload, "description");
            String ref = getJsonStringValue(payload, "referenceCode");
            if (ref == null) ref = getJsonStringValue(payload, "id");
            
            String dateStr = getJsonStringValue(payload, "transactionDate");
            LocalDateTime paidAt = parseDateTime(dateStr);

            if (content != null && amount != null) {
                txs.add(new WebhookTransaction(content, amount, ref, paidAt));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return txs;
    }

    /**
     * Extract a string value from a raw JSON string using a regex pattern.
     */
    private String getJsonStringValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\":\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extract a numeric value from a raw JSON string using a regex pattern.
     */
    private BigDecimal getJsonNumericValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\":\\s*([\\d\\.]+)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return new BigDecimal(matcher.group(1));
        }
        return null;
    }

    /**
     * Parse standard date strings to LocalDateTime objects.
     */
    private LocalDateTime parseDateTime(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return LocalDateTime.now();
        }
        try {
            String clean = dateStr.replace("T", " ").replace("Z", "").trim();
            if (clean.contains(".")) {
                clean = clean.substring(0, clean.indexOf("."));
            }
            if (clean.length() > 19) {
                clean = clean.substring(0, 19);
            }
            return LocalDateTime.parse(clean, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        } catch (Exception e) {
            try {
                return LocalDateTime.parse(dateStr, DateTimeFormatter.ISO_DATE_TIME);
            } catch (Exception ex) {
                return LocalDateTime.now();
            }
        }
    }
}
