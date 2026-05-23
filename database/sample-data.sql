-- ============================================================
-- Car Rental Management System — Sample Data
-- Database: CarRentalDB
-- ============================================================

USE CarRentalDB;
GO

-- ============================================================
-- USERS
-- Passwords are bcrypt hashed. Plain text password for ALL users is: password
-- ============================================================
SET IDENTITY_INSERT users ON;

INSERT INTO users (user_id, email, password_hash, full_name, phone, role, is_active)
VALUES
    (1, N'admin@carrental.com',    N'$2a$10$BTvczp4IUudpmprFZwTYU.Uu4wsDA88Jq.X6pnKgmTj14yI4y8ZES', N'Nguyễn Văn Admin',    N'0901234567', N'ADMIN',    1),
    (2, N'staff@carrental.com',    N'$2a$10$BTvczp4IUudpmprFZwTYU.Uu4wsDA88Jq.X6pnKgmTj14yI4y8ZES', N'Trần Thị Staff',     N'0912345678', N'STAFF',    1),
    (3, N'customer@carrental.com', N'$2a$10$BTvczp4IUudpmprFZwTYU.Uu4wsDA88Jq.X6pnKgmTj14yI4y8ZES', N'Lê Hoàng Customer',  N'0923456789', N'CUSTOMER', 1),
    (4, N'customer2@carrental.com',N'$2a$10$BTvczp4IUudpmprFZwTYU.Uu4wsDA88Jq.X6pnKgmTj14yI4y8ZES', N'Phạm Minh Khách',    N'0934567890', N'CUSTOMER', 1),
    (5, N'staff2@carrental.com',   N'$2a$10$BTvczp4IUudpmprFZwTYU.Uu4wsDA88Jq.X6pnKgmTj14yI4y8ZES', N'Võ Thị Nhân Viên',   N'0945678901', N'STAFF',    1);

SET IDENTITY_INSERT users OFF;
GO

-- ============================================================
-- CUSTOMER PROFILES
-- ============================================================
SET IDENTITY_INSERT customer_profiles ON;

INSERT INTO customer_profiles (profile_id, user_id, date_of_birth, address, id_card_number, driver_license_number, driver_license_expiry, verification_status, verified_by, verified_at)
VALUES
    (1, 3, '1995-06-15', N'123 Nguyễn Huệ, Quận 1, TP.HCM', N'079095001234', N'B2-012345', '2028-06-15', N'VERIFIED', 2, GETDATE()),
    (2, 4, '1998-03-20', N'456 Lê Lợi, Quận 3, TP.HCM',     N'079098002345', N'B2-023456', '2029-03-20', N'PENDING',  NULL, NULL);

SET IDENTITY_INSERT customer_profiles OFF;
GO

-- ============================================================
-- CARS
-- ============================================================
SET IDENTITY_INSERT cars ON;

INSERT INTO cars (car_id, license_plate, brand, model, year, color, seats, transmission, fuel_type, daily_rate, description, status, mileage, location, features)
VALUES
    (1, N'51A-12345', N'Toyota',   N'Vios',      2023, N'Trắng',  5, N'AUTOMATIC', N'GASOLINE', 800000.00,  N'Toyota Vios 2023, xe gia đình phổ biến, tiết kiệm nhiên liệu.',                    N'AVAILABLE',   15000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera lùi'),
    (2, N'51A-23456', N'Honda',    N'City',       2023, N'Đen',    5, N'AUTOMATIC', N'GASOLINE', 900000.00,  N'Honda City 2023, thiết kế thể thao, nội thất rộng rãi.',                           N'AVAILABLE',   12000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera lùi, Cảm biến va chạm'),
    (3, N'51A-34567', N'Hyundai',  N'Accent',     2022, N'Xám',    5, N'MANUAL',    N'GASOLINE', 700000.00,  N'Hyundai Accent 2022, giá tốt, phù hợp đi lại hàng ngày.',                         N'AVAILABLE',   20000, N'Chi nhánh Quận 7',  N'Bluetooth, USB'),
    (4, N'51A-45678', N'Mazda',    N'CX-5',       2023, N'Đỏ',     5, N'AUTOMATIC', N'GASOLINE', 1200000.00, N'Mazda CX-5 2023, SUV cao cấp, phù hợp gia đình và du lịch.',                       N'RENTED',      8000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Cảm biến va chạm, Ghế da'),
    (5, N'51A-56789', N'Kia',      N'Morning',    2022, N'Xanh',   4, N'AUTOMATIC', N'GASOLINE', 500000.00,  N'Kia Morning 2022, xe nhỏ gọn, phù hợp di chuyển nội thành.',                       N'MAINTENANCE', 30000, N'Chi nhánh Quận 7',  N'Bluetooth'),
    (6, N'51A-67890', N'Ford',     N'Ranger',     2023, N'Bạc',    5, N'AUTOMATIC', N'DIESEL',   1500000.00, N'Ford Ranger 2023, bán tải mạnh mẽ, phù hợp đi xa và off-road.',                    N'AVAILABLE',   5000,  N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Ghế da, 4WD'),
    (7, N'51A-78901', N'VinFast',  N'VF 8',       2024, N'Trắng',  5, N'AUTOMATIC', N'ELECTRIC', 1800000.00, N'VinFast VF 8 2024, SUV điện cao cấp, công nghệ hiện đại.',                          N'AVAILABLE',   2000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, ADAS, Ghế da, Sạc nhanh'),
    (8, N'51A-89012', N'Toyota',   N'Fortuner',   2022, N'Đen',    7, N'AUTOMATIC', N'DIESEL',   1400000.00, N'Toyota Fortuner 2022, SUV 7 chỗ, phù hợp gia đình lớn.',                           N'AVAILABLE',   18000, N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Ghế da');

SET IDENTITY_INSERT cars OFF;
GO

-- ============================================================
-- CAR IMAGES (sample image URLs — use placeholder paths)
-- ============================================================
INSERT INTO car_images (car_id, image_url, caption, is_primary, sort_order)
VALUES
    (1, N'/assets/images/cars/vios-front.jpg',     N'Mặt trước',  1, 1),
    (1, N'/assets/images/cars/vios-interior.jpg',  N'Nội thất',   0, 2),
    (2, N'/assets/images/cars/city-front.jpg',     N'Mặt trước',  1, 1),
    (3, N'/assets/images/cars/accent-front.jpg',   N'Mặt trước',  1, 1),
    (4, N'/assets/images/cars/cx5-front.jpg',      N'Mặt trước',  1, 1),
    (5, N'/assets/images/cars/morning-front.jpg',  N'Mặt trước',  1, 1),
    (6, N'/assets/images/cars/ranger-front.jpg',   N'Mặt trước',  1, 1),
    (7, N'/assets/images/cars/vf8-front.jpg',      N'Mặt trước',  1, 1),
    (8, N'/assets/images/cars/fortuner-front.jpg', N'Mặt trước',  1, 1);
GO

-- ============================================================
-- POLICY SETTINGS
-- ============================================================
INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by)
VALUES
    (N'LATE_FEE_PER_HOUR',          N'100000',  N'Phí trả trễ mỗi giờ (VND)',                              N'PENALTY',  1),
    (N'EXTRA_KM_FEE',               N'5000',    N'Phí vượt km mỗi km (VND)',                                N'PENALTY',  1),
    (N'MAX_BOOKING_DAYS',           N'30',      N'Số ngày đặt xe tối đa',                                   N'BOOKING',  1),
    (N'MIN_BOOKING_HOURS',          N'24',      N'Số giờ đặt xe tối thiểu',                                 N'BOOKING',  1),
    (N'DEPOSIT_PERCENTAGE',         N'30',      N'Phần trăm đặt cọc (%)',                                   N'PRICING',  1),
    (N'CLEANING_FEE',               N'200000',  N'Phí vệ sinh xe (VND)',                                    N'PENALTY',  1),
    (N'TAX_RATE',                   N'10',      N'Thuế suất VAT (%)',                                       N'TAX',      1),
    (N'COMPANY_NAME',               N'Car Rental Co.', N'Tên công ty trên hóa đơn',                         N'TAX',      1),
    (N'COMPANY_TAX_ID',             N'0123456789',     N'Mã số thuế công ty',                                N'TAX',      1),
    (N'COMPANY_ADDRESS',            N'123 Nguyễn Huệ, Quận 1, TP.HCM', N'Địa chỉ công ty trên hóa đơn',   N'TAX',      1),
    (N'KM_LIMIT_PER_DAY',           N'300',     N'Giới hạn km mỗi ngày',                                    N'BOOKING',  1),
    (N'CANCELLATION_FEE_PERCENTAGE',N'10',      N'Phần trăm phí hủy đặt xe (%)',                            N'PENALTY',  1);
GO

-- ============================================================
-- SAMPLE BOOKINGS
-- ============================================================
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings (booking_id, customer_id, car_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status, approved_by, approved_at)
VALUES
    (1, 3, 4, '2026-05-20 08:00:00', '2026-05-25 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 6000000.00, 1800000.00, N'IN_PROGRESS', 2, '2026-05-19 14:00:00'),
    (2, 3, 1, '2026-06-01 08:00:00', '2026-06-03 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 1600000.00, 480000.00,  N'CONFIRMED',   2, '2026-05-22 10:00:00'),
    (3, 4, 2, '2026-06-05 08:00:00', '2026-06-07 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 7', 1800000.00, 540000.00,  N'PENDING',     NULL, NULL);

SET IDENTITY_INSERT bookings OFF;
GO

-- ============================================================
-- SAMPLE CONTRACT (for the in-progress booking)
-- ============================================================
SET IDENTITY_INSERT rental_contracts ON;

INSERT INTO rental_contracts (contract_id, booking_id, contract_number, customer_id, car_id, start_date, end_date, daily_rate, total_amount, deposit_amount, status, created_by, signed_at)
VALUES
    (1, 1, N'CTR-2026-0001', 3, 4, '2026-05-20 08:00:00', '2026-05-25 08:00:00', 1200000.00, 6000000.00, 1800000.00, N'ACTIVE', 2, '2026-05-20 07:30:00');

SET IDENTITY_INSERT rental_contracts OFF;
GO

-- ============================================================
-- SAMPLE PAYMENTS
-- ============================================================
INSERT INTO payments (booking_id, contract_id, amount, payment_type, payment_method, status, transaction_ref, paid_at, recorded_by)
VALUES
    (1, 1, 1800000.00, N'DEPOSIT', N'BANK_TRANSFER', N'COMPLETED', N'TXN-20260520-001', '2026-05-19 15:00:00', 2);
GO

-- ============================================================
-- SAMPLE HANDOVER
-- ============================================================
INSERT INTO vehicle_handovers (booking_id, contract_id, car_id, handover_date, mileage_at_handover, fuel_level, exterior_condition, interior_condition, notes, handed_by, received_by)
VALUES
    (1, 1, 4, '2026-05-20 08:00:00', 8000, N'FULL', N'Tình trạng tốt, không trầy xước', N'Sạch sẽ, đầy đủ phụ kiện', N'Đã kiểm tra và bàn giao xe', 2, 3);
GO

PRINT 'Sample data inserted successfully!';
GO
