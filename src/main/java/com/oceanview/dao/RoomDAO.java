package com.oceanview.dao;

import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import java.sql.Date;
import java.util.List;

/**
 * RoomDAO Interface
 * Defines CRUD operations for Room and RoomType entities
 */
public interface RoomDAO {
    
    // Room Operations
    
    /**
     * Create a new room
     * @param room Room object to create
     * @return Generated room ID
     */
    int createRoom(Room room) throws Exception;
    
    /**
     * Read room by ID
     * @param roomId Room ID
     * @return Room object or null if not found
     */
    Room readRoom(int roomId) throws Exception;
    
    /**
     * Update existing room
     * @param room Room object with updated data
     * @return true if update successful
     */
    boolean updateRoom(Room room) throws Exception;
    
    /**
     * Delete room by ID
     * @param roomId Room ID to delete
     * @return true if deletion successful
     */
    boolean deleteRoom(int roomId) throws Exception;
    
    /**
     * Get all rooms
     * @return List of all rooms
     */
    List<Room> getAllRooms() throws Exception;
    
    /**
     * Find room by room number
     * @param roomNumber Room number
     * @return Room object or null
     */
    Room findByRoomNumber(String roomNumber) throws Exception;
    
    /**
     * Get rooms by status
     * @param status Room status (AVAILABLE, OCCUPIED, MAINTENANCE)
     * @return List of rooms with specified status
     */
    List<Room> getRoomsByStatus(String status) throws Exception;
    
    /**
     * Get rooms by room type
     * @param roomTypeId Room type ID
     * @return List of rooms of specified type
     */
    List<Room> getRoomsByType(int roomTypeId) throws Exception;
    
    /**
     * Update room status
     * @param roomId Room ID
     * @param status New status
     * @return true if update successful
     */
    boolean updateRoomStatus(int roomId, String status) throws Exception;
    
    /**
     * Get available rooms for date range
     * @param checkInDate Check-in date
     * @param checkOutDate Check-out date
     * @return List of available rooms
     */
    List<Room> getAvailableRooms(Date checkInDate, Date checkOutDate) throws Exception;
    
    /**
     * Read room by ID (alias for readRoom)
     * @param roomId Room ID
     * @return Room object or null if not found
     */
    Room read(int roomId) throws Exception;
    
    // RoomType Operations
    
    /**
     * Create a new room type
     * @param roomType RoomType object to create
     * @return Generated room type ID
     */
    int createRoomType(RoomType roomType) throws Exception;
    
    /**
     * Read room type by ID
     * @param roomTypeId Room type ID
     * @return RoomType object or null if not found
     */
    RoomType readRoomType(int roomTypeId) throws Exception;
    
    /**
     * Update existing room type
     * @param roomType RoomType object with updated data
     * @return true if update successful
     */
    boolean updateRoomType(RoomType roomType) throws Exception;
    
    /**
     * Delete room type by ID
     * @param roomTypeId Room type ID to delete
     * @return true if deletion successful
     */
    boolean deleteRoomType(int roomTypeId) throws Exception;
    
    /**
     * Get all room types
     * @return List of all room types
     */
    List<RoomType> getAllRoomTypes() throws Exception;
}
