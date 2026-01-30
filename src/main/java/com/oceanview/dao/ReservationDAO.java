package com.oceanview.dao;

import com.oceanview.model.Reservation;
import java.sql.Date;
import java.util.List;

/**
 * ReservationDAO Interface
 * Defines CRUD operations for Reservation entity
 */
public interface ReservationDAO {
    
    /**
     * Create a new reservation
     * @param reservation Reservation object to create
     * @return Generated reservation ID
     */
    int create(Reservation reservation) throws Exception;
    
    /**
     * Read reservation by ID
     * @param reservationId Reservation ID
     * @return Reservation object or null if not found
     */
    Reservation read(int reservationId) throws Exception;
    
    /**
     * Update existing reservation
     * @param reservation Reservation object with updated data
     * @return true if update successful
     */
    boolean update(Reservation reservation) throws Exception;
    
    /**
     * Delete reservation by ID
     * @param reservationId Reservation ID to delete
     * @return true if deletion successful
     */
    boolean delete(int reservationId) throws Exception;
    
    /**
     * Get all reservations
     * @return List of all reservations
     */
    List<Reservation> getAll() throws Exception;
    
    /**
     * Find reservation by reservation number
     * @param reservationNumber Unique reservation number
     * @return Reservation object or null
     */
    Reservation findByReservationNumber(String reservationNumber) throws Exception;
    
    /**
     * Get reservations by guest ID
     * @param guestId Guest user ID
     * @return List of reservations for the guest
     */
    List<Reservation> getByGuestId(int guestId) throws Exception;
    
    /**
     * Get reservations by status
     * @param status Reservation status
     * @return List of reservations with specified status
     */
    List<Reservation> getByStatus(String status) throws Exception;
    
    /**
     * Get reservations by date range
     * @param startDate Start date
     * @param endDate End date
     * @return List of reservations within date range
     */
    List<Reservation> getByDateRange(Date startDate, Date endDate) throws Exception;
    
    /**
     * Check room availability for date range
     * @param roomId Room ID
     * @param checkInDate Check-in date
     * @param checkOutDate Check-out date
     * @return true if room is available
     */
    boolean isRoomAvailable(int roomId, Date checkInDate, Date checkOutDate) throws Exception;
    
    /**
     * Update reservation status
     * @param reservationId Reservation ID
     * @param status New status
     * @return true if update successful
     */
    boolean updateStatus(int reservationId, String status) throws Exception;
    
    /**
     * Get today's check-ins
     * @return List of reservations checking in today
     */
    List<Reservation> getTodayCheckIns() throws Exception;
    
    /**
     * Get today's check-outs
     * @return List of reservations checking out today
     */
    List<Reservation> getTodayCheckOuts() throws Exception;
}
