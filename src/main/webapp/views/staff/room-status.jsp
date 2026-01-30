<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.Room" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is staff
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isStaff(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    
    // Calculate statistics
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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Status - Ocean View Resort</title>
    
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            text-align: center;
        }
        
        .stat-card.total {
            border-left: 4px solid #3b82f6;
        }
        
        .stat-card.available {
            border-left: 4px solid #10b981;
        }
        
        .stat-card.occupied {
            border-left: 4px solid #f59e0b;
        }
        
        .stat-card.maintenance {
            border-left: 4px solid #ef4444;
        }
        
        .stat-card h3 {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-card .value {
            font-size: 2.5rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .filter-bar {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            align-items: center;
        }
        
        .filter-bar input {
            flex: 1;
            min-width: 200px;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
        }
        
        .filter-bar input:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        .filter-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        
        .filter-btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .filter-btn:hover {
            transform: translateY(-2px);
        }
        
        .filter-btn.all {
            background: #3b82f6;
            color: white;
        }
        
        .filter-btn.available {
            background: #10b981;
            color: white;
        }
        
        .filter-btn.occupied {
            background: #f59e0b;
            color: white;
        }
        
        .filter-btn.maintenance {
            background: #ef4444;
            color: white;
        }
        
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
        }
        
        .room-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        .room-card.available {
            border-top: 4px solid #10b981;
        }
        
        .room-card.occupied {
            border-top: 4px solid #f59e0b;
        }
        
        .room-card.maintenance {
            border-top: 4px solid #ef4444;
        }
        
        .room-number {
            font-size: 2rem;
            font-weight: 700;
            color: #1e3a8a;
            text-align: center;
            padding: 1.5rem 1rem 0.5rem;
        }
        
        .room-type {
            text-align: center;
            color: #6b7280;
            font-size: 0.9rem;
            padding: 0 1rem 1rem;
        }
        
        .room-info {
            padding: 1rem;
            background: #f9fafb;
        }
        
        .info-item {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-label {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .info-value {
            color: #374151;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .status-badge {
            display: block;
            padding: 0.75rem;
            text-align: center;
            font-weight: 700;
            font-size: 0.9rem;
            margin: 1rem;
            border-radius: 8px;
        }
        
        .status-available {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-occupied {
            background: #fef3c7;
            color: #92400e;
        }
        
        .status-maintenance {
            background: #fee2e2;
            color: #991b1b;
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
        
        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            animation: fadeIn 0.3s;
        }
        
        .modal-overlay.show {
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .modal-content {
            background: white;
            border-radius: 15px;
            padding: 0;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            animation: slideUp 0.3s;
            overflow: hidden;
        }
        
        @keyframes slideUp {
            from { 
                transform: translateY(50px);
                opacity: 0;
            }
            to { 
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        .modal-header {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h3 {
            margin: 0;
            font-size: 1.3rem;
        }
        
        .modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 1.5rem;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s;
        }
        
        .modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .modal-body {
            padding: 2rem;
        }
        
        .room-info {
            background: #f9fafb;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            text-align: center;
        }
        
        .room-info h4 {
            margin: 0 0 0.5rem 0;
            color: #1e3a8a;
            font-size: 1.5rem;
        }
        
        .room-info p {
            margin: 0.25rem 0;
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .status-options {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        
        .status-option {
            padding: 1.2rem;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 1rem;
            background: white;
        }
        
        .status-option:hover {
            border-color: #3b82f6;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.2);
        }
        
        .status-option.current {
            border-color: #10b981;
            background: #d1fae5;
            cursor: not-allowed;
        }
        
        .status-option.current:hover {
            transform: none;
            box-shadow: none;
        }
        
        .status-option-icon {
            font-size: 2rem;
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }
        
        .status-option.available .status-option-icon {
            background: #d1fae5;
        }
        
        .status-option.occupied .status-option-icon {
            background: #fef3c7;
        }
        
        .status-option.maintenance .status-option-icon {
            background: #fee2e2;
        }
        
        .status-option-content {
            flex: 1;
        }
        
        .status-option-title {
            font-weight: 700;
            font-size: 1.1rem;
            margin-bottom: 0.25rem;
            color: #1e3a8a;
        }
        
        .status-option-desc {
            color: #6b7280;
            font-size: 0.9rem;
        }
        
        .current-badge {
            background: #10b981;
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        @media (max-width: 768px) {
            .filter-bar {
                flex-direction: column;
            }
            
            .filter-bar input {
                width: 100%;
            }
            
            .filter-buttons {
                width: 100%;
                justify-content: center;
            }
            
            .rooms-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            }
            
            .modal-content {
                width: 95%;
                margin: 1rem;
            }
            
            .modal-body {
                padding: 1.5rem;
            }
            
            .status-option {
                padding: 1rem;
            }
        }
    </style>
    
    <script>
        function searchRooms() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const cards = document.querySelectorAll('.room-card');
            
            cards.forEach(card => {
                const text = card.textContent.toLowerCase();
                card.style.display = text.includes(filter) ? '' : 'none';
            });
        }
        
        function filterByStatus(status) {
            const cards = document.querySelectorAll('.room-card');
            
            cards.forEach(card => {
                if (status === 'ALL') {
                    card.style.display = '';
                } else {
                    card.style.display = card.classList.contains(status.toLowerCase()) ? '' : 'none';
                }
            });
        }
        
        let currentRoomStatus = '';
        
        function showStatusModal(roomId, roomNumber, currentStatus, roomType) {
            currentRoomStatus = currentStatus;
            
            // Set modal data
            document.getElementById('modalRoomId').value = roomId;
            document.getElementById('modalRoomNumber').textContent = roomNumber;
            document.getElementById('modalRoomType').textContent = roomType;
            document.getElementById('modalCurrentStatus').textContent = currentStatus;
            
            // Reset all badges and current class
            document.querySelectorAll('.status-option').forEach(option => {
                option.classList.remove('current');
            });
            document.querySelectorAll('.current-badge').forEach(badge => {
                badge.style.display = 'none';
            });
            
            // Mark current status
            const currentStatusLower = currentStatus.toLowerCase();
            const currentOption = document.querySelector('.status-option.' + currentStatusLower);
            if (currentOption) {
                currentOption.classList.add('current');
                document.getElementById('badge-' + currentStatusLower).style.display = 'inline-block';
            }
            
            // Show modal
            document.getElementById('statusModal').classList.add('show');
        }
        
        function closeModal() {
            document.getElementById('statusModal').classList.remove('show');
        }
        
        function selectStatus(newStatus) {
            // Don't allow selecting current status
            if (newStatus === currentRoomStatus) {
                return;
            }
            
            if (confirm('Are you sure you want to change the room status to ' + newStatus + '?')) {
                document.getElementById('modalNewStatus').value = newStatus;
                document.getElementById('statusUpdateForm').submit();
            }
        }
        
        // Close modal on outside click
        window.addEventListener('DOMContentLoaded', function() {
            document.getElementById('statusModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeModal();
                }
            });
            
            // Close modal on ESC key
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeModal();
                }
            });
        });
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Room Status</h1>
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
            <h2>🏠 Room Status Overview</h2>
            <p>Monitor and manage all room statuses in real-time</p>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <div class="stats-grid">
            <div class="stat-card total">
                <h3>Total Rooms</h3>
                <div class="value"><%= totalRooms %></div>
            </div>
            <div class="stat-card available">
                <h3>✅ Available</h3>
                <div class="value"><%= availableRooms %></div>
            </div>
            <div class="stat-card occupied">
                <h3>🔒 Occupied</h3>
                <div class="value"><%= occupiedRooms %></div>
            </div>
            <div class="stat-card maintenance">
                <h3>🔧 Maintenance</h3>
                <div class="value"><%= maintenanceRooms %></div>
            </div>
        </div>
        
        <div class="filter-bar">
            <input type="text" 
                   id="searchInput" 
                   placeholder="🔍 Search by room number, floor, type..." 
                   onkeyup="searchRooms()">
            
            <div class="filter-buttons">
                <button class="filter-btn all" onclick="filterByStatus('ALL')">All Rooms</button>
                <button class="filter-btn available" onclick="filterByStatus('AVAILABLE')">Available</button>
                <button class="filter-btn occupied" onclick="filterByStatus('OCCUPIED')">Occupied</button>
                <button class="filter-btn maintenance" onclick="filterByStatus('MAINTENANCE')">Maintenance</button>
            </div>
        </div>
        
        <div style="background: white; padding: 1rem; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05); margin-bottom: 2rem;">
            <p style="color: #6b7280; margin: 0;">💡 <strong>Tip:</strong> Click on any room card to update its status (Available, Occupied, Maintenance)</p>
        </div>
        
        <% if (rooms != null && !rooms.isEmpty()) { %>
            <div class="rooms-grid">
                <% for (Room room : rooms) { 
                    String statusClass = room.getStatus().toLowerCase();
                %>
                    <div class="room-card <%= statusClass %>">
                        <div class="room-number">
                            <%= "AVAILABLE".equals(room.getStatus()) ? "✅" : 
                                "OCCUPIED".equals(room.getStatus()) ? "🔒" : "🔧" %>
                            <%= room.getRoomNumber() %>
                        </div>
                        <div class="room-type">
                            <% if (room.getRoomType() != null) { %>
                                <%= room.getRoomType().getTypeName() %>
                            <% } else { %>
                                Room Type ID: <%= room.getRoomTypeId() %>
                            <% } %>
                        </div>
                        
                        <div class="room-info">
                            <div class="info-item">
                                <span class="info-label">Room ID</span>
                                <span class="info-value">#<%= room.getRoomId() %></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Floor</span>
                                <span class="info-value">Floor <%= room.getFloorNumber() %></span>
                            </div>
                            <% if (room.getRoomType() != null) { %>
                                <div class="info-item">
                                    <span class="info-label">Capacity</span>
                                    <span class="info-value">👥 <%= room.getRoomType().getCapacity() %></span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Price/Night</span>
                                    <span class="info-value">LKR <%= String.format("%,.2f", room.getRoomType().getPricePerNight()) %></span>
                                </div>
                            <% } %>
                        </div>
                        
                        <% if ("AVAILABLE".equals(room.getStatus())) { %>
                            <div class="status-badge status-available">✅ Available for Booking</div>
                        <% } else if ("OCCUPIED".equals(room.getStatus())) { %>
                            <div class="status-badge status-occupied">🔒 Currently Occupied</div>
                        <% } else if ("MAINTENANCE".equals(room.getStatus())) { %>
                            <div class="status-badge status-maintenance">🔧 Under Maintenance</div>
                        <% } %>
                        
                        <div style="padding: 0 1rem 1rem 1rem;">
                            <button onclick="showStatusModal(<%= room.getRoomId() %>, '<%= room.getRoomNumber() %>', '<%= room.getStatus() %>', '<%= room.getRoomType() != null ? room.getRoomType().getTypeName() : "Unknown" %>')" 
                                    style="width: 100%; padding: 0.5rem; background: #3b82f6; color: white; border: none; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: background 0.3s;">
                                🔄 Update Status
                            </button>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon">🏠</div>
                <h3>No Rooms Found</h3>
                <p>There are no rooms in the system</p>
            </div>
        <% } %>
    </div>
    
    <!-- Status Update Modal -->
    <div id="statusModal" class="modal-overlay">
        <div class="modal-content">
            <div class="modal-header">
                <h3>🔄 Update Room Status</h3>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="room-info">
                    <h4>Room <span id="modalRoomNumber"></span></h4>
                    <p id="modalRoomType"></p>
                    <p>Current Status: <strong id="modalCurrentStatus"></strong></p>
                </div>
                
                <form id="statusUpdateForm" method="POST" action="<%= request.getContextPath() %>/staff/rooms/updateStatus">
                    <input type="hidden" id="modalRoomId" name="roomId">
                    <input type="hidden" id="modalNewStatus" name="status">
                    
                    <div class="status-options">
                        <div class="status-option available" onclick="selectStatus('AVAILABLE')">
                            <div class="status-option-icon">✅</div>
                            <div class="status-option-content">
                                <div class="status-option-title">Available</div>
                                <div class="status-option-desc">Room is ready for new bookings</div>
                            </div>
                            <span class="current-badge" id="badge-available" style="display: none;">Current</span>
                        </div>
                        
                        <div class="status-option occupied" onclick="selectStatus('OCCUPIED')">
                            <div class="status-option-icon">🔒</div>
                            <div class="status-option-content">
                                <div class="status-option-title">Occupied</div>
                                <div class="status-option-desc">Room is currently in use by a guest</div>
                            </div>
                            <span class="current-badge" id="badge-occupied" style="display: none;">Current</span>
                        </div>
                        
                        <div class="status-option maintenance" onclick="selectStatus('MAINTENANCE')">
                            <div class="status-option-icon">🔧</div>
                            <div class="status-option-content">
                                <div class="status-option-title">Maintenance</div>
                                <div class="status-option-desc">Room needs repairs or cleaning</div>
                            </div>
                            <span class="current-badge" id="badge-maintenance" style="display: none;">Current</span>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
