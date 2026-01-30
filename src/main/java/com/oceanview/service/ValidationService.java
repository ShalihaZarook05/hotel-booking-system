package com.oceanview.service;

import com.oceanview.util.DateUtil;

import java.sql.Date;
import java.util.regex.Pattern;

/**
 * ValidationService
 * Centralized validation logic for input data
 */
public class ValidationService {
    
    // Regex patterns
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );
    
    private static final Pattern PHONE_PATTERN = Pattern.compile(
        "^[0-9]{10,15}$"
    );
    
    private static final Pattern USERNAME_PATTERN = Pattern.compile(
        "^[A-Za-z0-9_]{3,20}$"
    );
    
    private static final Pattern ROOM_NUMBER_PATTERN = Pattern.compile(
        "^[A-Z0-9]{1,10}$"
    );
    
    /**
     * Validate email address
     * @param email Email address
     * @return true if valid
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }
    
    /**
     * Validate phone number
     * @param phone Phone number
     * @return true if valid
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        // Remove spaces, hyphens, and parentheses
        String cleanPhone = phone.replaceAll("[\\s\\-()]", "");
        return PHONE_PATTERN.matcher(cleanPhone).matches();
    }
    
    /**
     * Validate username
     * @param username Username
     * @return true if valid
     */
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        return USERNAME_PATTERN.matcher(username.trim()).matches();
    }
    
    /**
     * Validate password strength
     * @param password Password
     * @return true if valid
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        return true;
    }
    
    /**
     * Validate password with strong criteria
     * @param password Password
     * @return true if strong password
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;
        
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c)) hasDigit = true;
            else hasSpecial = true;
        }
        
        return hasUpper && hasLower && hasDigit;
    }
    
    /**
     * Validate room number format
     * @param roomNumber Room number
     * @return true if valid
     */
    public static boolean isValidRoomNumber(String roomNumber) {
        if (roomNumber == null || roomNumber.trim().isEmpty()) {
            return false;
        }
        return ROOM_NUMBER_PATTERN.matcher(roomNumber.trim()).matches();
    }
    
    /**
     * Validate date range
     * @param startDate Start date
     * @param endDate End date
     * @return true if valid range
     */
    public static boolean isValidDateRange(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            return false;
        }
        return DateUtil.isValidDateRange(startDate, endDate);
    }
    
    /**
     * Validate check-in date (not in the past)
     * @param checkInDate Check-in date
     * @return true if valid
     */
    public static boolean isValidCheckInDate(Date checkInDate) {
        if (checkInDate == null) {
            return false;
        }
        return !DateUtil.isPastDate(checkInDate);
    }
    
    /**
     * Validate string is not empty
     * @param value String value
     * @param fieldName Field name for error message
     * @return Error message or null if valid
     */
    public static String validateRequired(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            return fieldName + " is required!";
        }
        return null;
    }
    
    /**
     * Validate string length
     * @param value String value
     * @param fieldName Field name
     * @param minLength Minimum length
     * @param maxLength Maximum length
     * @return Error message or null if valid
     */
    public static String validateLength(String value, String fieldName, int minLength, int maxLength) {
        if (value == null) {
            return fieldName + " is required!";
        }
        
        int length = value.trim().length();
        
        if (length < minLength) {
            return fieldName + " must be at least " + minLength + " characters!";
        }
        
        if (length > maxLength) {
            return fieldName + " must not exceed " + maxLength + " characters!";
        }
        
        return null;
    }
    
    /**
     * Validate numeric range
     * @param value Numeric value
     * @param fieldName Field name
     * @param min Minimum value
     * @param max Maximum value
     * @return Error message or null if valid
     */
    public static String validateRange(int value, String fieldName, int min, int max) {
        if (value < min) {
            return fieldName + " must be at least " + min + "!";
        }
        
        if (value > max) {
            return fieldName + " must not exceed " + max + "!";
        }
        
        return null;
    }
    
    /**
     * Validate email with error message
     * @param email Email address
     * @return Error message or null if valid
     */
    public static String validateEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "Email is required!";
        }
        
        if (!isValidEmail(email)) {
            return "Invalid email format!";
        }
        
        return null;
    }
    
    /**
     * Validate phone with error message
     * @param phone Phone number
     * @return Error message or null if valid
     */
    public static String validatePhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return "Phone number is required!";
        }
        
        if (!isValidPhone(phone)) {
            return "Invalid phone number format! Must be 10-15 digits.";
        }
        
        return null;
    }
    
    /**
     * Validate username with error message
     * @param username Username
     * @return Error message or null if valid
     */
    public static String validateUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return "Username is required!";
        }
        
        if (!isValidUsername(username)) {
            return "Username must be 3-20 characters (letters, numbers, underscore only)!";
        }
        
        return null;
    }
    
    /**
     * Validate password with error message
     * @param password Password
     * @return Error message or null if valid
     */
    public static String validatePassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            return "Password is required!";
        }
        
        if (!isValidPassword(password)) {
            return "Password must be at least 6 characters!";
        }
        
        return null;
    }
    
    /**
     * Validate password confirmation
     * @param password Password
     * @param confirmPassword Confirmation password
     * @return Error message or null if valid
     */
    public static String validatePasswordMatch(String password, String confirmPassword) {
        if (password == null || confirmPassword == null) {
            return "Password and confirmation are required!";
        }
        
        if (!password.equals(confirmPassword)) {
            return "Passwords do not match!";
        }
        
        return null;
    }
    
    /**
     * Validate date range with error message
     * @param startDate Start date
     * @param endDate End date
     * @param startFieldName Start field name
     * @param endFieldName End field name
     * @return Error message or null if valid
     */
    public static String validateDateRange(Date startDate, Date endDate, 
                                          String startFieldName, String endFieldName) {
        if (startDate == null) {
            return startFieldName + " is required!";
        }
        
        if (endDate == null) {
            return endFieldName + " is required!";
        }
        
        if (!isValidDateRange(startDate, endDate)) {
            return endFieldName + " must be after " + startFieldName + "!";
        }
        
        return null;
    }
    
    /**
     * Sanitize string input (remove potentially dangerous characters)
     * @param input Input string
     * @return Sanitized string
     */
    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        
        // Remove HTML tags and script content
        String sanitized = input.replaceAll("<[^>]*>", "");
        
        // Remove SQL injection attempts
        sanitized = sanitized.replaceAll("('|(--)|;|\\*|\\||%)", "");
        
        return sanitized.trim();
    }
    
    /**
     * Check if string contains only alphanumeric characters
     * @param value String value
     * @return true if alphanumeric
     */
    public static boolean isAlphanumeric(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }
        return value.matches("^[A-Za-z0-9]+$");
    }
    
    /**
     * Check if string is numeric
     * @param value String value
     * @return true if numeric
     */
    public static boolean isNumeric(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
    
    /**
     * Check if string is a valid decimal number
     * @param value String value
     * @return true if valid decimal
     */
    public static boolean isDecimal(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }
        try {
            Double.parseDouble(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
