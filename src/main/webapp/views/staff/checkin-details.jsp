<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    User guest = (User) request.getAttribute("guest");
    Room room = (Room) request.getAttribute("room");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
    
    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/staff/checkin");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Check-In Details - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f4f6; }
        .navbar { background: linear-gradient(135deg, #1e3a8a, #0d9488); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .navbar h1 { font-size: 1.5rem; }
        .navbar .nav-links { display: flex; gap: 1rem; }
        .navbar a { color: white; text-decoration: none; padding: 0.5rem 1rem; background: rgba(255, 255, 255, 0.2); border-radius: 5px; }
        .container { max-width: 1000px; margin: 2rem auto; padding: 0 2rem; }
        .card { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05); margin-bottom: 1.5rem; }
        .card h2 { color: #1e3a8a; margin-bottom: 1.5rem; }
        .info-grid { display: grid; gap: 1rem; }
        .info-row { display: flex; justify-content: space-between; padding: 0.75rem 0; border-bottom: 1px solid #e5e7eb; }
        .info-label { color: #6b7280; font-weight: 600; }
        .info-value { color: #374151; font-weight: 500; }
        .btn { padding: 0.75rem 2rem; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; text-align: center; }
        .btn-primary { background: #3b82f6; color: white; }
        .btn-secondary { background: #e5e7eb; color: #374151; }
        .actions { display: flex; gap: 1rem; margin-top: 2rem; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>🏖️ Ocean View Resort</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/staff/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/checkin">Check-Ins</a>
        </div>
    </div>
    
    <div class="container">
        <div class="card">
            <h2>📋 Reservation Details</h2>
            <div class="info-grid">
                <div class="info-row">
                    <span class="info-label">Reservation Number:</span>
                    <span class="info-value"><%= reservation.getReservationNumber() %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Status:</span>
                    <span class="info-value"><%= reservation.getStatus() %></span>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>👤 Guest Information</h2>
            <div class="info-grid">
                <div class="info-row">
                    <span class="info-label">Name:</span>
                    <span class="info-value"><%= guest != null ? guest.getFullName() : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Email:</span>
                    <span class="info-value"><%= guest != null ? guest.getEmail() : "N/A" %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Phone:</span>
                    <span class="info-value"><%= guest != null ? guest.getPhone() : "N/A" %></span>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>🏨 Room & Stay Information</h2>
            <div class="info-grid">
                <div class="info-row">
                    <span class="info-label">Room Number:</span>
                    <span class="info-value"><%= room != null ? room.getRoomNumber() : reservation.getRoomId() %></span>
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
                    <span class="info-label">Number of Guests:</span>
                    <span class="info-value"><%= reservation.getNumberOfGuests() %></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Total Amount:</span>
                    <span class="info-value">LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></span>
                </div>
            </div>
        </div>
        
        <div class="actions">
            <a href="<%= request.getContextPath() %>/staff/checkin" class="btn btn-secondary">← Back to Check-Ins</a>
        </div>
    </div>
</body>
</html>
