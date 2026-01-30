package com.oceanview.dao.impl;

import com.oceanview.dao.UserDAO;
import com.oceanview.model.User;
import com.oceanview.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO Implementation
 * Implements CRUD operations for User entity using JDBC
 */
public class UserDAOImpl implements UserDAO {
    
    private Connection getConnection() throws SQLException {
        return DatabaseConnection.getInstance().getConnection();
    }
    
    @Override
    public int create(User user) throws Exception {
        String sql = "INSERT INTO users (username, password, full_name, email, phone, address, role, status, created_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getPhone());
            pstmt.setString(6, user.getAddress());
            pstmt.setString(7, user.getRole());
            pstmt.setString(8, user.getStatus());
            pstmt.setTimestamp(9, user.getCreatedDate());
            
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
    public User read(int userId) throws Exception {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean update(User user) throws Exception {
        String sql = "UPDATE users SET username = ?, password = ?, full_name = ?, email = ?, " +
                     "phone = ?, address = ?, role = ?, status = ? WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getEmail());
            pstmt.setString(5, user.getPhone());
            pstmt.setString(6, user.getAddress());
            pstmt.setString(7, user.getRole());
            pstmt.setString(8, user.getStatus());
            pstmt.setInt(9, user.getUserId());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean delete(int userId) throws Exception {
        // First check if user has any reservations
        if (hasReservations(userId)) {
            throw new Exception("Cannot delete user with existing reservations. Please delete or reassign reservations first.");
        }
        
        // Check if user has any payments
        if (hasPayments(userId)) {
            throw new Exception("Cannot delete user with existing payment records. Please handle payments first.");
        }
        
        String sql = "DELETE FROM users WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Check if user has any reservations
     */
    private boolean hasReservations(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM reservations WHERE guest_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    /**
     * Check if user has any payments
     */
    private boolean hasPayments(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM payments p " +
                     "INNER JOIN reservations r ON p.reservation_id = r.reservation_id " +
                     "WHERE r.guest_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    @Override
    public List<User> getAll() throws Exception {
        String sql = "SELECT * FROM users ORDER BY created_date DESC";
        List<User> users = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        }
        return users;
    }
    
    @Override
    public User findByUsername(String username) throws Exception {
        String sql = "SELECT * FROM users WHERE username = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public User findByEmail(String email) throws Exception {
        String sql = "SELECT * FROM users WHERE email = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public List<User> getUsersByRole(String role) throws Exception {
        String sql = "SELECT * FROM users WHERE role = ? ORDER BY full_name";
        List<User> users = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, role);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        }
        return users;
    }
    
    @Override
    public User authenticate(String username, String password) throws Exception {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ? AND status = 'ACTIVE'";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public User authenticateByUsernameOrEmail(String usernameOrEmail, String password) throws Exception {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ? AND status = 'ACTIVE'";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, usernameOrEmail);
            pstmt.setString(2, usernameOrEmail);
            pstmt.setString(3, password);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean updateLastLogin(int userId) throws Exception {
        String sql = "UPDATE users SET last_login = ? WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
            pstmt.setInt(2, userId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean updateStatus(int userId, String status) throws Exception {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setInt(2, userId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Helper method to map ResultSet to User object
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        user.setCreatedDate(rs.getTimestamp("created_date"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        return user;
    }
}
