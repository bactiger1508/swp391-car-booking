-- ============================================================
-- Car Rental Management System — Reset Database
-- WARNING: This will DROP ALL TABLES and recreate them.
-- ============================================================

USE CarRentalDB;
GO

-- Drop tables in reverse dependency order
IF OBJECT_ID('dbo.audit_logs', 'U') IS NOT NULL DROP TABLE audit_logs;
IF OBJECT_ID('dbo.reviews', 'U') IS NOT NULL DROP TABLE reviews;
IF OBJECT_ID('dbo.vehicle_returns', 'U') IS NOT NULL DROP TABLE vehicle_returns;
IF OBJECT_ID('dbo.vehicle_handovers', 'U') IS NOT NULL DROP TABLE vehicle_handovers;
IF OBJECT_ID('dbo.payments', 'U') IS NOT NULL DROP TABLE payments;
IF OBJECT_ID('dbo.rental_contracts', 'U') IS NOT NULL DROP TABLE rental_contracts;
IF OBJECT_ID('dbo.bookings', 'U') IS NOT NULL DROP TABLE bookings;
IF OBJECT_ID('dbo.car_images', 'U') IS NOT NULL DROP TABLE car_images;
IF OBJECT_ID('dbo.cars', 'U') IS NOT NULL DROP TABLE cars;
IF OBJECT_ID('dbo.policy_settings', 'U') IS NOT NULL DROP TABLE policy_settings;
IF OBJECT_ID('dbo.customer_profiles', 'U') IS NOT NULL DROP TABLE customer_profiles;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE users;
GO

PRINT 'All tables dropped successfully.';
PRINT 'Now run schema.sql followed by sample-data.sql to recreate.';
GO
