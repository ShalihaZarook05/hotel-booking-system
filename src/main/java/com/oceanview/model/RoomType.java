package com.oceanview.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * RoomType Model Class
 * Represents different types of rooms (Standard, Deluxe, Suite, etc.)
 */
public class RoomType implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // Private fields
    private int roomTypeId;
    private String typeName;
    private String description;
    private BigDecimal pricePerNight;
    private int capacity;
    private String amenities;
    private String imageUrls; // Comma-separated image URLs
    
    // Constructors
    public RoomType() {
    }
    
    public RoomType(String typeName, String description, BigDecimal pricePerNight, 
                    int capacity, String amenities) {
        this.typeName = typeName;
        this.description = description;
        this.pricePerNight = pricePerNight;
        this.capacity = capacity;
        this.amenities = amenities;
    }
    
    // Getters and Setters
    public int getRoomTypeId() {
        return roomTypeId;
    }
    
    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
    }
    
    public String getTypeName() {
        return typeName;
    }
    
    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }
    
    public void setPricePerNight(BigDecimal pricePerNight) {
        this.pricePerNight = pricePerNight;
    }
    
    public int getCapacity() {
        return capacity;
    }
    
    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }
    
    public String getAmenities() {
        return amenities;
    }
    
    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }
    
    public String getImageUrls() {
        return imageUrls;
    }
    
    public void setImageUrls(String imageUrls) {
        this.imageUrls = imageUrls;
    }
    
    /**
     * Get image URLs as an array
     * @return Array of image URLs (never null, may be empty)
     */
    public String[] getImageUrlsArray() {
        if (imageUrls != null && !imageUrls.trim().isEmpty()) {
            return imageUrls.split(",");
        }
        return new String[0];
    }
    
    /**
     * Check if room type has images
     * @return true if at least one image URL exists
     */
    public boolean hasImages() {
        return imageUrls != null && !imageUrls.trim().isEmpty();
    }
    
    @Override
    public String toString() {
        return "RoomType{" +
                "roomTypeId=" + roomTypeId +
                ", typeName='" + typeName + '\'' +
                ", pricePerNight=" + pricePerNight +
                ", capacity=" + capacity +
                '}';
    }
}
