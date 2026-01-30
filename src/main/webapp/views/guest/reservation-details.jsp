<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM dd, yyyy");
    
    if (reservation == null) {
        response.sendRedirect(request.getContextPath() + "/guest/reservations");
        return;
    }
    
    long days = (reservation.getCheckOutDate().getTime() - reservation.getCheckInDate().getTime()) / (1000 * 60 * 60 * 24);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details - Ocean View Resort</title>
    
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
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .details-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .card-header {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .card-header h2 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .reservation-id {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        
        .badge {
            display: inline-block;
            padding: 0.5rem 1.5rem;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 600;
            margin-top: 1rem;
        }
        
        .badge-pending { background: #fef3c7; color: #92400e; }
        .badge-confirmed { background: #d1fae5; color: #065f46; }
        .badge-checkedin { background: #dbeafe; color: #1e40af; }
        .badge-checkedout { background: #f3f4f6; color: #6b7280; }
        .badge-cancelled { background: #fee2e2; color: #991b1b; }
        
        .card-body { padding: 2rem; }
        
        .section {
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 2px solid #e5e7eb;
        }
        
        .section:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .section-title {
            color: #1e3a8a;
            font-size: 1.3rem;
            margin-bottom: 1rem;
            font-weight: 700;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }
        
        .info-box {
            background: #f9fafb;
            padding: 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #3b82f6;
        }
        
        .info-label {
            color: #6b7280;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
        }
        
        .info-value {
            color: #1e3a8a;
            font-size: 1.3rem;
            font-weight: 700;
        }
        
        .special-requests-box {
            background: #fef3c7;
            padding: 1.5rem;
            border-radius: 8px;
            border-left: 4px solid #f59e0b;
        }
        
        .special-requests-box p {
            color: #78350f;
            line-height: 1.6;
        }
        
        .price-summary {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            padding: 2rem;
            border-radius: 10px;
            border: 2px solid #3b82f6;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            font-size: 1.1rem;
        }
        
        .price-row.total {
            border-top: 2px solid #3b82f6;
            margin-top: 1rem;
            padding-top: 1rem;
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .actions {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }
        
        .btn {
            flex: 1;
            padding: 1rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s;
            text-decoration: none;
            text-align: center;
            display: block;
        }
        
        .btn:hover { transform: translateY(-2px); }
        
        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            color: white;
        }
        
        @media (max-width: 768px) {
            .info-grid { grid-template-columns: 1fr; }
            .actions { flex-direction: column; }
        }
    </style>
    
    <script>
        function cancelReservation(id) {
            if (confirm('Are you sure you want to cancel this reservation?\n\nThis action cannot be undone.')) {
                document.getElementById('cancelForm').submit();
            }
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Reservation Details</h1>
        <a href="<%= request.getContextPath() %>/guest/reservations">← Back to My Reservations</a>
    </div>
    
    <div class="container">
        <div class="details-card">
            <div class="card-header">
                <h2>🛏️ Reservation Details</h2>
                <div class="reservation-id">Reservation #<%= reservation.getReservationId() %></div>
                <% 
                    String statusBadge = "badge-" + reservation.getStatus().toLowerCase().replace("_", "");
                %>
                <span class="badge <%= statusBadge %>"><%= reservation.getStatus() %></span>
            </div>
            
            <div class="card-body">
                <!-- Dates Section -->
                <div class="section">
                    <h3 class="section-title">📅 Stay Information</h3>
                    <div class="info-grid">
                        <div class="info-box">
                            <div class="info-label">Check-In Date</div>
                            <div class="info-value"><%= dateFormat.format(reservation.getCheckInDate()) %></div>
                        </div>
                        <div class="info-box">
                            <div class="info-label">Check-Out Date</div>
                            <div class="info-value"><%= dateFormat.format(reservation.getCheckOutDate()) %></div>
                        </div>
                        <div class="info-box">
                            <div class="info-label">Duration</div>
                            <div class="info-value"><%= days %> Night<%= days != 1 ? "s" : "" %></div>
                        </div>
                    </div>
                </div>
                
                <!-- Room & Guests Section -->
                <div class="section">
                    <h3 class="section-title">🏠 Room & Guests</h3>
                    <div class="info-grid">
                        <div class="info-box">
                            <div class="info-label">Room Number</div>
                            <div class="info-value">Room <%= reservation.getRoomId() %></div>
                        </div>
                        <div class="info-box">
                            <div class="info-label">Number of Guests</div>
                            <div class="info-value">👥 <%= reservation.getNumberOfGuests() %></div>
                        </div>
                    </div>
                </div>
                
                <!-- Special Requests -->
                <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().trim().isEmpty()) { %>
                    <div class="section">
                        <h3 class="section-title">📝 Special Requests</h3>
                        <div class="special-requests-box">
                            <p><%= reservation.getSpecialRequests() %></p>
                        </div>
                    </div>
                <% } %>
                
                <!-- Price Summary -->
                <div class="section">
                    <h3 class="section-title">💰 Price Summary</h3>
                    <div class="price-summary">
                        <div class="price-row">
                            <span><%= days %> Night<%= days != 1 ? "s" : "" %></span>
                            <span>LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></span>
                        </div>
                        <div class="price-row">
                            <span>Price per Night</span>
                            <span>LKR <%= String.format("%,.2f", reservation.getTotalAmount().divide(java.math.BigDecimal.valueOf(days), 2, java.math.RoundingMode.HALF_UP)) %></span>
                        </div>
                        <div class="price-row total">
                            <span>Total Amount</span>
                            <span>LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></span>
                        </div>
                    </div>
                </div>
                
                <!-- Actions -->
                <div class="actions">
                    <a href="<%= request.getContextPath() %>/guest/reservations" class="btn btn-primary">
                        ← Back to Reservations
                    </a>
                    
                    <% if (reservation.isPending() || reservation.isConfirmed()) { %>
                        <form id="cancelForm" 
                              action="<%= request.getContextPath() %>/guest/reservation/cancel" 
                              method="post"
                              style="flex: 1;">
                            <input type="hidden" name="reservationId" value="<%= reservation.getReservationId() %>">
                            <button type="button" 
                                    class="btn btn-danger" 
                                    style="width: 100%;"
                                    onclick="cancelReservation(<%= reservation.getReservationId() %>)">
                                ❌ Cancel Reservation
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
</body>
</html>
