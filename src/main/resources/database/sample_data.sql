-- ================================================================
-- Ocean View Resort - Sample Data
-- Hotel Booking System Sample/Test Data
-- ================================================================

USE ocean_view_resort;

-- ================================================================
-- 1. INSERT USERS (Admin, Staff, Guests)
-- Password for all users: "password123" (SHA-256 hash)
-- Hash: ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f
-- ================================================================

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

-- ================================================================
-- 2. INSERT ROOM TYPES
-- ================================================================

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

-- ================================================================
-- 3. INSERT ROOMS (30 rooms across 3 floors)
-- ================================================================

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

-- ================================================================
-- 4. INSERT RESERVATIONS
-- ================================================================

-- Active Reservations (Confirmed/Checked-In)
INSERT INTO reservations (reservation_number, guest_id, room_id, check_in_date, check_out_date, 
                         number_of_guests, special_requests, status, total_amount, created_by) VALUES
-- Checked-In Reservations
('RES1738070001', 4, 3, '2026-01-28', '2026-01-31', 2, 
 'Late check-in requested', 'CHECKED_IN', 15000.00, 2),

('RES1738070002', 5, 10, '2026-01-27', '2026-01-30', 2, 
 'Honeymoon package', 'CHECKED_IN', 36000.00, 2),

('RES1738070003', 6, 22, '2026-01-28', '2026-02-02', 3, 
 'Extra bed needed', 'CHECKED_IN', 45000.00, 1),

-- Confirmed Future Reservations
('RES1738070004', 7, 13, '2026-02-01', '2026-02-05', 2, 
 'Ground floor preferred', 'CONFIRMED', 32000.00, 2),

('RES1738070005', 8, 23, '2026-02-03', '2026-02-07', 4, 
 'Breakfast included', 'CONFIRMED', 60000.00, 1),

('RES1738070006', 4, 11, '2026-02-10', '2026-02-15', 2, 
 'Anniversary celebration', 'CONFIRMED', 40000.00, 2),

('RES1738070007', 5, 21, '2026-02-15', '2026-02-20', 2, 
 'Sea view preferred', 'CONFIRMED', 75000.00, 1),

-- Pending Reservations
('RES1738070008', 6, 14, '2026-02-20', '2026-02-25', 4, 
 'Airport pickup needed', 'PENDING', 60000.00, 2),

-- Checked-Out (Historical)
('RES1738070009', 7, 1, '2026-01-20', '2026-01-25', 2, 
 'Early check-in', 'CHECKED_OUT', 25000.00, 2),

('RES1738070010', 8, 5, '2026-01-15', '2026-01-20', 2, 
 'Quiet room requested', 'CHECKED_OUT', 25000.00, 1),

-- Cancelled
('RES1738070011', 4, 7, '2026-02-05', '2026-02-08', 2, 
 'Business trip', 'CANCELLED', 15000.00, 2);

-- ================================================================
-- 5. INSERT PAYMENTS
-- ================================================================

-- Payments for checked-out reservations (completed)
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(9, 25000.00, 'CARD', 'COMPLETED'),
(10, 25000.00, 'CASH', 'COMPLETED');

-- Partial payments for checked-in reservations
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(1, 10000.00, 'CARD', 'COMPLETED'),
(2, 20000.00, 'ONLINE', 'COMPLETED'),
(3, 30000.00, 'CARD', 'COMPLETED');

-- Advance payments for confirmed reservations
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(4, 10000.00, 'ONLINE', 'COMPLETED'),
(5, 20000.00, 'CARD', 'COMPLETED'),
(6, 15000.00, 'ONLINE', 'COMPLETED');

-- Pending payment
INSERT INTO payments (reservation_id, amount, payment_method, payment_status) VALUES
(8, 20000.00, 'CARD', 'PENDING');

-- ================================================================
-- 6. INSERT AUDIT LOG (Sample entries)
-- ================================================================

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
-- Data Insertion Complete
-- ================================================================

-- Display record counts
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
SELECT role, COUNT(*) AS user_count, 
       SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_users
FROM users
GROUP BY role;

-- Display room summary by type
SELECT rt.type_name, COUNT(r.room_id) AS total_rooms,
       SUM(CASE WHEN r.status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available,
       SUM(CASE WHEN r.status = 'OCCUPIED' THEN 1 ELSE 0 END) AS occupied,
       SUM(CASE WHEN r.status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS maintenance
FROM room_types rt
LEFT JOIN rooms r ON rt.room_type_id = r.room_type_id
GROUP BY rt.room_type_id, rt.type_name;

-- Display reservation summary by status
SELECT status, COUNT(*) AS reservation_count, SUM(total_amount) AS total_revenue
FROM reservations
GROUP BY status;

-- Display payment summary
SELECT payment_method, payment_status, 
       COUNT(*) AS transaction_count, 
       SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method, payment_status;

-- Display total revenue
SELECT SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'COMPLETED';
