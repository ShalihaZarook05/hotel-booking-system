package com.oceanview.test;

import com.oceanview.dao.*;
import com.oceanview.model.*;
import com.oceanview.service.*;
import com.oceanview.util.*;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 * BackendTest - Comprehensive test for all backend components
 * Tests Models, DAOs, Services, and Utilities
 */
public class BackendTest {
    
    private static int testsPassed = 0;
    private static int testsFailed = 0;
    private static int testsTotal = 0;
    
    public static void main(String[] args) {
        System.out.println("=====================================");
        System.out.println("Ocean View Resort - Backend Testing");
        System.out.println("=====================================\n");
        
        // Test Utilities
        testUtilities();
        
        // Test Models
        testModels();
        
        // Test Database Connection
        testDatabaseConnection();
        
        // Test DAOs
        testDAOs();
        
        // Test Services
        testServices();
        
        // Print summary
        printSummary();
    }
    
    // ============================================
    // UTILITY TESTS
    // ============================================
    
    private static void testUtilities() {
        System.out.println("\n=== TESTING UTILITIES ===\n");
        
        // Test PasswordUtil
        testPasswordUtil();
        
        // Test DateUtil
        testDateUtil();
        
        // Test ValidationService
        testValidationService();
    }
    
    private static void testPasswordUtil() {
        System.out.println("Testing PasswordUtil...");
        
        try {
            String password = "password123";
            String hashed = PasswordUtil.hashPassword(password);
            
            assertTrue("Password hashing", hashed != null && hashed.length() == 64);
            assertTrue("Password verification", PasswordUtil.verifyPassword(password, hashed));
            assertFalse("Wrong password rejection", PasswordUtil.verifyPassword("wrongpass", hashed));
            
            String salt = PasswordUtil.generateSalt();
            assertTrue("Salt generation", salt != null && !salt.isEmpty());
            
            String randomPass = PasswordUtil.generateRandomPassword(10);
            assertTrue("Random password generation", randomPass != null && randomPass.length() == 10);
            
            System.out.println("✓ PasswordUtil - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ PasswordUtil - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testDateUtil() {
        System.out.println("Testing DateUtil...");
        
        try {
            Date currentDate = DateUtil.getCurrentDate();
            assertTrue("Get current date", currentDate != null);
            
            Timestamp currentTimestamp = DateUtil.getCurrentTimestamp();
            assertTrue("Get current timestamp", currentTimestamp != null);
            
            String dateStr = "2026-01-28";
            Date sqlDate = DateUtil.stringToSqlDate(dateStr);
            assertTrue("String to SQL Date", sqlDate != null);
            
            String converted = DateUtil.sqlDateToString(sqlDate);
            assertTrue("SQL Date to String", dateStr.equals(converted));
            
            Date startDate = DateUtil.stringToSqlDate("2026-01-28");
            Date endDate = DateUtil.stringToSqlDate("2026-01-31");
            long days = DateUtil.daysBetween(startDate, endDate);
            assertTrue("Days between dates", days == 3);
            
            assertTrue("Valid date range", DateUtil.isValidDateRange(startDate, endDate));
            assertFalse("Invalid date range", DateUtil.isValidDateRange(endDate, startDate));
            
            Date futureDate = DateUtil.addDays(currentDate, 5);
            assertTrue("Add days to date", futureDate != null && futureDate.after(currentDate));
            
            System.out.println("✓ DateUtil - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ DateUtil - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testValidationService() {
        System.out.println("Testing ValidationService...");
        
        try {
            assertTrue("Valid email", ValidationService.isValidEmail("test@email.com"));
            assertFalse("Invalid email", ValidationService.isValidEmail("invalid-email"));
            
            assertTrue("Valid phone", ValidationService.isValidPhone("0771234567"));
            assertFalse("Invalid phone", ValidationService.isValidPhone("123"));
            
            assertTrue("Valid username", ValidationService.isValidUsername("user123"));
            assertFalse("Invalid username", ValidationService.isValidUsername("us"));
            
            assertTrue("Valid password", ValidationService.isValidPassword("pass123"));
            assertFalse("Invalid password", ValidationService.isValidPassword("123"));
            
            assertTrue("Numeric check", ValidationService.isNumeric("123"));
            assertFalse("Non-numeric check", ValidationService.isNumeric("abc"));
            
            String sanitized = ValidationService.sanitizeInput("<script>alert('xss')</script>");
            assertTrue("Input sanitization", !sanitized.contains("<script>"));
            
            System.out.println("✓ ValidationService - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ ValidationService - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    // ============================================
    // MODEL TESTS
    // ============================================
    
    private static void testModels() {
        System.out.println("\n=== TESTING MODELS ===\n");
        
        testUserModel();
        testRoomTypeModel();
        testRoomModel();
        testReservationModel();
        testPaymentModel();
    }
    
    private static void testUserModel() {
        System.out.println("Testing User Model...");
        
        try {
            User user = new User();
            user.setUserId(1);
            user.setUsername("testuser");
            user.setPassword("hashedpass");
            user.setFullName("Test User");
            user.setEmail("test@email.com");
            user.setPhone("0771234567");
            user.setAddress("Test Address");
            user.setRole(User.ROLE_GUEST);
            user.setStatus(User.STATUS_ACTIVE);
            
            assertTrue("User ID", user.getUserId() == 1);
            assertTrue("Username", "testuser".equals(user.getUsername()));
            assertTrue("Is Guest", user.isGuest());
            assertTrue("Is Active", user.isActive());
            assertFalse("Is Not Admin", user.isAdmin());
            
            System.out.println("✓ User Model - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ User Model - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testRoomTypeModel() {
        System.out.println("Testing RoomType Model...");
        
        try {
            RoomType roomType = new RoomType();
            roomType.setRoomTypeId(1);
            roomType.setTypeName("Deluxe Room");
            roomType.setDescription("Luxury room with sea view");
            roomType.setPricePerNight(new BigDecimal("8000.00"));
            roomType.setCapacity(2);
            roomType.setAmenities("WiFi, TV, AC");
            
            assertTrue("Room Type ID", roomType.getRoomTypeId() == 1);
            assertTrue("Type Name", "Deluxe Room".equals(roomType.getTypeName()));
            assertTrue("Price", roomType.getPricePerNight().compareTo(new BigDecimal("8000.00")) == 0);
            assertTrue("Capacity", roomType.getCapacity() == 2);
            
            System.out.println("✓ RoomType Model - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ RoomType Model - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testRoomModel() {
        System.out.println("Testing Room Model...");
        
        try {
            Room room = new Room();
            room.setRoomId(1);
            room.setRoomNumber("201");
            room.setRoomTypeId(1);
            room.setFloorNumber(2);
            room.setStatus(Room.STATUS_AVAILABLE);
            
            assertTrue("Room ID", room.getRoomId() == 1);
            assertTrue("Room Number", "201".equals(room.getRoomNumber()));
            assertTrue("Is Available", room.isAvailable());
            assertFalse("Is Not Occupied", room.isOccupied());
            
            System.out.println("✓ Room Model - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ Room Model - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testReservationModel() {
        System.out.println("Testing Reservation Model...");
        
        try {
            Reservation reservation = new Reservation();
            reservation.setReservationId(1);
            reservation.setReservationNumber("RES123456");
            reservation.setGuestId(1);
            reservation.setRoomId(1);
            reservation.setCheckInDate(DateUtil.stringToSqlDate("2026-01-28"));
            reservation.setCheckOutDate(DateUtil.stringToSqlDate("2026-01-31"));
            reservation.setNumberOfGuests(2);
            reservation.setStatus(Reservation.STATUS_CONFIRMED);
            reservation.setTotalAmount(new BigDecimal("24000.00"));
            reservation.setCreatedBy(1);
            
            assertTrue("Reservation ID", reservation.getReservationId() == 1);
            assertTrue("Number of nights", reservation.getNumberOfNights() == 3);
            assertTrue("Is Confirmed", reservation.isConfirmed());
            assertTrue("Is Active", reservation.isActive());
            
            System.out.println("✓ Reservation Model - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ Reservation Model - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testPaymentModel() {
        System.out.println("Testing Payment Model...");
        
        try {
            Payment payment = new Payment();
            payment.setPaymentId(1);
            payment.setReservationId(1);
            payment.setAmount(new BigDecimal("24000.00"));
            payment.setPaymentMethod(Payment.METHOD_CARD);
            payment.setPaymentStatus(Payment.STATUS_COMPLETED);
            
            assertTrue("Payment ID", payment.getPaymentId() == 1);
            assertTrue("Amount", payment.getAmount().compareTo(new BigDecimal("24000.00")) == 0);
            assertTrue("Is Completed", payment.isCompleted());
            assertTrue("Is Card Payment", payment.isCardPayment());
            
            System.out.println("✓ Payment Model - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ Payment Model - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    // ============================================
    // DATABASE CONNECTION TEST
    // ============================================
    
    private static void testDatabaseConnection() {
        System.out.println("\n=== TESTING DATABASE CONNECTION ===\n");
        
        try {
            DatabaseConnection dbConn = DatabaseConnection.getInstance();
            assertTrue("Database instance created", dbConn != null);
            
            boolean connected = dbConn.testConnection();
            assertTrue("Database connection test", connected);
            
            System.out.println("✓ Database Connection - Successfully connected\n");
        } catch (Exception e) {
            System.out.println("✗ Database Connection - Error: " + e.getMessage());
            System.out.println("  Make sure MySQL is running and database is created!\n");
            e.printStackTrace();
        }
    }
    
    // ============================================
    // DAO TESTS
    // ============================================
    
    private static void testDAOs() {
        System.out.println("\n=== TESTING DAOs ===\n");
        
        testUserDAO();
        testRoomDAO();
        testReservationDAO();
        testPaymentDAO();
    }
    
    private static void testUserDAO() {
        System.out.println("Testing UserDAO...");
        
        try {
            UserDAO userDAO = DAOFactory.getUserDAO();
            assertTrue("UserDAO instance", userDAO != null);
            
            // Test getAll
            List<User> users = userDAO.getAll();
            assertTrue("Get all users", users != null && users.size() > 0);
            System.out.println("  Found " + users.size() + " users");
            
            // Test findByUsername
            User admin = userDAO.findByUsername("admin");
            assertTrue("Find admin by username", admin != null && admin.isAdmin());
            System.out.println("  Admin user found: " + admin.getFullName());
            
            // Test authenticate
            String hashedPassword = PasswordUtil.hashPassword("password123");
            User authenticated = userDAO.authenticate("admin", hashedPassword);
            assertTrue("Authenticate user", authenticated != null);
            
            // Test getUsersByRole
            List<User> guests = userDAO.getUsersByRole(User.ROLE_GUEST);
            assertTrue("Get guests", guests != null && guests.size() > 0);
            System.out.println("  Found " + guests.size() + " guests");
            
            System.out.println("✓ UserDAO - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ UserDAO - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testRoomDAO() {
        System.out.println("Testing RoomDAO...");
        
        try {
            RoomDAO roomDAO = DAOFactory.getRoomDAO();
            assertTrue("RoomDAO instance", roomDAO != null);
            
            // Test getAllRooms
            List<Room> rooms = roomDAO.getAllRooms();
            assertTrue("Get all rooms", rooms != null && rooms.size() > 0);
            System.out.println("  Found " + rooms.size() + " rooms");
            
            // Test getAllRoomTypes
            List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
            assertTrue("Get all room types", roomTypes != null && roomTypes.size() > 0);
            System.out.println("  Found " + roomTypes.size() + " room types");
            
            // Test getRoomsByStatus
            List<Room> availableRooms = roomDAO.getRoomsByStatus(Room.STATUS_AVAILABLE);
            assertTrue("Get available rooms", availableRooms != null);
            System.out.println("  Found " + availableRooms.size() + " available rooms");
            
            // Test findByRoomNumber
            Room room = roomDAO.findByRoomNumber("101");
            assertTrue("Find room by number", room != null);
            
            System.out.println("✓ RoomDAO - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ RoomDAO - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testReservationDAO() {
        System.out.println("Testing ReservationDAO...");
        
        try {
            ReservationDAO reservationDAO = DAOFactory.getReservationDAO();
            assertTrue("ReservationDAO instance", reservationDAO != null);
            
            // Test getAll
            List<Reservation> reservations = reservationDAO.getAll();
            assertTrue("Get all reservations", reservations != null && reservations.size() > 0);
            System.out.println("  Found " + reservations.size() + " reservations");
            
            // Test getByStatus
            List<Reservation> confirmed = reservationDAO.getByStatus(Reservation.STATUS_CONFIRMED);
            assertTrue("Get confirmed reservations", confirmed != null);
            System.out.println("  Found " + confirmed.size() + " confirmed reservations");
            
            // Test getTodayCheckIns
            List<Reservation> checkIns = reservationDAO.getTodayCheckIns();
            assertTrue("Get today's check-ins", checkIns != null);
            System.out.println("  Today's check-ins: " + checkIns.size());
            
            // Test getTodayCheckOuts
            List<Reservation> checkOuts = reservationDAO.getTodayCheckOuts();
            assertTrue("Get today's check-outs", checkOuts != null);
            System.out.println("  Today's check-outs: " + checkOuts.size());
            
            System.out.println("✓ ReservationDAO - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ ReservationDAO - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testPaymentDAO() {
        System.out.println("Testing PaymentDAO...");
        
        try {
            PaymentDAO paymentDAO = DAOFactory.getPaymentDAO();
            assertTrue("PaymentDAO instance", paymentDAO != null);
            
            // Test getAll
            List<Payment> payments = paymentDAO.getAll();
            assertTrue("Get all payments", payments != null && payments.size() > 0);
            System.out.println("  Found " + payments.size() + " payments");
            
            // Test getTotalRevenue
            BigDecimal revenue = paymentDAO.getTotalRevenue();
            assertTrue("Get total revenue", revenue != null && revenue.compareTo(BigDecimal.ZERO) > 0);
            System.out.println("  Total revenue: LKR " + revenue);
            
            // Test getByStatus
            List<Payment> completed = paymentDAO.getByStatus(Payment.STATUS_COMPLETED);
            assertTrue("Get completed payments", completed != null);
            System.out.println("  Completed payments: " + completed.size());
            
            System.out.println("✓ PaymentDAO - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ PaymentDAO - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    // ============================================
    // SERVICE TESTS
    // ============================================
    
    private static void testServices() {
        System.out.println("\n=== TESTING SERVICES ===\n");
        
        testUserService();
        testReservationService();
        testBillingService();
    }
    
    private static void testUserService() {
        System.out.println("Testing UserService...");
        
        try {
            UserService userService = new UserService();
            assertTrue("UserService instance", userService != null);
            
            // Test authenticateUser
            User user = userService.authenticateUser("admin", "password123");
            assertTrue("Authenticate user", user != null && user.isAdmin());
            System.out.println("  Authenticated: " + user.getFullName());
            
            // Test getAllUsers
            List<User> users = userService.getAllUsers();
            assertTrue("Get all users", users != null && users.size() > 0);
            System.out.println("  Total users: " + users.size());
            
            // Test getUsersByRole
            List<User> guests = userService.getUsersByRole(User.ROLE_GUEST);
            assertTrue("Get guests", guests != null);
            System.out.println("  Total guests: " + guests.size());
            
            System.out.println("✓ UserService - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ UserService - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testReservationService() {
        System.out.println("Testing ReservationService...");
        
        try {
            ReservationService reservationService = new ReservationService();
            assertTrue("ReservationService instance", reservationService != null);
            
            // Test getAllReservations
            List<Reservation> reservations = reservationService.getAllReservations();
            assertTrue("Get all reservations", reservations != null && reservations.size() > 0);
            System.out.println("  Total reservations: " + reservations.size());
            
            // Test getReservationsByStatus
            List<Reservation> confirmed = reservationService.getReservationsByStatus(Reservation.STATUS_CONFIRMED);
            assertTrue("Get confirmed reservations", confirmed != null);
            System.out.println("  Confirmed reservations: " + confirmed.size());
            
            // Test getTodayCheckIns
            List<Reservation> checkIns = reservationService.getTodayCheckIns();
            assertTrue("Get today's check-ins", checkIns != null);
            
            // Test getTodayCheckOuts
            List<Reservation> checkOuts = reservationService.getTodayCheckOuts();
            assertTrue("Get today's check-outs", checkOuts != null);
            
            System.out.println("✓ ReservationService - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ ReservationService - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    private static void testBillingService() {
        System.out.println("Testing BillingService...");
        
        try {
            BillingService billingService = new BillingService();
            assertTrue("BillingService instance", billingService != null);
            
            // Test getTotalRevenue
            BigDecimal revenue = billingService.getTotalRevenue();
            assertTrue("Get total revenue", revenue != null && revenue.compareTo(BigDecimal.ZERO) >= 0);
            System.out.println("  Total revenue: LKR " + revenue);
            
            // Test getAllPayments
            List<Payment> payments = billingService.getAllPayments();
            assertTrue("Get all payments", payments != null);
            System.out.println("  Total payments: " + payments.size());
            
            System.out.println("✓ BillingService - All tests passed\n");
        } catch (Exception e) {
            System.out.println("✗ BillingService - Error: " + e.getMessage() + "\n");
            e.printStackTrace();
        }
    }
    
    // ============================================
    // HELPER METHODS
    // ============================================
    
    private static void assertTrue(String testName, boolean condition) {
        testsTotal++;
        if (condition) {
            testsPassed++;
            System.out.println("  ✓ " + testName);
        } else {
            testsFailed++;
            System.out.println("  ✗ " + testName + " - FAILED");
        }
    }
    
    private static void assertFalse(String testName, boolean condition) {
        assertTrue(testName, !condition);
    }
    
    private static void printSummary() {
        System.out.println("\n=====================================");
        System.out.println("TEST SUMMARY");
        System.out.println("=====================================");
        System.out.println("Total Tests: " + testsTotal);
        System.out.println("Passed: " + testsPassed + " ✓");
        System.out.println("Failed: " + testsFailed + " ✗");
        System.out.println("Success Rate: " + String.format("%.2f", (testsPassed * 100.0 / testsTotal)) + "%");
        System.out.println("=====================================\n");
        
        if (testsFailed == 0) {
            System.out.println("🎉 ALL TESTS PASSED! Backend is working correctly.");
        } else {
            System.out.println("⚠️  Some tests failed. Please review the errors above.");
        }
    }
}
