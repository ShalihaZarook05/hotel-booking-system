package com.oceanview.model;

import java.sql.Timestamp;
import java.io.Serializable;

/**
 * User Model Class
 * Represents users in the system (Admin, Staff, Guest)
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;
    
    // User roles constants
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_STAFF = "STAFF";
    public static final String ROLE_GUEST = "GUEST";
    
    // User status constants
    public static final String STATUS_ACTIVE = "ACTIVE";
    public static final String STATUS_INACTIVE = "INACTIVE";
    
    // Private fields
    private int userId;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private String role;
    private String status;
    private Timestamp createdDate;
    private Timestamp lastLogin;
    
    // Constructors
    public User() {
        this.status = STATUS_ACTIVE;
        this.createdDate = new Timestamp(System.currentTimeMillis());
    }
    
    public User(String username, String password, String fullName, String email, 
                String phone, String address, String role) {
        this();
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.role = role;
    }
    
    // Getters and Setters
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Timestamp getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
    
    public Timestamp getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    // Utility methods
    public boolean isAdmin() {
        return ROLE_ADMIN.equals(this.role);
    }
    
    public boolean isStaff() {
        return ROLE_STAFF.equals(this.role);
    }
    
    public boolean isGuest() {
        return ROLE_GUEST.equals(this.role);
    }
    
    public boolean isActive() {
        return STATUS_ACTIVE.equals(this.status);
    }
    
    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", fullName='" + fullName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", role='" + role + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
