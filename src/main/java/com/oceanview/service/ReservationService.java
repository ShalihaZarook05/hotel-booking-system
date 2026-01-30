package com.oceanview.service;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.util.DateUtil;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/**
 * ReservationService
 * Business logic for reservation operations
 */
public class ReservationService {
    
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    private UserDAO userDAO;
    
    public ReservationService() {
        this.reservationDAO = DAOFactory.getReservationDAO();
        this.roomDAO = DAOFactory.getRoomDAO();
        this.userDAO = DAOFactory.getUserDAO();
    }
    
    /**
     * Create a new reservation
     * @param reservation Reservation object
     * @return Reservation ID if successful
     * @throws Exception if creation fails
     */
    public int createReservation(Reservation reservation) throws Exception {
        // Validate reservation data
        validateReservationData(reservation);
        
        // Check if guest exists
        User guest = userDAO.read(reservation.getGuestId());
        if (guest == null) {
            throw new Exception("Guest not found!");
        }
        
        // Check if room exists
        Room room = roomDAO.readRoom(reservation.getRoomId());
        if (room == null) {
            throw new Exception("Room not found!");
        }
        
        // Check room availability
        if (!reservationDAO.isRoomAvailable(reservation.getRoomId(), 
                                           reservation.getCheckInDate(), 
                                           reservation.getCheckOutDate())) {
            throw new Exception("Room is not available for the selected dates!");
        }
        
        // Calculate total amount
        long numberOfNights = DateUtil.daysBetween(reservation.getCheckInDate(), 
                                                   reservation.getCheckOutDate());
        BigDecimal totalAmount = room.getRoomType().getPricePerNight()
                                    .multiply(BigDecimal.valueOf(numberOfNights));
        reservation.setTotalAmount(totalAmount);
        
        // Generate unique reservation number
        String reservationNumber = generateReservationNumber();
        reservation.setReservationNumber(reservationNumber);
        
        // Set initial status
        if (reservation.getStatus() == null || reservation.getStatus().isEmpty()) {
            reservation.setStatus(Reservation.STATUS_PENDING);
        }
        
        // Create reservation
        int reservationId = reservationDAO.create(reservation);
        
        if (reservationId > 0) {
            // Update room status to OCCUPIED
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_OCCUPIED);
        }
        
        return reservationId;
    }
    
    /**
     * Get reservation by ID with full details
     * @param reservationId Reservation ID
     * @return Reservation object with guest and room details
     * @throws Exception if reservation not found
     */
    public Reservation getReservationById(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        // Load guest details
        User guest = userDAO.read(reservation.getGuestId());
        reservation.setGuest(guest);
        
        // Load room details
        Room room = roomDAO.readRoom(reservation.getRoomId());
        reservation.setRoom(room);
        
        // Load creator details
        User creator = userDAO.read(reservation.getCreatedBy());
        reservation.setCreator(creator);
        
        return reservation;
    }
    
    /**
     * Get reservation by reservation number
     * @param reservationNumber Reservation number
     * @return Reservation object
     * @throws Exception if reservation not found
     */
    public Reservation getReservationByNumber(String reservationNumber) throws Exception {
        Reservation reservation = reservationDAO.findByReservationNumber(reservationNumber);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        return reservation;
    }
    
    /**
     * Get all reservations
     * @return List of all reservations
     * @throws Exception if operation fails
     */
    public List<Reservation> getAllReservations() throws Exception {
        return reservationDAO.getAll();
    }
    
    /**
     * Get reservations by guest ID
     * @param guestId Guest user ID
     * @return List of reservations
     * @throws Exception if operation fails
     */
    public List<Reservation> getReservationsByGuest(int guestId) throws Exception {
        return reservationDAO.getByGuestId(guestId);
    }
    
    /**
     * Get reservations by status
     * @param status Reservation status
     * @return List of reservations
     * @throws Exception if operation fails
     */
    public List<Reservation> getReservationsByStatus(String status) throws Exception {
        return reservationDAO.getByStatus(status);
    }
    
    /**
     * Update reservation
     * @param reservation Reservation object with updated data
     * @return true if update successful
     * @throws Exception if update fails
     */
    public boolean updateReservation(Reservation reservation) throws Exception {
        // Validate reservation data
        validateReservationData(reservation);
        
        // Check if reservation exists
        Reservation existingReservation = reservationDAO.read(reservation.getReservationId());
        if (existingReservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        // Check if room changed and new room is available
        if (existingReservation.getRoomId() != reservation.getRoomId()) {
            if (!reservationDAO.isRoomAvailable(reservation.getRoomId(), 
                                               reservation.getCheckInDate(), 
                                               reservation.getCheckOutDate())) {
                throw new Exception("New room is not available for the selected dates!");
            }
        }
        
        // Recalculate total amount
        Room room = roomDAO.readRoom(reservation.getRoomId());
        long numberOfNights = DateUtil.daysBetween(reservation.getCheckInDate(), 
                                                   reservation.getCheckOutDate());
        BigDecimal totalAmount = room.getRoomType().getPricePerNight()
                                    .multiply(BigDecimal.valueOf(numberOfNights));
        reservation.setTotalAmount(totalAmount);
        
        return reservationDAO.update(reservation);
    }
    
    /**
     * Confirm reservation
     * @param reservationId Reservation ID
     * @return true if confirmation successful
     * @throws Exception if confirmation fails
     */
    public boolean confirmReservation(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        if (!reservation.isPending()) {
            throw new Exception("Only pending reservations can be confirmed!");
        }
        
        return reservationDAO.updateStatus(reservationId, Reservation.STATUS_CONFIRMED);
    }
    
    /**
     * Check-in reservation
     * @param reservationId Reservation ID
     * @return true if check-in successful
     * @throws Exception if check-in fails
     */
    public boolean checkInReservation(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        if (!reservation.isConfirmed()) {
            throw new Exception("Only confirmed reservations can be checked in!");
        }
        
        // Update reservation status
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_IN);
        
        if (success) {
            // Update room status
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_OCCUPIED);
        }
        
        return success;
    }
    
    /**
     * Check-out reservation
     * @param reservationId Reservation ID
     * @return true if check-out successful
     * @throws Exception if check-out fails
     */
    public boolean checkOutReservation(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        if (!reservation.isCheckedIn()) {
            throw new Exception("Only checked-in reservations can be checked out!");
        }
        
        // Update reservation status
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_OUT);
        
        if (success) {
            // Update room status to available
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
        }
        
        return success;
    }
    
    /**
     * Cancel reservation
     * @param reservationId Reservation ID
     * @return true if cancellation successful
     * @throws Exception if cancellation fails
     */
    public boolean cancelReservation(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        if (reservation.isCheckedOut()) {
            throw new Exception("Cannot cancel a checked-out reservation!");
        }
        
        // Update reservation status
        boolean success = reservationDAO.updateStatus(reservationId, Reservation.STATUS_CANCELLED);
        
        if (success && (reservation.isConfirmed() || reservation.isCheckedIn())) {
            // Update room status to available if it was occupied
            roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
        }
        
        return success;
    }
    
    /**
     * Check room availability for date range
     * @param roomId Room ID
     * @param checkInDate Check-in date
     * @param checkOutDate Check-out date
     * @return true if room is available
     * @throws Exception if check fails
     */
    public boolean isRoomAvailable(int roomId, Date checkInDate, Date checkOutDate) throws Exception {
        return reservationDAO.isRoomAvailable(roomId, checkInDate, checkOutDate);
    }
    
    /**
     * Get available rooms for date range
     * @param checkInDate Check-in date
     * @param checkOutDate Check-out date
     * @return List of available rooms
     * @throws Exception if operation fails
     */
    public List<Room> getAvailableRooms(Date checkInDate, Date checkOutDate) throws Exception {
        return roomDAO.getAvailableRooms(checkInDate, checkOutDate);
    }
    
    /**
     * Get today's check-ins
     * @return List of reservations checking in today
     * @throws Exception if operation fails
     */
    public List<Reservation> getTodayCheckIns() throws Exception {
        return reservationDAO.getTodayCheckIns();
    }
    
    /**
     * Get today's check-outs
     * @return List of reservations checking out today
     * @throws Exception if operation fails
     */
    public List<Reservation> getTodayCheckOuts() throws Exception {
        return reservationDAO.getTodayCheckOuts();
    }
    
    /**
     * Delete reservation
     * @param reservationId Reservation ID
     * @return true if deletion successful
     * @throws Exception if deletion fails
     */
    public boolean deleteReservation(int reservationId) throws Exception {
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        return reservationDAO.delete(reservationId);
    }
    
    /**
     * Generate unique reservation number
     * @return Unique reservation number
     */
    private String generateReservationNumber() {
        return "RES" + System.currentTimeMillis();
    }
    
    /**
     * Validate reservation data
     * @param reservation Reservation object
     * @throws Exception if validation fails
     */
    private void validateReservationData(Reservation reservation) throws Exception {
        if (reservation.getGuestId() <= 0) {
            throw new Exception("Valid guest ID is required!");
        }
        
        if (reservation.getRoomId() <= 0) {
            throw new Exception("Valid room ID is required!");
        }
        
        if (reservation.getCheckInDate() == null) {
            throw new Exception("Check-in date is required!");
        }
        
        if (reservation.getCheckOutDate() == null) {
            throw new Exception("Check-out date is required!");
        }
        
        if (!DateUtil.isValidDateRange(reservation.getCheckInDate(), reservation.getCheckOutDate())) {
            throw new Exception("Check-out date must be after check-in date!");
        }
        
        if (DateUtil.isPastDate(reservation.getCheckInDate())) {
            throw new Exception("Check-in date cannot be in the past!");
        }
        
        if (reservation.getNumberOfGuests() <= 0) {
            throw new Exception("Number of guests must be at least 1!");
        }
        
        // Validate number of guests against room capacity
        Room room = roomDAO.readRoom(reservation.getRoomId());
        if (room != null && room.getRoomType() != null) {
            if (reservation.getNumberOfGuests() > room.getRoomType().getCapacity()) {
                throw new Exception("Number of guests exceeds room capacity (" + 
                                  room.getRoomType().getCapacity() + ")!");
            }
        }
    }
}
