package com.oceanview.controller;

import com.oceanview.dao.UserDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.User;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.util.PasswordUtil;
import com.oceanview.util.SessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * AdminServlet
 * Handles admin-specific operations
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    private PaymentDAO paymentDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = DAOFactory.getUserDAO();
        reservationDAO = DAOFactory.getReservationDAO();
        roomDAO = DAOFactory.getRoomDAO();
        paymentDAO = DAOFactory.getPaymentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
            SessionManager.setErrorMessage(request, "Access denied! Admin access required.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/") || action.equals("/dashboard")) {
                showDashboard(request, response);
            } else if (action.equals("/users")) {
                listUsers(request, response);
            } else if (action.equals("/user/new")) {
                showNewUserForm(request, response);
            } else if (action.equals("/user/edit")) {
                showEditUserForm(request, response);
            } else if (action.equals("/user/delete")) {
                deleteUser(request, response);
            } else if (action.equals("/rooms")) {
                listRooms(request, response);
            } else if (action.equals("/room/new")) {
                showNewRoomForm(request, response);
            } else if (action.equals("/room/edit")) {
                showEditRoomForm(request, response);
            } else if (action.equals("/room/delete")) {
                deleteRoom(request, response);
            } else if (action.equals("/roomtypes")) {
                listRoomTypes(request, response);
            } else if (action.equals("/roomtype/new")) {
                showNewRoomTypeForm(request, response);
            } else if (action.equals("/roomtype/edit")) {
                showEditRoomTypeForm(request, response);
            } else if (action.equals("/roomtype/delete")) {
                deleteRoomType(request, response);
            } else if (action.equals("/reservations")) {
                listReservations(request, response);
            } else if (action.equals("/reservation/view")) {
                viewReservation(request, response);
            } else {
                showDashboard(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action.equals("/user/create")) {
                createUser(request, response);
            } else if (action.equals("/user/update")) {
                updateUser(request, response);
            } else if (action.equals("/room/create")) {
                createRoom(request, response);
            } else if (action.equals("/room/update")) {
                updateRoom(request, response);
            } else if (action.equals("/roomtype/create")) {
                createRoomType(request, response);
            } else if (action.equals("/roomtype/update")) {
                updateRoomType(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }
    
    /**
     * Show admin dashboard with statistics
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get statistics
        List<Reservation> allReservations = reservationDAO.getAll();
        List<User> allUsers = userDAO.getAll();
        List<Room> allRooms = roomDAO.getAllRooms();
        BigDecimal totalRevenue = paymentDAO.getTotalRevenue();
        
        // Calculate statistics
        long totalReservations = allReservations.size();
        long totalUsers = allUsers.size();
        long totalRooms = allRooms.size();
        long availableRooms = allRooms.stream().filter(Room::isAvailable).count();
        long occupiedRooms = allRooms.stream().filter(Room::isOccupied).count();
        long maintenanceRooms = allRooms.stream().filter(Room::isUnderMaintenance).count();
        
        // Today's check-ins and check-outs
        List<Reservation> todayCheckIns = reservationDAO.getTodayCheckIns();
        List<Reservation> todayCheckOuts = reservationDAO.getTodayCheckOuts();
        
        // Set attributes
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalRooms", totalRooms);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("occupiedRooms", occupiedRooms);
        request.setAttribute("maintenanceRooms", maintenanceRooms);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("todayCheckIns", todayCheckIns);
        request.setAttribute("todayCheckOuts", todayCheckOuts);
        
        request.getRequestDispatcher("/views/dashboard-admin.jsp").forward(request, response);
    }
    
    /**
     * List all users
     */
    private void listUsers(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<User> users = userDAO.getAll();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/views/admin/user-list.jsp").forward(request, response);
    }
    
    /**
     * Show new user form
     */
    private void showNewUserForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        request.getRequestDispatcher("/views/admin/user-form.jsp").forward(request, response);
    }
    
    /**
     * Create new user
     */
    private void createUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String role = request.getParameter("role");
        
        // Hash password
        String hashedPassword = PasswordUtil.hashPassword(password);
        
        // Create user
        User user = new User(username, hashedPassword, fullName, email, phone, address, role);
        int userId = userDAO.create(user);
        
        if (userId > 0) {
            SessionManager.setSuccessMessage(request, "User created successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create user!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
    
    /**
     * Show edit user form
     */
    private void showEditUserForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.read(userId);
        
        request.setAttribute("user", user);
        request.getRequestDispatcher("/views/admin/user-form.jsp").forward(request, response);
    }
    
    /**
     * Update user
     */
    private void updateUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = userDAO.read(userId);
        
        user.setUsername(request.getParameter("username"));
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setAddress(request.getParameter("address"));
        user.setRole(request.getParameter("role"));
        user.setStatus(request.getParameter("status"));
        
        // Update password if provided
        String newPassword = request.getParameter("password");
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            user.setPassword(PasswordUtil.hashPassword(newPassword));
        }
        
        boolean success = userDAO.update(user);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "User updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update user!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
    
    /**
     * Delete user
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = Integer.parseInt(request.getParameter("id"));
        
        try {
            boolean success = userDAO.delete(userId);
            
            if (success) {
                SessionManager.setSuccessMessage(request, "User deleted successfully!");
            } else {
                SessionManager.setErrorMessage(request, "Failed to delete user!");
            }
        } catch (Exception e) {
            // Handle the foreign key constraint error with a user-friendly message
            SessionManager.setErrorMessage(request, e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
    
    /**
     * List all rooms
     */
    private void listRooms(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Room> rooms = roomDAO.getAllRooms();
        request.setAttribute("rooms", rooms);
        request.getRequestDispatcher("/views/admin/room-list.jsp").forward(request, response);
    }
    
    /**
     * Show new room form
     */
    private void showNewRoomForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);
        request.getRequestDispatcher("/views/admin/room-form.jsp").forward(request, response);
    }
    
    /**
     * Create new room
     */
    private void createRoom(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String roomNumber = request.getParameter("roomNumber");
        int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
        int floorNumber = Integer.parseInt(request.getParameter("floorNumber"));
        String status = request.getParameter("status");
        
        Room room = new Room(roomNumber, roomTypeId, floorNumber);
        room.setStatus(status);
        
        int roomId = roomDAO.createRoom(room);
        
        if (roomId > 0) {
            SessionManager.setSuccessMessage(request, "Room created successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create room!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/rooms");
    }
    
    /**
     * Show edit room form
     */
    private void showEditRoomForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomId = Integer.parseInt(request.getParameter("id"));
        Room room = roomDAO.readRoom(roomId);
        List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
        
        request.setAttribute("room", room);
        request.setAttribute("roomTypes", roomTypes);
        request.getRequestDispatcher("/views/admin/room-form.jsp").forward(request, response);
    }
    
    /**
     * Update room
     */
    private void updateRoom(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        Room room = roomDAO.readRoom(roomId);
        
        room.setRoomNumber(request.getParameter("roomNumber"));
        room.setRoomTypeId(Integer.parseInt(request.getParameter("roomTypeId")));
        room.setFloorNumber(Integer.parseInt(request.getParameter("floorNumber")));
        room.setStatus(request.getParameter("status"));
        
        boolean success = roomDAO.updateRoom(room);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Room updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update room!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/rooms");
    }
    
    /**
     * Delete room
     */
    private void deleteRoom(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomId = Integer.parseInt(request.getParameter("id"));
        
        try {
            boolean success = roomDAO.deleteRoom(roomId);
            
            if (success) {
                SessionManager.setSuccessMessage(request, "Room deleted successfully!");
            } else {
                SessionManager.setErrorMessage(request, "Failed to delete room!");
            }
        } catch (Exception e) {
            // Handle the foreign key constraint error with a user-friendly message
            SessionManager.setErrorMessage(request, e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/rooms");
    }
    
    /**
     * List all room types
     */
    private void listRoomTypes(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
        request.setAttribute("roomTypes", roomTypes);
        request.getRequestDispatcher("/views/admin/roomtype-list.jsp").forward(request, response);
    }
    
    /**
     * Show new room type form
     */
    private void showNewRoomTypeForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        request.getRequestDispatcher("/views/admin/roomtype-form.jsp").forward(request, response);
    }
    
    /**
     * Create new room type
     */
    private void createRoomType(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String typeName = request.getParameter("typeName");
        String description = request.getParameter("description");
        BigDecimal pricePerNight = new BigDecimal(request.getParameter("pricePerNight"));
        int capacity = Integer.parseInt(request.getParameter("capacity"));
        String amenities = request.getParameter("amenities");
        
        RoomType roomType = new RoomType(typeName, description, pricePerNight, capacity, amenities);
        int roomTypeId = roomDAO.createRoomType(roomType);
        
        if (roomTypeId > 0) {
            SessionManager.setSuccessMessage(request, "Room type created successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create room type!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/roomtypes");
    }
    
    /**
     * Show edit room type form
     */
    private void showEditRoomTypeForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomTypeId = Integer.parseInt(request.getParameter("id"));
        RoomType roomType = roomDAO.readRoomType(roomTypeId);
        
        request.setAttribute("roomType", roomType);
        request.getRequestDispatcher("/views/admin/roomtype-form.jsp").forward(request, response);
    }
    
    /**
     * Update room type
     */
    private void updateRoomType(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
        RoomType roomType = roomDAO.readRoomType(roomTypeId);
        
        roomType.setTypeName(request.getParameter("typeName"));
        roomType.setDescription(request.getParameter("description"));
        roomType.setPricePerNight(new BigDecimal(request.getParameter("pricePerNight")));
        roomType.setCapacity(Integer.parseInt(request.getParameter("capacity")));
        roomType.setAmenities(request.getParameter("amenities"));
        
        boolean success = roomDAO.updateRoomType(roomType);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Room type updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update room type!");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/roomtypes");
    }
    
    /**
     * Delete room type
     */
    private void deleteRoomType(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomTypeId = Integer.parseInt(request.getParameter("id"));
        
        try {
            boolean success = roomDAO.deleteRoomType(roomTypeId);
            
            if (success) {
                SessionManager.setSuccessMessage(request, "Room type deleted successfully!");
            } else {
                SessionManager.setErrorMessage(request, "Failed to delete room type!");
            }
        } catch (Exception e) {
            // Handle the foreign key constraint error with a user-friendly message
            SessionManager.setErrorMessage(request, e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/roomtypes");
    }
    
    /**
     * List all reservations
     */
    private void listReservations(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        System.out.println("=== listReservations() called ===");
        
        try {
            // Get all reservations
            List<Reservation> reservations = reservationDAO.getAll();
            System.out.println("Found " + (reservations != null ? reservations.size() : "null") + " reservations");
            
            // Get statistics
            long confirmedCount = reservations.stream().filter(r -> "CONFIRMED".equals(r.getStatus())).count();
            long checkedInCount = reservations.stream().filter(r -> "CHECKED_IN".equals(r.getStatus())).count();
            long checkedOutCount = reservations.stream().filter(r -> "CHECKED_OUT".equals(r.getStatus())).count();
            long cancelledCount = reservations.stream().filter(r -> "CANCELLED".equals(r.getStatus())).count();
            long pendingCount = reservations.stream().filter(r -> "PENDING".equals(r.getStatus())).count();
            
            request.setAttribute("reservations", reservations);
            request.setAttribute("confirmedCount", confirmedCount);
            request.setAttribute("checkedInCount", checkedInCount);
            request.setAttribute("checkedOutCount", checkedOutCount);
            request.setAttribute("cancelledCount", cancelledCount);
            request.setAttribute("pendingCount", pendingCount);
            
            request.getRequestDispatcher("/views/admin/reservation-list.jsp").forward(request, response);
            System.out.println("=== listReservations() completed ===");
            
        } catch (Exception e) {
            System.err.println("=== ERROR in listReservations() ===");
            e.printStackTrace(System.err);
            throw e;
        }
    }
    
    /**
     * View reservation details
     */
    private void viewReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            // Get guest details
            User guest = userDAO.read(reservation.getGuestId());
            // Get room details
            Room room = roomDAO.readRoom(reservation.getRoomId());
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("guest", guest);
            request.setAttribute("room", room);
            
            request.getRequestDispatcher("/views/admin/reservation-details.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/admin/reservations");
        }
    }
}
