<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // Check if user is logged in and is admin
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User user = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    
    // Get statistics from request attributes
    Long totalReservations = (Long) request.getAttribute("totalReservations");
    Long totalUsers = (Long) request.getAttribute("totalUsers");
    Long totalRooms = (Long) request.getAttribute("totalRooms");
    Long availableRooms = (Long) request.getAttribute("availableRooms");
    Long occupiedRooms = (Long) request.getAttribute("occupiedRooms");
    Long maintenanceRooms = (Long) request.getAttribute("maintenanceRooms");
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    List<Reservation> todayCheckIns = (List<Reservation>) request.getAttribute("todayCheckIns");
    List<Reservation> todayCheckOuts = (List<Reservation>) request.getAttribute("todayCheckOuts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Ocean View Resort</title>
    
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
            max-width: 1400px;
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        
        .stat-card.revenue {
            border-left-color: #10b981;
        }
        
        .stat-card.users {
            border-left-color: #f59e0b;
        }
        
        .stat-card.rooms {
            border-left-color: #8b5cf6;
        }
        
        .stat-card.maintenance {
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
        
        .today-activities {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        
        .activity-card {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .activity-card h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
        }
        
        .activity-list {
            list-style: none;
        }
        
        .activity-list li {
            padding: 0.75rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .activity-list li:last-child {
            border-bottom: none;
        }
        
        .empty-state {
            text-align: center;
            color: #6b7280;
            padding: 2rem;
        }
        
        @media (max-width: 768px) {
            .today-activities {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    
    <!-- Navigation Bar -->
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Admin Dashboard</h1>
        <div class="user-info">
            <span>👤 <%= user.getFullName() %> (Admin)</span>
            <a href="<%= request.getContextPath() %>/logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <!-- Welcome Section -->
        <div class="welcome">
            <h2>Welcome back, <%= user.getFullName() %>!</h2>
            <p style="color: #6b7280;">Here's what's happening in your resort today.</p>
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
            
            <div class="stat-card revenue">
                <h3>Total Revenue</h3>
                <div class="value">LKR <%= totalRevenue != null ? String.format("%,.2f", Double.parseDouble(totalRevenue.toString())) : "0.00" %></div>
            </div>
            
            <div class="stat-card users">
                <h3>Total Users</h3>
                <div class="value"><%= totalUsers != null ? totalUsers : 0 %></div>
            </div>
            
            <div class="stat-card rooms">
                <h3>Total Rooms</h3>
                <div class="value"><%= totalRooms != null ? totalRooms : 0 %></div>
            </div>
            
            <div class="stat-card">
                <h3>✅ Available Rooms</h3>
                <div class="value"><%= availableRooms != null ? availableRooms : 0 %></div>
            </div>
            
            <div class="stat-card users">
                <h3>🔒 Occupied Rooms</h3>
                <div class="value"><%= occupiedRooms != null ? occupiedRooms : 0 %></div>
            </div>
            
            <div class="stat-card maintenance">
                <h3>🔧 Maintenance Rooms</h3>
                <div class="value"><%= maintenanceRooms != null ? maintenanceRooms : 0 %></div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <h3>⚡ Quick Actions</h3>
            <div class="action-buttons">
                <a href="<%= request.getContextPath() %>/admin/users" class="btn">👥 Manage Users</a>
                <a href="<%= request.getContextPath() %>/admin/rooms" class="btn">🏠 Manage Rooms</a>
                <a href="<%= request.getContextPath() %>/admin/roomtypes" class="btn">🛏️ Room Types</a>
                <a href="<%= request.getContextPath() %>/admin/reservations" class="btn">📋 View Reservations</a>
                <a href="<%= request.getContextPath() %>/reports" class="btn">📊 Reports</a>
            </div>
        </div>
        
        <!-- Today's Activities -->
        <div class="today-activities">
            <div class="activity-card">
                <h3>📥 Today's Check-Ins (<%= todayCheckIns != null ? todayCheckIns.size() : 0 %>)</h3>
                <% if (todayCheckIns != null && !todayCheckIns.isEmpty()) { %>
                    <ul class="activity-list">
                        <% for (Reservation res : todayCheckIns) { %>
                            <li>
                                <strong>Reservation #<%= res.getReservationId() %></strong><br>
                                Room: <%= res.getRoomId() %> | Guest: <%= res.getGuestId() %>
                            </li>
                        <% } %>
                    </ul>
                <% } else { %>
                    <div class="empty-state">No check-ins scheduled for today</div>
                <% } %>
            </div>
            
            <div class="activity-card">
                <h3>📤 Today's Check-Outs (<%= todayCheckOuts != null ? todayCheckOuts.size() : 0 %>)</h3>
                <% if (todayCheckOuts != null && !todayCheckOuts.isEmpty()) { %>
                    <ul class="activity-list">
                        <% for (Reservation res : todayCheckOuts) { %>
                            <li>
                                <strong>Reservation #<%= res.getReservationId() %></strong><br>
                                Room: <%= res.getRoomId() %> | Guest: <%= res.getGuestId() %>
                            </li>
                        <% } %>
                    </ul>
                <% } else { %>
                    <div class="empty-state">No check-outs scheduled for today</div>
                <% } %>
            </div>
        </div>
    </div>
    
</body>
</html>
