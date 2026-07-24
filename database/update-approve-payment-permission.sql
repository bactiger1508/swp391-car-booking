-- update-approve-payment-permission.sql
USE CarRentalDB;
GO

-- 1. Insert APPROVE_PAYMENT permission if not exists
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'APPROVE_PAYMENT')
BEGIN
    INSERT INTO permission (permission_key, permission_name, functional_area)
    VALUES ('APPROVE_PAYMENT', N'Duyệt thanh toán/hoàn tiền', N'Contract and Payment');
END
GO

-- 2. Assign to ADMIN role
INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permission p
WHERE r.role = N'ADMIN' AND p.permission_key = 'APPROVE_PAYMENT'
AND NOT EXISTS (
    SELECT 1 FROM role_permission rp 
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
GO

-- 3. Assign to STAFF role
INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permission p
WHERE r.role = N'STAFF' AND p.permission_key = 'APPROVE_PAYMENT'
AND NOT EXISTS (
    SELECT 1 FROM role_permission rp 
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
GO

PRINT 'Successfully mapped APPROVE_PAYMENT permission to STAFF and ADMIN roles!';
GO
