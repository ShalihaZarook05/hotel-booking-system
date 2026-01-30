package com.oceanview.service;

import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Payment;
import com.oceanview.model.Reservation;
import com.oceanview.model.Room;
import com.oceanview.util.DateUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BillingService
 * Business logic for billing and payment operations
 */
public class BillingService {
    
    private PaymentDAO paymentDAO;
    private ReservationDAO reservationDAO;
    private RoomDAO roomDAO;
    
    // Tax and service charge rates
    private static final BigDecimal TAX_RATE = BigDecimal.valueOf(0.10); // 10%
    private static final BigDecimal SERVICE_CHARGE_RATE = BigDecimal.valueOf(0.05); // 5%
    
    public BillingService() {
        this.paymentDAO = DAOFactory.getPaymentDAO();
        this.reservationDAO = DAOFactory.getReservationDAO();
        this.roomDAO = DAOFactory.getRoomDAO();
    }
    
    /**
     * Generate bill for a reservation
     * @param reservationId Reservation ID
     * @return Map containing bill details
     * @throws Exception if bill generation fails
     */
    public Map<String, Object> generateBill(int reservationId) throws Exception {
        // Get reservation details
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        // Get room details
        Room room = roomDAO.readRoom(reservation.getRoomId());
        if (room == null || room.getRoomType() == null) {
            throw new Exception("Room details not found!");
        }
        
        // Calculate bill components
        long numberOfNights = DateUtil.daysBetween(reservation.getCheckInDate(), 
                                                   reservation.getCheckOutDate());
        
        BigDecimal roomRate = room.getRoomType().getPricePerNight();
        BigDecimal subtotal = roomRate.multiply(BigDecimal.valueOf(numberOfNights));
        
        // Calculate service charge
        BigDecimal serviceCharge = subtotal.multiply(SERVICE_CHARGE_RATE)
                                          .setScale(2, RoundingMode.HALF_UP);
        
        // Calculate tax
        BigDecimal tax = subtotal.add(serviceCharge).multiply(TAX_RATE)
                                .setScale(2, RoundingMode.HALF_UP);
        
        // Calculate total
        BigDecimal total = subtotal.add(serviceCharge).add(tax)
                                  .setScale(2, RoundingMode.HALF_UP);
        
        // Create bill details map
        Map<String, Object> billDetails = new HashMap<>();
        billDetails.put("reservation", reservation);
        billDetails.put("room", room);
        billDetails.put("numberOfNights", numberOfNights);
        billDetails.put("roomRate", roomRate);
        billDetails.put("subtotal", subtotal);
        billDetails.put("serviceCharge", serviceCharge);
        billDetails.put("tax", tax);
        billDetails.put("total", total);
        
        // Check for existing payments
        List<Payment> existingPayments = paymentDAO.getByReservationId(reservationId);
        BigDecimal totalPaid = calculateTotalPaid(existingPayments);
        BigDecimal balance = total.subtract(totalPaid);
        
        billDetails.put("existingPayments", existingPayments);
        billDetails.put("totalPaid", totalPaid);
        billDetails.put("balance", balance);
        
        return billDetails;
    }
    
    /**
     * Process payment for a reservation
     * @param reservationId Reservation ID
     * @param amount Payment amount
     * @param paymentMethod Payment method (CASH, CARD, ONLINE)
     * @return Payment ID if successful
     * @throws Exception if payment processing fails
     */
    public int processPayment(int reservationId, BigDecimal amount, String paymentMethod) throws Exception {
        // Validate payment data
        validatePaymentData(reservationId, amount, paymentMethod);
        
        // Get reservation
        Reservation reservation = reservationDAO.read(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found!");
        }
        
        // Generate bill to get total amount
        Map<String, Object> billDetails = generateBill(reservationId);
        BigDecimal totalAmount = (BigDecimal) billDetails.get("total");
        BigDecimal balance = (BigDecimal) billDetails.get("balance");
        
        // Validate payment amount
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new Exception("Payment amount must be greater than zero!");
        }
        
        if (amount.compareTo(balance) > 0) {
            throw new Exception("Payment amount exceeds balance due!");
        }
        
        // Create payment
        Payment payment = new Payment(reservationId, amount, paymentMethod);
        payment.setPaymentStatus(Payment.STATUS_COMPLETED);
        
        int paymentId = paymentDAO.create(payment);
        
        if (paymentId > 0) {
            // Check if full payment is made
            BigDecimal newBalance = balance.subtract(amount);
            if (newBalance.compareTo(BigDecimal.ZERO) == 0) {
                // Update reservation status to checked out if fully paid
                if (reservation.isCheckedIn()) {
                    reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_OUT);
                    // Update room status to available
                    roomDAO.updateRoomStatus(reservation.getRoomId(), Room.STATUS_AVAILABLE);
                }
            }
        }
        
        return paymentId;
    }
    
    /**
     * Get payment by ID
     * @param paymentId Payment ID
     * @return Payment object
     * @throws Exception if payment not found
     */
    public Payment getPaymentById(int paymentId) throws Exception {
        Payment payment = paymentDAO.read(paymentId);
        if (payment == null) {
            throw new Exception("Payment not found!");
        }
        
        // Load reservation details
        Reservation reservation = reservationDAO.read(payment.getReservationId());
        payment.setReservation(reservation);
        
        return payment;
    }
    
    /**
     * Get all payments
     * @return List of all payments
     * @throws Exception if operation fails
     */
    public List<Payment> getAllPayments() throws Exception {
        return paymentDAO.getAll();
    }
    
    /**
     * Get payments by reservation ID
     * @param reservationId Reservation ID
     * @return List of payments for the reservation
     * @throws Exception if operation fails
     */
    public List<Payment> getPaymentsByReservation(int reservationId) throws Exception {
        return paymentDAO.getByReservationId(reservationId);
    }
    
    /**
     * Get payments by status
     * @param status Payment status
     * @return List of payments with specified status
     * @throws Exception if operation fails
     */
    public List<Payment> getPaymentsByStatus(String status) throws Exception {
        return paymentDAO.getByStatus(status);
    }
    
    /**
     * Get total revenue
     * @return Total revenue from completed payments
     * @throws Exception if operation fails
     */
    public BigDecimal getTotalRevenue() throws Exception {
        return paymentDAO.getTotalRevenue();
    }
    
    /**
     * Get revenue by date range
     * @param startDate Start date (YYYY-MM-DD)
     * @param endDate End date (YYYY-MM-DD)
     * @return Revenue for the date range
     * @throws Exception if operation fails
     */
    public BigDecimal getRevenueByDateRange(String startDate, String endDate) throws Exception {
        return paymentDAO.getRevenueByDateRange(startDate, endDate);
    }
    
    /**
     * Get revenue breakdown by payment method
     * @return Map of payment method to revenue
     * @throws Exception if operation fails
     */
    public Map<String, BigDecimal> getRevenueByPaymentMethod() throws Exception {
        List<Payment> allPayments = paymentDAO.getAll();
        
        BigDecimal cashRevenue = BigDecimal.ZERO;
        BigDecimal cardRevenue = BigDecimal.ZERO;
        BigDecimal onlineRevenue = BigDecimal.ZERO;
        
        for (Payment payment : allPayments) {
            if (payment.isCompleted()) {
                if (payment.isCashPayment()) {
                    cashRevenue = cashRevenue.add(payment.getAmount());
                } else if (payment.isCardPayment()) {
                    cardRevenue = cardRevenue.add(payment.getAmount());
                } else if (payment.isOnlinePayment()) {
                    onlineRevenue = onlineRevenue.add(payment.getAmount());
                }
            }
        }
        
        Map<String, BigDecimal> breakdown = new HashMap<>();
        breakdown.put("CASH", cashRevenue);
        breakdown.put("CARD", cardRevenue);
        breakdown.put("ONLINE", onlineRevenue);
        
        return breakdown;
    }
    
    /**
     * Refund payment
     * @param paymentId Payment ID
     * @return true if refund successful
     * @throws Exception if refund fails
     */
    public boolean refundPayment(int paymentId) throws Exception {
        Payment payment = paymentDAO.read(paymentId);
        if (payment == null) {
            throw new Exception("Payment not found!");
        }
        
        if (!payment.isCompleted()) {
            throw new Exception("Only completed payments can be refunded!");
        }
        
        // Update payment status to refunded
        return paymentDAO.updateStatus(paymentId, Payment.STATUS_REFUNDED);
    }
    
    /**
     * Calculate total paid for a reservation
     * @param payments List of payments
     * @return Total amount paid
     */
    private BigDecimal calculateTotalPaid(List<Payment> payments) {
        BigDecimal total = BigDecimal.ZERO;
        
        for (Payment payment : payments) {
            if (payment.isCompleted()) {
                total = total.add(payment.getAmount());
            }
        }
        
        return total;
    }
    
    /**
     * Validate payment data
     * @param reservationId Reservation ID
     * @param amount Payment amount
     * @param paymentMethod Payment method
     * @throws Exception if validation fails
     */
    private void validatePaymentData(int reservationId, BigDecimal amount, String paymentMethod) throws Exception {
        if (reservationId <= 0) {
            throw new Exception("Valid reservation ID is required!");
        }
        
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new Exception("Payment amount must be greater than zero!");
        }
        
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            throw new Exception("Payment method is required!");
        }
        
        if (!paymentMethod.equals(Payment.METHOD_CASH) && 
            !paymentMethod.equals(Payment.METHOD_CARD) && 
            !paymentMethod.equals(Payment.METHOD_ONLINE)) {
            throw new Exception("Invalid payment method! Must be CASH, CARD, or ONLINE.");
        }
    }
}
