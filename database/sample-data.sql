-- ============================================================
-- Vehicle Rental Management System — Sample Data
-- Database: CarRentalDB
-- NOTE: Run schema.sql FIRST before running this file.
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
-- VEHICLE BRANDS
-- ============================================================
SET IDENTITY_INSERT vehicle_brands ON;

INSERT INTO vehicle_brands (brand_id, brand_name)
VALUES
    (1, N'Toyota'),
    (2, N'Honda'),
    (3, N'Hyundai'),
    (4, N'Mazda'),
    (5, N'Kia'),
    (6, N'Ford'),
    (7, N'VinFast'),
    (8, N'Mercedes'),
    (9, N'Mitsubishi'),
    (10, N'Suzuki'),
    (11, N'BMW');

SET IDENTITY_INSERT vehicle_brands OFF;
GO

-- ============================================================
-- VEHICLE MODELS
-- ============================================================
SET IDENTITY_INSERT vehicle_models ON;

INSERT INTO vehicle_models (model_id, brand_id, model_name)
VALUES
    (1, 1, N'Vios'),
    (2, 2, N'City'),
    (3, 3, N'Accent'),
    (4, 4, N'CX-5'),
    (5, 5, N'Morning'),
    (6, 6, N'Ranger'),
    (7, 7, N'VF 8'),
    (8, 1, N'Fortuner'),
    (9, 7, N'VF 5'),
    (10, 7, N'VF e34'),
    (11, 7, N'VF 9'),
    (12, 7, N'VF 8 Plus'),
    (13, 1, N'Camry'),
    (14, 3, N'Santa Fe'),
    (15, 5, N'Cerato'),
    (16, 8, N'C200'),
    (17, 9, N'Xpander'),
    (18, 10, N'Ertiga'),
    (19, 11, N'320i'),
    (20, 5, N'Carnival'),
    (21, 3, N'Tucson'),
    (22, 4, N'CX-8'),
    (23, 1, N'Innova'),
    (24, 2, N'CR-V'),
    (25, 7, N'VF 6'),
    (26, 6, N'Everest'),
    (27, 3, N'Stargazer'),
    (28, 1, N'Veloz'),
    (29, 5, N'Seltos'),
    (30, 3, N'Custin'),
    (31, 4, N'3'),
    (32, 7, N'VF 7'),
    (33, 1, N'Cross'),
    (34, 6, N'Explorer'),
    (35, 8, N'GLC 300');

SET IDENTITY_INSERT vehicle_models OFF;
GO

-- ============================================================
-- VEHICLES
-- ============================================================
SET IDENTITY_INSERT vehicles ON;

INSERT INTO vehicles (vehicle_id, license_plate, model_id, year, color, seats, transmission, fuel_type, daily_rate, description, status, mileage, location, features)
VALUES
    (1, N'51A-12345', 1,  2023, N'Trắng',  5, N'AUTOMATIC', N'GASOLINE', 800000.00,  N'Toyota Vios 2023, xe gia đình phổ biến, tiết kiệm nhiên liệu.',                    N'AVAILABLE',   15000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera lùi'),
    (2, N'51A-23456', 2,  2023, N'Đen',    5, N'AUTOMATIC', N'GASOLINE', 900000.00,  N'Honda City 2023, thiết kế thể thao, nội thất rộng rãi.',                           N'AVAILABLE',   12000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera lùi, Cảm biến va chạm'),
    (3, N'51A-34567', 3,  2022, N'Xám',    5, N'MANUAL',    N'GASOLINE', 700000.00,  N'Hyundai Accent 2022, giá tốt, phù hợp đi lại hàng ngày.',                         N'AVAILABLE',   20000, N'Chi nhánh Quận 7',  N'Bluetooth, USB'),
    (4, N'51A-45678', 4,  2023, N'Đỏ',     5, N'AUTOMATIC', N'GASOLINE', 1200000.00, N'Mazda CX-5 2023, SUV cao cấp, phù hợp gia đình và du lịch.',                       N'RENTED',      8000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Cảm biến va chạm, Ghế da'),
    (5, N'51A-56789', 5,  2022, N'Xanh',   4, N'AUTOMATIC', N'GASOLINE', 500000.00,  N'Kia Morning 2022, xe nhỏ gọn, phù hợp di chuyển nội thành.',                       N'MAINTENANCE', 30000, N'Chi nhánh Quận 7',  N'Bluetooth'),
    (6, N'51A-67890', 6,  2023, N'Bạc',    5, N'AUTOMATIC', N'DIESEL',   1500000.00, N'Ford Ranger 2023, bán tải mạnh mẽ, phù hợp đi xa và off-road.',                    N'AVAILABLE',   5000,  N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Ghế da, 4WD'),
    (7, N'51A-78901', 7,  2024, N'Trắng',  5, N'AUTOMATIC', N'ELECTRIC', 1800000.00, N'VinFast VF 8 2024, SUV điện cao cấp, công nghệ hiện đại.',                          N'AVAILABLE',   2000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, ADAS, Ghế da, Sạc nhanh'),
    (8, N'51A-89012', 8,  2022, N'Đen',    7, N'AUTOMATIC', N'DIESEL',   1400000.00, N'Toyota Fortuner 2022, SUV 7 chỗ, phù hợp gia đình lớn.',                           N'AVAILABLE',   18000, N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Ghế da'),
    (9, N'51G-111.11', 9,  2023, N'Xanh',   5, N'AUTOMATIC', N'ELECTRIC', 900000.00,  N'VinFast VF 5 Plus 2023, xe điện thông minh, linh hoạt.',                           N'AVAILABLE',   5000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Cảm biến lùi'),
    (10, N'51G-222.22', 10, 2023, N'Xanh',   5, N'AUTOMATIC', N'ELECTRIC', 1200000.00, N'VinFast VF e34 2023, xe điện tiện dụng, trợ lý ảo thông minh.',                  N'AVAILABLE',   9000,  N'Chi nhánh Quận 7',  N'GPS, Bluetooth, Camera 360'),
    (11, N'51G-333.33', 11, 2024, N'Đen',    7, N'AUTOMATIC', N'ELECTRIC', 2500000.00, N'VinFast VF 9 2024, SUV điện cỡ lớn, siêu sang trọng, công nghệ tối tân.',             N'AVAILABLE',   1000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, ADAS, Ghế mát-xa'),
    (12, N'51G-444.44', 12, 2024, N'Xám',    5, N'AUTOMATIC', N'ELECTRIC', 2000000.00, N'VinFast VF 8 Plus 2024, phiên bản thể thao nâng cấp của VF 8.',                    N'AVAILABLE',   3000,  N'Chi nhánh Cầu Giấy', N'GPS, Bluetooth, Camera 360, ADAS, Cửa sổ trời'),
    (13, N'51G-555.55', 1,  2022, N'Bạc',    5, N'AUTOMATIC', N'GASOLINE', 800000.00,  N'Toyota Vios 2022, xe gia đình bền bỉ, tiết kiệm xăng tốt.',                        N'AVAILABLE',   22000, N'Chi nhánh Quận 7',  N'Bluetooth, USB, Camera lùi'),
    (14, N'51G-666.66', 13, 2023, N'Đen',    5, N'AUTOMATIC', N'GASOLINE', 1600000.00, N'Toyota Camry 2.0Q 2023, sedan hạng D sang trọng, êm ái.',                            N'AVAILABLE',   7000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Ghế điện'),
    (15, N'51G-777.77', 14, 2023, N'Trắng',  7, N'AUTOMATIC', N'DIESEL',   1500000.00, N'Hyundai Santa Fe 2023, xe SUV 7 chỗ đa dụng gia đình.',                             N'AVAILABLE',   11000, N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Ghế sưởi, Camera 360'),
    (16, N'51G-888.88', 15, 2022, N'Trắng',  5, N'AUTOMATIC', N'GASOLINE', 950000.00,  N'Kia Cerato 2022, kiểu dáng trẻ trung, hiện đại.',                                  N'AVAILABLE',   16000, N'Chi nhánh Quận 7',  N'Bluetooth, Camera lùi, Cửa sổ trời'),
    (17, N'51G-999.99', 16, 2023, N'Đen',    5, N'AUTOMATIC', N'GASOLINE', 2200000.00, N'Mercedes-Benz C200 Avantgarde sang trọng, lịch lãm.',                      N'AVAILABLE',   9500,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Ghế da, Phanh tự động'),
    (18, N'51H-123.45', 17, 2023, N'Trắng',  7, N'AUTOMATIC', N'GASOLINE', 950000.00,  N'Mitsubishi Xpander 2023, dòng MPV 7 chỗ bán chạy nhất, cực kỳ tiết kiệm.',        N'AVAILABLE',   16000, N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Apple CarPlay'),
    (19, N'51H-234.56', 18, 2022, N'Bạc',    7, N'AUTOMATIC', N'HYBRID',   850000.00,  N'Suzuki Ertiga Hybrid 2022, MPV 7 chỗ tiết kiệm nhiên liệu tối ưu.',               N'AVAILABLE',   24000, N'Chi nhánh Quận 7',  N'Bluetooth, USB, Cảm biến lùi'),
    (20, N'51H-345.67', 19, 2023, N'Đỏ',     5, N'AUTOMATIC', N'GASOLINE', 2800000.00, N'BMW 320i Sport Line 2023, sedan hạng sang lái thể thao, đẳng cấp.',             N'AVAILABLE',   6000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Live Cockpit, Ghế da'),
    (21, N'51H-456.78', 20, 2023, N'Đen',    7, N'AUTOMATIC', N'DIESEL',   2200000.00, N'Kia Carnival 2023, xe MPV cỡ lớn cao cấp, siêu rộng rãi cho gia đình.',           N'AVAILABLE',   12000, N'Chi nhánh Quận 7',  N'GPS, Bluetooth, Camera 360, Cửa lùa điện, Ghế VIP'),
    (22, N'51H-567.89', 21, 2023, N'Trắng',  5, N'AUTOMATIC', N'GASOLINE', 1100000.00, N'Hyundai Tucson 2023, thiết kế hiện đại, nhiều tính năng an toàn.',                 N'AVAILABLE',   8000,  N'Chi nhánh Quận 7',  N'GPS, Bluetooth, Camera lùi, Sạc không dây'),
    (23, N'51H-678.90', 22, 2022, N'Xám',    7, N'AUTOMATIC', N'GASOLINE', 1400000.00, N'Mazda CX-8 2022, SUV 7 chỗ sang trọng, cách âm tốt, động cơ êm ái.',            N'AVAILABLE',   18000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, HUD, Hàng ghế 2 sưởi'),
    (24, N'51H-789.01', 23, 2023, N'Đồng',   7, N'MANUAL',    N'GASOLINE', 900000.00,  N'Toyota Innova 2023, xe 7 chỗ bền bỉ rộng rãi, phù hợp đi tỉnh.',                  N'AVAILABLE',   35000, N'Chi nhánh Thủ Đức', N'Bluetooth, Camera lùi, Điều hòa 2 giàn'),
    (25, N'51H-890.12', 24, 2023, N'Đen',    7, N'AUTOMATIC', N'GASOLINE', 1300000.00, N'Honda CR-V 2023, SUV 7 chỗ linh hoạt với gói an toàn Honda Sensing.',            N'AVAILABLE',   10000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera lùi, Honda Sensing, Ghế da'),
    (26, N'51K-111.22', 25, 2024, N'Đỏ',     5, N'AUTOMATIC', N'ELECTRIC', 1100000.00, N'VinFast VF 6 Plus 2024, SUV điện cỡ B thời thượng, thông minh.',                  N'AVAILABLE',   1500,  N'Chi nhánh Quận 7',  N'GPS, Bluetooth, ADAS, Trợ lý ảo'),
    (27, N'51K-222.33', 26, 2024, N'Đen',    7, N'AUTOMATIC', N'DIESEL',   1800000.00, N'Ford Ranger Everest Titanium 2024, SUV 7 chỗ off-road đỉnh cao.',                 N'AVAILABLE',   3000,  N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera 360, Cửa sổ trời toàn cảnh'),
    (28, N'51K-333.44', 27, 2023, N'Bạc',    7, N'AUTOMATIC', N'GASOLINE', 800000.00,  N'Hyundai Stargazer 2023, xe MPV gia đình tiện dụng, giá thuê hợp lý.',             N'AVAILABLE',   14000, N'Chi nhánh Thủ Đức', N'Bluetooth, Apple CarPlay, Camera lùi'),
    (29, N'51K-444.55', 28, 2023, N'Trắng',  7, N'AUTOMATIC', N'GASOLINE', 1000000.00, N'Toyota Veloz Cross 2023, xe 7 chỗ đa dụng hiện đại và tiết kiệm.',              N'AVAILABLE',   13000, N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Sạc không dây, Camera 360'),
    (30, N'51K-555.66', 29, 2023, N'Vàng',   5, N'AUTOMATIC', N'GASOLINE', 950000.00,  N'Kia Seltos 2023, SUV đô thị cá tính, tầm quan sát tốt.',                          N'AVAILABLE',   17000, N'Chi nhánh Quận 7',  N'Bluetooth, Camera lùi, Ghế thông gió'),
    (31, N'51K-666.77', 30, 2023, N'Trắng',  7, N'AUTOMATIC', N'GASOLINE', 1600000.00, N'Hyundai Custin 2023, dòng MPV trung cao cấp cửa lùa tự động cực kỳ tiện nghi.',      N'AVAILABLE',   9000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Cửa lùa điện, Hàng ghế 2 thương gia'),
    (32, N'51K-777.88', 31, 2023, N'Đỏ',     5, N'AUTOMATIC', N'GASOLINE', 900000.00,  N'Mazda 3 Premium 2023, sedan hạng C sang trọng, thiết kế Kodo quyến rũ.',           N'AVAILABLE',   11000, N'Chi nhánh Quận 7',  N'GPS, Bluetooth, Camera lùi, Ghế da, HUD'),
    (33, N'51K-888.99', 32, 2024, N'Xanh',   5, N'AUTOMATIC', N'ELECTRIC', 1500000.00, N'VinFast VF 7 Plus 2024, SUV điện phân khúc C thể thao, mạnh mẽ.',                  N'AVAILABLE',   1000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, ADAS'),
    (34, N'51K-999.00', 33, 2023, N'Xám',    5, N'AUTOMATIC', N'HYBRID',   1100000.00, N'Toyota Corolla Cross 1.8V 2023, SUV đô thị tiết kiệm xăng và êm ái.',                 N'AVAILABLE',   12000, N'Chi nhánh Thủ Đức', N'GPS, Bluetooth, Camera lùi, Ghế da'),
    (35, N'51L-001.23', 34, 2023, N'Trắng',  7, N'AUTOMATIC', N'GASOLINE', 3000000.00, N'Ford Explorer Limited 2023, SUV cỡ lớn cao cấp nhập Mỹ, đầy uy lực.',                N'AVAILABLE',   15000, N'Chi nhánh Cầu Giấy', N'GPS, Bluetooth, Camera 360, Ghế mát-xa, Cửa sổ trời'),
    (36, N'51L-012.34', 35, 2023, N'Đỏ',     5, N'AUTOMATIC', N'GASOLINE', 3500000.00, N'Mercedes GLC 300 4MATIC 2023, SUV sang trọng bán chạy hàng đầu.',                   N'AVAILABLE',   8000,  N'Chi nhánh Quận 1',  N'GPS, Bluetooth, Camera 360, Loa Burmester, Ghế da nâng điện');

SET IDENTITY_INSERT vehicles OFF;
GO

-- ============================================================
-- VEHICLE IMAGES (sample image URLs)
-- ============================================================
INSERT INTO vehicle_images (vehicle_id, image_url, caption, is_primary, sort_order)
VALUES
    (1, N'/assets/images/vehicles/vios-front.jpg',     N'Mặt trước',  1, 1),
    (1, N'/assets/images/vehicles/vios-interior.jpg',  N'Nội thất',   0, 2),
    (2, N'/assets/images/vehicles/city-front.jpg',     N'Mặt trước',  1, 1),
    (3, N'/assets/images/vehicles/accent-front.jpg',   N'Mặt trước',  1, 1),
    (4, N'/assets/images/vehicles/cx5-front.jpg',      N'Mặt trước',  1, 1),
    (5, N'/assets/images/vehicles/morning-front.jpg',  N'Mặt trước',  1, 1),
    (6, N'/assets/images/vehicles/ranger-front.jpg',   N'Mặt trước',  1, 1),
    (7, N'/assets/images/vehicles/vf8-front.jpg',      N'Mặt trước',  1, 1),
    (8, N'/assets/images/vehicles/fortuner-front.jpg', N'Mặt trước',  1, 1),
    (9, N'/assets/images/vehicles/vf5-front.jpg',      N'Mặt trước',  1, 1),
    (10, N'/assets/images/vehicles/vfe34-front.jpg',   N'Mặt trước',  1, 1),
    (11, N'/assets/images/vehicles/vf9-front.jpg',     N'Mặt trước',  1, 1),
    (12, N'/assets/images/vehicles/vf8plus-front.jpg', N'Mặt trước',  1, 1),
    (13, N'/assets/images/vehicles/vios-front2.jpg',   N'Mặt trước',  1, 1),
    (14, N'/assets/images/vehicles/camry-front.jpg',   N'Mặt trước',  1, 1),
    (15, N'/assets/images/vehicles/santafe-front.jpg', N'Mặt trước',  1, 1),
    (16, N'/assets/images/vehicles/cerato-front.jpg',  N'Mặt trước',  1, 1),
    (17, N'/assets/images/vehicles/c200-front.jpg',    N'Mặt trước',  1, 1),
    (18, N'/assets/images/vehicles/xpander-front.jpg', N'Mặt trước',  1, 1),
    (19, N'/assets/images/vehicles/ertiga-front.jpg',  N'Mặt trước',  1, 1),
    (20, N'/assets/images/vehicles/320i-front.jpg',    N'Mặt trước',  1, 1),
    (21, N'/assets/images/vehicles/carnival-front.jpg', N'Mặt trước', 1, 1),
    (22, N'/assets/images/vehicles/tucson-front.jpg',  N'Mặt trước',  1, 1),
    (23, N'/assets/images/vehicles/cx8-front.jpg',     N'Mặt trước',  1, 1),
    (24, N'/assets/images/vehicles/innova-front.jpg',  N'Mặt trước',  1, 1),
    (25, N'/assets/images/vehicles/crv-front.jpg',     N'Mặt trước',  1, 1),
    (26, N'/assets/images/vehicles/vf6-front.jpg',     N'Mặt trước',  1, 1),
    (27, N'/assets/images/vehicles/everest-front.jpg', N'Mặt trước',  1, 1),
    (28, N'/assets/images/vehicles/stargazer-front.jpg', N'Mặt trước', 1, 1),
    (29, N'/assets/images/vehicles/veloz-front.jpg',   N'Mặt trước',  1, 1),
    (30, N'/assets/images/vehicles/seltos-front.jpg',  N'Mặt trước',  1, 1),
    (31, N'/assets/images/vehicles/custin-front.jpg',  N'Mặt trước',  1, 1),
    (32, N'/assets/images/vehicles/mazda3-front.jpg',  N'Mặt trước',  1, 1),
    (33, N'/assets/images/vehicles/vf7-front.jpg',     N'Mặt trước',  1, 1),
    (34, N'/assets/images/vehicles/corollacross-front.jpg', N'Mặt trước', 1, 1),
    (35, N'/assets/images/vehicles/explorer-front.jpg', N'Mặt trước', 1, 1),
    (36, N'/assets/images/vehicles/glc300-front.jpg',  N'Mặt trước',  1, 1);
GO

-- ============================================================
-- MAINTENANCE SCHEDULES
-- ============================================================
INSERT INTO maintenance_schedules (vehicle_id, maintenance_type, scheduled_date, status, description, cost, notes, created_by)
VALUES
    (5, N'OIL_CHANGE',   CAST(GETDATE() AS DATE),              N'SCHEDULED', N'Thay dầu động cơ và lọc dầu',           1500000.00, N'Xe đang ở trạng thái bảo trì', N'staff@carrental.com'),
    (4, N'INSPECTION',   DATEADD(DAY, 14, CAST(GETDATE() AS DATE)), N'SCHEDULED', N'Kiểm tra định kỳ sau chuyến thuê',  500000.00,  NULL, N'staff@carrental.com'),
    (1, N'TIRE_CHANGE',  DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), N'SCHEDULED', N'Thay lốp trước mùa mưa',            3000000.00, NULL, N'staff@carrental.com'),
    (17, N'OIL_CHANGE',   CAST(GETDATE() AS DATE),              N'SCHEDULED', N'Thay nhớt định kỳ C200',                1800000.00, NULL, N'staff@carrental.com'),
    (21, N'REPAIR',       DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), N'SCHEDULED', N'Bảo dưỡng hệ thống điện và cửa lùa', 2500000.00, NULL, N'staff@carrental.com'),
    (26, N'INSPECTION',   DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), N'SCHEDULED', N'Kiểm tra định kỳ pin và ADAS',     800000.00,  NULL, N'staff@carrental.com');
GO

-- ============================================================
-- POLICY SETTINGS
-- ============================================================
INSERT INTO policy_settings (policy_key, policy_value, description, category, updated_by)
VALUES
    (N'LATE_FEE_PER_HOUR',          N'100000',  N'Phí trả trễ mỗi giờ (VND)',                              N'PENALTY',  1),
    (N'EXTRA_KM_FEE',               N'4000',    N'Phí vượt km mỗi km (VND)',                                N'PENALTY',  1),
    (N'MAX_BOOKING_DAYS',           N'30',      N'Số ngày đặt xe tối đa',                                   N'BOOKING',  1),
    (N'MIN_BOOKING_HOURS',          N'24',      N'Số giờ đặt xe tối thiểu',                                 N'BOOKING',  1),
    (N'DEPOSIT_PERCENTAGE',         N'30',      N'Phần trăm đặt cọc (%)',                                   N'PRICING',  1),
    (N'CLEANING_FEE',               N'200000',  N'Phí vệ sinh xe (VND)',                                    N'PENALTY',  1),
    (N'TAX_RATE',                   N'10',      N'Thuế suất VAT (%)',                                       N'TAX',      1),
    (N'COMPANY_NAME',               N'Car Rental Co.', N'Tên công ty trên hóa đơn',                         N'TAX',      1),
    (N'COMPANY_TAX_ID',             N'0123456789',     N'Mã số thuế công ty',                                N'TAX',      1),
    (N'COMPANY_ADDRESS',            N'123 Nguyễn Huệ, Quận 1, TP.HCM', N'Địa chỉ công ty trên hóa đơn',   N'TAX',      1),
    (N'KM_LIMIT_PER_DAY',           N'300',     N'Giới hạn km mỗi ngày',                                    N'BOOKING',  1),
    (N'TRIP_KM_LIMIT',              N'150',     N'Giới hạn km cho gói thuê theo chuyến',                    N'BOOKING',  1),
    (N'COMBO_7_KM_LIMIT',           N'1500',    N'Giới hạn km cho gói Combo 7 ngày',                        N'BOOKING',  1),
    (N'COMBO_10_KM_LIMIT',          N'2000',    N'Giới hạn km cho gói Combo 10 ngày',                       N'BOOKING',  1),
    (N'COMBO_30_KM_LIMIT',          N'5000',    N'Giới hạn km cho gói Combo 30 ngày',                       N'BOOKING',  1),
    (N'DELIVERY_FEE_PER_KM',        N'15000',   N'Phí giao xe tận nơi cho mỗi km (VND)',                    N'PRICING',  1),
    (N'DISCOUNT_SHORT_TIER',        N'5',       N'Phần trăm chiết khấu cho thuê từ 5 - 9 ngày (%)',         N'PRICING',  1),
    (N'DISCOUNT_MEDIUM_TIER',       N'10',      N'Phần trăm chiết khấu cho thuê từ 10 - 29 ngày (%)',       N'PRICING',  1),
    (N'DISCOUNT_LONG_TIER',          N'20',      N'Phần trăm chiết khấu cho thuê từ 30 ngày trở lên (%)',    N'PRICING',  1),
    (N'LOW_MILEAGE_DISCOUNT_PERCENT',N'5',      N'Phần trăm chiết khấu hao xe thấp (%)',                    N'PRICING',  1),
    (N'COMBO_7_DISCOUNT_PERCENT',   N'15',      N'Phần trăm chiết khấu cho gói Combo 7 ngày (%)',           N'PRICING',  1),
    (N'COMBO_10_DISCOUNT_PERCENT',  N'20',      N'Phần trăm chiết khấu cho gói Combo 10 ngày (%)',          N'PRICING',  1),
    (N'COMBO_30_DISCOUNT_PERCENT',  N'30',      N'Phần trăm chiết khấu cho gói Combo 30 ngày (%)',          N'PRICING',  1),
    -- Lunar New Year surcharge configuration
    (N'TET_START_DATE',             N'2026-02-12',N'Ngày bắt đầu áp dụng giá Tết Nguyên Đán (YYYY-MM-DD)',  N'PRICING',  1),
    (N'TET_END_DATE',               N'2026-02-22',N'Ngày kết thúc áp dụng giá Tết Nguyên Đán (YYYY-MM-DD)', N'PRICING',  1),
    (N'TET_SURCHARGE_PERCENT',      N'20',      N'Phần trăm phụ thu dịp Tết Nguyên Đán (%)',                N'PRICING',  1),
    -- Payment settings
    (N'PAYMENT_METHOD_CASH_ENABLED',          N'true',  N'Cho phép thanh toán tiền mặt',                N'PAYMENT', 1),
    (N'PAYMENT_METHOD_BANK_TRANSFER_ENABLED', N'true',  N'Cho phép thanh toán chuyển khoản ngân hàng',  N'PAYMENT', 1),
    -- Bank account settings
    (N'BANK_ACCOUNT_NAME',            N'NGUYEN LAM TUNG',    N'Tên tài khoản ngân hàng',             N'PAYMENT', 1),
    (N'BANK_ACCOUNT_NUMBER',          N'00000104077',         N'Số tài khoản ngân hàng',              N'PAYMENT', 1),
    (N'BANK_NAME',                    N'TPBank',              N'Tên ngân hàng',                       N'PAYMENT', 1),
    (N'BANK_BRANCH',                  N'Chi nhánh Hà Nội',   N'Chi nhánh ngân hàng',                 N'PAYMENT', 1);
GO

-- ============================================================
-- SAMPLE BOOKINGS
-- ============================================================
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings (booking_id, customer_id, vehicle_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status, approved_by, approved_at)
VALUES
    (1, 3, 4, '2026-05-20 08:00:00', '2026-05-25 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 6000000.00, 1800000.00, N'IN_PROGRESS', 2, '2026-05-19 14:00:00'),
    (2, 3, 1, '2026-06-01 08:00:00', '2026-06-03 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 1600000.00, 480000.00,  N'CONFIRMED',   2, '2026-05-22 10:00:00'),
    (3, 4, 2, '2026-06-05 08:00:00', '2026-06-07 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 7', 1800000.00, 540000.00,  N'PENDING',     NULL, NULL),
    (4, 3, 17, '2026-06-25 08:00:00', '2026-06-28 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 6600000.00, 1980000.00, N'CONFIRMED',   2, '2026-06-20 09:00:00'),
    (5, 4, 18, '2026-06-28 08:00:00', '2026-06-30 08:00:00', N'Chi nhánh Thủ Đức', N'Chi nhánh Thủ Đức', 1900000.00, 570000.00,  N'PENDING',     NULL, NULL),
    (6, 3, 21, '2026-07-01 08:00:00', '2026-07-08 08:00:00', N'Chi nhánh Quận 7', N'Chi nhánh Quận 7', 15400000.00, 4620000.00, N'IN_PROGRESS', 2, '2026-06-20 15:30:00'),
    (7, 4, 26, '2026-06-22 08:00:00', '2026-06-24 08:00:00', N'Chi nhánh Quận 7', N'Chi nhánh Quận 7', 2200000.00, 660000.00,  N'CONFIRMED',   2, '2026-06-20 16:00:00'),
    (8, 3, 29, '2026-06-15 08:00:00', '2026-06-17 08:00:00', N'Chi nhánh Quận 1', N'Chi nhánh Quận 1', 2000000.00, 600000.00,  N'CANCELLED',   NULL, NULL);

SET IDENTITY_INSERT bookings OFF;
GO

-- ============================================================
-- SAMPLE CONTRACT (for the in-progress booking)
-- ============================================================
SET IDENTITY_INSERT rental_contracts ON;

INSERT INTO rental_contracts (contract_id, booking_id, contract_number, customer_id, vehicle_id, start_date, end_date, daily_rate, total_amount, deposit_amount, status, created_by, signed_at)
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
INSERT INTO vehicle_handovers (booking_id, contract_id, vehicle_id, handover_date, mileage_at_handover, fuel_level, exterior_condition, interior_condition, notes, handed_by, received_by)
VALUES
    (1, 1, 4, '2026-05-20 08:00:00', 8000, N'FULL', N'Tình trạng tốt, không trầy xước', N'Sạch sẽ, đầy đủ phụ kiện', N'Đã kiểm tra và bàn giao xe', 2, 3);
GO

-- ============================================================
-- ROLES & PERMISSIONS SEED DATA
-- ============================================================

-- Seed roles
IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'ADMIN')
    INSERT INTO roles (role, description) VALUES (N'ADMIN', N'Quản trị viên toàn quyền hệ thống');
IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'STAFF')
    INSERT INTO roles (role, description) VALUES (N'STAFF', N'Nhân viên vận hành');
IF NOT EXISTS (SELECT 1 FROM roles WHERE role = N'CUSTOMER')
    INSERT INTO roles (role, description) VALUES (N'CUSTOMER', N'Khách thuê xe đã đăng ký tài khoản');
GO

-- Seed permissions
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

IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PREPARE_CONTRACT')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PREPARE_CONTRACT', N'Chuẩn bị hợp đồng', N'Contract and Payment');
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_CONTRACT')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_CONTRACT', N'Xem hợp đồng', N'Contract and Payment');
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'UPDATE_CONTRACT')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('UPDATE_CONTRACT', N'Cập nhật hợp đồng', N'Contract and Payment');
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'PROCESS_ELECTRONIC_SIGNATURE')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('PROCESS_ELECTRONIC_SIGNATURE', N'Chữ ký điện tử', N'Contract and Payment');
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
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'APPROVE_PAYMENT')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('APPROVE_PAYMENT', N'Duyệt thanh toán/hoàn tiền', N'Contract and Payment');

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

IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_NOTIFICATION')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_NOTIFICATION', N'Xem thông báo', N'Notification Management');
IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'MARK_NOTIFICATION_AS_READ')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('MARK_NOTIFICATION_AS_READ', N'Đánh dấu thông báo đã đọc', N'Notification Management');

IF NOT EXISTS (SELECT 1 FROM permission WHERE permission_key = 'VIEW_ACTIVITY_HISTORY')
    INSERT INTO permission (permission_key, permission_name, functional_area) VALUES ('VIEW_ACTIVITY_HISTORY', N'Xem lịch sử hoạt động', N'Audit & Activity History');
GO

-- ============================================================
-- ROLE-PERMISSION MAPPING
-- ============================================================

-- Customer permissions
INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permission p
WHERE r.role = N'CUSTOMER'
AND p.permission_key IN (
    'CHECK_VEHICLE_AVAILABILITY', 'CREATE_BOOKING', 'VIEW_BOOKING', 'UPDATE_BOOKING', 
    'VIEW_VEHICLE_CATALOG', 'CANCEL_BOOKING', 'VIEW_BOOKINGS_POLICE', 'VIEW_CONTRACT', 
    'GENERATE_PAYMENT_QR_CODE', 'VIEW_VEHICLE_DETAIL_CUSTOMER', 'SEARCH_VEHICLE', 
    'VIEW_VEHICLE', 'UPDATE_PROFILE', 'CHANGE_PASSWORD', 'VIEW_NOTIFICATION', 
    'MARK_NOTIFICATION_AS_READ'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permission rp 
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);

-- Staff permissions
INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permission p
WHERE r.role = N'STAFF'
AND p.permission_key IN (
    'CHECK_VEHICLE_AVAILABILITY', 'VIEW_BOOKING', 'VIEW_BOOKINGS_CALENDAR', 'PROCESS_BOOKING_REQUEST',
    'RECORD_VEHICLE_MAINTENANCE', 'VIEW_BOOKINGS_POLICE', 'PREPARE_CONTRACT', 'VIEW_CONTRACT', 
    'UPDATE_CONTRACT', 'PROCESS_ELECTRONIC_SIGNATURE', 'RECORD_PAYMENT', 'GENERATE_PAYMENT_QR_CODE', 
    'RECORD_REFUND', 'EXPORT_VAT_INVOICE', 'PROCESS_HANDOVER', 'PROCESS_RETURN', 
    'RECORD_ADDITIONAL_FEE', 'SETTLE_DEPOSIT', 
    'MONITOR_VEHICLE_STATUS', 'VIEW_VEHICLE_DETAIL_STAFF', 'VERIFY_CUSTOMER_PROFILE', 
    'CHANGE_PASSWORD', 'VIEW_NOTIFICATION', 'MARK_NOTIFICATION_AS_READ', 'UPDATE_BOOKING', 
    'CREATE_BOOKING', 'CANCEL_BOOKING', 'UPDATE_PROFILE', 'VIEW_USER_LIST', 'SEARCH_VEHICLE', 
    'VIEW_VEHICLE', 'VIEW_VEHICLE_CATALOG', 'VIEW_VEHICLE_DETAIL_CUSTOMER', 'APPROVE_PAYMENT'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permission rp 
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);

-- Admin gets ALL permissions
INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permission p
WHERE r.role = N'ADMIN'
AND NOT EXISTS (
    SELECT 1 FROM role_permission rp 
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);
GO

-- ============================================================
-- REVENUE TEST DATA (Tháng 7, 8, 9)
-- ============================================================

-- Cleanup revenue test data first
DELETE FROM reviews WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM vehicle_returns WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM vehicle_handovers WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM payments WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM rental_contracts WHERE booking_id BETWEEN 9 AND 18;
DELETE FROM bookings WHERE booking_id BETWEEN 9 AND 18;
GO

-- Tháng 7 (Bookings 9 to 13)
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, vehicle_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
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

-- Tháng 8 (Bookings 14 to 16)
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, vehicle_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
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

-- Tháng 9 (Bookings 17 to 18)
SET IDENTITY_INSERT bookings ON;

INSERT INTO bookings
(booking_id, customer_id, vehicle_id, start_date, end_date, pickup_location, return_location, total_amount, deposit_amount, status)
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

PRINT 'Sample data inserted successfully!';
GO
