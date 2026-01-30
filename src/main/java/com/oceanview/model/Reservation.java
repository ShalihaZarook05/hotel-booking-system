package com.oceanview.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * Reservation Model Class
 * Represents room reservations in the system
 */
public class Reservation implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Reservation status constants
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_CONFIRMED = "CONFIRMED";
    public static final String STATUS_CHECKED_IN = "CHECKED_IN";
    public static final String STATUS_CHECKED_OUT = "CHECKED_OUT";
    public static final String STATUS_CANCELLED = "CANCELLED";
    
    // Private fields
    private int reservationId;
    private String reservationNumber;
    private int guestId;
    private int roomId;
    private Date checkInDate;
    private Date checkOutDate;
    private int numberOfGuests;
    private String specialRequests;
    private String status;
    private BigDecimal totalAmount;
    private int createdBy;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // For joining with other tables
    private User guest;
    private Room room;
    private User creator;
    
    // Constructors
    public Reservation() {
        this.status = STATUS_PENDING;
        this.createdDate = new Timestamp(System.currentTimeMillis());
    }
    
    public Reservation(String reservationNumber, int guestId, int roomId, 
                      Date checkInDate, Date checkOutDate, int numberOfGuests, 
                      String specialRequests, int createdBy) {
        this();
        this.reservationNumber = reservationNumber;
        this.guestId = guestId;
        this.roomId = roomId;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.numberOfGuests = numberOfGuests;
        this.specialRequests = specialRequests;
        this.createdBy = createdBy;
    }
    
    // Getters and Setters
    public int getReservationId() {
        return reservationId;
    }
    
    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }
    
    public String getReservationNumber() {
        return reservationNumber;
    }
    
    public void setReservationNumber(String reservationNumber) {
        this.reservationNumber = reservationNumber;
    }
    
    public int getGuestId() {
        return guestId;
    }
    
    public void setGuestId(int guestId) {
        this.guestId = guestId;
    }
    
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public Date getCheckInDate() {
        return checkInDate;
    }
    
    public void setCheckInDate(Date checkInDate) {
        this.checkInDate = checkInDate;
    }
    
    public Date getCheckOutDate() {
        return checkOutDate;
    }
    
    public void setCheckOutDate(Date checkOutDate) {
        this.checkOutDate = checkOutDate;
    }
    
    public int getNumberOfGuests() {
        return numberOfGuests;
    }
    
    public void setNumberOfGuests(int numberOfGuests) {
        this.numberOfGuests = numberOfGuests;
    }
    
    public String getSpecialRequests() {
        return specialRequests;
    }
    
    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public BigDecimal getTotalAmount() {
        return totalAmount;
    }
    
    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    public int getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }
    
    public Timestamp getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
    
    public Timestamp getUpdatedDate() {
        return updatedDate;
    }
    
    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }
    
    public User getGuest() {
        return guest;
    }
    
    public void setGuest(User guest) {
        this.guest = guest;
    }
    
    public Room getRoom() {
        return room;
    }
    
    public void setRoom(Room room) {
        this.room = room;
    }
    
    public User getCreator() {
        return creator;
    }
    
    public void setCreator(User creator) {
        this.creator = creator;
    }
    
    // Utility methods
    public long getNumberOfNights() {
        if (checkInDate != null && checkOutDate != null) {
            LocalDate checkIn = checkInDate.toLocalDate();
            LocalDate checkOut = checkOutDate.toLocalDate();
            return ChronoUnit.DAYS.between(checkIn, checkOut);
        }
        return 0;
    }
    
    public boolean isPending() {
        return STATUS_PENDING.equals(this.status);
    }
    
    public boolean isConfirmed() {
        return STATUS_CONFIRMED.equals(this.status);
    }
    
    public boolean isCheckedIn() {
        return STATUS_CHECKED_IN.equals(this.status);
    }
    
    public boolean isCheckedOut() {
        return STATUS_CHECKED_OUT.equals(this.status);
    }
    
    public boolean isCancelled() {
        return STATUS_CANCELLED.equals(this.status);
    }
    
    public boolean isActive() {
        return !STATUS_CANCELLED.equals(this.status) && !STATUS_CHECKED_OUT.equals(this.status);
    }
    
    @Override
    public String toString() {
        return "Reservation{" +
                "reservationId=" + reservationId +
                ", reservationNumber='" + reservationNumber + '\'' +
                ", guestId=" + guestId +
                ", roomId=" + roomId +
                ", checkInDate=" + checkInDate +
                ", checkOutDate=" + checkOutDate +
                ", numberOfGuests=" + numberOfGuests +
                ", status='" + status + '\'' +
                ", totalAmount=" + totalAmount +
                '}';
    }
}
