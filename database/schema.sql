-- ============================================================
-- Car Rental Management System — Database Schema
-- Database: CarRentalDB
-- SQL Server (T-SQL)
-- ============================================================

USE CarRentalDB;
GO

-- ============================================================
-- 1. USERS
-- Stores all user accounts (Admin, Staff, Customer)
-- ============================================================
CREATE TABLE users (
    user_id         INT IDENTITY(1,1) PRIMARY KEY,
    email           NVARCHAR(255)   NOT NULL UNIQUE,
    password_hash   NVARCHAR(255)   NOT NULL,
    full_name       NVARCHAR(255)   NOT NULL,
    phone           NVARCHAR(20)    NULL,
    role            NVARCHAR(20)    NOT NULL DEFAULT 'CUSTOMER',  -- ADMIN, STAFF, CUSTOMER
    is_active       BIT             NOT NULL DEFAULT 1,
    avatar_url      NVARCHAR(500)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2       NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 2. CUSTOMER_PROFILES
-- Extended profile for customers (driver license, ID card)
-- ============================================================
CREATE TABLE customer_profiles (
    profile_id          INT IDENTITY(1,1) PRIMARY KEY,
    user_id             INT             NOT NULL UNIQUE,
    date_of_birth       DATE            NULL,
    address             NVARCHAR(500)   NULL,
    id_card_number      NVARCHAR(20)    NULL,
    id_card_image_front NVARCHAR(500)   NULL,
    id_card_image_back  NVARCHAR(500)   NULL,
    driver_license_number   NVARCHAR(20)    NULL,
    driver_license_image    NVARCHAR(500)   NULL,
    driver_license_expiry   DATE            NULL,
    verification_status     NVARCHAR(20)    NOT NULL DEFAULT 'PENDING',  -- PENDING, VERIFIED, REJECTED
    verified_by         INT             NULL,
    verified_at         DATETIME2       NULL,
    created_at          DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_customer_profiles_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT FK_customer_profiles_verified_by FOREIGN KEY (verified_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 3. CARS
-- Vehicle inventory for the rental shop
-- ============================================================
CREATE TABLE cars (
    car_id              INT IDENTITY(1,1) PRIMARY KEY,
    license_plate       NVARCHAR(20)    NOT NULL UNIQUE,
    brand               NVARCHAR(100)   NOT NULL,
    model               NVARCHAR(100)   NOT NULL,
    year                INT             NOT NULL,
    color               NVARCHAR(50)    NULL,
    seats               INT             NOT NULL DEFAULT 4,
    transmission        NVARCHAR(20)    NOT NULL DEFAULT 'AUTOMATIC',  -- AUTOMATIC, MANUAL
    fuel_type           NVARCHAR(20)    NOT NULL DEFAULT 'GASOLINE',   -- GASOLINE, DIESEL, ELECTRIC, HYBRID
    daily_rate          DECIMAL(18,2)   NOT NULL,
    description         NVARCHAR(MAX)   NULL,
    status              NVARCHAR(20)    NOT NULL DEFAULT 'AVAILABLE',  -- AVAILABLE, RENTED, MAINTENANCE, INACTIVE
    mileage             INT             NOT NULL DEFAULT 0,
    location            NVARCHAR(255)   NULL,
    features            NVARCHAR(MAX)   NULL,   -- e.g., GPS, Bluetooth, Dashcam
    created_at          DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2       NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 4. CAR_IMAGES
-- Multiple images per car
-- ============================================================
CREATE TABLE car_images (
    image_id    INT IDENTITY(1,1) PRIMARY KEY,
    car_id      INT             NOT NULL,
    image_url   NVARCHAR(500)   NOT NULL,
    caption     NVARCHAR(255)   NULL,
    is_primary  BIT             NOT NULL DEFAULT 0,
    sort_order  INT             NOT NULL DEFAULT 0,
    created_at  DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_car_images_car FOREIGN KEY (car_id) REFERENCES cars(car_id)
);
GO

-- ============================================================
-- 5. BOOKINGS
-- Rental reservations
-- ============================================================
CREATE TABLE bookings (
    booking_id      INT IDENTITY(1,1) PRIMARY KEY,
    customer_id     INT             NOT NULL,
    car_id          INT             NOT NULL,
    start_date      DATETIME2       NOT NULL,
    end_date        DATETIME2       NOT NULL,
    pickup_location NVARCHAR(500)   NULL,
    return_location NVARCHAR(500)   NULL,
    total_amount    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    deposit_amount  DECIMAL(18,2)   NOT NULL DEFAULT 0,
    status          NVARCHAR(30)    NOT NULL DEFAULT 'PENDING',
        -- PENDING, CONFIRMED, REJECTED, CANCELLED,
        -- IN_PROGRESS, COMPLETED, NO_SHOW, PENDING_SETTLEMENT
    notes           NVARCHAR(MAX)   NULL,
    approved_by     INT             NULL,
    approved_at     DATETIME2       NULL,
    cancelled_at    DATETIME2       NULL,
    cancel_reason   NVARCHAR(500)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_bookings_customer FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_bookings_car FOREIGN KEY (car_id) REFERENCES cars(car_id),
    CONSTRAINT FK_bookings_approved_by FOREIGN KEY (approved_by) REFERENCES users(user_id),
    CONSTRAINT CHK_bookings_dates CHECK (end_date >= start_date)
);
GO

-- ============================================================
-- 6. RENTAL_CONTRACTS
-- Formal rental contracts linked to confirmed bookings
-- ============================================================
CREATE TABLE rental_contracts (
    contract_id         INT IDENTITY(1,1) PRIMARY KEY,
    booking_id          INT             NOT NULL UNIQUE,
    contract_number     NVARCHAR(50)    NOT NULL UNIQUE,
    customer_id         INT             NOT NULL,
    car_id              INT             NOT NULL,
    start_date          DATETIME2       NOT NULL,
    end_date            DATETIME2       NOT NULL,
    daily_rate          DECIMAL(18,2)   NOT NULL,
    total_amount        DECIMAL(18,2)   NOT NULL,
    deposit_amount      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    status              NVARCHAR(20)    NOT NULL DEFAULT 'DRAFT',  -- DRAFT, ACTIVE, COMPLETED, TERMINATED
    terms_and_conditions NVARCHAR(MAX)  NULL,
    created_by          INT             NOT NULL,
    signed_at           DATETIME2       NULL,
    created_at          DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at          DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_contracts_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_contracts_customer FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_contracts_car FOREIGN KEY (car_id) REFERENCES cars(car_id),
    CONSTRAINT FK_contracts_created_by FOREIGN KEY (created_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 7. PAYMENTS
-- Payment records for bookings/contracts
-- ============================================================
CREATE TABLE payments (
    payment_id      INT IDENTITY(1,1) PRIMARY KEY,
    booking_id      INT             NOT NULL,
    contract_id     INT             NULL,
    amount          DECIMAL(18,2)   NOT NULL,
    payment_type    NVARCHAR(30)    NOT NULL,     -- DEPOSIT, RENTAL, ADDITIONAL_FEE, REFUND
    payment_method  NVARCHAR(30)    NULL,         -- CASH, BANK_TRANSFER, CARD
    status          NVARCHAR(20)    NOT NULL DEFAULT 'PENDING',  -- PENDING, COMPLETED, FAILED, REFUNDED
    transaction_ref NVARCHAR(100)   NULL,
    notes           NVARCHAR(500)   NULL,
    paid_at         DATETIME2       NULL,
    recorded_by     INT             NULL,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_payments_contract FOREIGN KEY (contract_id) REFERENCES rental_contracts(contract_id),
    CONSTRAINT FK_payments_recorded_by FOREIGN KEY (recorded_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 8. VEHICLE_HANDOVERS
-- Records when vehicle is handed over to customer
-- ============================================================
CREATE TABLE vehicle_handovers (
    handover_id     INT IDENTITY(1,1) PRIMARY KEY,
    booking_id      INT             NOT NULL,
    contract_id     INT             NULL,
    car_id          INT             NOT NULL,
    handover_date   DATETIME2       NOT NULL,
    mileage_at_handover INT         NOT NULL DEFAULT 0,
    fuel_level      NVARCHAR(20)    NULL,       -- FULL, 3/4, 1/2, 1/4, EMPTY
    exterior_condition  NVARCHAR(MAX) NULL,
    interior_condition  NVARCHAR(MAX) NULL,
    accessories_checklist NVARCHAR(MAX) NULL,
    photos_url      NVARCHAR(MAX)   NULL,
    notes           NVARCHAR(MAX)   NULL,
    handed_by       INT             NOT NULL,   -- staff who performed handover
    received_by     INT             NOT NULL,   -- customer
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_handovers_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_handovers_contract FOREIGN KEY (contract_id) REFERENCES rental_contracts(contract_id),
    CONSTRAINT FK_handovers_car FOREIGN KEY (car_id) REFERENCES cars(car_id),
    CONSTRAINT FK_handovers_handed_by FOREIGN KEY (handed_by) REFERENCES users(user_id),
    CONSTRAINT FK_handovers_received_by FOREIGN KEY (received_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 9. VEHICLE_RETURNS
-- Records when vehicle is returned by customer
-- ============================================================
CREATE TABLE vehicle_returns (
    return_id       INT IDENTITY(1,1) PRIMARY KEY,
    booking_id      INT             NOT NULL,
    contract_id     INT             NULL,
    car_id          INT             NOT NULL,
    handover_id     INT             NULL,
    return_date     DATETIME2       NOT NULL,
    mileage_at_return INT           NOT NULL DEFAULT 0,
    fuel_level      NVARCHAR(20)    NULL,
    exterior_condition  NVARCHAR(MAX) NULL,
    interior_condition  NVARCHAR(MAX) NULL,
    damage_description  NVARCHAR(MAX) NULL,
    photos_url      NVARCHAR(MAX)   NULL,
    late_fee        DECIMAL(18,2)   NOT NULL DEFAULT 0,
    extra_km_fee    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    damage_fee      DECIMAL(18,2)   NOT NULL DEFAULT 0,
    cleaning_fee    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    lost_item_fee   DECIMAL(18,2)   NOT NULL DEFAULT 0,
    total_additional_fee DECIMAL(18,2) NOT NULL DEFAULT 0,
    notes           NVARCHAR(MAX)   NULL,
    received_by     INT             NOT NULL,   -- staff who received the car
    returned_by     INT             NOT NULL,   -- customer
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_returns_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_returns_contract FOREIGN KEY (contract_id) REFERENCES rental_contracts(contract_id),
    CONSTRAINT FK_returns_car FOREIGN KEY (car_id) REFERENCES cars(car_id),
    CONSTRAINT FK_returns_handover FOREIGN KEY (handover_id) REFERENCES vehicle_handovers(handover_id),
    CONSTRAINT FK_returns_received_by FOREIGN KEY (received_by) REFERENCES users(user_id),
    CONSTRAINT FK_returns_returned_by FOREIGN KEY (returned_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 10. REVIEWS
-- Customer reviews for completed rentals
-- ============================================================
CREATE TABLE reviews (
    review_id       INT IDENTITY(1,1) PRIMARY KEY,
    booking_id      INT             NOT NULL,
    customer_id     INT             NOT NULL,
    car_id          INT             NOT NULL,
    rating          INT             NOT NULL,       -- 1-5
    comment         NVARCHAR(MAX)   NULL,
    is_visible      BIT             NOT NULL DEFAULT 1,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT FK_reviews_customer FOREIGN KEY (customer_id) REFERENCES users(user_id),
    CONSTRAINT FK_reviews_car FOREIGN KEY (car_id) REFERENCES cars(car_id),
    CONSTRAINT CHK_reviews_rating CHECK (rating >= 1 AND rating <= 5)
);
GO

-- ============================================================
-- 11. POLICY_SETTINGS
-- Configurable business policies (rates, limits, rules)
-- ============================================================
CREATE TABLE policy_settings (
    policy_id       INT IDENTITY(1,1) PRIMARY KEY,
    policy_key      NVARCHAR(100)   NOT NULL UNIQUE,
    policy_value    NVARCHAR(500)   NOT NULL,
    description     NVARCHAR(500)   NULL,
    category        NVARCHAR(50)    NULL,          -- PRICING, BOOKING, PENALTY, TAX, GENERAL
    updated_by      INT             NULL,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
    updated_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_policy_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);
GO

-- ============================================================
-- 12. AUDIT_LOGS
-- Tracks important actions in the system
-- ============================================================
CREATE TABLE audit_logs (
    log_id          INT IDENTITY(1,1) PRIMARY KEY,
    user_id         INT             NULL,
    action          NVARCHAR(100)   NOT NULL,
    entity_type     NVARCHAR(50)    NULL,     -- e.g., BOOKING, CAR, USER
    entity_id       INT             NULL,
    old_value       NVARCHAR(MAX)   NULL,
    new_value       NVARCHAR(MAX)   NULL,
    ip_address      NVARCHAR(45)    NULL,
    description     NVARCHAR(500)   NULL,
    created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);
GO

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX IX_bookings_customer ON bookings(customer_id);
CREATE INDEX IX_bookings_car ON bookings(car_id);
CREATE INDEX IX_bookings_status ON bookings(status);
CREATE INDEX IX_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX IX_cars_status ON cars(status);
CREATE INDEX IX_payments_booking ON payments(booking_id);
CREATE INDEX IX_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IX_audit_logs_entity ON audit_logs(entity_type, entity_id);
GO

PRINT 'Schema created successfully!';
GO
