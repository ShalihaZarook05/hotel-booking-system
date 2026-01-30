package com.oceanview.util;

import java.sql.Date;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * DateUtil
 * Utility class for date operations and formatting
 */
public class DateUtil {
    
    private static final String DATE_FORMAT = "yyyy-MM-dd";
    private static final String DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
    private static final String DISPLAY_DATE_FORMAT = "dd/MM/yyyy";
    
    /**
     * Convert String to SQL Date
     * @param dateString Date string in yyyy-MM-dd format
     * @return SQL Date object
     */
    public static Date stringToSqlDate(String dateString) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);
            java.util.Date utilDate = sdf.parse(dateString);
            return new Date(utilDate.getTime());
        } catch (ParseException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Convert SQL Date to String
     * @param date SQL Date object
     * @return Formatted date string
     */
    public static String sqlDateToString(Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT);
        return sdf.format(date);
    }
    
    /**
     * Convert SQL Date to display format
     * @param date SQL Date object
     * @return Formatted date string (dd/MM/yyyy)
     */
    public static String sqlDateToDisplayFormat(Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat(DISPLAY_DATE_FORMAT);
        return sdf.format(date);
    }
    
    /**
     * Get current SQL Date
     * @return Current date as SQL Date
     */
    public static Date getCurrentDate() {
        return new Date(System.currentTimeMillis());
    }
    
    /**
     * Get current Timestamp
     * @return Current timestamp
     */
    public static Timestamp getCurrentTimestamp() {
        return new Timestamp(System.currentTimeMillis());
    }
    
    /**
     * Calculate days between two dates
     * @param startDate Start date
     * @param endDate End date
     * @return Number of days
     */
    public static long daysBetween(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) return 0;
        
        LocalDate start = startDate.toLocalDate();
        LocalDate end = endDate.toLocalDate();
        return ChronoUnit.DAYS.between(start, end);
    }
    
    /**
     * Check if date is in the past
     * @param date Date to check
     * @return true if date is in the past
     */
    public static boolean isPastDate(Date date) {
        if (date == null) return false;
        return date.before(getCurrentDate());
    }
    
    /**
     * Check if date is in the future
     * @param date Date to check
     * @return true if date is in the future
     */
    public static boolean isFutureDate(Date date) {
        if (date == null) return false;
        return date.after(getCurrentDate());
    }
    
    /**
     * Check if date is today
     * @param date Date to check
     * @return true if date is today
     */
    public static boolean isToday(Date date) {
        if (date == null) return false;
        return sqlDateToString(date).equals(sqlDateToString(getCurrentDate()));
    }
    
    /**
     * Validate date range (start date before end date)
     * @param startDate Start date
     * @param endDate End date
     * @return true if valid range
     */
    public static boolean isValidDateRange(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) return false;
        return startDate.before(endDate) || startDate.equals(endDate);
    }
    
    /**
     * Add days to a date
     * @param date Original date
     * @param days Number of days to add
     * @return New date
     */
    public static Date addDays(Date date, int days) {
        if (date == null) return null;
        LocalDate localDate = date.toLocalDate().plusDays(days);
        return Date.valueOf(localDate);
    }
}
