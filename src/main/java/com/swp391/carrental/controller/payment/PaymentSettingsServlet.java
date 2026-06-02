/*
 * Name: PaymentSettingsServlet
 * @Author: TungNLHE186756
 * Date: 30/05/2026
 * Version: 1.0
 * Description: Admin servlet to configure payment methods and payment-related settings.
 */
package com.swp391.carrental.controller.payment;

import com.swp391.carrental.model.PolicySetting;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.PolicyService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Admin-only servlet for configuring payment methods and payment-related settings.
 * URL: /admin/payment-settings
 */
@WebServlet(name = "PaymentSettingsServlet", urlPatterns = {"/admin/payment-settings"})
public class PaymentSettingsServlet extends HttpServlet {

    private final PolicyService policyService = new PolicyService();

    // Policy keys for payment methods (toggle on/off)
    private static final String[] METHOD_KEYS = {
        "PAYMENT_METHOD_CASH_ENABLED",
        "PAYMENT_METHOD_BANK_TRANSFER_ENABLED",
        "PAYMENT_METHOD_CARD_ENABLED",
        "PAYMENT_METHOD_MOMO_ENABLED",
        "PAYMENT_METHOD_VNPAY_ENABLED",
        "PAYMENT_METHOD_ZALOPAY_ENABLED"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<PolicySetting> paymentPolicies = policyService.getPoliciesByCategory("PAYMENT");

        // Separate method toggles from general settings for easier rendering
        Map<String, PolicySetting> methodMap  = new LinkedHashMap<>();
        Map<String, PolicySetting> settingMap = new LinkedHashMap<>();

        for (PolicySetting ps : paymentPolicies) {
            boolean isMethodKey = false;
            for (String mk : METHOD_KEYS) {
                if (mk.equals(ps.getPolicyKey())) { isMethodKey = true; break; }
            }
            if (isMethodKey) {
                methodMap.put(ps.getPolicyKey(), ps);
            } else {
                settingMap.put(ps.getPolicyKey(), ps);
            }
        }

        // Fetch DEPOSIT_PERCENTAGE which is under BOOKING category and put in settingMap
        try {
            PolicySetting depositPct = policyService.getPolicyByKey("DEPOSIT_PERCENTAGE");
            if (depositPct != null) {
                settingMap.put("DEPOSIT_PERCENTAGE", depositPct);
            }
        } catch (Exception ignored) {}

        request.setAttribute("methodMap",  methodMap);
        request.setAttribute("settingMap", settingMap);
        request.setAttribute("activeTab",  request.getParameter("tab") != null ? request.getParameter("tab") : "methods");

        String success = (String) request.getSession().getAttribute("paymentSettingsSuccess");
        String error   = (String) request.getSession().getAttribute("paymentSettingsError");
        if (success != null) { request.setAttribute("successMsg", success); request.getSession().removeAttribute("paymentSettingsSuccess"); }
        if (error   != null) { request.setAttribute("errorMsg",   error);   request.getSession().removeAttribute("paymentSettingsError"); }

        request.getRequestDispatcher("/WEB-INF/views/payment/payment-settings.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String tab    = request.getParameter("tab") != null ? request.getParameter("tab") : "methods";

        try {
            if ("updateAll".equals(action)) {
                updateMethodToggles(request, currentUser.getUserId());
                updateGeneralSettings(request, currentUser.getUserId());
                request.getSession().setAttribute("paymentSettingsSuccess", "Lưu tất cả cấu hình thanh toán thành công!");

            } else if ("updateMethods".equals(action)) {
                updateMethodToggles(request, currentUser.getUserId());
                request.getSession().setAttribute("paymentSettingsSuccess", "Cập nhật phương thức thanh toán thành công!");

            } else if ("updateSettings".equals(action)) {
                updateGeneralSettings(request, currentUser.getUserId());
                request.getSession().setAttribute("paymentSettingsSuccess", "Cập nhật cài đặt thanh toán thành công!");

            } else {
                request.getSession().setAttribute("paymentSettingsError", "Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            request.getSession().setAttribute("paymentSettingsError", "Lỗi khi lưu cài đặt: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/payment-settings?tab=" + tab);
    }

    // ----------------------------------------------------------------
    // Helpers
    // ----------------------------------------------------------------

    /**
     * Reads checkbox params for each method key and writes true/false to DB.
     */
    private void updateMethodToggles(HttpServletRequest request, int userId) {
        Map<String, String> updates = new LinkedHashMap<>();
        for (String key : METHOD_KEYS) {
            String val = request.getParameter(key);
            updates.put(key, "on".equalsIgnoreCase(val) ? "true" : "false");
        }
        policyService.batchUpdatePolicies(updates, userId);
    }

    /**
     * Reads all policy_ prefixed POST params that are NOT method toggles and updates DB.
     */
    private void updateGeneralSettings(HttpServletRequest request, int userId) {
        Map<String, String> updates = new LinkedHashMap<>();
        Enumeration<String> names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name.startsWith("policy_")) {
                String key   = name.substring("policy_".length());
                String value = request.getParameter(name);
                if (value != null) updates.put(key, value.trim());
            }
        }
        // Checkbox for PAYMENT_PARTIAL_ALLOWED is not submitted when unchecked;
        // default to "false" so toggling OFF is properly persisted.
        updates.putIfAbsent("PAYMENT_PARTIAL_ALLOWED", "false");
        if (!updates.isEmpty()) {
            policyService.batchUpdatePolicies(updates, userId);
        }
    }
}
