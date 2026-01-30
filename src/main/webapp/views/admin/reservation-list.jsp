<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Reservation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    Long confirmedCount = (Long) request.getAttribute("confirmedCount");
    Long checkedInCount = (Long) request.getAttribute("checkedInCount");
    Long checkedOutCount = (Long) request.getAttribute("checkedOutCount");
    Long cancelledCount = (Long) request.getAttribute("cancelledCount");
    Long pendingCount = (Long) request.getAttribute("pendingCount");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Reservations - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f4f6; }
        
        .navbar { background: linear-gradient(135deg, #1e3a8a, #0d9488); color: white; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 1.5rem; }
        .navbar .nav-links { display: flex; gap: 1rem; }
        .navbar a { color: white; text-decoration: none; padding: 0.5rem 1rem; background: rgba(255,255,255,0.2); border-radius: 5px; transition: background 0.3s; }
        .navbar a:hover { background: rgba(255,255,255,0.3); }
        
        .container { max-width: 1400px; margin: 2rem auto; padding: 0 2rem; }
        
        .page-header { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 2rem; }
        .page-header h2 { color: #1e3a8a; font-size: 1.8rem; margin-bottom: 0.5rem; }
        .page-header p { color: #6b7280; }
        
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .stat-card h3 { font-size: 0.9rem; color: #6b7280; margin-bottom: 0.5rem; }
        .stat-card .value { font-size: 2rem; font-weight: 700; }
        .stat-card.pending .value { color: #f59e0b; }
        .stat-card.confirmed .value { color: #3b82f6; }
        .stat-card.checkedin .value { color: #10b981; }
        .stat-card.checkedout .value { color: #6b7280; }
        .stat-card.cancelled .value { color: #ef4444; }
        
        .alert { padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; }
        .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }
        .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
        
        .card { background: white; padding: 2rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        
        .filter-bar { display: flex; gap: 1rem; margin-bottom: 2rem; flex-wrap: wrap; }
        .filter-bar input { flex: 1; min-width: 300px; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 8px; font-size: 1rem; }
        .filter-bar select { padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 8px; font-size: 1rem; }
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 1rem; text-align: left; border-bottom: 1px solid #e5e7eb; }
        th { background: #f9fafb; font-weight: 600; color: #374151; }
        tr:hover { background: #f9fafb; }
        
        .status-badge { padding: 0.25rem 0.75rem; border-radius: 20px; font-size: 0.875rem; font-weight: 600; }
        .status-pending { background: #fef3c7; color: #92400e; }
        .status-confirmed { background: #dbeafe; color: #1e40af; }
        .status-checkedin { background: #d1fae5; color: #065f46; }
        .status-checkedout { background: #e5e7eb; color: #374151; }
        .status-cancelled { background: #fee2e2; color: #991b1b; }
        
        .btn { padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none; font-weight: 600; display: inline-block; transition: transform 0.2s; }
        .btn:hover { transform: translateY(-2px); }
        .btn-primary { background: #3b82f6; color: white; border: none; cursor: pointer; }
        .btn-secondary { background: #e5e7eb; color: #374151; }
        
        .no-data { text-align: center; padding: 3rem; color: #6b7280; }
    </style>
    <script>
        function filterTable() {
            const searchInput = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const rows = document.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                const status = row.getAttribute('data-status');
                
                const matchesSearch = text.includes(searchInput);
                const matchesStatus = statusFilter === '' || status === statusFilter;
                
                row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
            });
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Admin</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/reservations">📋 Reservations</a>
            <a href="<%= request.getContextPath() %>/admin/users">👥 Users</a>
            <a href="<%= request.getContextPath() %>/admin/rooms">🏠 Rooms</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>📋 All Reservations</h2>
            <p>View and manage all hotel reservations</p>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <div class="stats-grid">
            <div class="stat-card pending">
                <h3>Pending</h3>
                <div class="value"><%= pendingCount != null ? pendingCount : 0 %></div>
            </div>
            <div class="stat-card confirmed">
                <h3>Confirmed</h3>
                <div class="value"><%= confirmedCount != null ? confirmedCount : 0 %></div>
            </div>
            <div class="stat-card checkedin">
                <h3>Checked In</h3>
                <div class="value"><%= checkedInCount != null ? checkedInCount : 0 %></div>
            </div>
            <div class="stat-card checkedout">
                <h3>Checked Out</h3>
                <div class="value"><%= checkedOutCount != null ? checkedOutCount : 0 %></div>
            </div>
            <div class="stat-card cancelled">
                <h3>Cancelled</h3>
                <div class="value"><%= cancelledCount != null ? cancelledCount : 0 %></div>
            </div>
        </div>
        
        <div class="filter-bar">
            <input type="text" id="searchInput" placeholder="🔍 Search by reservation number, guest ID..." onkeyup="filterTable()">
            <select id="statusFilter" onchange="filterTable()">
                <option value="">All Statuses</option>
                <option value="PENDING">Pending</option>
                <option value="CONFIRMED">Confirmed</option>
                <option value="CHECKED_IN">Checked In</option>
                <option value="CHECKED_OUT">Checked Out</option>
                <option value="CANCELLED">Cancelled</option>
            </select>
        </div>
        
        <div class="card">
            <% if (reservations != null && !reservations.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Reservation #</th>
                            <th>Guest ID</th>
                            <th>Room ID</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Total Amount</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Reservation res : reservations) { %>
                            <tr data-status="<%= res.getStatus() %>">
                                <td><%= res.getReservationId() %></td>
                                <td><strong><%= res.getReservationNumber() %></strong></td>
                                <td>#<%= res.getGuestId() %></td>
                                <td>Room <%= res.getRoomId() %></td>
                                <td><%= dateFormat.format(res.getCheckInDate()) %></td>
                                <td><%= dateFormat.format(res.getCheckOutDate()) %></td>
                                <td>LKR <%= String.format("%,.2f", res.getTotalAmount()) %></td>
                                <td>
                                    <span class="status-badge status-<%= res.getStatus().toLowerCase() %>">
                                        <%= res.getStatus() %>
                                    </span>
                                </td>
                                <td>
                                    <a href="<%= request.getContextPath() %>/admin/reservation/view?id=<%= res.getReservationId() %>" class="btn btn-primary">View</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">
                    <h3>📋 No Reservations Found</h3>
                    <p>There are currently no reservations in the system.</p>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
