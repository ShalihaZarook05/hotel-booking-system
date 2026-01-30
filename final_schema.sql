-- ================================================================
-- OCEAN VIEW RESORT - FINAL DATABASE SCHEMA
-- Complete Hotel Booking System Database
-- Version: 1.0 Final
-- MySQL 8.0+
-- Date: 2026-01-29
-- ================================================================
-- 
-- This is the complete, finalized database schema including:
-- - All table structures with foreign key constraints
-- - Sample data for testing
-- - Views for common queries
-- - All latest updates and fixes applied
-- 
-- USAGE:
-- 1. Run this entire script in MySQL Workbench or command line
-- 2. It will create the database, tables, and insert sample data
-- 3. Default password for all users: "password123"
-- 
-- ================================================================

-- ================================================================
-- DATABASE SETUP
-- ================================================================

-- Drop database if exists (CAUTION: This will delete all data)
DROP DATABASE IF EXISTS ocean_view_resort;

-- Create database with UTF-8 support
CREATE DATABASE ocean_view_resort
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Use the database
USE ocean_view_resort;

-- ================================================================
-- TABLE DEFINITIONS
-- ================================================================

-- ----------------------------------------------------------------
-- Table 1: users
-- Stores user information (Admin, Staff, Guest)
-- ----------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='User accounts with role-based access (Admin, Staff, Guest)';

-- ----------------------------------------------------------------
-- Table 2: room_types
-- Stores different types of rooms with pricing and amenities
-- ----------------------------------------------------------------
CREATE TABLE room_types (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    price_per_night DECIMAL(10,2) NOT NULL CHECK (price_per_night > 0),
    capacity INT NOT NULL CHECK (capacity > 0) COMMENT 'Maximum number of guests',
    amenities TEXT COMMENT 'Comma-separated list of amenities',
    image_urls TEXT COMMENT 'Comma-separated list of image URLs (5 images)',
    INDEX idx_type_name (type_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Room type definitions with pricing in LKR (Sri Lankan Rupees)';

-- ----------------------------------------------------------------
-- Table 3: rooms
-- Stores individual room information
-- ----------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Individual room inventory';

-- ----------------------------------------------------------------
-- Table 4: reservations
-- Stores reservation/booking information
-- ----------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Guest reservations and bookings';

-- ----------------------------------------------------------------
-- Table 5: payments
-- Stores payment transactions
-- ----------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Payment transactions for reservations';

-- ----------------------------------------------------------------
-- Table 6: audit_log
-- Stores system activity logs for auditing
-- ----------------------------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='System audit trail for tracking user actions';

-- ================================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================================

-- ----------------------------------------------------------------
-- View: Active Reservations with Guest and Room Details
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- View: Room Availability Status
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- View: Revenue Summary by Date and Payment Method
-- ----------------------------------------------------------------
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
-- SAMPLE DATA INSERTION
-- ================================================================

-- ----------------------------------------------------------------
-- 1. INSERT USERS (Admin, Staff, Guests)
-- Password for all users: "password123"
-- SHA-256 Hash: ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f
-- ----------------------------------------------------------------

-- Admin User
INSERT INTO users (username, password, full_name, email, phone, address, role, status) VALUES
('admin', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'System Administrator', 'admin@oceanview.com', '0771234567', 
 '123 Main Street, Galle, Sri Lanka', 'ADMIN', 'ACTIVE');

-- Staff Users
INSERT INTO users (username, password, full_name, email, phone, address, role, status) VALUES
('staff1', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'John Smith', 'john.smith@oceanview.com', '0772345678', 
 '45 Beach Road, Galle', 'STAFF', 'ACTIVE'),
('staff2', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Sarah Williams', 'sarah.williams@oceanview.com', '0773456789', 
 '67 Ocean Drive, Galle', 'STAFF', 'ACTIVE');

-- Guest Users
INSERT INTO users (username, password, full_name, email, phone, address, role, status) VALUES
('guest1', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Michael Johnson', 'michael.j@email.com', '0774567890', 
 '89 Park Avenue, Colombo', 'GUEST', 'ACTIVE'),
('guest2', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Emily Brown', 'emily.brown@email.com', '0775678901', 
 '12 Hill Street, Kandy', 'GUEST', 'ACTIVE'),
('guest3', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'David Wilson', 'david.wilson@email.com', '0776789012', 
 '34 Lake Road, Negombo', 'GUEST', 'ACTIVE'),
('guest4', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Jessica Taylor', 'jessica.t@email.com', '0777890123', 
 '56 Beach Lane, Matara', 'GUEST', 'ACTIVE'),
('guest5', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 
 'Robert Anderson', 'robert.a@email.com', '0778901234', 
 '78 Garden Street, Galle', 'GUEST', 'ACTIVE');

-- ----------------------------------------------------------------
-- 2. INSERT ROOM TYPES
-- Prices in LKR (Sri Lankan Rupees) - Reasonable rates
-- ----------------------------------------------------------------

INSERT INTO room_types (type_name, description, price_per_night, capacity, amenities, image_urls) VALUES
('Standard Room', 
 'Comfortable room with basic amenities perfect for budget travelers', 
 18000.00, 2, 
 'Air Conditioning, TV, WiFi, Mini Fridge',
 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304,https://images.unsplash.com/photo-1611892440504-42a792e24d32,https://images.unsplash.com/photo-1598928506311-c55ded91a20c,https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af,https://images.unsplash.com/photo-1590490360182-c33d57733427'),

('Deluxe Room', 
 'Spacious room with sea view and premium amenities', 
 35000.00, 2, 
 'Air Conditioning, LED TV, WiFi, Mini Bar, Sea View, Balcony',
 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b,https://images.unsplash.com/photo-1566665797739-1674de7a421a,https://images.unsplash.com/photo-1618773928121-c32242e63f39,https://images.unsplash.com/photo-1540518614846-7eded433c457,https://images.unsplash.com/photo-1445019980597-93fa8acb246c'),

('Family Suite', 
 'Large suite perfect for families with separate living area', 
 55000.00, 4, 
 'Air Conditioning, 2 LED TVs, WiFi, Mini Bar, Sea View, Living Room, 2 Bathrooms',
 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1596394516093-501ba68a0ba6,https://images.unsplash.com/photo-1560448204-e02f11c3d0e2,https://images.unsplash.com/photo-1615873968403-89e068629265,https://images.unsplash.com/photo-1584132967334-10e028bd69f7'),

('Deluxe Suite', 
 'Luxurious suite with panoramic ocean view', 
 80000.00, 2, 
 'Air Conditioning, Smart TV, High-Speed WiFi, Mini Bar, Jacuzzi, Ocean View, Private Balcony',
 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461,https://images.unsplash.com/photo-1455587734955-081b22074882,https://images.unsplash.com/photo-1616594039964-ae9021a400a0,https://images.unsplash.com/photo-1582719508461-905c673771fd,https://images.unsplash.com/photo-1566195992011-5f6b21e539aa'),

('Presidential Suite', 
 'Ultimate luxury with exclusive services and premium facilities', 
 95000.00, 4, 
 'Air Conditioning, Smart TVs, Premium WiFi, Full Bar, Jacuzzi, Ocean View, Private Terrace, Butler Service',
 'https://images.unsplash.com/photo-1591088398332-8a7791972843,https://images.unsplash.com/photo-1615460549969-36fa19521a4f,https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd,https://images.unsplash.com/photo-1600596542815-ffad4c1539a9,https://images.unsplash.com/photo-1631049552240-59c37f563fd4');

-- ----------------------------------------------------------------
-- 3. INSERT ROOMS (30 rooms across 3 floors)
-- ----------------------------------------------------------------

-- Floor 1: Standard Rooms (101-110)
INSERT INTO rooms (room_number, room_type_id, floor_number, status) VALUES
('101', 1, 1, 'AVAILABLE'),
('102', 1, 1, 'AVAILABLE'),
('103', 1, 1, 'OCCUPIED'),
('104', 1, 1, 'AVAILABLE'),
('105', 1, 1, 'AVAILABLE'),
('106', 1, 1, 'MAINTENANCE'),
('107', 1, 1, 'AVAILABLE'),
('108', 1, 1, 'AVAILABLE'),
('109', 1, 1, 'AVAILABLE'),
('110', 1, 1, 'AVAILABLE');

-- Floor 2: Deluxe Rooms and Family Suites (201-215)
INSERT INTO rooms (room_number, room_type_id, floor_number, status) VALUES
('201', 2, 2, 'AVAILABLE'),
('202', 2, 2, 'OCCUPIED'),
('203', 2, 2, 'AVAILABLE'),
('204', 2, 2, 'AVAILABLE'),
('205', 2, 2, 'AVAILABLE'),
('206', 2, 2, 'AVAILABLE'),
('207', 2, 2, 'AVAILABLE'),
('208', 2, 2, 'AVAILABLE'),
('209', 3, 2, 'AVAILABLE'),
('210', 3, 2, 'OCCUPIED'),
('211', 3, 2, 'AVAILABLE'),
('212', 3, 2, 'AVAILABLE'),
('213', 3, 2, 'AVAILABLE'),
('214', 3, 2, 'AVAILABLE'),
('215', 3, 2, 'AVAILABLE');

-- Floor 3: Deluxe Suites and Presidential Suite (301-305)
INSERT INTO rooms (room_number, room_type_id, floor_number, status) VALUES
('301', 4, 3, 'AVAILABLE'),
('302', 4, 3, 'OCCUPIED'),
('303', 4, 3, 'AVAILABLE'),
('304', 4, 3, 'AVAILABLE'),
('305', 5, 3, 'AVAILABLE');

-- ----------------------------------------------------------------
-- 4. INSERT RESERVATIONS (Sample data for testing)
-- ----------------------------------------------------------------

-- Active Reservations (Confirmed/Checked-In)
INSERT INTO reservations (reservation_number, guest_id, room_id, check_in_date, check_out_date, 
                         number_of_guests, special_requests, status, total_amount, created_by) VALUES
-- Checked-In Reservations
('RES1738070001', 4, 3, '2026-01-28', '2026-01-31', 2, 
 'Late check-in requested', 'CHECKED_IN', 54000.00, 2),

('RES1738070002', 5, 10, '2026-01-27', '2026-01-30', 2, 
 'Honeymoon package', 'CHECKED_IN', 165000.00, 2),

('RES1738070003', 6, 22, '2026-01-28', '2026-02-02', 3, 
 'Extra bed needed', 'CHECKED_IN', 275000.00, 1),

-- Confirmed Future Reservations
('RES1738070004', 7, 13, '2026-02-01', '2026-02-05', 2, 
 'Ground floor preferred', 'CONFIRMED', 140000.00, 2),

('RES1738070005', 8, 23, '2026-02-03', '2026-02-07', 4, 
 'Breakfast included', 'CONFIRMED', 220000.00, 1),

('RES1738070006', 4, 11, '2026-02-10', '2026-02-15', 2, 
 'Anniversary celebration', 'CONFIRMED', 175000.00, 2),

('RES1738070007', 5, 21, '2026-02-15', '2026-02-20', 2, 
 'Sea view preferred', 'CONFIRMED', 175000.00, 1),

-- Pending Reservations
('RES1738070008', 6, 14, '2026-02-20', '2026-02-25', 4, 
 'Airport pickup needed', 'PENDING', 275000.00, 2),

-- Checked-Out (Historical)
('RES1738070009', 7, 1, '2026-01-20', '2026-01-25', 2, 
 'Early check-in', 'CHECKED_OUT', 90000.00, 2),

('RES1738070010', 8, 5, '2026-01-15', '2026-01-20', 2, 
 'Quiet room requested', 'CHECKED_OUT', 90000.00, 1),

-- Cancelled
('RES1738070011', 4, 7, '2026-02-05', '2026-02-08', 2, 
 'Business trip', 'CANCELLED', 54000.00, 2);

-- ----------------------------------------------------------------
-- 5. INSERT PAYMENTS (Sample transactions)
-- ----------------------------------------------------------------

-- Payments for checked-out reservations (completed)
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(9, 90000.00, 'CARD', 'COMPLETED'),
(10, 90000.00, 'CASH', 'COMPLETED');

-- Partial payments for checked-in reservations
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(1, 30000.00, 'CARD', 'COMPLETED'),
(2, 100000.00, 'ONLINE', 'COMPLETED'),
(3, 150000.00, 'CARD', 'COMPLETED');

-- Advance payments for confirmed reservations
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(4, 50000.00, 'ONLINE', 'COMPLETED'),
(5, 100000.00, 'CARD', 'COMPLETED'),
(6, 80000.00, 'ONLINE', 'COMPLETED');

-- Pending payment
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(8, 100000.00, 'CARD', 'PENDING');

-- ----------------------------------------------------------------
-- 6. INSERT AUDIT LOG (Sample entries)
-- ----------------------------------------------------------------

INSERT INTO audit_log (user_id, action, table_name, record_id) VALUES
(1, 'LOGIN', NULL, NULL),
(2, 'LOGIN', NULL, NULL),
(1, 'CREATE', 'reservations', 1),
(2, 'CREATE', 'reservations', 2),
(1, 'UPDATE', 'reservations', 1),
(2, 'CREATE', 'payments', 1),
(1, 'CREATE', 'users', 4),
(2, 'UPDATE', 'rooms', 3);

-- ================================================================
-- VERIFICATION & SUMMARY QUERIES
-- ================================================================

-- Show all tables
SELECT '=====================================' AS '';
SELECT 'DATABASE TABLES CREATED' AS '';
SELECT '=====================================' AS '';
SHOW TABLES;

-- Display record counts
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'RECORD COUNTS BY TABLE' AS '';
SELECT '=====================================' AS '';
SELECT 'Users' AS Table_Name, COUNT(*) AS Record_Count FROM users
UNION ALL
SELECT 'Room Types', COUNT(*) FROM room_types
UNION ALL
SELECT 'Rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'Reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments
UNION ALL
SELECT 'Audit Log', COUNT(*) FROM audit_log;

-- Display user summary by role
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'USER SUMMARY BY ROLE' AS '';
SELECT '=====================================' AS '';
SELECT role AS Role, 
       COUNT(*) AS Total_Users, 
       SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS Active_Users
FROM users
GROUP BY role
ORDER BY FIELD(role, 'ADMIN', 'STAFF', 'GUEST');

-- Display room summary by type
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'ROOM INVENTORY SUMMARY' AS '';
SELECT '=====================================' AS '';
SELECT rt.type_name AS Room_Type, 
       CONCAT('LKR ', FORMAT(rt.price_per_night, 0)) AS Price_Per_Night,
       COUNT(r.room_id) AS Total_Rooms,
       SUM(CASE WHEN r.status = 'AVAILABLE' THEN 1 ELSE 0 END) AS Available,
       SUM(CASE WHEN r.status = 'OCCUPIED' THEN 1 ELSE 0 END) AS Occupied,
       SUM(CASE WHEN r.status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS Maintenance
FROM room_types rt
LEFT JOIN rooms r ON rt.room_type_id = r.room_type_id
GROUP BY rt.room_type_id, rt.type_name, rt.price_per_night
ORDER BY rt.price_per_night;

-- Display reservation summary by status
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'RESERVATION SUMMARY' AS '';
SELECT '=====================================' AS '';
SELECT status AS Status, 
       COUNT(*) AS Count, 
       CONCAT('LKR ', FORMAT(SUM(total_amount), 0)) AS Total_Amount
FROM reservations
GROUP BY status
ORDER BY FIELD(status, 'CHECKED_IN', 'CONFIRMED', 'PENDING', 'CHECKED_OUT', 'CANCELLED');

-- Display payment summary
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'PAYMENT SUMMARY' AS '';
SELECT '=====================================' AS '';
SELECT payment_method AS Method, 
       payment_status AS Status,
       COUNT(*) AS Transactions, 
       CONCAT('LKR ', FORMAT(SUM(amount), 0)) AS Total_Amount
FROM payments
GROUP BY payment_method, payment_status
ORDER BY payment_method, payment_status;

-- Display total revenue
SELECT '' AS '';
SELECT '=====================================' AS '';
SELECT 'TOTAL REVENUE (COMPLETED PAYMENTS)' AS '';
SELECT '=====================================' AS '';
SELECT CONCAT('LKR ', FORMAT(SUM(amount), 0)) AS Total_Revenue
FROM payments
WHERE payment_status = 'COMPLETED';

-- ================================================================
-- SETUP COMPLETE MESSAGE
-- ================================================================

SELECT '' AS '';
SELECT '============================================' AS '';
SELECT '   DATABASE SETUP COMPLETE!' AS '';
SELECT '============================================' AS '';
SELECT '' AS '';
SELECT 'Database Name: ocean_view_resort' AS '';
SELECT 'Total Tables: 6 (users, room_types, rooms, reservations, payments, audit_log)' AS '';
SELECT 'Total Views: 3 (v_active_reservations, v_room_availability, v_revenue_summary)' AS '';
SELECT '' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'LOGIN CREDENTIALS (All users)' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'Password: password123' AS '';
SELECT '' AS '';
SELECT 'Admin Account:' AS '';
SELECT '  Username: admin' AS '';
SELECT '  Role: ADMIN' AS '';
SELECT '' AS '';
SELECT 'Staff Accounts:' AS '';
SELECT '  Username: staff1, staff2' AS '';
SELECT '  Role: STAFF' AS '';
SELECT '' AS '';
SELECT 'Guest Accounts:' AS '';
SELECT '  Username: guest1, guest2, guest3, guest4, guest5' AS '';
SELECT '  Role: GUEST' AS '';
SELECT '' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'DATABASE STATISTICS' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'Total Users: 8 (1 Admin, 2 Staff, 5 Guests)' AS '';
SELECT 'Total Room Types: 5' AS '';
SELECT 'Total Rooms: 30 (across 3 floors)' AS '';
SELECT 'Sample Reservations: 11' AS '';
SELECT 'Sample Payments: 9' AS '';
SELECT '' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'NEXT STEPS' AS '';
SELECT '--------------------------------------------' AS '';
SELECT '1. Update DatabaseConnection.java with your MySQL credentials' AS '';
SELECT '2. Set database name: ocean_view_resort' AS '';
SELECT '3. Deploy application to Tomcat server' AS '';
SELECT '4. Access: http://localhost:8080/OceanViewResort/login' AS '';
SELECT '5. Login with any user account using password: password123' AS '';
SELECT '' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'CURRENCY & PRICING' AS '';
SELECT '--------------------------------------------' AS '';
SELECT 'All prices are in LKR (Sri Lankan Rupees)' AS '';
SELECT 'Standard Room: LKR 18,000/night' AS '';
SELECT 'Deluxe Room: LKR 35,000/night' AS '';
SELECT 'Family Suite: LKR 55,000/night' AS '';
SELECT 'Deluxe Suite: LKR 80,000/night' AS '';
SELECT 'Presidential Suite: LKR 95,000/night' AS '';
SELECT '' AS '';
SELECT '============================================' AS '';

-- ================================================================
-- END OF SCRIPT
-- ================================================================
