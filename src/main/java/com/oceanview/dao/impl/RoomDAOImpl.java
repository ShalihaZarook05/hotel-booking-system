package com.oceanview.dao.impl;

import com.oceanview.dao.RoomDAO;
import com.oceanview.model.Room;
import com.oceanview.model.RoomType;
import com.oceanview.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * RoomDAO Implementation
 * Implements CRUD operations for Room and RoomType entities using JDBC
 */
public class RoomDAOImpl implements RoomDAO {
    
    private Connection getConnection() throws SQLException {
        return DatabaseConnection.getInstance().getConnection();
    }
    
    // Room Operations
    
    @Override
    public int createRoom(Room room) throws Exception {
        String sql = "INSERT INTO rooms (room_number, room_type_id, floor_number, status) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, room.getRoomNumber());
            pstmt.setInt(2, room.getRoomTypeId());
            pstmt.setInt(3, room.getFloorNumber());
            pstmt.setString(4, room.getStatus());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return 0;
        }
    }
    
    @Override
    public Room readRoom(int roomId) throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "WHERE r.room_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRoom(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean updateRoom(Room room) throws Exception {
        String sql = "UPDATE rooms SET room_number = ?, room_type_id = ?, floor_number = ?, status = ? WHERE room_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, room.getRoomNumber());
            pstmt.setInt(2, room.getRoomTypeId());
            pstmt.setInt(3, room.getFloorNumber());
            pstmt.setString(4, room.getStatus());
            pstmt.setInt(5, room.getRoomId());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean deleteRoom(int roomId) throws Exception {
        // First check if room has any reservations
        if (hasReservations(roomId)) {
            throw new Exception("Cannot delete room with existing reservations. Please delete or cancel reservations first.");
        }
        
        String sql = "DELETE FROM rooms WHERE room_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Check if room has any reservations
     */
    private boolean hasReservations(int roomId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations WHERE room_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    @Override
    public List<Room> getAllRooms() throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "ORDER BY r.room_number";
        List<Room> rooms = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        }
        return rooms;
    }
    
    @Override
    public Room findByRoomNumber(String roomNumber) throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "WHERE r.room_number = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, roomNumber);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRoom(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public List<Room> getRoomsByStatus(String status) throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "WHERE r.status = ? ORDER BY r.room_number";
        List<Room> rooms = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapResultSetToRoom(rs));
                }
            }
        }
        return rooms;
    }
    
    @Override
    public List<Room> getRoomsByType(int roomTypeId) throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "WHERE r.room_type_id = ? ORDER BY r.room_number";
        List<Room> rooms = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomTypeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapResultSetToRoom(rs));
                }
            }
        }
        return rooms;
    }
    
    @Override
    public boolean updateRoomStatus(int roomId, String status) throws Exception {
        String sql = "UPDATE rooms SET status = ? WHERE room_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setInt(2, roomId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public List<Room> getAvailableRooms(Date checkInDate, Date checkOutDate) throws Exception {
        String sql = "SELECT r.*, rt.* FROM rooms r " +
                     "LEFT JOIN room_types rt ON r.room_type_id = rt.room_type_id " +
                     "WHERE r.status = 'AVAILABLE' AND r.room_id NOT IN " +
                     "(SELECT room_id FROM reservations WHERE status NOT IN ('CANCELLED', 'CHECKED_OUT') " +
                     "AND ((check_in_date <= ? AND check_out_date > ?) " +
                     "OR (check_in_date < ? AND check_out_date >= ?) " +
                     "OR (check_in_date >= ? AND check_out_date <= ?))) " +
                     "ORDER BY r.room_number";
        List<Room> rooms = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDate(1, checkInDate);
            pstmt.setDate(2, checkInDate);
            pstmt.setDate(3, checkOutDate);
            pstmt.setDate(4, checkOutDate);
            pstmt.setDate(5, checkInDate);
            pstmt.setDate(6, checkOutDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapResultSetToRoom(rs));
                }
            }
        }
        return rooms;
    }
    
    // RoomType Operations
    
    @Override
    public int createRoomType(RoomType roomType) throws Exception {
        String sql = "INSERT INTO room_types (type_name, description, price_per_night, capacity, amenities) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, roomType.getTypeName());
            pstmt.setString(2, roomType.getDescription());
            pstmt.setBigDecimal(3, roomType.getPricePerNight());
            pstmt.setInt(4, roomType.getCapacity());
            pstmt.setString(5, roomType.getAmenities());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return 0;
        }
    }
    
    @Override
    public RoomType readRoomType(int roomTypeId) throws Exception {
        String sql = "SELECT * FROM room_types WHERE room_type_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomTypeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRoomType(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean updateRoomType(RoomType roomType) throws Exception {
        String sql = "UPDATE room_types SET type_name = ?, description = ?, price_per_night = ?, " +
                     "capacity = ?, amenities = ? WHERE room_type_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, roomType.getTypeName());
            pstmt.setString(2, roomType.getDescription());
            pstmt.setBigDecimal(3, roomType.getPricePerNight());
            pstmt.setInt(4, roomType.getCapacity());
            pstmt.setString(5, roomType.getAmenities());
            pstmt.setInt(6, roomType.getRoomTypeId());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean deleteRoomType(int roomTypeId) throws Exception {
        // First check if any rooms are using this room type
        if (hasRoomsOfType(roomTypeId)) {
            throw new Exception("Cannot delete room type that is being used by existing rooms. Please reassign or delete rooms first.");
        }
        
        String sql = "DELETE FROM room_types WHERE room_type_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomTypeId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Check if any rooms are using this room type
     */
    private boolean hasRoomsOfType(int roomTypeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM rooms WHERE room_type_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomTypeId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    @Override
    public List<RoomType> getAllRoomTypes() throws Exception {
        String sql = "SELECT * FROM room_types ORDER BY type_name";
        List<RoomType> roomTypes = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                roomTypes.add(mapResultSetToRoomType(rs));
            }
        }
        return roomTypes;
    }
    
    @Override
    public Room read(int roomId) throws Exception {
        return readRoom(roomId);
    }
    
    /**
     * Helper method to map ResultSet to Room object
     */
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomTypeId(rs.getInt("room_type_id"));
        room.setFloorNumber(rs.getInt("floor_number"));
        room.setStatus(rs.getString("status"));
        
        // Check if RoomType columns exist (from JOIN)
        try {
            RoomType roomType = new RoomType();
            roomType.setRoomTypeId(rs.getInt("room_type_id"));
            roomType.setTypeName(rs.getString("type_name"));
            roomType.setDescription(rs.getString("description"));
            roomType.setPricePerNight(rs.getBigDecimal("price_per_night"));
            roomType.setCapacity(rs.getInt("capacity"));
            roomType.setAmenities(rs.getString("amenities"));
            
            // Safely handle image_urls
            try {
                roomType.setImageUrls(rs.getString("image_urls"));
            } catch (SQLException ex) {
                roomType.setImageUrls(null);
            }
            
            room.setRoomType(roomType);
        } catch (SQLException e) {
            // RoomType columns not present, skip
        }
        
        return room;
    }
    
    /**
     * Helper method to map ResultSet to RoomType object
     */
    private RoomType mapResultSetToRoomType(ResultSet rs) throws SQLException {
        RoomType roomType = new RoomType();
        roomType.setRoomTypeId(rs.getInt("room_type_id"));
        roomType.setTypeName(rs.getString("type_name"));
        roomType.setDescription(rs.getString("description"));
        roomType.setPricePerNight(rs.getBigDecimal("price_per_night"));
        roomType.setCapacity(rs.getInt("capacity"));
        roomType.setAmenities(rs.getString("amenities"));
        
        // Safely handle image_urls - may not exist in older databases
        try {
            roomType.setImageUrls(rs.getString("image_urls"));
        } catch (SQLException e) {
            // Column doesn't exist yet, set null (will return empty array from getImageUrlsArray)
            roomType.setImageUrls(null);
        }
        
        return roomType;
    }
}
