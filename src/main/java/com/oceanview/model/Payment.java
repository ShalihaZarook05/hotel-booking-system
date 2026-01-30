package com.oceanview.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Payment Model Class
 * Represents payment transactions for reservations
 */
public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Payment method constants
    public static final String METHOD_CASH = "CASH";
    public static final String METHOD_CARD = "CARD";
    public static final String METHOD_ONLINE = "ONLINE";
    
    // Payment status constants
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_COMPLETED = "COMPLETED";
    public static final String STATUS_REFUNDED = "REFUNDED";
    
    // Private fields
    private int paymentId;
    private int reservationId;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentStatus;
    private Timestamp transactionDate;
    
    // For joining with Reservation table
    private Reservation reservation;
    
    // Constructors
    public Payment() {
        this.paymentStatus = STATUS_PENDING;
        this.transactionDate = new Timestamp(System.currentTimeMillis());
    }
    
    public Payment(int reservationId, BigDecimal amount, String paymentMethod) {
        this();
        this.reservationId = reservationId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
    }
    
    // Getters and Setters
    public int getPaymentId() {
        return paymentId;
    }
    
    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }
    
    public int getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public String getPaymentMethod() {
        return paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    
    public String getPaymentStatus() {
        return paymentStatus;
    }
    
    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }
    
    public Timestamp getTransactionDate() {
        return transactionDate;
    }
    
    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }
    
    public Reservation getReservation() {
        return reservation;
    }
    
    public void setReservation(Reservation reservation) {
        this.reservation = reservation;
    }
    
    // Utility methods
    public boolean isPending() {
        return STATUS_PENDING.equals(this.paymentStatus);
    }
    
    public boolean isCompleted() {
        return STATUS_COMPLETED.equals(this.paymentStatus);
    }
    
    public boolean isRefunded() {
        return STATUS_REFUNDED.equals(this.paymentStatus);
    }
    
    public boolean isCashPayment() {
        return METHOD_CASH.equals(this.paymentMethod);
    }
    
    public boolean isCardPayment() {
        return METHOD_CARD.equals(this.paymentMethod);
    }
    
    public boolean isOnlinePayment() {
        return METHOD_ONLINE.equals(this.paymentMethod);
    }
    
    @Override
    public String toString() {
        return "Payment{" +
                "paymentId=" + paymentId +
                ", reservationId=" + reservationId +
                ", amount=" + amount +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", transactionDate=" + transactionDate +
                '}';
    }
}
