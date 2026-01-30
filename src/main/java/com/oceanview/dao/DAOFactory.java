package com.oceanview.dao;

import com.oceanview.dao.impl.UserDAOImpl;
import com.oceanview.dao.impl.ReservationDAOImpl;
import com.oceanview.dao.impl.RoomDAOImpl;
import com.oceanview.dao.impl.PaymentDAOImpl;

/**
 * DAOFactory - Factory Pattern Implementation
 * Provides centralized access to all DAO implementations
 */
public class DAOFactory {
    
    // Singleton instances of DAO implementations
    private static UserDAO userDAO;
    private static ReservationDAO reservationDAO;
    private static RoomDAO roomDAO;
    private static PaymentDAO paymentDAO;
    
    /**
     * Get UserDAO instance
     * @return UserDAO implementation
     */
    public static UserDAO getUserDAO() {
        if (userDAO == null) {
            synchronized (DAOFactory.class) {
                if (userDAO == null) {
                    userDAO = new UserDAOImpl();
                }
            }
        }
        return userDAO;
    }
    
    /**
     * Get ReservationDAO instance
     * @return ReservationDAO implementation
     */
    public static ReservationDAO getReservationDAO() {
        if (reservationDAO == null) {
            synchronized (DAOFactory.class) {
                if (reservationDAO == null) {
                    reservationDAO = new ReservationDAOImpl();
                }
            }
        }
        return reservationDAO;
    }
    
    /**
     * Get RoomDAO instance
     * @return RoomDAO implementation
     */
    public static RoomDAO getRoomDAO() {
        if (roomDAO == null) {
            synchronized (DAOFactory.class) {
                if (roomDAO == null) {
                    roomDAO = new RoomDAOImpl();
                }
            }
        }
        return roomDAO;
    }
    
    /**
     * Get PaymentDAO instance
     * @return PaymentDAO implementation
     */
    public static PaymentDAO getPaymentDAO() {
        if (paymentDAO == null) {
            synchronized (DAOFactory.class) {
                if (paymentDAO == null) {
                    paymentDAO = new PaymentDAOImpl();
                }
            }
        }
        return paymentDAO;
    }
}
