-- ============================================================
-- Add Roles & Permissions Tables to CarRentalDB
-- ============================================================

USE CarRentalDB;
GO

-- Xóa dữ liệu cũ nếu có để tránh trùng lặp/lỗi font khi nạp lại
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[role_permission]') AND type in (N'U'))
    DELETE FROM role_permission;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[permission]') AND type in (N'U'))
    DELETE FROM permission;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
    DELETE FROM roles;
GO

-- 1. TẠO BẢNG ROLES (Vai trò)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
    CREATE TABLE roles (
        role_id INT IDENTITY(1,1) PRIMARY KEY,
        role NVARCHAR(20) NOT NULL,
        description NVARCHAR(255) NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 2. TẠO BẢNG PERMISSION (Quyền hạn chi tiết)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[permission]') AND type in (N'U'))
BEGIN
    CREATE TABLE permission (
        permission_id INT IDENTITY(1,1) PRIMARY KEY,
        permission_key VARCHAR(100) NOT NULL UNIQUE, -- Code dùng để check trong code logic (ví dụ: 'CREATE_BOOKING')
        permission_name NVARCHAR(100) NOT NULL,      -- Tên hiển thị thân thiện (ví dụ: 'Tạo đơn đặt xe')
        functional_area NVARCHAR(100) NOT NULL,     -- Khu vực chức năng (ví dụ: 'Quản lý Đội xe', 'Đặt xe & Giữ chỗ')
    );
END
GO

-- 3. TẠO BẢNG TRUNG GIAN ROLE_PERMISSION (Liên kết vai trò và quyền)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[role_permission]') AND type in (N'U'))
BEGIN
    CREATE TABLE role_permission (
        role_id INT NOT NULL,
        permission_id INT NOT NULL,
        assigned_at DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (role_id, permission_id),
        CONSTRAINT FK_RolePermission_Role FOREIGN KEY (role_id) 
            REFERENCES roles(role_id) ON DELETE CASCADE,
        CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (permission_id) 
            REFERENCES permission(permission_id) ON DELETE CASCADE
    );
END
GO

-- =========================================================================
-- CHÈN DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)
-- =========================================================================

-- Seed dữ liệu cho bảng [roles] nếu chưa tồn tại
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'ADMIN')
        INSERT INTO roles (role, description) VALUES (N'ADMIN', N'Quản trị viên toàn quyền hệ thống');
        
    IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'STAFF')
        INSERT INTO roles (role, description) VALUES (N'STAFF', N'Nhân viên vận hành');
        
    IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'CUSTOMER')
        INSERT INTO roles (role, description) VALUES (N'CUSTOMER', N'Khách thuê xe đã đăng ký tài khoản');
END
GO

-- Seed dữ liệu cho bảng [permission] dựa theo các Use Case của CarPro
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[permission]') AND type in (N'U'))
BEGIN
    -- Bookings & Availability
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CHECK_VEHICLE_AVAILABILITY')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CHECK_VEHICLE_AVAILABILITY', N'Kiểm tra tình trạng của xe', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CREATE_BOOKING')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CREATE_BOOKING', N'Tạo đơn đặt xe mới', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_BOOKING')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_BOOKING', N'Xem lịch sử booking cá nhân', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_BOOKINGS_CALENDAR')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_BOOKINGS_CALENDAR', N'Xem lịch đặt xe', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_BOOKINGS_POLICE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_BOOKINGS_POLICE', N'Xem thông tin đặt xe', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'UPDATE_BOOKING')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('UPDATE_BOOKING', N'Cập nhật đơn đặt xe', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CANCEL_BOOKING')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CANCEL_BOOKING', N'Hủy đơn đặt xe', N'Bookings & Availability');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PROCESS_BOOKING_REQUEST')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PROCESS_BOOKING_REQUEST', N'Xử lý yêu cầu đặt xe', N'Bookings & Availability');

    -- Contract and Payment
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PREPARE_CONTRACT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PREPARE_CONTRACT', N'Chuẩn bị hợp đồng', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_CONTRACT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_CONTRACT', N'Xem hợp đồng', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'UPDATE_CONTRACT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('UPDATE_CONTRACT', N'Cập nhật hợp đồng', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PROCESS_ELECTRONIC_SIGNATURE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PROCESS_ELECTRONIC_SIGNATURE', N'CHữ ký điện tử', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'RECORD_PAYMENT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('RECORD_PAYMENT', N'Ghi nhận thanh toán', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'GENERATE_PAYMENT_QR_CODE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('GENERATE_PAYMENT_QR_CODE', N'Tạo mã QR thanh toán', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'RECORD_REFUND')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('RECORD_REFUND', N'Ghi nhận hoàn tiền', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CONFIGURE_PAYMENT_METHOD')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CONFIGURE_PAYMENT_METHOD', N'Phương thức thanh toán', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CONFIGURE_RENTAL_POLICY')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CONFIGURE_RENTAL_POLICY', N'Chính sách cho thuê', N'Contract and Payment');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'EXPORT_VAT_INVOICE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('EXPORT_VAT_INVOICE', N'Hoá đơn VAT', N'Contract and Payment');

    -- Handover and Return
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PROCESS_HANDOVER')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PROCESS_HANDOVER', N'Quy trình bàn giao xe', N'Handover and Return');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PROCESS_RETURN')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PROCESS_RETURN', N'Quy trình trả xe', N'Handover and Return');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'RECORD_ADDITIONAL_FEE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('RECORD_ADDITIONAL_FEE', N'Phí bổ sung', N'Handover and Return');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'SETTLE_DEPOSIT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('SETTLE_DEPOSIT', N'Thanh toán tiền gửi', N'Handover and Return');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_REVENUE_REPORT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_REVENUE_REPORT', N'Xem báo cáo doanh thu', N'Handover and Return');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_VEHICLE_UTILIZATION_REPORT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_VEHICLE_UTILIZATION_REPORT', N'Báo cáo sử dụng xe', N'Handover and Return');

    -- Vehicle Management
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_VEHICLE_CATALOG')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_VEHICLE_CATALOG', N'Xem danh mục xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_VEHICLE_DETAIL_CUSTOMER')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_VEHICLE_DETAIL_CUSTOMER', N'Xem chi tiết xe của khách hàng', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_VEHICLE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_VEHICLE', N'Xem xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'MONITOR_VEHICLE_STATUS')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('MONITOR_VEHICLE_STATUS', N'Giám sát tình trạng xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'RECORD_VEHICLE_MAINTENANCE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('RECORD_VEHICLE_MAINTENANCE', N'Ghi chép bảo dưỡng xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'SEARCH_VEHICLE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('SEARCH_VEHICLE', N'Tìm kiếm xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_VEHICLE_DETAIL_STAFF')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_VEHICLE_DETAIL_STAFF', N'Xem chi tiết xe của nhân viên', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'ADD_VEHICLE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('ADD_VEHICLE', N'Thêm xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'EDIT_VEHICLE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('EDIT_VEHICLE', N'Chỉnh sửa xe', N'Vehicle Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'DELETE_VEHICLE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('DELETE_VEHICLE', N'Xoá xe', N'Vehicle Management');

    -- Authentication & Profile Management
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'UPDATE_PROFILE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('UPDATE_PROFILE', N'Cập nhật hồ sơ', N'Authentication & Profile Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VERIFY_CUSTOMER_PROFILE')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VERIFY_CUSTOMER_PROFILE', N'Xác minh hồ sơ khách hàng', N'Authentication & Profile Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_USER_LIST')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_USER_LIST', N'Xem danh sách người dùng', N'Authentication & Profile Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'UPDATE_USER_ACCOUNT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('UPDATE_USER_ACCOUNT', N'Cập nhật tài khoản người dùng', N'Authentication & Profile Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'LOCK_USER_ACCOUNT')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('LOCK_USER_ACCOUNT', N'Khoá tài khoản người dùng', N'Authentication & Profile Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'CHANGE_PASSWORD')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('CHANGE_PASSWORD', N'Thay đổi mật khẩu', N'Authentication & Profile Management');

    -- Notification Management
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_NOTIFICATION')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_NOTIFICATION', N'Xem thông báo', N'Notification Management');
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'MARK_NOTIFICATION_AS_READ')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('MARK_NOTIFICATION_AS_READ', N'Đánh dấu thông báo đã đọc', N'Notification Management');

    -- Audit & Activity History
    IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_ACTIVITY_HISTORY')
        INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_ACTIVITY_HISTORY', N'Xem lịch sử hoạt động', N'Audit & Activity History');
END
GO

-- =========================================================================
-- GÁN QUYỀN MẶC ĐỊNH CHO CÁC VAI TRÒ (ROLE_PERMISSION MAP)
-- =========================================================================

-- Gán quyền cho Customer (chỉ chèn nếu chưa được gán)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[role_permission]') AND type in (N'U'))
BEGIN
    INSERT INTO role_permission (role_id, permission_id)
    SELECT r.role_id, p.permission_id
    FROM roles r, permission p
    WHERE r.role = N'CUSTOMER'
    AND p.permission_key IN (
        'CHECK_VEHICLE_AVAILABILITY', 'CREATE_BOOKING', 'VIEW_BOOKING', 'UPDATE_BOOKING', 
        'VIEW_VEHICLE_CATALOG', 'CANCEL_BOOKING', 'VIEW_BOOKINGS_POLICE', 'VIEW_CONTRACT', 
        'PROCESS_ELECTRONIC_SIGNATURE', 'GENERATE_PAYMENT_QR_CODE', 'VIEW_VEHICLE_DETAIL_CUSTOMER', 
        'SEARCH_VEHICLE', 'UPDATE_PROFILE', 'CHANGE_PASSWORD', 'VIEW_NOTIFICATION', 'MARK_NOTIFICATION_AS_READ'
    )
    AND NOT EXISTS (
        SELECT 1 FROM role_permission rp 
        WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
    );

    -- Gán quyền cho Staff
    INSERT INTO role_permission (role_id, permission_id)
    SELECT r.role_id, p.permission_id
    FROM roles r, permission p
    WHERE r.role = N'STAFF'
    AND p.permission_key IN (
        'CHECK_VEHICLE_AVAILABILITY', 'VIEW_BOOKING', 'VIEW_BOOKINGS_CALENDAR', 'PROCESS_BOOKING_REQUEST',
        'RECORD_VEHICLE_MAINTENANCE', 'VIEW_BOOKINGS_POLICE', 'PREPARE_CONTRACT', 'VIEW_CONTRACT', 
        'UPDATE_CONTRACT', 'PROCESS_ELECTRONIC_SIGNATURE', 'RECORD_PAYMENT', 'GENERATE_PAYMENT_QR_CODE', 
        'RECORD_REFUND', 'EXPORT_VAT_INVOICE', 'PROCESS_HANDOVER', 'PROCESS_RETURN', 
        'RECORD_ADDITIONAL_FEE', 'SETTLE_DEPOSIT', 'VIEW_REVENUE_REPORT', 'VIEW_VEHICLE_UTILIZATION_REPORT', 
        'MONITOR_VEHICLE_STATUS', 'RECORD_VEHICLE_MAINTENANCE', 'VIEW_VEHICLE_DETAIL_STAFF', 
        'VERIFY_CUSTOMER_PROFILE', 'CHANGE_PASSWORD', 'VIEW_NOTIFICATION', 'MARK_NOTIFICATION_AS_READ'
    )
    AND NOT EXISTS (
        SELECT 1 FROM role_permission rp 
        WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
    );

    -- Gán toàn bộ quyền cho Admin
    INSERT INTO role_permission (role_id, permission_id)
    SELECT r.role_id, p.permission_id
    FROM roles r, permission p
    WHERE r.role = N'ADMIN'
    AND NOT EXISTS (
        SELECT 1 FROM role_permission rp 
        WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
    );
END
GO
