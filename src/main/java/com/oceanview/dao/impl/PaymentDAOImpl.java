package com.oceanview.dao.impl;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.model.Payment;
import com.oceanview.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAO Implementation
 * Implements CRUD operations for Payment entity using JDBC
 */
public class PaymentDAOImpl implements PaymentDAO {
    
    private Connection getConnection() throws SQLException {
        return DatabaseConnection.getInstance().getConnection();
    }
    
    @Override
    public int create(Payment payment) throws Exception {
        String sql = "INSERT INTO payments (reservation_id, amount, payment_method, payment_status, transaction_date) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, payment.getReservationId());
            pstmt.setBigDecimal(2, payment.getAmount());
            pstmt.setString(3, payment.getPaymentMethod());
            pstmt.setString(4, payment.getPaymentStatus());
            pstmt.setTimestamp(5, payment.getTransactionDate());
            
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
    public Payment read(int paymentId) throws Exception {
        String sql = "SELECT * FROM payments WHERE payment_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, paymentId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPayment(rs);
                }
            }
        }
        return null;
    }
    
    @Override
    public boolean update(Payment payment) throws Exception {
        String sql = "UPDATE payments SET reservation_id = ?, amount = ?, payment_method = ?, " +
                     "payment_status = ? WHERE payment_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, payment.getReservationId());
            pstmt.setBigDecimal(2, payment.getAmount());
            pstmt.setString(3, payment.getPaymentMethod());
            pstmt.setString(4, payment.getPaymentStatus());
            pstmt.setInt(5, payment.getPaymentId());
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public boolean delete(int paymentId) throws Exception {
        String sql = "DELETE FROM payments WHERE payment_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, paymentId);
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public List<Payment> getAll() throws Exception {
        String sql = "SELECT * FROM payments ORDER BY transaction_date DESC";
        List<Payment> payments = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                payments.add(mapResultSetToPayment(rs));
            }
        }
        return payments;
    }
    
    @Override
    public List<Payment> getByReservationId(int reservationId) throws Exception {
        String sql = "SELECT * FROM payments WHERE reservation_id = ? ORDER BY transaction_date";
        List<Payment> payments = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reservationId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }
    
    @Override
    public List<Payment> getByStatus(String status) throws Exception {
        String sql = "SELECT * FROM payments WHERE payment_status = ? ORDER BY transaction_date DESC";
        List<Payment> payments = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }
    
    @Override
    public List<Payment> getByPaymentMethod(String paymentMethod) throws Exception {
        String sql = "SELECT * FROM payments WHERE payment_method = ? ORDER BY transaction_date DESC";
        List<Payment> payments = new ArrayList<>();
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, paymentMethod);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    payments.add(mapResultSetToPayment(rs));
                }
            }
        }
        return payments;
    }
    
    @Override
    public boolean updateStatus(int paymentId, String status) throws Exception {
        String sql = "UPDATE payments SET payment_status = ? WHERE payment_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status);
            pstmt.setInt(2, paymentId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    @Override
    public BigDecimal getTotalRevenue() throws Exception {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE payment_status = 'COMPLETED'";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                return rs.getBigDecimal("total");
            }
        }
        return BigDecimal.ZERO;
    }
    
    @Override
    public BigDecimal getRevenueByDateRange(String startDate, String endDate) throws Exception {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total FROM payments " +
                     "WHERE payment_status = 'COMPLETED' " +
                     "AND DATE(transaction_date) BETWEEN ? AND ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, startDate);
            pstmt.setString(2, endDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total");
                }
            }
        }
        return BigDecimal.ZERO;
    }
    
    /**
     * Helper method to map ResultSet to Payment object
     */
    private Payment mapResultSetToPayment(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setPaymentId(rs.getInt("payment_id"));
        payment.setReservationId(rs.getInt("reservation_id"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setPaymentStatus(rs.getString("payment_status"));
        payment.setTransactionDate(rs.getTimestamp("transaction_date"));
        return payment;
    }
}
