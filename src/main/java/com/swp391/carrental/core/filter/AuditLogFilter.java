package com.swp391.carrental.core.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import com.swp391.carrental.audit.service.AuditLogService;
import com.swp391.carrental.audit.util.AuditLabels;
import com.swp391.carrental.user.model.User;

/*
 * Name: AuditLogFilter
 * Description: Records an audit log entry for every state-changing (POST) request
 * made by an authenticated user, regardless of role (including ADMIN). Descriptions
 * are written in Vietnamese so they can be displayed as-is on the Audit Log screen.
 */

@WebFilter(filterName = "AuditLogFilter", urlPatterns = {"/*"})
public class AuditLogFilter implements Filter {

    private static final String[] ID_PARAM_NAMES = {
        "carId", "bookingId", "contractId", "paymentId", "handoverId", "returnId",
        "notificationId", "maintenanceId", "brandId", "modelId", "userId", "profileId",
        "reviewId", "policyId", "id"
    };

    private final AuditLogService auditLogService = new AuditLogService();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;

        chain.doFilter(request, response);

        if (!"POST".equalsIgnoreCase(httpRequest.getMethod())) {
            return;
        }

        // The servlet already wrote a richer, business-specific audit entry (e.g. with the
        // actual vehicle name/plate) — skip the generic fallback to avoid duplicate rows.
        if (Boolean.TRUE.equals(httpRequest.getAttribute("auditLogged"))) {
            return;
        }

        try {
            logRequest(httpRequest);
        } catch (Exception e) {
            // Never let audit logging break the actual request.
            System.err.println("AuditLogFilter: failed to record audit log: " + e.getMessage());
        }
    }

    private void logRequest(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);
        if (currentUser == null) {
            return;
        }

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        String actionParam = request.getParameter("action");
        String actionKey = actionParam != null ? actionParam.toUpperCase() : "SUBMIT";

        String entityType = deriveEntityType(path);
        Integer entityId = deriveEntityId(request);

        String description = buildDescription(path, actionKey, entityType, entityId, request);

        auditLogService.logAction(currentUser.getUserId(), actionKey, entityType, entityId, description);
    }

    /**
     * Builds a natural Vietnamese sentence describing what happened, e.g.
     * "Xóa xe #9", "Cập nhật trạng thái bảo trì #10 sang Đang thực hiện", "Ghi nhận bảo trì xe #1",
     * "Đăng nhập vào hệ thống".
     */
    private String buildDescription(String path, String actionKey, String entityType, Integer entityId,
                                     HttpServletRequest request) {
        if (path.startsWith("/login")) {
            return "Đăng nhập vào hệ thống";
        }
        if (path.startsWith("/logout")) {
            return "Đăng xuất khỏi hệ thống";
        }
        if (path.startsWith("/register")) {
            return "Đăng ký tài khoản mới";
        }

        String actionLabel = AuditLabels.translateAction(actionKey);
        StringBuilder description = new StringBuilder(actionLabel);

        if (AuditLabels.isGenericAction(actionKey)) {
            description.append(" ").append(AuditLabels.translateEntity(entityType).toLowerCase());
        }
        if (entityId != null) {
            description.append(" #").append(entityId);
        }

        if ("UPDATESTATUS".equals(actionKey)) {
            String statusParam = request.getParameter("status");
            if (statusParam != null && !statusParam.trim().isEmpty()) {
                description.append(" sang ").append(AuditLabels.translateStatus(statusParam.trim()));
            }
        }

        return description.toString();
    }

    /**
     * Maps a request path to a normalized entity type key (matches AuditLabels.ENTITY_LABELS).
     * Uses full-path prefixes (not just the first segment) so nested routes like
     * /vehicles/maintenance are distinguished from /vehicles/manage.
     */
    private String deriveEntityType(String path) {
        if (path.startsWith("/vehicles/maintenance")) return "MAINTENANCE";
        if (path.startsWith("/vehicles/brands")) return "BRAND_MODEL";
        if (path.startsWith("/vehicles")) return "VEHICLE";
        if (path.startsWith("/bookings")) return "BOOKING";
        if (path.startsWith("/contracts")) return "CONTRACT";
        if (path.startsWith("/admin/payment-settings")) return "PAYMENT_SETTINGS";
        if (path.startsWith("/payments")) return "PAYMENT";
        if (path.startsWith("/handovers") || path.startsWith("/handover")) return "HANDOVER";
        if (path.startsWith("/returns") || path.startsWith("/return")) return "RETURN";
        if (path.startsWith("/additional-fees")) return "ADDITIONAL_FEE";
        if (path.startsWith("/notifications")) return "NOTIFICATION";
        if (path.startsWith("/audit-logs")) return "AUDIT_LOG";
        if (path.startsWith("/users")) return "USER";
        if (path.startsWith("/roles")) return "ROLE";
        if (path.startsWith("/profile")) return "PROFILE";
        if (path.startsWith("/policies")) return "POLICY";
        if (path.startsWith("/reports")) return "REPORT";
        if (path.startsWith("/tax-invoice-settings")) return "TAX_SETTINGS";
        if (path.startsWith("/home") || "/".equals(path)) return "HOME";
        if (path.startsWith("/admin")) return "ADMIN_SETTINGS";

        String[] segments = path.split("/");
        for (String segment : segments) {
            if (!segment.isEmpty()) {
                return segment.toUpperCase();
            }
        }
        return "UNKNOWN";
    }

    private Integer deriveEntityId(HttpServletRequest request) {
        for (String paramName : ID_PARAM_NAMES) {
            String value = request.getParameter(paramName);
            if (value != null && !value.trim().isEmpty()) {
                try {
                    return Integer.parseInt(value.trim());
                } catch (NumberFormatException ignored) {
                    // Not a numeric id, skip.
                }
            }
        }
        return null;
    }
}
