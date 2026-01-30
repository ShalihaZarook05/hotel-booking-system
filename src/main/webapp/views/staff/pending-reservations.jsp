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
    
    User user = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    
    List<Reservation> pendingReservations = (List<Reservation>) request.getAttribute("pendingReservations");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Reservations - Ocean View Resort</title>
    
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
        
        .navbar .nav-links {
            display: flex;
            gap: 1rem;
            align-items: center;
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
        
        .header h2 {
            color: #1e3a8a;
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
        
        .alert-warning {
            background: #fef3c7;
            color: #92400e;
            border: 1px solid #fcd34d;
        }
        
        .content {
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }
        
        .search-section {
            margin-bottom: 2rem;
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        
        .search-section input {
            flex: 1;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 5px;
            font-size: 1rem;
        }
        
        .search-section button {
            padding: 0.75rem 1.5rem;
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .search-section button:hover {
            opacity: 0.9;
        }
        
        .table-wrapper {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        
        table th {
            background: #f9fafb;
            padding: 1rem;
            text-align: left;
            color: #374151;
            font-weight: 600;
            border-bottom: 2px solid #e5e7eb;
        }
        
        table td {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        table tr:hover {
            background: #f9fafb;
        }
        
        .status-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-confirmed {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-cancelled {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .actions {
            display: flex;
            gap: 0.5rem;
        }
        
        .btn {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
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
        
        .btn-view {
            background: #3b82f6;
            color: white;
        }
        
        .btn-edit {
            background: #f59e0b;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #6b7280;
        }
        
        .empty-state img {
            width: 150px;
            opacity: 0.5;
            margin-bottom: 1rem;
        }
        
        .guest-info {
            display: flex;
            flex-direction: column;
        }
        
        .guest-name {
            font-weight: 600;
            color: #1e3a8a;
        }
        
        .guest-email {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .reservation-details {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }
        
        .room-info {
            font-weight: 600;
            color: #0d9488;
        }
        
        .date-info {
            font-size: 0.9rem;
            color: #374151;
        }
        
        .amount {
            font-weight: 700;
            color: #1e3a8a;
            font-size: 1.1rem;
        }
        
        .stats-bar {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            padding: 1rem;
            background: #f9fafb;
            border-radius: 8px;
        }
        
        .stat-item {
            flex: 1;
            text-align: center;
        }
        
        .stat-item .label {
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 0.25rem;
        }
        
        .stat-item .value {
            font-size: 1.5rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background: white;
            margin: 5% auto;
            padding: 2rem;
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .modal-header h3 {
            color: #1e3a8a;
        }
        
        .close {
            font-size: 2rem;
            cursor: pointer;
            color: #6b7280;
        }
        
        .close:hover {
            color: #1e3a8a;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-weight: 600;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 5px;
            font-family: inherit;
            resize: vertical;
        }
        
        .modal-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }
        
        .btn-cancel {
            background: #6b7280;
            color: white;
        }
        
        @media (max-width: 768px) {
            .stats-bar {
                flex-direction: column;
            }
            
            .actions {
                flex-direction: column;
            }
            
            table th, table td {
                padding: 0.5rem;
                font-size: 0.9rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h1>🏨 Ocean View Resort - Staff Portal</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/staff/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/staff/pending">Pending</a>
            <a href="<%= request.getContextPath() %>/staff/checkin">Check-In</a>
            <a href="<%= request.getContextPath() %>/staff/checkout">Check-Out</a>
            <a href="<%= request.getContextPath() %>/staff/rooms">Rooms</a>
            <a href="<%= request.getContextPath() %>/logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <!-- Page Header -->
        <div class="header">
            <div>
                <h2>⏳ Pending Reservations</h2>
                <p style="color: #6b7280; margin-top: 0.5rem;">Review and process pending reservation requests</p>
            </div>
            <div>
                <span style="background: #fef3c7; padding: 0.5rem 1rem; border-radius: 20px; color: #92400e; font-weight: 600;">
                    <%= pendingReservations != null ? pendingReservations.size() : 0 %> Pending
                </span>
            </div>
        </div>
        
        <!-- Alert Messages -->
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
        
        <!-- Main Content -->
        <div class="content">
            <!-- Statistics Bar -->
            <div class="stats-bar">
                <div class="stat-item">
                    <div class="label">Total Pending</div>
                    <div class="value"><%= pendingReservations != null ? pendingReservations.size() : 0 %></div>
                </div>
                <div class="stat-item">
                    <div class="label">Today's Date</div>
                    <div class="value" style="font-size: 1rem; margin-top: 0.5rem;">
                        <%= new SimpleDateFormat("MMM dd, yyyy").format(new java.util.Date()) %>
                    </div>
                </div>
            </div>
            
            <!-- Search Section -->
            <div class="search-section">
                <input type="text" id="searchInput" placeholder="Search by reservation number, guest name, or email..." onkeyup="filterTable()">
                <button onclick="filterTable()">🔍 Search</button>
            </div>
            
            <!-- Reservations Table -->
            <% if (pendingReservations != null && !pendingReservations.isEmpty()) { %>
                <div class="table-wrapper">
                    <table id="reservationsTable">
                        <thead>
                            <tr>
                                <th>Reservation #</th>
                                <th>Guest Information</th>
                                <th>Room & Dates</th>
                                <th>Guests</th>
                                <th>Total Amount</th>
                                <th>Requested On</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Reservation reservation : pendingReservations) { 
                                String guestName = reservation.getGuest() != null ? reservation.getGuest().getFullName() : "N/A";
                                String guestEmail = reservation.getGuest() != null ? reservation.getGuest().getEmail() : "";
                                String roomNumber = reservation.getRoom() != null ? reservation.getRoom().getRoomNumber() : "N/A";
                                String roomType = reservation.getRoom() != null && reservation.getRoom().getRoomType() != null 
                                    ? reservation.getRoom().getRoomType().getTypeName() : "N/A";
                            %>
                                <tr>
                                    <td><strong><%= reservation.getReservationNumber() %></strong></td>
                                    <td>
                                        <div class="guest-info">
                                            <span class="guest-name"><%= guestName %></span>
                                            <span class="guest-email"><%= guestEmail %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="reservation-details">
                                            <span class="room-info">Room <%= roomNumber %> - <%= roomType %></span>
                                            <span class="date-info">
                                                📅 <%= dateFormat.format(reservation.getCheckInDate()) %> 
                                                → <%= dateFormat.format(reservation.getCheckOutDate()) %>
                                            </span>
                                            <span class="date-info" style="color: #6b7280; font-size: 0.85rem;">
                                                <%= reservation.getNumberOfNights() %> night(s)
                                            </span>
                                        </div>
                                    </td>
                                    <td style="text-align: center;">
                                        <strong><%= reservation.getNumberOfGuests() %></strong>
                                    </td>
                                    <td>
                                        <span class="amount">LKR <%= String.format("%,.2f", reservation.getTotalAmount()) %></span>
                                    </td>
                                    <td>
                                        <%= reservation.getCreatedDate() != null 
                                            ? new SimpleDateFormat("MMM dd, yyyy HH:mm").format(reservation.getCreatedDate()) 
                                            : "N/A" %>
                                    </td>
                                    <td>
                                        <span class="status-badge status-pending">⏳ PENDING</span>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <button class="btn btn-confirm" 
                                                    onclick="confirmReservation(<%= reservation.getReservationId() %>, '<%= reservation.getReservationNumber() %>')">
                                                ✅ Confirm
                                            </button>
                                            <button class="btn btn-reject" 
                                                    onclick="showRejectModal(<%= reservation.getReservationId() %>, '<%= reservation.getReservationNumber() %>')">
                                                ❌ Reject
                                            </button>
                                            <a href="<%= request.getContextPath() %>/staff/pending/view?id=<%= reservation.getReservationId() %>" 
                                               class="btn btn-view">
                                                👁️ View
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <div style="font-size: 4rem; margin-bottom: 1rem;">🎉</div>
                    <h3>No Pending Reservations</h3>
                    <p>All reservation requests have been processed!</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <!-- Reject Modal -->
    <div id="rejectModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Reject Reservation</h3>
                <span class="close" onclick="closeRejectModal()">&times;</span>
            </div>
            <form id="rejectForm" method="POST" action="<%= request.getContextPath() %>/staff/pending/reject">
                <input type="hidden" id="rejectReservationId" name="reservationId">
                
                <div class="alert alert-warning">
                    ⚠️ You are about to reject reservation <strong id="rejectReservationNumber"></strong>
                </div>
                
                <div class="form-group">
                    <label for="rejectionReason">Reason for Rejection: *</label>
                    <textarea id="rejectionReason" 
                              name="rejectionReason" 
                              rows="4" 
                              placeholder="Please provide a reason for rejecting this reservation..."
                              required></textarea>
                </div>
                
                <div class="modal-actions">
                    <button type="button" class="btn btn-cancel" onclick="closeRejectModal()">Cancel</button>
                    <button type="submit" class="btn btn-reject">Reject Reservation</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Filter table based on search input
        function filterTable() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toUpperCase();
            const table = document.getElementById('reservationsTable');
            
            if (!table) return;
            
            const tr = table.getElementsByTagName('tr');
            
            for (let i = 1; i < tr.length; i++) {
                const row = tr[i];
                const cells = row.getElementsByTagName('td');
                let found = false;
                
                for (let j = 0; j < cells.length - 1; j++) {
                    const cell = cells[j];
                    if (cell) {
                        const textValue = cell.textContent || cell.innerText;
                        if (textValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                row.style.display = found ? '' : 'none';
            }
        }
        
        // Confirm reservation
        function confirmReservation(reservationId, reservationNumber) {
            if (confirm('Are you sure you want to CONFIRM reservation ' + reservationNumber + '?')) {
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
        
        // Show reject modal
        function showRejectModal(reservationId, reservationNumber) {
            document.getElementById('rejectReservationId').value = reservationId;
            document.getElementById('rejectReservationNumber').textContent = reservationNumber;
            document.getElementById('rejectModal').style.display = 'block';
        }
        
        // Close reject modal
        function closeRejectModal() {
            document.getElementById('rejectModal').style.display = 'none';
            document.getElementById('rejectionReason').value = '';
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('rejectModal');
            if (event.target == modal) {
                closeRejectModal();
            }
        }
    </script>
</body>
</html>
