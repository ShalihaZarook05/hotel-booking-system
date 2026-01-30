package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.RoomDAO;
import com.oceanview.dao.UserDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Payment;
import com.oceanview.model.Room;
import com.oceanview.model.User;
import com.oceanview.util.SessionManager;
import com.oceanview.util.DateUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ReportServlet
 * Handles report generation and analytics
 */
@WebServlet("/reports/*")
public class ReportServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private PaymentDAO paymentDAO;
    private RoomDAO roomDAO;
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = DAOFactory.getReservationDAO();
        paymentDAO = DAOFactory.getPaymentDAO();
        roomDAO = DAOFactory.getRoomDAO();
        userDAO = DAOFactory.getUserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in and is admin or staff
        if (!SessionManager.isLoggedIn(request) || 
            (!SessionManager.isAdmin(request) && !SessionManager.isStaff(request))) {
            SessionManager.setErrorMessage(request, "Access denied! Admin or Staff access required.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/") || action.equals("/dashboard")) {
                showReportDashboard(request, response);
            } else if (action.equals("/revenue")) {
                generateRevenueReport(request, response);
            } else if (action.equals("/occupancy")) {
                generateOccupancyReport(request, response);
            } else if (action.equals("/reservations")) {
                generateReservationReport(request, response);
            } else {
                showReportDashboard(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/reports");
        }
    }
    
    /**
     * Show report dashboard with overview
     */
    private void showReportDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        // Get overall statistics
        List<Reservation> allReservations = reservationDAO.getAll();
        List<Payment> allPayments = paymentDAO.getAll();
        List<Room> allRooms = roomDAO.getAllRooms();
        List<User> allUsers = userDAO.getAll();
        
        // Calculate totals
        BigDecimal totalRevenue = paymentDAO.getTotalRevenue();
        long totalReservations = allReservations.size();
        long totalRooms = allRooms.size();
        long availableRooms = allRooms.stream().filter(Room::isAvailable).count();
        long occupiedRooms = allRooms.stream().filter(Room::isOccupied).count();
        
        // Calculate occupancy rate
        double occupancyRate = totalRooms > 0 ? (occupiedRooms * 100.0) / totalRooms : 0;
        
        // Get reservation status breakdown
        long pendingReservations = allReservations.stream()
            .filter(Reservation::isPending).count();
        long confirmedReservations = allReservations.stream()
            .filter(Reservation::isConfirmed).count();
        long checkedInReservations = allReservations.stream()
            .filter(Reservation::isCheckedIn).count();
        long checkedOutReservations = allReservations.stream()
            .filter(Reservation::isCheckedOut).count();
        long cancelledReservations = allReservations.stream()
            .filter(Reservation::isCancelled).count();
        
        // Get payment method breakdown
        long cashPayments = allPayments.stream()
            .filter(Payment::isCashPayment).count();
        long cardPayments = allPayments.stream()
            .filter(Payment::isCardPayment).count();
        long onlinePayments = allPayments.stream()
            .filter(Payment::isOnlinePayment).count();
        
        // Set attributes for Chart.js
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalRooms", totalRooms);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("occupiedRooms", occupiedRooms);
        request.setAttribute("occupancyRate", String.format("%.2f", occupancyRate));
        
        request.setAttribute("pendingReservations", pendingReservations);
        request.setAttribute("confirmedReservations", confirmedReservations);
        request.setAttribute("checkedInReservations", checkedInReservations);
        request.setAttribute("checkedOutReservations", checkedOutReservations);
        request.setAttribute("cancelledReservations", cancelledReservations);
        
        request.setAttribute("cashPayments", cashPayments);
        request.setAttribute("cardPayments", cardPayments);
        request.setAttribute("onlinePayments", onlinePayments);
        
        request.getRequestDispatcher("/views/reports.jsp").forward(request, response);
    }
    
    /**
     * Generate revenue report
     */
    private void generateRevenueReport(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        
        // Default to current month if dates not provided
        if (startDateStr == null || endDateStr == null) {
            Date currentDate = DateUtil.getCurrentDate();
            startDateStr = DateUtil.sqlDateToString(currentDate);
            endDateStr = DateUtil.sqlDateToString(DateUtil.addDays(currentDate, 30));
        }
        
        // Get revenue for date range
        BigDecimal revenue = paymentDAO.getRevenueByDateRange(startDateStr, endDateStr);
        
        // Get payments for the date range
        List<Payment> payments = paymentDAO.getAll(); // Filter by date in real scenario
        
        // Calculate breakdown
        BigDecimal cashRevenue = BigDecimal.ZERO;
        BigDecimal cardRevenue = BigDecimal.ZERO;
        BigDecimal onlineRevenue = BigDecimal.ZERO;
        
        for (Payment payment : payments) {
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
        
        request.setAttribute("totalRevenue", revenue);
        request.setAttribute("cashRevenue", cashRevenue);
        request.setAttribute("cardRevenue", cardRevenue);
        request.setAttribute("onlineRevenue", onlineRevenue);
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);
        request.setAttribute("payments", payments);
        
        request.getRequestDispatcher("/views/revenue-report.jsp").forward(request, response);
    }
    
    /**
     * Generate occupancy report
     */
    private void generateOccupancyReport(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Room> allRooms = roomDAO.getAllRooms();
        
        // Calculate occupancy statistics
        long totalRooms = allRooms.size();
        long availableRooms = allRooms.stream().filter(Room::isAvailable).count();
        long occupiedRooms = allRooms.stream().filter(Room::isOccupied).count();
        long maintenanceRooms = allRooms.stream().filter(Room::isUnderMaintenance).count();
        
        double occupancyRate = totalRooms > 0 ? (occupiedRooms * 100.0) / totalRooms : 0;
        double availabilityRate = totalRooms > 0 ? (availableRooms * 100.0) / totalRooms : 0;
        
        request.setAttribute("totalRooms", totalRooms);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("occupiedRooms", occupiedRooms);
        request.setAttribute("maintenanceRooms", maintenanceRooms);
        request.setAttribute("occupancyRate", String.format("%.2f", occupancyRate));
        request.setAttribute("availabilityRate", String.format("%.2f", availabilityRate));
        request.setAttribute("rooms", allRooms);
        
        request.getRequestDispatcher("/views/occupancy-report.jsp").forward(request, response);
    }
    
    /**
     * Generate reservation report
     */
    private void generateReservationReport(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        String status = request.getParameter("status");
        
        List<Reservation> reservations;
        
        if (status != null && !status.isEmpty()) {
            reservations = reservationDAO.getByStatus(status);
        } else {
            reservations = reservationDAO.getAll();
        }
        
        // Calculate statistics
        long totalReservations = reservations.size();
        
        // Calculate total amount
        BigDecimal totalAmount = reservations.stream()
            .filter(r -> r.getTotalAmount() != null)
            .map(Reservation::getTotalAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        request.setAttribute("reservations", reservations);
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalAmount", totalAmount);
        request.setAttribute("selectedStatus", status);
        
        request.getRequestDispatcher("/views/reservation-report.jsp").forward(request, response);
    }
}
