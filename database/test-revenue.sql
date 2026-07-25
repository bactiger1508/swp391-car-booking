USE CarRentalDB;
GO

-- ============================================================
-- CLEANUP TEST DATA (To make the script fully re-runnable)
-- ============================================================
DELETE FROM reviews WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM vehicle_returns WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM vehicle_handovers WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM payments WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM rental_contracts WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM bookings WHERE booking_id BETWEEN 9 AND 18;
GO

-- ============================================================
-- THÁNG 7 (Bookings 9 to 13)
-- ============================================================
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, car_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
VALUES
(9, 3, 7 ,'2026-07-02','2026-07-05',N'Q1',N'Q1',5400000,1600000,'COMPLETED'),
(10, 4, 14,'2026-07-06','2026-07-08',N'Q1',N'Q1',4800000,1400000,'COMPLETED'),
(11, 3, 20,'2026-07-10','2026-07-13',N'Q7',N'Q7',8400000,2500000,'COMPLETED'),
(12, 4, 35,'2026-07-18','2026-07-22',N'Q1',N'Q1',9000000,2700000,'IN_PROGRESS'),
(13, 3, 33,'2026-07-24','2026-07-27',N'Q1',N'Q1',6000000,1800000,'IN_PROGRESS');

SET IDENTITY_INSERT bookings OFF;
GO

INSERT INTO payments
(booking_id, contract_id, amount, payment_type, payment_method, status, transaction_ref, paid_at, recorded_by)
VALUES
(9, NULL, 5400000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN7001', '2026-07-02', 2),
(10, NULL, 4800000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN7002', '2026-07-06', 2),
(11, NULL, 8400000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN7003', '2026-07-10', 2),
(12, NULL, 9000000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN7004', '2026-07-18', 2),
(13, NULL, 6000000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN7005', '2026-07-24', 2),

(9, NULL, 300000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN7011', '2026-07-05', 2),
(10, NULL, 500000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN7012', '2026-07-08', 2),
(11, NULL, 200000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN7013', '2026-07-13', 2),
(12, NULL, 700000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN7014', '2026-07-22', 2),
(13, NULL, 400000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN7015', '2026-07-27', 2);
GO


-- ============================================================
-- THÁNG 8 (Bookings 14 to 16)
-- ============================================================
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, car_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
VALUES
(14, 3, 22,'2026-08-02','2026-08-05',N'Q1',N'Q1',5000000,1500000,'COMPLETED'),
(15, 4, 23,'2026-08-07','2026-08-10',N'Q7',N'Q7',5600000,1700000,'IN_PROGRESS'),
(16, 3, 25,'2026-08-15','2026-08-18',N'Q1',N'Q1',6500000,1900000,'COMPLETED');

SET IDENTITY_INSERT bookings OFF;
GO

INSERT INTO payments
(booking_id, contract_id, amount, payment_type, payment_method, status, transaction_ref, paid_at, recorded_by)
VALUES
(14, NULL, 5000000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN8001', '2026-08-02', 2),
(15, NULL, 5600000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN8002', '2026-08-07', 2),
(16, NULL, 6500000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN8003', '2026-08-15', 2),

(14, NULL, 300000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN8011', '2026-08-05', 2),
(15, NULL, 200000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN8012', '2026-08-10', 2),
(16, NULL, 500000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN8013', '2026-08-18', 2);
GO


-- ============================================================
-- THÁNG 9 (Bookings 17 to 18)
-- ============================================================
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, car_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
VALUES
(17, 3, 31,'2026-09-03','2026-09-07',N'Q1',N'Q1',7000000,2100000,'IN_PROGRESS'),
(18, 4, 32,'2026-09-12','2026-09-15',N'Q7',N'Q7',4800000,1400000,'COMPLETED');

SET IDENTITY_INSERT bookings OFF;
GO

INSERT INTO payments
(booking_id, contract_id, amount, payment_type, payment_method, status, transaction_ref, paid_at, recorded_by)
VALUES
(17, NULL, 7000000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN9001', '2026-09-03', 2),
(18, NULL, 4800000, 'RENTAL', 'BANK_TRANSFER', 'COMPLETED', 'TXN9002', '2026-09-12', 2),

(17, NULL, 600000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN9011', '2026-09-07', 2),
(18, NULL, 100000, 'ADDITIONAL_FEE', 'BANK_TRANSFER', 'COMPLETED', 'TXN9012', '2026-09-15', 2);
GO

PRINT 'Revenue test data inserted successfully!';
GO