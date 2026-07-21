-- Add staff_signed_at if it does not exist
IF COL_LENGTH('rental_contracts', 'staff_signed_at') IS NULL
BEGIN
    ALTER TABLE rental_contracts
    ADD staff_signed_at DATETIME2 NULL;
END;
GO

-- Add customer_signed_at if it does not exist
IF COL_LENGTH('rental_contracts', 'customer_signed_at') IS NULL
BEGIN
    ALTER TABLE rental_contracts
    ADD customer_signed_at DATETIME2 NULL;
END;
GO