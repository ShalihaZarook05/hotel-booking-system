package com.oceanview.dao;

import com.oceanview.model.Payment;
import java.math.BigDecimal;
import java.util.List;

/**
 * PaymentDAO Interface
 * Defines CRUD operations for Payment entity
 */
public interface PaymentDAO {
    
    /**
     * Create a new payment
     * @param payment Payment object to create
     * @return Generated payment ID
     */
    int create(Payment payment) throws Exception;
    
    /**
     * Read payment by ID
     * @param paymentId Payment ID
     * @return Payment object or null if not found
     */
    Payment read(int paymentId) throws Exception;
    
    /**
     * Update existing payment
     * @param payment Payment object with updated data
     * @return true if update successful
     */
    boolean update(Payment payment) throws Exception;
    
    /**
     * Delete payment by ID
     * @param paymentId Payment ID to delete
     * @return true if deletion successful
     */
    boolean delete(int paymentId) throws Exception;
    
    /**
     * Get all payments
     * @return List of all payments
     */
    List<Payment> getAll() throws Exception;
    
    /**
     * Get payments by reservation ID
     * @param reservationId Reservation ID
     * @return List of payments for the reservation
     */
    List<Payment> getByReservationId(int reservationId) throws Exception;
    
    /**
     * Get payments by status
     * @param status Payment status
     * @return List of payments with specified status
     */
    List<Payment> getByStatus(String status) throws Exception;
    
    /**
     * Get payments by payment method
     * @param paymentMethod Payment method (CASH, CARD, ONLINE)
     * @return List of payments with specified method
     */
    List<Payment> getByPaymentMethod(String paymentMethod) throws Exception;
    
    /**
     * Update payment status
     * @param paymentId Payment ID
     * @param status New status
     * @return true if update successful
     */
    boolean updateStatus(int paymentId, String status) throws Exception;
    
    /**
     * Get total revenue
     * @return Total completed payments amount
     */
    BigDecimal getTotalRevenue() throws Exception;
    
    /**
     * Get revenue by date range
     * @param startDate Start date (YYYY-MM-DD)
     * @param endDate End date (YYYY-MM-DD)
     * @return Total revenue in date range
     */
    BigDecimal getRevenueByDateRange(String startDate, String endDate) throws Exception;
}
