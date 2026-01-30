<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in and is staff
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    User guest = (User) request.getAttribute("guest");
    Room room = (Room) request.getAttribute("room");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details - Ocean View Resort</title>
    
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
            max-width: 1000px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .header {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            background: #fef3c7;
            color: #92400e;
        }
        
        .content {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }
        
        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }
        
        .detail-section {
            border-left: 4px solid #3b82f6;
            padding-left: 1rem;
        }
        
        .detail-section h3 {
            color: #1e3a8a;
            margin-bottom: 1rem;
            font-size: 1.2rem;
        }
        
        .detail-item {
            margin-bottom: 1rem;
        }
        
        .detail-item label {
            display: block;
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 0.25rem;
        }
        
        .detail-item .value {
            font-size: 1rem;
            color: #1f2937;
            font-weight: 600;
        }
        
        .actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            padding: 2rem 0;
        }
        
        .btn {
            padding: 1rem 2rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: opacity 0.3s;
        }
        
        .btn:hover {
            opacity: 0.8;
        }
        
        .btn-confirm {
            background: #10b981;
            color: white;
        }
        
        .btn-reject {
            background: #ef4444;
            color: white;
        }
        
        .btn-back {
            background: #6b7280;
            color: white;
        }
        
        .amount-section {
            background: #f9fafb;
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
        }
        
        .amount-section h4 {
            color: #6b7280;
            margin-bottom: 0.5rem;
        }
        
        .amount-section .amount {
            font-size: 2.5rem;
            color: #1e3a8a;
            font-weight: 700;
        }
        
        .special-requests {
            background: #fef3c7;
            padding: 1rem;
            border-radius: 8px;
            border-left: 4px solid #f59e0b;
            margin-top: 1rem;
        }
        
        .special-requests h4 {
            color: #92400e;
            margin-bottom: 0.5rem;
        }
        
        .special-requests p {
            color: #78350f;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>🏨 Ocean View Resort - Staff Portal</h1>
        <a href="<%= request.getContextPath() %>/staff/pending">← Back to Pending</a>
    </div>
    
    <div class="container">
        <div class="header">
            <div>
                <h2>Reservation Details</h2>
                <p style="color: #6b7280; margin-top: 0.5rem;">
                    Reservation #<%= reservation.getReservationNumber() %>
                </p>
            </div>
            <span class="status-badge">⏳ PENDING</span>
        </div>
        
        <div class="content">
            <div class="detail-grid">
                <!-- Guest Information -->
                <div class="detail-section">
                    <h3>👤 Guest Information</h3>
                    <div class="detail-item">
                        <label>Full Name</label>
                        <div class="value"><%= guest.getFullName() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Email</label>
                        <div class="value"><%= guest.getEmail() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Phone Number</label>
                        <div class="value"><%= guest.getPhone() != null ? guest.getPhone() : "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <label>Address</label>
                        <div class="value"><%= guest.getAddress() != null ? guest.getAddress() : "N/A" %></div>
                    </div>
                </div>
                
                <!-- Room Information -->
                <div class="detail-section" style="border-left-color: #0d9488;">
                    <h3>🏠 Room Information</h3>
                    <div class="detail-item">
                        <label>Room Number</label>
                        <div class="value"><%= room.getRoomNumber() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Room Type</label>
                        <div class="value"><%= room.getRoomType() != null ? room.getRoomType().getTypeName() : "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <label>Floor</label>
                        <div class="value"><%= room.getFloorNumber() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Capacity</label>
                        <div class="value"><%= room.getRoomType() != null ? room.getRoomType().getCapacity() + " Guests" : "N/A" %></div>
                    </div>
                </div>
            </div>
            
            <div class="detail-grid">
                <!-- Reservation Details -->
                <div class="detail-section" style="border-left-color: #f59e0b;">
                    <h3>📅 Reservation Details</h3>
                    <div class="detail-item">
                        <label>Check-In Date</label>
                        <div class="value"><%= dateFormat.format(reservation.getCheckInDate()) %></div>
                    </div>
                    <div class="detail-item">
                        <label>Check-Out Date</label>
                        <div class="value"><%= dateFormat.format(reservation.getCheckOutDate()) %></div>
                    </div>
                    <div class="detail-item">
                        <label>Number of Nights</label>
                        <div class="value"><%= reservation.getNumberOfNights() %> night(s)</div>
                    </div>
                    <div class="detail-item">
                        <label>Number of Guests</label>
                        <div class="value"><%= reservation.getNumberOfGuests() %></div>
                    </div>
                    <div class="detail-item">
                        <label>Requested On</label>
                        <div class="value">
                            <%= reservation.getCreatedDate() != null 
                                ? dateTimeFormat.format(reservation.getCreatedDate()) 
                                : "N/A" %>
                        </div>
                    </div>
                </div>
                
                <!-- Payment Information -->
                <div class="amount-section">
                    <h4>Total Amount</h4>
                    <div class="amount">LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></div>
                    <p style="color: #6b7280; margin-top: 0.5rem; font-size: 0.9rem;">
                        (<%= reservation.getNumberOfNights() %> nights × 
                        LKR <%= room.getRoomType() != null ? String.format("%,.2f", room.getRoomType().getPricePerNight()) : "0.00" %>)
                    </p>
                </div>
            </div>
            
            <!-- Special Requests -->
            <% if (reservation.getSpecialRequests() != null && !reservation.getSpecialRequests().trim().isEmpty()) { %>
                <div class="special-requests">
                    <h4>📝 Special Requests</h4>
                    <p><%= reservation.getSpecialRequests() %></p>
                </div>
            <% } %>
        </div>
        
        <!-- Action Buttons -->
        <div class="actions">
            <button class="btn btn-confirm" 
                    onclick="confirmReservation(<%= reservation.getReservationId() %>, '<%= reservation.getReservationNumber() %>')">
                ✅ Confirm Reservation
            </button>
            <button class="btn btn-reject" onclick="showRejectConfirm()">
                ❌ Reject Reservation
            </button>
            <a href="<%= request.getContextPath() %>/staff/pending" class="btn btn-back">
                ← Back to List
            </a>
        </div>
    </div>
    
    <script>
        function confirmReservation(reservationId, reservationNumber) {
            if (confirm('Are you sure you want to CONFIRM reservation ' + reservationNumber + '?\n\nThis will notify the guest that their reservation is confirmed.')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath() %>/staff/pending/confirm';
                
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'reservationId';
                input.value = reservationId;
                
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        function showRejectConfirm() {
            const reason = prompt('Please provide a reason for rejecting this reservation:');
            if (reason && reason.trim() !== '') {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= request.getContextPath() %>/staff/pending/reject';
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'reservationId';
                idInput.value = <%= reservation.getReservationId() %>;
                
                const reasonInput = document.createElement('input');
                reasonInput.type = 'hidden';
                reasonInput.name = 'rejectionReason';
                reasonInput.value = reason;
                
                form.appendChild(idInput);
                form.appendChild(reasonInput);
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
