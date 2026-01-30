<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is guest
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User user = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    
    // Get data from request attributes
    Long totalReservations = (Long) request.getAttribute("totalReservations");
    Long activeReservations = (Long) request.getAttribute("activeReservations");
    Long completedReservations = (Long) request.getAttribute("completedReservations");
    Long cancelledReservations = (Long) request.getAttribute("cancelledReservations");
    List<Reservation> upcomingReservations = (List<Reservation>) request.getAttribute("upcomingReservations");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Dashboard - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f3f4f6;
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
        
        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .navbar .user-info span {
            background: rgba(255, 255, 255, 0.2);
            padding: 0.5rem 1rem;
            border-radius: 20px;
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
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .welcome {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .welcome h2 {
            color: #1e3a8a;
            margin-bottom: 0.5rem;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border-left: 4px solid #3b82f6;
        }
        
        .stat-card.active {
            border-left-color: #10b981;
        }
        
        .stat-card.completed {
            border-left-color: #8b5cf6;
        }
        
        .stat-card.cancelled {
            border-left-color: #ef4444;
        }
        
        .stat-card h3 {
            color: #6b7280;
            font-size: 0.9rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }
        
        .stat-card .value {
            font-size: 2rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .quick-actions {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }
        
        .quick-actions h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
        }
        
        .action-buttons {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .btn {
            display: block;
            padding: 1rem;
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            text-decoration: none;
            text-align: center;
            border-radius: 8px;
            font-weight: 600;
            transition: transform 0.3s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .upcoming-section {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .upcoming-section h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
        }
        
        .reservation-card {
            background: #f9fafb;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            border-left: 4px solid #3b82f6;
        }
        
        .reservation-card:last-child {
            margin-bottom: 0;
        }
        
        .reservation-card h4 {
            color: #1e3a8a;
            margin-bottom: 0.5rem;
        }
        
        .reservation-info {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .reservation-status {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-top: 0.5rem;
        }
        
        .status-confirmed {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        
        .empty-state {
            text-align: center;
            color: #6b7280;
            padding: 3rem;
        }
        
        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    
    <!-- Navigation Bar -->
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - My Dashboard</h1>
        <div class="user-info">
            <span>👤 <%= user.getFullName() %></span>
            <a href="<%= request.getContextPath() %>/logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <!-- Welcome Section -->
        <div class="welcome">
            <h2>Welcome back, <%= user.getFullName() %>! 🎉</h2>
            <p style="color: #6b7280;">Manage your reservations and profile here.</p>
        </div>
        
        <!-- Messages -->
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                ❌ <%= errorMessage %>
            </div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                ✅ <%= successMessage %>
            </div>
        <% } %>
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Reservations</h3>
                <div class="value"><%= totalReservations != null ? totalReservations : 0 %></div>
            </div>
            
            <div class="stat-card active">
                <h3>Active Reservations</h3>
                <div class="value"><%= activeReservations != null ? activeReservations : 0 %></div>
            </div>
            
            <div class="stat-card completed">
                <h3>Completed Stays</h3>
                <div class="value"><%= completedReservations != null ? completedReservations : 0 %></div>
            </div>
            
            <div class="stat-card cancelled">
                <h3>Cancelled</h3>
                <div class="value"><%= cancelledReservations != null ? cancelledReservations : 0 %></div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3>⚡ Quick Actions</h3>
            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/guest/reservation/new" class="btn">➕ New Reservation</a>
                <a href="<%= request.getContextPath() %>/guest/reservations" class="btn">📋 My Reservations</a>
                <a href="<%= request.getContextPath() %>/guest/profile" class="btn">👤 My Profile</a>
                <a href="<%= request.getContextPath() %>/guest/reservation/new" class="btn">🏠 Browse Rooms</a>
            </div>
        </div>
        
        <!-- Upcoming Reservations -->
        <div class="upcoming-section">
            <h3>📅 Upcoming Reservations</h3>
            <% if (upcomingReservations != null && !upcomingReservations.isEmpty()) { %>
                <% for (Reservation res : upcomingReservations) { %>
                    <div class="reservation-card">
                        <h4>Reservation #<%= res.getReservationId() %></h4>
                        <div class="reservation-info">
                            <p><strong>Room:</strong> <%= res.getRoomId() %></p>
                            <p><strong>Check-in:</strong> <%= res.getCheckInDate() %></p>
                            <p><strong>Check-out:</strong> <%= res.getCheckOutDate() %></p>
                            <p><strong>Guests:</strong> <%= res.getNumberOfGuests() %></p>
                        </div>
                        <span class="reservation-status <%= res.isConfirmed() ? "status-confirmed" : "status-pending" %>">
                            <%= res.getStatus() %>
                        </span>
                    </div>
                <% } %>
            <% } else { %>
                <div class="empty-state">
                    <div class="empty-state-icon">📭</div>
                    <h3>No Upcoming Reservations</h3>
                    <p>Book your next stay at Ocean View Resort!</p>
                    <br>
                    <a href="<%= request.getContextPath() %>/guest/reservation/new" class="btn" style="display: inline-block; width: auto;">Make a Reservation</a>
                </div>
            <% } %>
        </div>
    </div>
    
</body>
</html>
