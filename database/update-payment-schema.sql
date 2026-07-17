-- 1. Update payments table schema to support overpayment/underpayment tracking
IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('payments') AND name = 'amount_paid'
)
BEGIN
    ALTER TABLE payments ADD amount_paid DECIMAL(18,2) NULL;
END
GO

-- Update existing completed payments to default amount_paid if null
UPDATE payments 
SET amount_paid = amount 
WHERE amount_paid IS NULL AND status = 'COMPLETED';
GO

-- 2. Configure bank account and webhook policies
IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'BANK_ACCOUNT_NAME')
    UPDATE policy_settings SET policy_value = N'NGUYEN LAM TUNG' WHERE policy_key = 'BANK_ACCOUNT_NAME';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'BANK_ACCOUNT_NAME', N'NGUYEN LAM TUNG', N'Tên tài khoản ngân hàng', N'PAYMENT', 1);

IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'BANK_ACCOUNT_NUMBER')
    UPDATE policy_settings SET policy_value = N'00000104077' WHERE policy_key = 'BANK_ACCOUNT_NUMBER';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'BANK_ACCOUNT_NUMBER', N'00000104077', N'Số tài khoản ngân hàng', N'PAYMENT', 1);

IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'BANK_NAME')
    UPDATE policy_settings SET policy_value = N'TPBank' WHERE policy_key = 'BANK_NAME';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'BANK_NAME', N'TPBank', N'Tên ngân hàng', N'PAYMENT', 1);

IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'BANK_BRANCH')
    UPDATE policy_settings SET policy_value = N'Chi nhánh Hà Nội' WHERE policy_key = 'BANK_BRANCH';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'BANK_BRANCH', N'Chi nhánh Hà Nội', N'Chi nhánh ngân hàng', N'PAYMENT', 1);

IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'WEBHOOK_PROVIDER')
    UPDATE policy_settings SET policy_value = N'SEPAY' WHERE policy_key = 'WEBHOOK_PROVIDER';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'WEBHOOK_PROVIDER', N'SEPAY', N'Nhà cung cấp dịch vụ Webhook thanh toán (SEPAY, CASSO, PAYOS)', N'PAYMENT', 1);

IF EXISTS (SELECT 1 FROM policy_settings WHERE policy_key = 'WEBHOOK_SECRET')
    UPDATE policy_settings SET policy_value = N'CRS' WHERE policy_key = 'WEBHOOK_SECRET';
ELSE
    INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by) 
    VALUES (N'WEBHOOK_SECRET', N'CRS', N'Khóa bảo mật để xác thực request webhook từ provider', N'PAYMENT', 1);
GO
