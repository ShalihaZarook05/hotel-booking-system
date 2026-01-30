package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.util.SessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.math.BigDecimal;
import java.util.List;

/**
 * StaffServlet
 * Handles staff-specific operations including CRUD for check-in/check-out
 */
@WebServlet("/staff/*")
public class StaffServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = DAOFactory.getReservationDAO();
        roomDAO = DAOFactory.getRoomDAO();
        userDAO = DAOFactory.getUserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is staff
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
            SessionManager.setErrorMessage(request, "Access denied! Staff access required.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/") || action.equals("/dashboard")) {
                showDashboard(request, response);
            } else if (action.equals("/pending")) {
                showPendingReservations(request, response);
            } else if (action.equals("/pending/view")) {
                viewPendingReservationDetails(request, response);
            } else if (action.equals("/checkin")) {
                showCheckIns(request, response);
            } else if (action.equals("/checkin/form")) {
                showCheckInForm(request, response);
            } else if (action.equals("/checkin/view")) {
                viewCheckInDetails(request, response);
            } else if (action.equals("/checkout")) {
                showCheckOuts(request, response);
            } else if (action.equals("/checkout/form")) {
                showCheckOutForm(request, response);
            } else if (action.equals("/checkout/view")) {
                viewCheckOutDetails(request, response);
            } else if (action.equals("/rooms")) {
                showRoomStatus(request, response);
            } else if (action.equals("/rooms/updateStatus")) {
                showUpdateRoomStatusForm(request, response);
            } else if (action.equals("/reservation/search")) {
                searchReservation(request, response);
            } else {
                showDashboard(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is staff
        if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action.equals("/pending/confirm")) {
                confirmPendingReservation(request, response);
            } else if (action.equals("/pending/reject")) {
                rejectPendingReservation(request, response);
            } else if (action.equals("/processCheckIn")) {
                processCheckIn(request, response);
            } else if (action.equals("/processCheckOut")) {
                processCheckOut(request, response);
            } else if (action.equals("/checkin/create")) {
                createCheckIn(request, response);
            } else if (action.equals("/checkin/update")) {
                updateCheckIn(request, response);
            } else if (action.equals("/checkin/cancel")) {
                cancelReservation(request, response);
            } else if (action.equals("/checkout/process")) {
                processCheckOutWithBilling(request, response);
            } else if (action.equals("/rooms/updateStatus")) {
                updateRoomStatus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
        }
    }
    
    /**
     * Show staff dashboard
     */
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get today's activities
        List<Reservation> todayCheckIns = reservationDAO.getTodayCheckIns();
        List<Reservation> todayCheckOuts = reservationDAO.getTodayCheckOuts();
        
        // Get room statistics
        List<Room> allRooms = roomDAO.getAllRooms();
        long availableRooms = allRooms.stream().filter(Room::isAvailable).count();
        long occupiedRooms = allRooms.stream().filter(Room::isOccupied).count();
        long maintenanceRooms = allRooms.stream().filter(Room::isUnderMaintenance).count();
        
        // Get pending reservations
        List<Reservation> pendingReservations = reservationDAO.getByStatus(Reservation.STATUS_PENDING);
        
        request.setAttribute("todayCheckIns", todayCheckIns);
        request.setAttribute("todayCheckOuts", todayCheckOuts);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("occupiedRooms", occupiedRooms);
        request.setAttribute("maintenanceRooms", maintenanceRooms);
        request.setAttribute("pendingReservations", pendingReservations);
        
        request.getRequestDispatcher("/views/dashboard-staff.jsp").forward(request, response);
    }
    
    /**
     * Show check-ins
     */
    private void showCheckIns(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Reservation> checkIns = reservationDAO.getTodayCheckIns();
        request.setAttribute("checkIns", checkIns);
        request.getRequestDispatcher("/views/staff/checkin-list.jsp").forward(request, response);
    }
    
    /**
     * Show check-outs
     */
    private void showCheckOuts(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Reservation> checkOuts = reservationDAO.getTodayCheckOuts();
        request.setAttribute("checkOuts", checkOuts);
        request.getRequestDispatcher("/views/staff/checkout-list.jsp").forward(request, response);
    }
    
    /**
     * Show room status
     */
    private void showRoomStatus(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Room> rooms = roomDAO.getAllRooms();
        request.setAttribute("rooms", rooms);
        request.getRequestDispatcher("/views/staff/room-status.jsp").forward(request, response);
    }
    
    /**
     * Process check-in
     */
    private void processCheckIn(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        
        // Update reservation status to CHECKED_IN
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_IN);
        
        if (success) {
            // Update room status to OCCUPIED
            Reservation reservation = reservationDAO.read(reservationId);
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_OCCUPIED);
            
            SessionManager.setSuccessMessage(request, "Check-in processed successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to process check-in!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/checkin");
    }
    
    /**
     * Process check-out
     */
    private void processCheckOut(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        
        // Update reservation status to CHECKED_OUT
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_OUT);
        
        if (success) {
            // Update room status to AVAILABLE
            Reservation reservation = reservationDAO.read(reservationId);
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
            
            SessionManager.setSuccessMessage(request, "Check-out processed successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to process check-out!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/checkout");
    }
    
    /**
     * Show check-in form for creating new walk-in reservation
     */
    private void showCheckInForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get all available rooms for selection
        List<Room> availableRooms = roomDAO.getRoomsByStatus(Room.STATUS_AVAILABLE);
        request.setAttribute("availableRooms", availableRooms);
        
        // Get all guests for selection
        List<User> guests = userDAO.getUsersByRole(User.ROLE_GUEST);
        request.setAttribute("guests", guests);
        
        request.getRequestDispatcher("/views/staff/checkin-form.jsp").forward(request, response);
    }
    
    /**
     * View check-in details
     */
    private void viewCheckInDetails(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            User guest = userDAO.read(reservation.getGuestId());
            Room room = roomDAO.read(reservation.getRoomId());
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("guest", guest);
            request.setAttribute("room", room);
            
            request.getRequestDispatcher("/views/staff/checkin-details.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/staff/checkin");
        }
    }
    
    /**
     * Create new check-in (walk-in guest)
     */
    private void createCheckIn(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int guestId = Integer.parseInt(request.getParameter("guestId"));
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        Date checkInDate = Date.valueOf(request.getParameter("checkInDate"));
        Date checkOutDate = Date.valueOf(request.getParameter("checkOutDate"));
        int numberOfGuests = Integer.parseInt(request.getParameter("numberOfGuests"));
        String specialRequests = request.getParameter("specialRequests");
        BigDecimal totalAmount = new BigDecimal(request.getParameter("totalAmount"));
        
        User currentUser = SessionManager.getLoggedInUser(request);
        
        // Create reservation object
        Reservation reservation = new Reservation();
        reservation.setReservationNumber("RES" + System.currentTimeMillis());
        reservation.setGuestId(guestId);
        reservation.setRoomId(roomId);
        reservation.setCheckInDate(checkInDate);
        reservation.setCheckOutDate(checkOutDate);
        reservation.setNumberOfGuests(numberOfGuests);
        reservation.setSpecialRequests(specialRequests);
        reservation.setStatus(Reservation.STATUS_CONFIRMED);
        reservation.setTotalAmount(totalAmount);
        reservation.setCreatedBy(currentUser.getUserId());
        reservation.setCreatedDate(new Timestamp(System.currentTimeMillis()));
        
        int reservationId = reservationDAO.create(reservation);
        
        if (reservationId > 0) {
            SessionManager.setSuccessMessage(request, "Check-in reservation created successfully!");
            response.sendRedirect(request.getContextPath() + "/staff/checkin");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create check-in reservation!");
            response.sendRedirect(request.getContextPath() + "/staff/checkin/form");
        }
    }
    
    /**
     * Update check-in reservation
     */
    private void updateCheckIn(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            reservation.setCheckInDate(Date.valueOf(request.getParameter("checkInDate")));
            reservation.setCheckOutDate(Date.valueOf(request.getParameter("checkOutDate")));
            reservation.setNumberOfGuests(Integer.parseInt(request.getParameter("numberOfGuests")));
            reservation.setSpecialRequests(request.getParameter("specialRequests"));
            
            boolean success = reservationDAO.update(reservation);
            
            if (success) {
                SessionManager.setSuccessMessage(request, "Reservation updated successfully!");
            } else {
                SessionManager.setErrorMessage(request, "Failed to update reservation!");
            }
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/checkin");
    }
    
    /**
     * Cancel reservation
     */
    private void cancelReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CANCELLED);
        
        if (success) {
            // Update room status to available
            Reservation reservation = reservationDAO.read(reservationId);
            if (reservation != null && "CONFIRMED".equals(reservation.getStatus())) {
                roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
            }
            SessionManager.setSuccessMessage(request, "Reservation cancelled successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to cancel reservation!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/checkin");
    }
    
    /**
     * Show checkout form with billing details
     */
    private void showCheckOutForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            User guest = userDAO.read(reservation.getGuestId());
            Room room = roomDAO.read(reservation.getRoomId());
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("guest", guest);
            request.setAttribute("room", room);
            
            request.getRequestDispatcher("/views/staff/checkout-form.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/staff/checkout");
        }
    }
    
    /**
     * View checkout details
     */
    private void viewCheckOutDetails(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            User guest = userDAO.read(reservation.getGuestId());
            Room room = roomDAO.read(reservation.getRoomId());
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("guest", guest);
            request.setAttribute("room", room);
            
            request.getRequestDispatcher("/views/staff/checkout-details.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/staff/checkout");
        }
    }
    
    /**
     * Process checkout with billing
     */
    private void processCheckOutWithBilling(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String paymentMethod = request.getParameter("paymentMethod");
        String notes = request.getParameter("notes");
        
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            // Update reservation status to CHECKED_OUT
            boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_OUT);
            
            if (success) {
                // Update room status to AVAILABLE
                roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
                
                SessionManager.setSuccessMessage(request, "Check-out completed successfully! Payment method: " + paymentMethod);
            } else {
                SessionManager.setErrorMessage(request, "Failed to process check-out!");
            }
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/checkout");
    }
    
    /**
     * Show update room status form
     */
    private void showUpdateRoomStatusForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomId = Integer.parseInt(request.getParameter("id"));
        Room room = roomDAO.read(roomId);
        
        if (room != null) {
            request.setAttribute("room", room);
            request.getRequestDispatcher("/views/staff/room-status-form.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Room not found!");
            response.sendRedirect(request.getContextPath() + "/staff/rooms");
        }
    }
    
    /**
     * Update room status
     */
    private void updateRoomStatus(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String newStatus = request.getParameter("status");
        
        boolean success = roomDAO.updateRoomStatus(roomId, newStatus);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Room status updated successfully to " + newStatus + "!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update room status!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/rooms");
    }
    
    /**
     * Search for reservation by number or guest name
     */
    private void searchReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String searchQuery = request.getParameter("query");
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            // Try to find by reservation number first
            Reservation reservation = reservationDAO.findByReservationNumber(searchQuery);
            
            if (reservation != null) {
                request.setAttribute("searchResults", List.of(reservation));
            } else {
                request.setAttribute("searchResults", List.of());
            }
        }
        
        request.getRequestDispatcher("/views/staff/reservation-search.jsp").forward(request, response);
    }
    
    /**
     * Show pending reservations
     */
    private void showPendingReservations(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get all pending reservations
        List<Reservation> pendingReservations = reservationDAO.getByStatus(Reservation.STATUS_PENDING);
        
        // Load guest and room information for each reservation
        for (Reservation reservation : pendingReservations) {
            User guest = userDAO.read(reservation.getGuestId());
            Room room = roomDAO.read(reservation.getRoomId());
            reservation.setGuest(guest);
            reservation.setRoom(room);
        }
        
        request.setAttribute("pendingReservations", pendingReservations);
        request.getRequestDispatcher("/views/staff/pending-reservations.jsp").forward(request, response);
    }
    
    /**
     * View pending reservation details
     */
    private void viewPendingReservationDetails(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null) {
            User guest = userDAO.read(reservation.getGuestId());
            Room room = roomDAO.read(reservation.getRoomId());
            
            request.setAttribute("reservation", reservation);
            request.setAttribute("guest", guest);
            request.setAttribute("room", room);
            
            request.getRequestDispatcher("/views/staff/pending-reservation-details.jsp").forward(request, response);
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/staff/pending");
        }
    }
    
    /**
     * Confirm pending reservation
     */
    private void confirmPendingReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        
        // Get reservation details
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null && Reservation.STATUS_PENDING.equals(reservation.getStatus())) {
            // For pending reservations, we don't need to check availability again
            // as the room was already reserved when the booking was made
            // Just update the status to CONFIRMED
            boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CONFIRMED);
            
            if (success) {
                SessionManager.setSuccessMessage(request, 
                    "Reservation " + reservation.getReservationNumber() + " confirmed successfully!");
            } else {
                SessionManager.setErrorMessage(request, "Failed to confirm reservation!");
            }
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found or already processed!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/pending");
    }
    
    /**
     * Reject pending reservation
     */
    private void rejectPendingReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String rejectionReason = request.getParameter("rejectionReason");
        
        // Get reservation details
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation != null && Reservation.STATUS_PENDING.equals(reservation.getStatus())) {
            // Update reservation status to CANCELLED
            boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CANCELLED);
            
            if (success) {
                // In a real application, you would:
                // 1. Send email notification to guest with rejection reason
                // 2. Log the rejection reason in the database
                // 3. Process any refunds if payment was made
                
                SessionManager.setSuccessMessage(request, 
                    "Reservation " + reservation.getReservationNumber() + " has been rejected.");
            } else {
                SessionManager.setErrorMessage(request, "Failed to reject reservation!");
            }
        } else {
            SessionManager.setErrorMessage(request, "Reservation not found or already processed!");
        }
        
        response.sendRedirect(request.getContextPath() + "/staff/pending");
    }
}
