package com.swp391.carrental.audit.util;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Vietnamese display labels for audit log action codes and entity types.
 * Keys must match the UPPERCASE values written by AuditLogFilter.
 */
public final class AuditLabels {

    public static final Map<String, String> ACTION_LABELS = new HashMap<>();
    public static final Map<String, String> ENTITY_LABELS = new HashMap<>();
    public static final Map<String, String> STATUS_LABELS = new HashMap<>();

    /**
     * Actions whose label is a bare verb (e.g. "Xóa", "Cập nhật") and therefore needs the
     * entity type appended to read naturally ("Xóa xe #9"). Actions NOT in this set already
     * carry their own object in the label (e.g. "Thêm hãng xe", "Ghi nhận bảo trì") and should
     * be used as-is.
     */
    private static final Set<String> GENERIC_ACTIONS = new HashSet<>();

    static {
        ACTION_LABELS.put("CREATE", "Tạo mới");
        ACTION_LABELS.put("UPDATE", "Cập nhật");
        ACTION_LABELS.put("DELETE", "Xóa");
        ACTION_LABELS.put("EDIT", "Sửa");
        ACTION_LABELS.put("APPROVE", "Duyệt");
        ACTION_LABELS.put("REJECT", "Từ chối");
        ACTION_LABELS.put("CONFIRM", "Xác nhận");
        ACTION_LABELS.put("ACTIVATE", "Kích hoạt");
        ACTION_LABELS.put("VERIFY", "Xác thực");
        ACTION_LABELS.put("SAVE", "Lưu");
        ACTION_LABELS.put("VIEW", "Xem");
        ACTION_LABELS.put("LIST", "Xem danh sách");
        ACTION_LABELS.put("SUBMIT", "Gửi yêu cầu");
        ACTION_LABELS.put("GETALL", "Xem tất cả");
        ACTION_LABELS.put("FILTER", "Lọc dữ liệu");

        ACTION_LABELS.put("GETSCHEDULE", "Xem lịch bảo trì");
        ACTION_LABELS.put("GETCARIMAGES", "Xem ảnh xe");
        ACTION_LABELS.put("GETMODELS", "Xem danh sách model");
        ACTION_LABELS.put("GETMODELSBYBRAND", "Xem model theo hãng");
        ACTION_LABELS.put("GETUNREADCOUNT", "Xem số thông báo chưa đọc");
        ACTION_LABELS.put("MARKASREAD", "Đánh dấu đã đọc");
        ACTION_LABELS.put("MARKALLASREAD", "Đánh dấu tất cả đã đọc");
        ACTION_LABELS.put("RECORDMAINTENANCE", "Ghi nhận bảo trì");
        ACTION_LABELS.put("UPDATESTATUS", "Cập nhật trạng thái");
        ACTION_LABELS.put("ADDBRAND", "Thêm hãng xe");
        ACTION_LABELS.put("ADDMODEL", "Thêm model xe");
        ACTION_LABELS.put("TOGGLEBRANDACTIVE", "Ẩn/Hiện hãng xe");
        ACTION_LABELS.put("TOGGLEMODELACTIVE", "Ẩn/Hiện model xe");
        ACTION_LABELS.put("TOGGLEACTIVE", "Ẩn/Hiện");
        ACTION_LABELS.put("SETPRIMARYIMAGE", "Đặt ảnh chính");
        ACTION_LABELS.put("DELETEIMAGE", "Xóa ảnh");
        ACTION_LABELS.put("CALCULATE", "Tính toán");
        ACTION_LABELS.put("REQUIREDUPDATE", "Cập nhật bắt buộc");
        ACTION_LABELS.put("UPDATEALL", "Cập nhật tất cả");
        ACTION_LABELS.put("UPDATEMETHODS", "Cập nhật phương thức thanh toán");
        ACTION_LABELS.put("UPDATESETTINGS", "Cập nhật cấu hình");

        // Generic verbs need " <entity> #<id>" appended to read naturally.
        GENERIC_ACTIONS.add("CREATE");
        GENERIC_ACTIONS.add("UPDATE");
        GENERIC_ACTIONS.add("DELETE");
        GENERIC_ACTIONS.add("EDIT");
        GENERIC_ACTIONS.add("APPROVE");
        GENERIC_ACTIONS.add("REJECT");
        GENERIC_ACTIONS.add("CONFIRM");
        GENERIC_ACTIONS.add("ACTIVATE");
        GENERIC_ACTIONS.add("VERIFY");
        GENERIC_ACTIONS.add("SAVE");
        GENERIC_ACTIONS.add("VIEW");
        GENERIC_ACTIONS.add("LIST");
        GENERIC_ACTIONS.add("SUBMIT");
        GENERIC_ACTIONS.add("GETALL");
        GENERIC_ACTIONS.add("FILTER");

        ENTITY_LABELS.put("VEHICLE", "Xe");
        ENTITY_LABELS.put("MAINTENANCE", "Bảo trì");
        ENTITY_LABELS.put("BRAND_MODEL", "Hãng xe/Model");
        ENTITY_LABELS.put("BOOKING", "Đặt xe");
        ENTITY_LABELS.put("CONTRACT", "Hợp đồng");
        ENTITY_LABELS.put("PAYMENT", "Thanh toán");
        ENTITY_LABELS.put("PAYMENT_SETTINGS", "Cấu hình thanh toán");
        ENTITY_LABELS.put("HANDOVER", "Giao xe");
        ENTITY_LABELS.put("RETURN", "Trả xe");
        ENTITY_LABELS.put("ADDITIONAL_FEE", "Phí phát sinh");
        ENTITY_LABELS.put("NOTIFICATION", "Thông báo");
        ENTITY_LABELS.put("AUDIT_LOG", "Lịch sử hoạt động");
        ENTITY_LABELS.put("USER", "Người dùng");
        ENTITY_LABELS.put("ROLE", "Phân quyền");
        ENTITY_LABELS.put("PROFILE", "Hồ sơ cá nhân");
        ENTITY_LABELS.put("POLICY", "Chính sách");
        ENTITY_LABELS.put("REPORT", "Báo cáo");
        ENTITY_LABELS.put("TAX_SETTINGS", "Cấu hình hóa đơn");
        ENTITY_LABELS.put("HOME", "Trang chủ");
        ENTITY_LABELS.put("ADMIN_SETTINGS", "Cấu hình hệ thống");

        // Status values that can appear in a "status" request param, across maintenance jobs,
        // vehicles, and bookings — used to describe *what* an UPDATESTATUS action changed to.
        STATUS_LABELS.put("SCHEDULED", "Đã lên lịch");
        STATUS_LABELS.put("IN_PROGRESS", "Đang thực hiện");
        STATUS_LABELS.put("COMPLETED", "Hoàn tất");
        STATUS_LABELS.put("CANCELLED", "Đã hủy");
        STATUS_LABELS.put("AVAILABLE", "Có sẵn");
        STATUS_LABELS.put("RENTED", "Đã thuê");
        STATUS_LABELS.put("MAINTENANCE", "Bảo trì");
        STATUS_LABELS.put("INACTIVE", "Ngừng hoạt động");
        STATUS_LABELS.put("PENDING", "Chờ duyệt");
        STATUS_LABELS.put("CONFIRMED", "Đã xác nhận");
        STATUS_LABELS.put("REJECTED", "Đã từ chối");
        STATUS_LABELS.put("ACTIVE", "Hoạt động");
    }

    public static String translateAction(String action) {
        if (action == null) return "";
        String label = ACTION_LABELS.get(action.toUpperCase());
        return label != null ? label : action;
    }

    public static String translateEntity(String entityType) {
        if (entityType == null) return "";
        String label = ENTITY_LABELS.get(entityType.toUpperCase());
        return label != null ? label : entityType;
    }

    public static String translateStatus(String status) {
        if (status == null) return "";
        String label = STATUS_LABELS.get(status.toUpperCase());
        return label != null ? label : status;
    }

    public static boolean isGenericAction(String action) {
        return action != null && GENERIC_ACTIONS.contains(action.toUpperCase());
    }

    private AuditLabels() {}
}
