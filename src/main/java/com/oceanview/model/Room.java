package com.oceanview.model;

import java.io.Serializable;

/**
 * Room Model Class
 * Represents individual rooms in the hotel
 */
public class Room implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Room status constants
    public static final String STATUS_AVAILABLE = "AVAILABLE";
    public static final String STATUS_OCCUPIED = "OCCUPIED";
    public static final String STATUS_MAINTENANCE = "MAINTENANCE";
    
    // Private fields
    private int roomId;
    private String roomNumber;
    private int roomTypeId;
    private int floorNumber;
    private String status;
    
    // For joining with RoomType table
    private RoomType roomType;
    
    // Constructors
    public Room() {
        this.status = STATUS_AVAILABLE;
    }
    
    public Room(String roomNumber, int roomTypeId, int floorNumber) {
        this();
        this.roomNumber = roomNumber;
        this.roomTypeId = roomTypeId;
        this.floorNumber = floorNumber;
    }
    
    // Getters and Setters
    public int getRoomId() {
        return roomId;
    }
    
    public void setRoomId(int roomId) {
        this.roomId = roomId;
    }
    
    public String getRoomNumber() {
        return roomNumber;
    }
    
    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }
    
    public int getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }
    
    public int getFloorNumber() {
        return floorNumber;
    }
    
    public void setFloorNumber(int floorNumber) {
        this.floorNumber = floorNumber;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public RoomType getRoomType() {
        return roomType;
    }
    
    public void setRoomType(RoomType roomType) {
        this.roomType = roomType;
    }
    
    // Utility methods
    public boolean isAvailable() {
        return STATUS_AVAILABLE.equals(this.status);
    }
    
    public boolean isOccupied() {
        return STATUS_OCCUPIED.equals(this.status);
    }
    
    public boolean isUnderMaintenance() {
        return STATUS_MAINTENANCE.equals(this.status);
    }
    
    @Override
    public String toString() {
        return "Room{" +
                "roomId=" + roomId +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomTypeId=" + roomTypeId +
                ", floorNumber=" + floorNumber +
                ", status='" + status + '\'' +
                '}';
    }
}
