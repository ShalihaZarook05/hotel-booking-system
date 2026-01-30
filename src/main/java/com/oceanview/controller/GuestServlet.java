package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.User;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.util.SessionManager;
import com.oceanview.util.PasswordUtil;
import java.sql.Date;
import java.math.BigDecimal;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * GuestServlet
 * Handles guest-specific operations
 */
@WebServlet("/guest/*")
public class GuestServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private UserDAO userDAO;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = DAOFactory.getReservationDAO();
        userDAO = DAOFactory.getUserDAO();
        roomDAO = DAOFactory.getRoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is guest
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
            SessionManager.setErrorMessage(request, "Access denied! Guest access required.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/") || action.equals("/dashboard")) {
                showDashboard(request, response);
            } else if (action.equals("/profile")) {
                showProfile(request, response);
            } else if (action.equals("/reservations")) {
                showMyReservations(request, response);
            } else if (action.equals("/reservation/new")) {
                showNewReservationForm(request, response);
            } else if (action.equals("/reservation/view")) {
                viewReservation(request, response);
            } else {
                showDashboard(request, response);
            }
        } catch (Exception e) {
            System.err.println("=== ERROR in GuestServlet.doGet() ===");
            System.err.println("Action: " + action);
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("Error Class: " + e.getClass().getName());
            e.printStackTrace(System.err);
            System.err.println("=================================");
            
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage() + " (Action: " + action + ")");
            
            try {
                request.setAttribute("errorDetails", e.getClass().getName() + ": " + e.getMessage());
                request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/guest/dashboard");
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is guest
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action.equals("/updateProfile")) {
                updateProfile(request, response);
            } else if (action.equals("/reservation/create")) {
                createReservation(request, response);
            } else if (action.equals("/reservation/cancel")) {
                cancelReservation(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/guest/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/guest/dashboard");
        }
    }
    
    /**
     * Show guest dashboard
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        
        // Get user's reservations
        List<Reservation> myReservations = reservationDAO.getByGuestId(userId);
        
        // Calculate statistics
        long totalReservations = myReservations.size();
        long activeReservations = myReservations.stream()
            .filter(Reservation::isActive).count();
        long completedReservations = myReservations.stream()
            .filter(Reservation::isCheckedOut).count();
        long cancelledReservations = myReservations.stream()
            .filter(Reservation::isCancelled).count();
        
        // Get upcoming reservations
        List<Reservation> upcomingReservations = myReservations.stream()
            .filter(r -> r.isConfirmed() || r.isPending())
            .limit(5)
            .collect(java.util.stream.Collectors.toList());
        
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("activeReservations", activeReservations);
        request.setAttribute("completedReservations", completedReservations);
        request.setAttribute("cancelledReservations", cancelledReservations);
        request.setAttribute("upcomingReservations", upcomingReservations);
        
        request.getRequestDispatcher("/views/dashboard-guest.jsp").forward(request, response);
    }
    
    /**
     * Show profile page
     */
    private void showProfile(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        User user = userDAO.read(userId);
        
        request.setAttribute("user", user);
        request.getRequestDispatcher("/views/guest/profile.jsp").forward(request, response);
    }
    
    /**
     * Show my reservations
     */
    private void showMyReservations(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        List<Reservation> myReservations = reservationDAO.getByGuestId(userId);
        
        request.setAttribute("reservations", myReservations);
        request.getRequestDispatcher("/views/guest/my-reservations.jsp").forward(request, response);
    }
    
    /**
     * Update profile
     */
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        User user = userDAO.read(userId);
        
        // Update user details
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setAddress(request.getParameter("address"));
        
        // Update password if provided
        String newPassword = request.getParameter("newPassword");
        String currentPassword = request.getParameter("currentPassword");
        
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            // Verify current password
            String hashedCurrentPassword = PasswordUtil.hashPassword(currentPassword);
            if (!hashedCurrentPassword.equals(user.getPassword())) {
                SessionManager.setErrorMessage(request, "Current password is incorrect!");
                response.sendRedirect(request.getContextPath() + "/guest/profile");
                return;
            }
            user.setPassword(PasswordUtil.hashPassword(newPassword));
        }
        
        boolean success = userDAO.update(user);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Profile updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update profile!");
        }
        
        response.sendRedirect(request.getContextPath() + "/guest/profile");
    }
    
    /**
     * Show new reservation form
     */
    private void showNewReservationForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        System.out.println("=== showNewReservationForm() called ===");
        
        try {
            // Get available room types
            System.out.println("Calling roomDAO.getAllRoomTypes()...");
            List<RoomType> roomTypes = roomDAO.getAllRoomTypes();
            System.out.println("Room types retrieved: " + (roomTypes != null ? roomTypes.size() : "null"));
            
            if (roomTypes == null || roomTypes.isEmpty()) {
                System.err.println("WARNING: No room types found!");
                SessionManager.setErrorMessage(request, "No room types available. Please contact administration.");
            } else {
                System.out.println("Room types loaded successfully:");
                for (RoomType rt : roomTypes) {
                    System.out.println("  - " + rt.getTypeName() + " (ID: " + rt.getRoomTypeId() + ")");
                    System.out.println("    Has images: " + rt.hasImages());
                }
            }
            
            request.setAttribute("roomTypes", roomTypes);
            System.out.println("Forwarding to /views/guest/reservation-form.jsp");
            request.getRequestDispatcher("/views/guest/reservation-form.jsp").forward(request, response);
            System.out.println("=== showNewReservationForm() completed successfully ===");
            
        } catch (Exception e) {
            System.err.println("=== EXCEPTION in showNewReservationForm() ===");
            System.err.println("Error: " + e.getMessage());
            System.err.println("Error Class: " + e.getClass().getName());
            e.printStackTrace(System.err);
            System.err.println("==========================================");
            throw e; // Re-throw to be caught by doGet
        }
    }
    
    /**
     * Create new reservation
     */
    private void createReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        
        // Get form parameters
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        Date checkInDate = Date.valueOf(request.getParameter("checkInDate"));
        Date checkOutDate = Date.valueOf(request.getParameter("checkOutDate"));
        int numberOfGuests = Integer.parseInt(request.getParameter("numberOfGuests"));
        String specialRequests = request.getParameter("specialRequests");
        
        // Validate dates
        if (checkOutDate.before(checkInDate) || checkInDate.before(new Date(System.currentTimeMillis()))) {
            SessionManager.setErrorMessage(request, "Invalid dates! Check-out must be after check-in and dates must be in the future.");
            response.sendRedirect(request.getContextPath() + "/guest/reservation/new");
            return;
        }
        
        // Create reservation
        Reservation reservation = new Reservation();
        
        // Generate unique reservation number
        String reservationNumber = "RES" + System.currentTimeMillis() + userId;
        reservation.setReservationNumber(reservationNumber);
        
        reservation.setGuestId(userId);
        reservation.setRoomId(roomId);
        reservation.setCheckInDate(checkInDate);
        reservation.setCheckOutDate(checkOutDate);
        reservation.setNumberOfGuests(numberOfGuests);
        reservation.setSpecialRequests(specialRequests);
        reservation.setStatus(Reservation.STATUS_PENDING);
        
        // Set created by and created date
        reservation.setCreatedBy(userId);
        reservation.setCreatedDate(new java.sql.Timestamp(System.currentTimeMillis()));
        
        // Calculate total price
        Room room = roomDAO.readRoom(roomId);
        long days = (checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24);
        BigDecimal totalPrice = room.getRoomType().getPricePerNight().multiply(new BigDecimal(days));
        reservation.setTotalAmount(totalPrice);
        
        int reservationId = reservationDAO.create(reservation);
        
        if (reservationId > 0) {
            SessionManager.setSuccessMessage(request, "Reservation created successfully! Reservation ID: " + reservationId);
            response.sendRedirect(request.getContextPath() + "/guest/reservations");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create reservation!");
            response.sendRedirect(request.getContextPath() + "/guest/reservation/new");
        }
    }
    
    /**
     * View reservation details
     */
    private void viewReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        int userId = SessionManager.getUserId(request);
        
        Reservation reservation = reservationDAO.read(reservationId);
        
        // Verify reservation belongs to the user
        if (reservation == null || reservation.getGuestId() != userId) {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/guest/reservations");
            return;
        }
        
        request.setAttribute("reservation", reservation);
        request.getRequestDispatcher("/views/guest/reservation-details.jsp").forward(request, response);
    }
    
    /**
     * Cancel reservation
     */
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        int userId = SessionManager.getUserId(request);
        
        // Verify reservation belongs to the user
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation == null || reservation.getGuestId() != userId) {
            SessionManager.setErrorMessage(request, "Unauthorized action!");
            response.sendRedirect(request.getContextPath() + "/guest/reservations");
            return;
        }
        
        // Can only cancel pending or confirmed reservations
        if (!reservation.isPending() && !reservation.isConfirmed()) {
            SessionManager.setErrorMessage(request, "Cannot cancel reservation with status: " + reservation.getStatus());
            response.sendRedirect(request.getContextPath() + "/guest/reservations");
            return;
        }
        
        // Cancel the reservation
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CANCELLED);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Reservation cancelled successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to cancel reservation!");
        }
        
        response.sendRedirect(request.getContextPath() + "/guest/reservations");
    }
}
