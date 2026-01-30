<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%@ page import="com.oceanview.model.RoomType" %>
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
    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Type Management - Ocean View Resort</title>
    
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
        
        .room-types-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
        }
        
        .room-type-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .room-type-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        
        .room-type-header {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 1.5rem;
        }
        
        .room-type-header h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        
        .price-tag {
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .price-tag small {
            font-size: 1rem;
            opacity: 0.9;
        }
        
        .room-type-body {
            padding: 1.5rem;
        }
        
        .room-type-description {
            color: #6b7280;
            margin-bottom: 1rem;
            line-height: 1.6;
        }
        
        .room-type-info {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .info-item {
            flex: 1;
            padding: 0.75rem;
            background: #f3f4f6;
            border-radius: 8px;
            text-align: center;
        }
        
        .info-item .label {
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 0.25rem;
        }
        
        .info-item .value {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1e3a8a;
        }
        
        .amenities-section {
            margin-bottom: 1rem;
        }
        
        .amenities-section h4 {
            color: #374151;
            margin-bottom: 0.5rem;
            font-size: 1rem;
        }
        
        .amenities-list {
            color: #6b7280;
            font-size: 0.9rem;
            line-height: 1.6;
        }
        
        .card-actions {
            display: flex;
            gap: 0.5rem;
            padding-top: 1rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .card-actions a {
            flex: 1;
            padding: 0.75rem;
            border-radius: 8px;
            text-decoration: none;
            text-align: center;
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
        
        .card-actions a:hover {
            transform: translateY(-2px);
        }
        
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6b7280;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
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
            
            .room-types-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
    
    <script>
        function confirmDelete(roomTypeId, typeName) {
            if (confirm('Are you sure you want to delete room type "' + typeName + '"?\n\nWarning: This will affect all rooms of this type!')) {
                window.location.href = '<%= request.getContextPath() %>/admin/roomtype/delete?id=' + roomTypeId;
            }
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - Room Type Management</h1>
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
            <h2>🛏️ Room Type Management</h2>
            <a href="<%= request.getContextPath() %>/admin/roomtype/new" class="btn">➕ Add New Room Type</a>
        </div>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">❌ <%= errorMessage %></div>
        <% } %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success">✅ <%= successMessage %></div>
        <% } %>
        
        <% if (roomTypes != null && !roomTypes.isEmpty()) { %>
            <div class="room-types-grid">
                <% for (RoomType roomType : roomTypes) { %>
                    <div class="room-type-card">
                        <div class="room-type-header">
                            <h3><%= roomType.getTypeName() %></h3>
                            <div class="price-tag">
                                LKR <%= String.format("%,.2f", roomType.getPricePerNight()) %>
                                <small>/night</small>
                            </div>
                        </div>
                        
                        <div class="room-type-body">
                            <div class="room-type-description">
                                <%= roomType.getDescription() != null ? roomType.getDescription() : "No description available" %>
                            </div>
                            
                            <div class="room-type-info">
                                <div class="info-item">
                                    <div class="label">ID</div>
                                    <div class="value">#<%= roomType.getRoomTypeId() %></div>
                                </div>
                                <div class="info-item">
                                    <div class="label">Capacity</div>
                                    <div class="value">👥 <%= roomType.getCapacity() %></div>
                                </div>
                            </div>
                            
                            <div class="amenities-section">
                                <h4>✨ Amenities</h4>
                                <div class="amenities-list">
                                    <%= roomType.getAmenities() != null ? roomType.getAmenities() : "Standard amenities" %>
                                </div>
                            </div>
                            
                            <div class="card-actions">
                                <a href="<%= request.getContextPath() %>/admin/roomtype/edit?id=<%= roomType.getRoomTypeId() %>" 
                                   class="btn-edit">
                                    ✏️ Edit
                                </a>
                                <a href="javascript:void(0);" 
                                   onclick="confirmDelete(<%= roomType.getRoomTypeId() %>, '<%= roomType.getTypeName() %>')" 
                                   class="btn-delete">
                                    🗑️ Delete
                                </a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="empty-state-icon">🛏️</div>
                <h3>No Room Types Found</h3>
                <p>Start by adding your first room type</p>
                <br>
                <a href="<%= request.getContextPath() %>/admin/roomtype/new" class="btn">➕ Add New Room Type</a>
            </div>
        <% } %>
    </div>
    
</body>
</html>
