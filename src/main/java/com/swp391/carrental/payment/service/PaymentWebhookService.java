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

/**
 * Service for verifying and parsing incoming payment webhook notifications.
 * Supports SePay, Casso, PayOS, and other generic/custom providers.
 */
public class PaymentWebhookService {

    private final PolicyService policyService = new PolicyService();

    /**
     * Verifies that the webhook request is authentic and comes from the payment provider.
     *
     * @param request the http request
     * @param payload the request payload body
     * @return true if verified, false otherwise
     */
    public boolean verifyWebhook(HttpServletRequest request, String payload) {
        String provider = policyService.getPolicyValue("WEBHOOK_PROVIDER", "SEPAY").toUpperCase();
        String configuredSecret = policyService.getPolicyValue("WEBHOOK_SECRET", "");

        // Deny verification if secret is not set
        if (configuredSecret == null || configuredSecret.trim().isEmpty()) {
            return false;
        }

        if ("SEPAY".equals(provider)) {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.contains(configuredSecret)) {
                return true;
            }
            String apiKeyHeader = request.getHeader("x-api-key");
            return configuredSecret.equals(apiKeyHeader);
        } else if ("CASSO".equals(provider)) {
            String secureToken = request.getHeader("Secure-Token");
            return configuredSecret.equals(secureToken);
        } else if ("PAYOS".equals(provider)) {
            String apiKey = request.getHeader("x-api-key");
            if (configuredSecret.equals(apiKey)) {
                return true;
            }
            String sig = request.getHeader("x-signature");
            return sig != null && !sig.trim().isEmpty();
        }

        // Generic fallback verification
        String apiKey = request.getHeader("x-api-key");
        if (configuredSecret.equals(apiKey)) return true;
        String authHeader = request.getHeader("Authorization");
        return authHeader != null && authHeader.contains(configuredSecret);
    }

    /**
     * Parses the webhook request body and maps it to unified WebhookTransaction objects.
     *
     * @param request the http request
     * @param payload the request payload body
     * @return a list of parsed transactions
     */
    public List<WebhookTransaction> parseWebhook(HttpServletRequest request, String payload) {
        List<WebhookTransaction> txs = new ArrayList<>();
        String provider = policyService.getPolicyValue("WEBHOOK_PROVIDER", "SEPAY").toUpperCase();

        try {
            if ("SEPAY".equals(provider)) {
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
            } else if ("CASSO".equals(provider)) {
                Pattern p = Pattern.compile("\\{[^\\}]*\"amount\"[^\\}]*\\}");
                Matcher m = p.matcher(payload);
                while (m.find()) {
                    String block = m.group();
                    BigDecimal amount = getJsonNumericValue(block, "amount");
                    String desc = getJsonStringValue(block, "description");
                    String tid = getJsonStringValue(block, "tid");
                    String whenStr = getJsonStringValue(block, "when");
                    LocalDateTime paidAt = parseDateTime(whenStr);
                    if (desc != null && amount != null) {
                        txs.add(new WebhookTransaction(desc, amount, tid, paidAt));
                    }
                }
            } else if ("PAYOS".equals(provider)) {
                BigDecimal amount = getJsonNumericValue(payload, "amount");
                String desc = getJsonStringValue(payload, "description");
                String ref = getJsonStringValue(payload, "reference");
                String dateStr = getJsonStringValue(payload, "transactionDateTime");
                LocalDateTime paidAt = parseDateTime(dateStr);
                if (desc != null && amount != null) {
                    txs.add(new WebhookTransaction(desc, amount, ref, paidAt));
                }
            } else {
                BigDecimal amount = getJsonNumericValue(payload, "amount");
                String desc = getJsonStringValue(payload, "description");
                String ref = getJsonStringValue(payload, "transactionRef");
                if (ref == null) ref = getJsonStringValue(payload, "reference");
                String dateStr = getJsonStringValue(payload, "paidAt");
                LocalDateTime paidAt = parseDateTime(dateStr);
                if (desc != null && amount != null) {
                    txs.add(new WebhookTransaction(desc, amount, ref, paidAt));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return txs;
    }

    private String getJsonStringValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\":\\s*\"([^\"]*)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private BigDecimal getJsonNumericValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\":\\s*([\\d\\.]+)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return new BigDecimal(matcher.group(1));
        }
        return null;
    }

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
