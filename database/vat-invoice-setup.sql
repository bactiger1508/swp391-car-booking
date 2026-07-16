-- ============================================================
-- VAT Invoice Setup & Test Data
-- Database: CarRentalDB
-- SQL Server (T-SQL)
-- ============================================================

USE CarRentalDB;
GO

-- 1. Create vat_invoices table if not exists
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[vat_invoices]') AND type in (N'U'))
BEGIN
    CREATE TABLE vat_invoices (
        invoice_id INT IDENTITY(1,1) PRIMARY KEY,
        contract_id INT NOT NULL UNIQUE,
        invoice_code NVARCHAR(50) NOT NULL UNIQUE,
        invoice_date DATETIME2 NOT NULL DEFAULT GETDATE(),
        invoice_status NVARCHAR(20) NOT NULL DEFAULT 'ISSUED',
        amount_before_tax DECIMAL(18,2) NOT NULL,
        tax_rate DECIMAL(5,2) NOT NULL,
        tax_amount DECIMAL(18,2) NOT NULL,
        total_amount DECIMAL(18,2) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_vat_invoices_contract FOREIGN KEY (contract_id) REFERENCES rental_contracts(contract_id)
    );
    PRINT 'Table vat_invoices created successfully!';
END
ELSE
BEGIN
    PRINT 'Table vat_invoices already exists.';
END
GO

-- 2. Insert Completed Booking for testing (if booking_id = 9 does not exist)
IF NOT EXISTS (SELECT 1 FROM bookings WHERE booking_id = 9)
BEGIN
    SET IDENTITY_INSERT bookings ON;
    INSERT INTO bookings (booking_id, customer_id, car_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status, approved_by, approved_at)
    VALUES (9, 3, 1, '2026-07-10 08:00:00', '2026-07-15 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 4000000.00, 1200000.00, N'COMPLETED', 2, '2026-07-09 10:00:00');
    SET IDENTITY_INSERT bookings OFF;
    PRINT 'Test Booking inserted successfully!';
END
GO

-- 3. Insert Completed Contract for testing (if contract_id = 9 does not exist)
IF NOT EXISTS (SELECT 1 FROM rental_contracts WHERE contract_id = 9)
BEGIN
    SET IDENTITY_INSERT rental_contracts ON;
    INSERT INTO rental_contracts (contract_id, booking_id, contract_number, customer_id, car_id, start_date, end_date, daily_rate, total_amount, deposit_amount, status, created_by, signed_at)
    VALUES (9, 9, N'CTR-2026-TEST9', 3, 1, '2026-07-10 08:00:00', '2026-07-15 08:00:00', 800000.00, 4000000.00, 1200000.00, N'COMPLETED', 2, '2026-07-10 07:30:00');
    SET IDENTITY_INSERT rental_contracts OFF;
    PRINT 'Test Contract inserted successfully!';
END
GO

-- 4. Insert Completed Payments (if not already present for booking_id = 9)
IF NOT EXISTS (SELECT 1 FROM payments WHERE booking_id = 9)
BEGIN
    INSERT INTO payments (booking_id, contract_id, amount, payment_type, payment_method, status, transaction_ref, paid_at, recorded_by)
    VALUES 
        (9, 9, 1200000.00, N'DEPOSIT', N'BANK_TRANSFER', N'COMPLETED', N'TXN-TEST-DEP9', '2026-07-09 11:00:00', 2),
        (9, 9, 2800000.00, N'RENTAL', N'BANK_TRANSFER', N'COMPLETED', N'TXN-TEST-RENT9', '2026-07-15 17:00:00', 2);
    PRINT 'Test Payments inserted successfully!';
END
GO
