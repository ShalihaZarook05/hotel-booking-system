-- ================================================================
-- Ocean View Resort - Complete Database Initialization Script
-- This script creates the database schema AND inserts sample data
-- Run this file to setup the complete database
-- ================================================================

-- Execute schema creation
SOURCE schema.sql;

-- Execute sample data insertion
SOURCE sample_data.sql;

-- ================================================================
-- Verification Queries
-- ================================================================

-- Check database creation
SELECT 'Database created successfully!' AS Status;

-- Show all tables with row counts
SELECT 
    'users' AS table_name, 
    COUNT(*) AS row_count 
FROM users
UNION ALL
SELECT 'room_types', COUNT(*) FROM room_types
UNION ALL
SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log;

-- ================================================================
-- Test Queries
-- ================================================================

-- Test 1: Verify admin user exists
SELECT 'Admin user verification:' AS test;
SELECT user_id, username, full_name, role 
FROM users 
WHERE role = 'ADMIN';

-- Test 2: Verify room types
SELECT 'Room types verification:' AS test;
SELECT room_type_id, type_name, price_per_night, capacity 
FROM room_types 
ORDER BY price_per_night;

-- Test 3: Check available rooms
SELECT 'Available rooms count:' AS test;
SELECT status, COUNT(*) AS count 
FROM rooms 
GROUP BY status;

-- Test 4: Active reservations
SELECT 'Active reservations:' AS test;
SELECT COUNT(*) AS active_count 
FROM reservations 
WHERE status IN ('PENDING', 'CONFIRMED', 'CHECKED_IN');

-- Test 5: Total revenue
SELECT 'Total revenue (completed payments):' AS test;
SELECT SUM(amount) AS total_revenue 
FROM payments 
WHERE payment_status = 'COMPLETED';

-- ================================================================
-- Database Initialization Complete!
-- ================================================================

SELECT '
====================================
DATABASE SETUP COMPLETE!
====================================

Login Credentials (All users):
- Password: password123

Admin Account:
- Username: admin
- Role: ADMIN

Staff Accounts:
- Username: staff1, staff2
- Role: STAFF

Guest Accounts:
- Username: guest1, guest2, guest3, guest4, guest5
- Role: GUEST

Database Statistics:
- Total Users: 8
- Total Room Types: 5
- Total Rooms: 30
- Sample Reservations: 11
- Sample Payments: 8

Next Steps:
1. Update DatabaseConnection.java with your MySQL credentials
2. Deploy the application to Tomcat
3. Access: http://localhost:8080/OceanViewResort/login

====================================
' AS 'Setup Information';
