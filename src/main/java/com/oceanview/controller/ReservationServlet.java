package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.util.DateUtil;
import com.oceanview.util.SessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/**
 * ReservationServlet
 * Handles reservation CRUD operations
 */
@WebServlet("/reservation/*")
public class ReservationServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = DAOFactory.getReservationDAO();
        roomDAO = DAOFactory.getRoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        if (!SessionManager.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/")) {
                listReservations(request, response);
            } else if (action.equals("/new")) {
                showNewReservationForm(request, response);
            } else if (action.equals("/edit")) {
                showEditReservationForm(request, response);
            } else if (action.equals("/view")) {
                viewReservation(request, response);
            } else if (action.equals("/delete")) {
                deleteReservation(request, response);
            } else {
                listReservations(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/reservation");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        if (!SessionManager.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action.equals("/create")) {
                createReservation(request, response);
            } else if (action.equals("/update")) {
                updateReservation(request, response);
            } else if (action.equals("/updateStatus")) {
                updateReservationStatus(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/reservation");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/reservation");
        }
    }
    
    /**
     * List all reservations
     */
    private void listReservations(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int userId = SessionManager.getUserId(request);
        String userRole = SessionManager.getUserRole(request);
        
        List<Reservation> reservations;
        
        // Admin and Staff can see all reservations, Guests see only their own
        if (SessionManager.isAdmin(request) || SessionManager.isStaff(request)) {
            reservations = reservationDAO.getAll();
        } else {
            reservations = reservationDAO.getByGuestId(userId);
        }
        
        request.setAttribute("reservations", reservations);
        request.getRequestDispatcher("/views/view-reservations.jsp").forward(request, response);
    }
    
    /**
     * Show new reservation form
     */
    private void showNewReservationForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get available room types
        List<Room> rooms = roomDAO.getAllRooms();
        request.setAttribute("rooms", rooms);
        
        request.getRequestDispatcher("/views/create-reservation.jsp").forward(request, response);
    }
    
    /**
     * Create new reservation
     */
    private void createReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get form parameters
        int guestId = SessionManager.getUserId(request);
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String checkInDateStr = request.getParameter("checkInDate");
        String checkOutDateStr = request.getParameter("checkOutDate");
        int numberOfGuests = Integer.parseInt(request.getParameter("numberOfGuests"));
        String specialRequests = request.getParameter("specialRequests");
        
        // Convert dates
        Date checkInDate = DateUtil.stringToSqlDate(checkInDateStr);
        Date checkOutDate = DateUtil.stringToSqlDate(checkOutDateStr);
        
        // Validation
        if (checkInDate == null || checkOutDate == null) {
            SessionManager.setErrorMessage(request, "Invalid dates!");
            response.sendRedirect(request.getContextPath() + "/reservation/new");
            return;
        }
        
        if (!DateUtil.isValidDateRange(checkInDate, checkOutDate)) {
            SessionManager.setErrorMessage(request, "Check-out date must be after check-in date!");
            response.sendRedirect(request.getContextPath() + "/reservation/new");
            return;
        }
        
        if (DateUtil.isPastDate(checkInDate)) {
            SessionManager.setErrorMessage(request, "Check-in date cannot be in the past!");
            response.sendRedirect(request.getContextPath() + "/reservation/new");
            return;
        }
        
        // Check room availability
        if (!reservationDAO.isRoomAvailable(roomId, checkInDate, checkOutDate)) {
            SessionManager.setErrorMessage(request, "Room is not available for selected dates!");
            response.sendRedirect(request.getContextPath() + "/reservation/new");
            return;
        }
        
        // Get room details for price calculation
        Room room = roomDAO.readRoom(roomId);
        long numberOfNights = DateUtil.daysBetween(checkInDate, checkOutDate);
        BigDecimal totalAmount = room.getRoomType().getPricePerNight().multiply(BigDecimal.valueOf(numberOfNights));
        
        // Generate unique reservation number
        String reservationNumber = "RES" + System.currentTimeMillis();
        
        // Create reservation object
        Reservation reservation = new Reservation(reservationNumber, guestId, roomId, 
                                                   checkInDate, checkOutDate, numberOfGuests, 
                                                   specialRequests, guestId);
        reservation.setTotalAmount(totalAmount);
        reservation.setStatus(Reservation.STATUS_PENDING);
        
        // Save to database
        int reservationId = reservationDAO.create(reservation);
        
        if (reservationId > 0) {
            // Update room status
            roomDAO.updateRoomStatus(roomId, Room.STATUS_OCCUPIED);
            
            SessionManager.setSuccessMessage(request, "Reservation created successfully! Reservation Number: " + reservationNumber);
            response.sendRedirect(request.getContextPath() + "/reservation");
        } else {
            SessionManager.setErrorMessage(request, "Failed to create reservation!");
            response.sendRedirect(request.getContextPath() + "/reservation/new");
        }
    }
    
    /**
     * Show edit reservation form
     */
    private void showEditReservationForm(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation == null) {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/reservation");
            return;
        }
        
        // Get available rooms
        List<Room> rooms = roomDAO.getAllRooms();
        
        request.setAttribute("reservation", reservation);
        request.setAttribute("rooms", rooms);
        request.getRequestDispatcher("/views/edit-reservation.jsp").forward(request, response);
    }
    
    /**
     * Update reservation
     */
    private void updateReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation == null) {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/reservation");
            return;
        }
        
        // Update fields
        reservation.setRoomId(Integer.parseInt(request.getParameter("roomId")));
        reservation.setCheckInDate(DateUtil.stringToSqlDate(request.getParameter("checkInDate")));
        reservation.setCheckOutDate(DateUtil.stringToSqlDate(request.getParameter("checkOutDate")));
        reservation.setNumberOfGuests(Integer.parseInt(request.getParameter("numberOfGuests")));
        reservation.setSpecialRequests(request.getParameter("specialRequests"));
        
        // Recalculate total amount
        Room room = roomDAO.readRoom(reservation.getRoomId());
        long numberOfNights = reservation.getNumberOfNights();
        BigDecimal totalAmount = room.getRoomType().getPricePerNight().multiply(BigDecimal.valueOf(numberOfNights));
        reservation.setTotalAmount(totalAmount);
        
        // Update in database
        boolean success = reservationDAO.update(reservation);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Reservation updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update reservation!");
        }
        
        response.sendRedirect(request.getContextPath() + "/reservation");
    }
    
    /**
     * View reservation details
     */
    private void viewReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation == null) {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/reservation");
            return;
        }
        
        request.setAttribute("reservation", reservation);
        request.getRequestDispatcher("/views/view-reservation-details.jsp").forward(request, response);
    }
    
    /**
     * Delete reservation
     */
    private void deleteReservation(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("id"));
        boolean success = reservationDAO.delete(reservationId);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Reservation deleted successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to delete reservation!");
        }
        
        response.sendRedirect(request.getContextPath() + "/reservation");
    }
    
    /**
     * Update reservation status
     */
    private void updateReservationStatus(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String status = request.getParameter("status");
        
        boolean success = reservationDAO.updateStatus(reservationId, status);
        
        if (success) {
            SessionManager.setSuccessMessage(request, "Reservation status updated successfully!");
        } else {
            SessionManager.setErrorMessage(request, "Failed to update status!");
        }
        
        response.sendRedirect(request.getContextPath() + "/reservation");
    }
}
