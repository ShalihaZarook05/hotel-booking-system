<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is admin
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Management - Ocean View Resort</title>
    
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
        
        .btn:hover {
            transform: translateY(-2px);
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
        }
        
        .stat-box h3 {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-box .value {
            font-size: 2rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .stat-box.available {
            border-left: 4px solid #10b981;
        }
        
        .stat-box.occupied {
            border-left: 4px solid #f59e0b;
        }
        
        .stat-box.maintenance {
            border-left: 4px solid #ef4444;
        }
        
        .table-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .search-bar {
            padding: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .search-bar input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
        }
        
        .search-bar input:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: #f9fafb;
        }
        
        thead th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: #374151;
            border-bottom: 2px solid #e5e7eb;
        }
        
        tbody tr {
            border-bottom: 1px solid #e5e7eb;
            transition: background 0.2s;
        }
        
        tbody tr:hover {
            background: #f9fafb;
        }
        
        tbody td {
            padding: 1rem;
            color: #6b7280;
        }
        
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .badge-available {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-occupied {
            background: #fef3c7;
            color: #92400e;
        }
        
        .badge-maintenance {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        .action-buttons a {
            padding: 0.5rem 1rem;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            transition: transform 0.2s;
        }
        
        .btn-edit {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .btn-delete {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .action-buttons a:hover {
            transform: translateY(-1px);
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6b7280;
        }
        
        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .table-container {
                overflow-x: auto;
            }
            
            table {
                min-width: 900px;
            }
        }
    </style>
    
    <script>
        function confirmDelete(roomId, roomNumber) {
            if (confirm('Are you sure you want to delete room "' + roomNumber + '"? This action cannot be undone.')) {
                window.location.href = '<%= request.getContextPath() %>/admin/room/delete?id=' + roomId;
            }
        }
        
        function searchRooms() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('roomTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 0; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName('td');
                let found = false;
                
                for (let j = 0; j < cells.length; j++) {
                    const cell = cells[j];
                    if (cell) {
                        const text = cell.textContent || cell.innerText;
                        if (text.toLowerCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                rows[i].style.display = found ? '' : 'none';
            }
        }
        
        function filterByStatus(status) {
            const table = document.getElementById('roomTable');
            const rows = table.getElementsByTagName('tr');
            
            for (let i = 0; i < rows.length; i++) {
                if (status === 'ALL') {
                    rows[i].style.display = '';
                } else {
                    const statusCell = rows[i].cells[4];
                    if (statusCell) {
                        const cellText = statusCell.textContent || statusCell.innerText;
                        rows[i].style.display = cellText.toUpperCase().includes(status) ? '' : 'none';
                    }
                }
            }
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Room Management</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/users">👥 Users</a>
            <a href="<%= request.getContextPath() %>/admin/rooms">🏠 Rooms</a>
            <a href="<%= request.getContextPath() %>/admin/roomtypes">🛏️ Room Types</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="page-header">
            <h2>🏠 Room Management</h2>
            <a href="<%= request.getContextPath() %>/admin/room/new" class="btn">➕ Add New Room</a>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <%
            long totalRooms = 0;
            long availableRooms = 0;
            long occupiedRooms = 0;
            long maintenanceRooms = 0;
            
            if (rooms != null) {
                totalRooms = rooms.size();
                for (Room r : rooms) {
                    if ("AVAILABLE".equals(r.getStatus())) availableRooms++;
                    else if ("OCCUPIED".equals(r.getStatus())) occupiedRooms++;
                    else if ("MAINTENANCE".equals(r.getStatus())) maintenanceRooms++;
                }
            }
        %>
        
        <div class="stats-bar">
            <div class="stat-box">
                <h3>Total Rooms</h3>
                <div class="value"><%= totalRooms %></div>
            </div>
            <div class="stat-box available">
                <h3>✅ Available</h3>
                <div class="value"><%= availableRooms %></div>
            </div>
            <div class="stat-box occupied">
                <h3>🔒 Occupied</h3>
                <div class="value"><%= occupiedRooms %></div>
            </div>
            <div class="stat-box maintenance">
                <h3>🔧 Maintenance</h3>
                <div class="value"><%= maintenanceRooms %></div>
            </div>
        </div>
        
        <div class="table-container">
            <div class="search-bar">
                <input type="text" 
                       id="searchInput" 
                       placeholder="🔍 Search rooms by number, floor, type, status..." 
                       onkeyup="searchRooms()">
                <div style="margin-top: 1rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
                    <button onclick="filterByStatus('ALL')" class="btn" style="padding: 0.5rem 1rem; font-size: 0.9rem;">All</button>
                    <button onclick="filterByStatus('AVAILABLE')" class="btn" style="padding: 0.5rem 1rem; font-size: 0.9rem; background: #10b981;">Available</button>
                    <button onclick="filterByStatus('OCCUPIED')" class="btn" style="padding: 0.5rem 1rem; font-size: 0.9rem; background: #f59e0b;">Occupied</button>
                    <button onclick="filterByStatus('MAINTENANCE')" class="btn" style="padding: 0.5rem 1rem; font-size: 0.9rem; background: #ef4444;">Maintenance</button>
                </div>
            </div>
            
            <% if (rooms != null && !rooms.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Room Number</th>
                            <th>Room Type</th>
                            <th>Floor</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="roomTable">
                        <% for (Room room : rooms) { %>
                            <tr>
                                <td><strong>#<%= room.getRoomId() %></strong></td>
                                <td><strong><%= room.getRoomNumber() %></strong></td>
                                <td>
                                    <% if (room.getRoomType() != null) { %>
                                        <%= room.getRoomType().getTypeName() %>
                                    <% } else { %>
                                        Room Type ID: <%= room.getRoomTypeId() %>
                                    <% } %>
                                </td>
                                <td>Floor <%= room.getFloorNumber() %></td>
                                <td>
                                    <% if ("AVAILABLE".equals(room.getStatus())) { %>
                                        <span class="badge badge-available">✅ Available</span>
                                    <% } else if ("OCCUPIED".equals(room.getStatus())) { %>
                                        <span class="badge badge-occupied">🔒 Occupied</span>
                                    <% } else if ("MAINTENANCE".equals(room.getStatus())) { %>
                                        <span class="badge badge-maintenance">🔧 Maintenance</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="<%= request.getContextPath() %>/admin/room/edit?id=<%= room.getRoomId() %>" 
                                           class="btn-edit">✏️ Edit</a>
                                        <a href="javascript:void(0);" 
                                           onclick="confirmDelete(<%= room.getRoomId() %>, '<%= room.getRoomNumber() %>')" 
                                           class="btn-delete">🗑️ Delete</a>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-state">
                    <div class="empty-state-icon">🏠</div>
                    <h3>No Rooms Found</h3>
                    <p>Start by adding your first room</p>
                    <br>
                    <a href="<%= request.getContextPath() %>/admin/room/new" class="btn">➕ Add New Room</a>
                </div>
            <% } %>
        </div>
    </div>
    
</body>
</html>
