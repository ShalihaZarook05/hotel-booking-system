-- ================================================================
-- Ocean View Resort - Database Schema
-- Hotel Booking System Database
-- MySQL 8.0+
-- ================================================================

-- Drop database if exists (CAUTION: This will delete all data)
DROP DATABASE IF EXISTS ocean_view_resort;

-- Create database
CREATE DATABASE ocean_view_resort
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE ocean_view_resort;

-- ================================================================
-- Table 1: users
-- Stores user information (Admin, Staff, Guest)
-- ================================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'SHA-256 hashed password',
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address TEXT,
    role ENUM('ADMIN', 'STAFF', 'GUEST') NOT NULL DEFAULT 'GUEST',
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Table 2: room_types
-- Stores different types of rooms (Standard, Deluxe, Suite, etc.)
-- ================================================================
CREATE TABLE room_types (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    price_per_night DECIMAL(10,2) NOT NULL CHECK (price_per_night > 0),
    capacity INT NOT NULL CHECK (capacity > 0) COMMENT 'Maximum number of guests',
    amenities TEXT COMMENT 'Comma-separated list of amenities',
    image_urls TEXT COMMENT 'Comma-separated list of image URLs (5 images)',
    INDEX idx_type_name (type_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Table 3: rooms
-- Stores individual room information
-- ================================================================
CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_type_id INT NOT NULL,
    floor_number INT,
    status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
    FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_room_number (room_number),
    INDEX idx_status (status),
    INDEX idx_room_type (room_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Table 4: reservations
-- Stores reservation/booking information
-- ================================================================
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_number VARCHAR(20) UNIQUE NOT NULL,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    number_of_guests INT NOT NULL CHECK (number_of_guests > 0),
    special_requests TEXT,
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED') 
        NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(10,2),
    created_by INT NOT NULL COMMENT 'User who created the reservation',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES users(user_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CHECK (check_out_date > check_in_date),
    INDEX idx_reservation_number (reservation_number),
    INDEX idx_guest_id (guest_id),
    INDEX idx_room_id (room_id),
    INDEX idx_status (status),
    INDEX idx_check_in_date (check_in_date),
    INDEX idx_check_out_date (check_out_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Table 5: payments
-- Stores payment transactions
-- ================================================================
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method ENUM('CASH', 'CARD', 'ONLINE') NOT NULL,
    payment_status ENUM('PENDING', 'COMPLETED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_reservation_id (reservation_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_transaction_date (transaction_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Table 6: audit_log (Optional - for tracking changes)
-- Stores system activity logs
-- ================================================================
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL COMMENT 'Action performed (LOGIN, CREATE, UPDATE, DELETE)',
    table_name VARCHAR(50) COMMENT 'Table affected',
    record_id INT COMMENT 'ID of the affected record',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- Create Views for Common Queries
-- ================================================================

-- View: Active Reservations with Guest and Room Details
CREATE OR REPLACE VIEW v_active_reservations AS
SELECT 
    r.reservation_id,
    r.reservation_number,
    r.check_in_date,
    r.check_out_date,
    r.number_of_guests,
    r.status,
    r.total_amount,
    u.full_name AS guest_name,
    u.email AS guest_email,
    u.phone AS guest_phone,
    rm.room_number,
    rt.type_name AS room_type,
    rt.price_per_night
FROM reservations r
JOIN users u ON r.guest_id = u.user_id
JOIN rooms rm ON r.room_id = rm.room_id
JOIN room_types rt ON rm.room_type_id = rt.room_type_id
WHERE r.status NOT IN ('CANCELLED', 'CHECKED_OUT');

-- View: Room Availability Status
CREATE OR REPLACE VIEW v_room_availability AS
SELECT 
    rm.room_id,
    rm.room_number,
    rm.floor_number,
    rm.status,
    rt.type_name,
    rt.price_per_night,
    rt.capacity
FROM rooms rm
JOIN room_types rt ON rm.room_type_id = rt.room_type_id;

-- View: Revenue Summary
CREATE OR REPLACE VIEW v_revenue_summary AS
SELECT 
    DATE(p.transaction_date) AS payment_date,
    COUNT(p.payment_id) AS total_transactions,
    SUM(p.amount) AS total_revenue,
    p.payment_method
FROM payments p
WHERE p.payment_status = 'COMPLETED'
GROUP BY DATE(p.transaction_date), p.payment_method;

-- ================================================================
-- Database Schema Creation Complete
-- ================================================================

-- Show all tables
SHOW TABLES;

-- Display table structures
DESCRIBE users;
DESCRIBE room_types;
DESCRIBE rooms;
DESCRIBE reservations;
DESCRIBE payments;
DESCRIBE audit_log;


UPDATE users SET password = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f' WHERE
    username IN ('admin', 'staff1', 'staff2', 'guest1', 'guest2', 'guest3', 'guest4', 'guest5');



-- Add column
ALTER TABLE room_types
    ADD COLUMN image_urls TEXT COMMENT 'Comma-separated list of image URLs';

-- Update Standard Room
UPDATE room_types
SET image_urls = 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304,https://images.unsplash.com/photo-1611892440504-42a792e24d32,https://images.unsplash.com/photo-1598928506311-c55ded91a20c,https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af,https://images.unsplash.com/photo-1590490360182-c33d57733427'
WHERE type_name = 'Standard Room';

-- Update Deluxe Room
UPDATE room_types
SET image_urls = 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b,https://images.unsplash.com/photo-1566665797739-1674de7a421a,https://images.unsplash.com/photo-1618773928121-c32242e63f39,https://images.unsplash.com/photo-1540518614846-7eded433c457,https://images.unsplash.com/photo-1445019980597-93fa8acb246c'
WHERE type_name = 'Deluxe Room';

-- Update Family Suite
UPDATE room_types
SET image_urls = 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1596394516093-501ba68a0ba6,https://images.unsplash.com/photo-1560448204-e02f11c3d0e2,https://images.unsplash.com/photo-1615873968403-89e068629265,https://images.unsplash.com/photo-1584132967334-10e028bd69f7'
WHERE type_name = 'Family Suite';

-- Update Deluxe Suite
UPDATE room_types
SET image_urls = 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461,https://images.unsplash.com/photo-1455587734955-081b22074882,https://images.unsplash.com/photo-1616594039964-ae9021a400a0,https://images.unsplash.com/photo-1582719508461-905c673771fd,https://images.unsplash.com/photo-1566195992011-5f6b21e539aa'
WHERE type_name = 'Deluxe Suite';

-- Update Presidential Suite
UPDATE room_types
SET image_urls = 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1615460549969-36fa19521a4f,https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd,https://images.unsplash.com/photo-1600596542815-ffad4c1539a9,https://images.unsplash.com/photo-1631049552240-59c37f563fd4'
WHERE type_name = 'Presidential Suite';

-- Verify
SELECT type_name,
       CASE WHEN image_urls IS NOT NULL THEN '✅ OK' ELSE '❌ NULL' END as status
FROM room_types;