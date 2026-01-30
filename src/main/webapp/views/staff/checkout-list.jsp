<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is staff
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    List<Reservation> checkOuts = (List<Reservation>) request.getAttribute("checkOuts");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Check-Out Management - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f3f4f6;
            min-height: 100vh;
        }
        
        .navbar {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .navbar h1 {
            font-size: 1.5rem;
        }
        
        .navbar .nav-links {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .navbar a:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .container {
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .page-header {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }
        
        .page-header h2 {
            color: #1e3a8a;
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }
        
        .page-header p {
            color: #6b7280;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }
        
        .alert-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
        
        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #6ee7b7;
        }
        
        .stats-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .stat-box {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            text-align: center;
            border-left: 4px solid #f59e0b;
        }
        
        .stat-box h3 {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-box .value {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .checkout-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 1.5rem;
        }
        
        .checkout-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .checkout-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        .card-header {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
            padding: 1.5rem;
        }
        
        .card-header h3 {
            font-size: 1.3rem;
            margin-bottom: 0.5rem;
        }
        
        .card-header .reservation-id {
            opacity: 0.9;
            font-size: 0.9rem;
        }
        
        .card-body {
            padding: 1.5rem;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #6b7280;
            font-weight: 600;
        }
        
        .info-value {
            color: #374151;
            font-weight: 500;
        }
        
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .badge-checkedin {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .card-actions {
            padding: 1rem 1.5rem;
            background: #f9fafb;
            border-top: 1px solid #e5e7eb;
        }
        
        .btn-checkout {
            width: 100%;
            padding: 0.75rem;
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s;
        }
        
        .btn-checkout:hover {
            transform: translateY(-2px);
        }
        
        .btn-checkout:disabled {
            background: #9ca3af;
            cursor: not-allowed;
            transform: none;
        }
        
        .duration-badge {
            background: #f3f4f6;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            text-align: center;
            margin-top: 1rem;
        }
        
        .duration-badge .label {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .duration-badge .value {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        
        .empty-state h3 {
            color: #374151;
            margin-bottom: 0.5rem;
        }
        
        .empty-state p {
            color: #6b7280;
        }
        
        @media (max-width: 768px) {
            .checkout-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    
    <script>
        function processCheckOut(reservationId, guestName) {
            if (confirm('Process check-out for ' + guestName + '?\n\nThis will mark the room as available.')) {
                document.getElementById('form-' + reservationId).submit();
            }
        }
        
        function calculateNights(checkIn, checkOut) {
            const oneDay = 24 * 60 * 60 * 1000;
            const firstDate = new Date(checkIn);
            const secondDate = new Date(checkOut);
            return Math.round(Math.abs((firstDate - secondDate) / oneDay));
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Check-Out Management</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/staff/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/checkin">📥 Check-Ins</a>
            <a href="<%= request.getContextPath() %>/staff/checkout">📤 Check-Outs</a>
            <a href="<%= request.getContextPath() %>/staff/rooms">🏠 Rooms</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>📤 Today's Check-Outs</h2>
            <p>Process guest check-outs for today, <%= dateFormat.format(new java.util.Date()) %></p>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <div class="stats-bar">
            <div class="stat-box">
                <h3>Total Check-Outs Today</h3>
                <div class="value"><%= checkOuts != null ? checkOuts.size() : 0 %></div>
            </div>
            <div class="stat-box">
                <h3>Current Time</h3>
                <div class="value" style="font-size: 1.5rem;"><%= timeFormat.format(new java.util.Date()) %></div>
            </div>
        </div>
        
        <div style="background: white; padding: 1rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05); margin-bottom: 2rem;">
            <p style="color: #6b7280; margin: 0;">Use the "Process Check-Out" button below to complete guest check-outs with billing details</p>
        </div>
        
        <% if (checkOuts != null && !checkOuts.isEmpty()) { %>
            <div class="checkout-grid">
                <% 
                for (Reservation reservation : checkOuts) { 
                    long diffInMillies = reservation.getCheckOutDate().getTime() - reservation.getCheckInDate().getTime();
                    long nights = diffInMillies / (1000 * 60 * 60 * 24);
                %>
                    <div class="checkout-card">
                        <div class="card-header">
                            <h3>🛏️ Room <%= reservation.getRoomId() %></h3>
                            <div class="reservation-id">Reservation #<%= reservation.getReservationId() %></div>
                        </div>
                        
                        <div class="card-body">
                            <div class="info-row">
                                <span class="info-label">Guest ID:</span>
                                <span class="info-value">#<%= reservation.getGuestId() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Check-In Date:</span>
                                <span class="info-value"><%= dateFormat.format(reservation.getCheckInDate()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Check-Out Date:</span>
                                <span class="info-value"><%= dateFormat.format(reservation.getCheckOutDate()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Guests:</span>
                                <span class="info-value">👥 <%= reservation.getNumberOfGuests() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="badge badge-checkedin">🏨 <%= reservation.getStatus() %></span>
                                </span>
                            </div>
                            
                            <div class="duration-badge">
                                <div class="label">Total Stay Duration</div>
                                <div class="value"><%= nights %> Night<%= nights != 1 ? "s" : "" %></div>
                            </div>
                        </div>
                        
                        <div class="card-actions">
                            <% if (!"CHECKED_OUT".equals(reservation.getStatus())) { %>
                                <div style="display: flex; gap: 0.5rem; margin-bottom: 0.5rem;">
                                    <a href="<%= request.getContextPath() %>/staff/checkout/form?id=<%= reservation.getReservationId() %>" 
                                       style="flex: 1; padding: 0.75rem; background: linear-gradient(135deg, #ef4444, #dc2626); color: white; text-align: center; text-decoration: none; border-radius: 8px; font-weight: 600;">
                                        💳 Process with Billing
                                    </a>
                                </div>
                                <div style="display: flex; gap: 0.5rem;">
                                    <a href="<%= request.getContextPath() %>/staff/checkout/view?id=<%= reservation.getReservationId() %>" 
                                       style="flex: 1; padding: 0.5rem; background: #3b82f6; color: white; text-align: center; text-decoration: none; border-radius: 6px; font-size: 0.9rem; font-weight: 600;">
                                        👁️ View Details
                                    </a>
                                    <form id="form-<%= reservation.getReservationId() %>" 
                                          action="<%= request.getContextPath() %>/staff/processCheckOut" 
                                          method="post" style="flex: 1; margin: 0;">
                                        <input type="hidden" name="reservationId" value="<%= reservation.getReservationId() %>">
                                        <button type="button" 
                                                class="btn-checkout" 
                                                onclick="processCheckOut(<%= reservation.getReservationId() %>, 'Guest #<%= reservation.getGuestId() %>')"
                                                style="width: 100%; padding: 0.5rem; background: #f59e0b; font-size: 0.9rem;">
                                            ⚡ Quick Check-Out
                                        </button>
                                    </form>
                                </div>
                            <% } else { %>
                                <button class="btn-checkout" disabled>✅ Already Checked Out</button>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <h3>No Check-Outs Scheduled</h3>
                <p>There are no check-outs scheduled for today</p>
            </div>
        <% } %>
    </div>
    
</body>
</html>
