package com.oceanview.controller;

import com.oceanview.dao.ReservationDAO;
import com.oceanview.dao.PaymentDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.Reservation;
import com.oceanview.model.Payment;
import com.oceanview.util.SessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * BillingServlet
 * Handles billing and payment operations
 */
@WebServlet("/billing/*")
public class BillingServlet extends HttpServlet {
    
    private ReservationDAO reservationDAO;
    private PaymentDAO paymentDAO;
    
    @Override
    public void init() throws ServletException {
        reservationDAO = DAOFactory.getReservationDAO();
        paymentDAO = DAOFactory.getPaymentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        if (!SessionManager.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action == null || action.equals("/")) {
                listPayments(request, response);
            } else if (action.equals("/generate")) {
                generateBill(request, response);
            } else if (action.equals("/view")) {
                viewBill(request, response);
            } else {
                listPayments(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/billing");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        if (!SessionManager.isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getPathInfo();
        
        try {
            if (action.equals("/process")) {
                processPayment(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/billing");
            }
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/billing");
        }
    }
    
    /**
     * List all payments
     */
    private void listPayments(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        List<Payment> payments;
        
        // Admin and Staff can see all payments, Guests see only their own
        if (SessionManager.isAdmin(request) || SessionManager.isStaff(request)) {
            payments = paymentDAO.getAll();
        } else {
            int userId = SessionManager.getUserId(request);
            // Get user's reservations and their payments
            List<Reservation> userReservations = reservationDAO.getByGuestId(userId);
            payments = new java.util.ArrayList<>();
            for (Reservation reservation : userReservations) {
                payments.addAll(paymentDAO.getByReservationId(reservation.getReservationId()));
            }
        }
        
        request.setAttribute("payments", payments);
        request.getRequestDispatcher("/views/billing.jsp").forward(request, response);
    }
    
    /**
     * Generate bill for a reservation
     */
    private void generateBill(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        Reservation reservation = reservationDAO.read(reservationId);
        
        if (reservation == null) {
            SessionManager.setErrorMessage(request, "Reservation not found!");
            response.sendRedirect(request.getContextPath() + "/billing");
            return;
        }
        
        // Check if payment already exists
        List<Payment> existingPayments = paymentDAO.getByReservationId(reservationId);
        
        // Calculate bill details
        long numberOfNights = reservation.getNumberOfNights();
        BigDecimal roomRate = reservation.getRoom().getRoomType().getPricePerNight();
        BigDecimal subtotal = roomRate.multiply(BigDecimal.valueOf(numberOfNights));
        
        // Add tax (10%)
        BigDecimal tax = subtotal.multiply(BigDecimal.valueOf(0.10));
        BigDecimal total = subtotal.add(tax);
        
        // Set attributes
        request.setAttribute("reservation", reservation);
        request.setAttribute("numberOfNights", numberOfNights);
        request.setAttribute("roomRate", roomRate);
        request.setAttribute("subtotal", subtotal);
        request.setAttribute("tax", tax);
        request.setAttribute("total", total);
        request.setAttribute("existingPayments", existingPayments);
        
        request.getRequestDispatcher("/views/generate-bill.jsp").forward(request, response);
    }
    
    /**
     * View bill details
     */
    private void viewBill(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int paymentId = Integer.parseInt(request.getParameter("paymentId"));
        Payment payment = paymentDAO.read(paymentId);
        
        if (payment == null) {
            SessionManager.setErrorMessage(request, "Payment not found!");
            response.sendRedirect(request.getContextPath() + "/billing");
            return;
        }
        
        Reservation reservation = reservationDAO.read(payment.getReservationId());
        
        request.setAttribute("payment", payment);
        request.setAttribute("reservation", reservation);
        request.getRequestDispatcher("/views/view-bill.jsp").forward(request, response);
    }
    
    /**
     * Process payment
     */
    private void processPayment(HttpServletRequest request, HttpServletResponse response) 
            throws Exception {
        
        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String paymentMethod = request.getParameter("paymentMethod");
        BigDecimal amount = new BigDecimal(request.getParameter("amount"));
        
        // Create payment
        Payment payment = new Payment(reservationId, amount, paymentMethod);
        payment.setPaymentStatus(Payment.STATUS_COMPLETED);
        
        int paymentId = paymentDAO.create(payment);
        
        if (paymentId > 0) {
            // Update reservation status to CHECKED_OUT if payment is complete
            reservationDAO.updateStatus(reservationId, Reservation.STATUS_CHECKED_OUT);
            
            SessionManager.setSuccessMessage(request, "Payment processed successfully! Payment ID: " + paymentId);
            response.sendRedirect(request.getContextPath() + "/billing/view?paymentId=" + paymentId);
        } else {
            SessionManager.setErrorMessage(request, "Failed to process payment!");
            response.sendRedirect(request.getContextPath() + "/billing/generate?reservationId=" + reservationId);
        }
    }
}
