<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reservations - Ocean View Resort</title>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
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
        
        .navbar h1 { font-size: 1.5rem; }
        
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
        
        .navbar a:hover { background: rgba(255, 255, 255, 0.3); }
        
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .page-header h2 {
            color: #1e3a8a;
            font-size: 1.8rem;
        }
        
        .btn {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: transform 0.3s;
            border: none;
            cursor: pointer;
        }
        
        .btn:hover { transform: translateY(-2px); }
        
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
        
        .reservations-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 1.5rem;
        }
        
        .reservation-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .reservation-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        .card-header {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
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
        
        .info-row:last-child { border-bottom: none; }
        
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
        
        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-confirmed { background: #d1fae5; color: #065f46; }
        .badge-checkedin { background: #dbeafe; color: #1e40af; }
        .badge-checkedout { background: #f3f4f6; color: #6b7280; }
        .badge-cancelled { background: #fee2e2; color: #991b1b; }
        
        .card-actions {
            padding: 1rem 1.5rem;
            background: #f9fafb;
            border-top: 1px solid #e5e7eb;
            display: flex;
            gap: 0.5rem;
        }
        
        .btn-small {
            flex: 1;
            padding: 0.5rem;
            border-radius: 8px;
            text-decoration: none;
            text-align: center;
            font-size: 0.9rem;
            font-weight: 600;
            transition: transform 0.2s;
            border: none;
            cursor: pointer;
        }
        
        .btn-view {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .btn-cancel {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .btn-small:hover { transform: translateY(-1px); }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .empty-state-icon { font-size: 4rem; margin-bottom: 1rem; }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .reservations-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    
    <script>
        function cancelReservation(reservationId) {
            if (confirm('Are you sure you want to cancel this reservation?\n\nThis action cannot be undone.')) {
                document.getElementById('cancelForm-' + reservationId).submit();
            }
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - My Reservations</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/guest/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/guest/reservations">📋 My Reservations</a>
            <a href="<%= request.getContextPath() %>/guest/profile">👤 Profile</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>📋 My Reservations</h2>
            <a href="<%= request.getContextPath() %>/guest/reservation/new" class="btn">➕ New Reservation</a>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <% if (reservations != null && !reservations.isEmpty()) { %>
            <div class="reservations-grid">
                <% for (Reservation res : reservations) { 
                    long days = (res.getCheckOutDate().getTime() - res.getCheckInDate().getTime()) / (1000 * 60 * 60 * 24);
                    String statusBadge = "badge-" + res.getStatus().toLowerCase().replace("_", "");
                %>
                    <div class="reservation-card">
                        <div class="card-header">
                            <h3>🛏️ Room <%= res.getRoomId() %></h3>
                            <div class="reservation-id">Reservation #<%= res.getReservationId() %></div>
                        </div>
                        
                        <div class="card-body">
                            <div class="info-row">
                                <span class="info-label">Check-In:</span>
                                <span class="info-value"><%= dateFormat.format(res.getCheckInDate()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Check-Out:</span>
                                <span class="info-value"><%= dateFormat.format(res.getCheckOutDate()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Duration:</span>
                                <span class="info-value"><%= days %> Night<%= days != 1 ? "s" : "" %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Guests:</span>
                                <span class="info-value">👥 <%= res.getNumberOfGuests() %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Total Price:</span>
                                <span class="info-value">LKR <%= String.format("%,.2f", res.getTotalAmount()) %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="info-value">
                                    <span class="badge <%= statusBadge %>"><%= res.getStatus() %></span>
                                </span>
                            </div>
                        </div>
                        
                        <div class="card-actions">
                            <a href="<%= request.getContextPath() %>/guest/reservation/view?id=<%= res.getReservationId() %>" 
                               class="btn-small btn-view">👁️ View Details</a>
                            
                            <% if (res.isPending() || res.isConfirmed()) { %>
                                <form id="cancelForm-<%= res.getReservationId() %>" 
                                      action="<%= request.getContextPath() %>/guest/reservation/cancel" 
                                      method="post" 
                                      style="flex: 1;">
                                    <input type="hidden" name="reservationId" value="<%= res.getReservationId() %>">
                                    <button type="button" 
                                            class="btn-small btn-cancel" 
                                            style="width: 100%;"
                                            onclick="cancelReservation(<%= res.getReservationId() %>)">
                                        ❌ Cancel
                                    </button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <h3>No Reservations Yet</h3>
                <p>You haven't made any reservations. Start planning your stay!</p>
                <br>
                <a href="<%= request.getContextPath() %>/guest/reservation/new" class="btn">➕ Make a Reservation</a>
            </div>
        <% } %>
    </div>
    
</body>
</html>
