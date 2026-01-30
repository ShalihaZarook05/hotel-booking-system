package com.oceanview.dao.impl;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.model.Reservation;
import com.oceanview.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ReservationDAO Implementation
 * Implements CRUD operations for Reservation entity using JDBC
 */
public class ReservationDAOImpl implements ReservationDAO {
    
    private Connection getConnection() throws SQLException {
        return DatabaseConnection.getInstance().getConnection();
    }
    
    @Override
    public int create(Reservation reservation) throws Exception {
        String sql = "INSERT INTO reservations (reservation_number, guest_id, room_id, check_in_date, " +
                     "check_out_date, number_of_guests, special_requests, status, total_amount, created_by, created_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, reservation.getReservationNumber());
            pstmt.setInt(2, reservation.getGuestId());
            pstmt.setInt(3, reservation.getRoomId());
            pstmt.setDate(4, reservation.getCheckInDate());
            pstmt.setDate(5, reservation.getCheckOutDate());
            pstmt.setInt(6, reservation.getNumberOfGuests());
            pstmt.setString(7, reservation.getSpecialRequests());
            pstmt.setString(8, reservation.getStatus());
            pstmt.setBigDecimal(9, reservation.getTotalAmount());
            pstmt.setInt(10, reservation.getCreatedBy());
            pstmt.setTimestamp(11, reservation.getCreatedDate());
            
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
    public Reservation read(int reservationId) throws Exception {
        String sql = "SELECT * FROM reservations WHERE reservation_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reservationId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReservation(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean update(Reservation reservation) throws Exception {
        String sql = "UPDATE reservations SET reservation_number = ?, guest_id = ?, room_id = ?, " +
                     "check_in_date = ?, check_out_date = ?, number_of_guests = ?, special_requests = ?, " +
                     "status = ?, total_amount = ? WHERE reservation_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, reservation.getReservationNumber());
            pstmt.setInt(2, reservation.getGuestId());
            pstmt.setInt(3, reservation.getRoomId());
            pstmt.setDate(4, reservation.getCheckInDate());
            pstmt.setDate(5, reservation.getCheckOutDate());
            pstmt.setInt(6, reservation.getNumberOfGuests());
            pstmt.setString(7, reservation.getSpecialRequests());
            pstmt.setString(8, reservation.getStatus());
            pstmt.setBigDecimal(9, reservation.getTotalAmount());
            pstmt.setInt(10, reservation.getReservationId());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean delete(int reservationId) throws Exception {
        String sql = "DELETE FROM reservations WHERE reservation_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reservationId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public List<Reservation> getAll() throws Exception {
        String sql = "SELECT * FROM reservations ORDER BY created_date DESC";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        }
        return reservations;
    }
    
    @Override
    public Reservation findByReservationNumber(String reservationNumber) throws Exception {
        String sql = "SELECT * FROM reservations WHERE reservation_number = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, reservationNumber);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReservation(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public List<Reservation> getByGuestId(int guestId) throws Exception {
        String sql = "SELECT * FROM reservations WHERE guest_id = ? ORDER BY check_in_date DESC";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, guestId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    @Override
    public List<Reservation> getByStatus(String status) throws Exception {
        String sql = "SELECT * FROM reservations WHERE status = ? ORDER BY check_in_date";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    @Override
    public List<Reservation> getByDateRange(Date startDate, Date endDate) throws Exception {
        String sql = "SELECT * FROM reservations WHERE check_in_date >= ? AND check_out_date <= ? ORDER BY check_in_date";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDate(1, startDate);
            pstmt.setDate(2, endDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        return reservations;
    }
    
    @Override
    public boolean isRoomAvailable(int roomId, Date checkInDate, Date checkOutDate) throws Exception {
        String sql = "SELECT COUNT(*) FROM reservations WHERE room_id = ? " +
                     "AND status NOT IN ('CANCELLED', 'CHECKED_OUT') " +
                     "AND ((check_in_date <= ? AND check_out_date > ?) " +
                     "OR (check_in_date < ? AND check_out_date >= ?) " +
                     "OR (check_in_date >= ? AND check_out_date <= ?))";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, roomId);
            pstmt.setDate(2, checkInDate);
            pstmt.setDate(3, checkInDate);
            pstmt.setDate(4, checkOutDate);
            pstmt.setDate(5, checkOutDate);
            pstmt.setDate(6, checkInDate);
            pstmt.setDate(7, checkOutDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        }
        return false;
    }
    
    @Override
    public boolean updateStatus(int reservationId, String status) throws Exception {
        String sql = "UPDATE reservations SET status = ? WHERE reservation_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setInt(2, reservationId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public List<Reservation> getTodayCheckIns() throws Exception {
        String sql = "SELECT * FROM reservations WHERE check_in_date = CURDATE() AND status = 'CONFIRMED' ORDER BY guest_id";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        }
        return reservations;
    }
    
    @Override
    public List<Reservation> getTodayCheckOuts() throws Exception {
        String sql = "SELECT * FROM reservations WHERE check_out_date = CURDATE() AND status = 'CHECKED_IN' ORDER BY guest_id";
        List<Reservation> reservations = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        }
        return reservations;
    }
    
    /**
     * Helper method to map ResultSet to Reservation object
     */
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setReservationId(rs.getInt("reservation_id"));
        reservation.setReservationNumber(rs.getString("reservation_number"));
        reservation.setGuestId(rs.getInt("guest_id"));
        reservation.setRoomId(rs.getInt("room_id"));
        reservation.setCheckInDate(rs.getDate("check_in_date"));
        reservation.setCheckOutDate(rs.getDate("check_out_date"));
        reservation.setNumberOfGuests(rs.getInt("number_of_guests"));
        reservation.setSpecialRequests(rs.getString("special_requests"));
        reservation.setStatus(rs.getString("status"));
        reservation.setTotalAmount(rs.getBigDecimal("total_amount"));
        reservation.setCreatedBy(rs.getInt("created_by"));
        reservation.setCreatedDate(rs.getTimestamp("created_date"));
        reservation.setUpdatedDate(rs.getTimestamp("updated_date"));
        return reservation;
    }
}
