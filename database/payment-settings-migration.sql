-- ============================================================
-- Payment Methods & Settings — Migration
-- Run against CarRentalDB after schema and sample-data
-- ============================================================

USE CarRentalDB;
GO

-- ============================================================
-- PAYMENT CATEGORY — Payment Method Toggles
-- ============================================================
INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by)
VALUES
    (N'PAYMENT_METHOD_CASH_ENABLED',          N'true',  N'Cho phép thanh toán tiền mặt',                N'PAYMENT', 1),
    (N'PAYMENT_METHOD_BANK_TRANSFER_ENABLED', N'true',  N'Cho phép thanh toán chuyển khoản ngân hàng',  N'PAYMENT', 1),
    (N'PAYMENT_METHOD_CARD_ENABLED',          N'true',  N'Cho phép thanh toán thẻ tín dụng/ghi nợ',    N'PAYMENT', 1),
    (N'PAYMENT_METHOD_MOMO_ENABLED',          N'false', N'Cho phép thanh toán qua ví MoMo',             N'PAYMENT', 1),
    (N'PAYMENT_METHOD_VNPAY_ENABLED',         N'false', N'Cho phép thanh toán qua VNPay',               N'PAYMENT', 1),
    (N'PAYMENT_METHOD_ZALOPAY_ENABLED',       N'false', N'Cho phép thanh toán qua ZaloPay',             N'PAYMENT', 1);
GO

-- ============================================================
-- PAYMENT CATEGORY — Payment Process Settings
-- ============================================================
INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by)
VALUES
    (N'PAYMENT_GRACE_PERIOD_HOURS',   N'24',  N'Số giờ gia hạn thanh toán trước khi hủy đặt xe',   N'PAYMENT', 1),
    (N'PAYMENT_CURRENCY',             N'VND', N'Đơn vị tiền tệ sử dụng trong hệ thống',             N'PAYMENT', 1),
    (N'PAYMENT_PARTIAL_ALLOWED',      N'false',N'Cho phép thanh toán từng phần (không đủ 100%)',    N'PAYMENT', 1),
    (N'PAYMENT_AUTO_CONFIRM_AMOUNT',  N'0',   N'Ngưỡng tự động xác nhận thanh toán (0 = tắt)',      N'PAYMENT', 1),
    (N'BANK_ACCOUNT_NAME',            N'CÔNG TY TNHH CAR RENTAL',   N'Tên tài khoản ngân hàng',     N'PAYMENT', 1),
    (N'BANK_ACCOUNT_NUMBER',          N'1234567890',                 N'Số tài khoản ngân hàng',      N'PAYMENT', 1),
    (N'BANK_NAME',                    N'Vietcombank',                N'Tên ngân hàng',               N'PAYMENT', 1),
    (N'BANK_BRANCH',                  N'Chi nhánh TP.HCM',          N'Chi nhánh ngân hàng',         N'PAYMENT', 1);
GO

PRINT 'Payment settings migration completed!';
GO
