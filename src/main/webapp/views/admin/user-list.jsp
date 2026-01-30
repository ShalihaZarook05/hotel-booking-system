<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
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
    List<User> users = (List<User>) request.getAttribute("users");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Ocean View Resort</title>
    
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
        
        /* Navbar Styles */
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
            display: flex;
            align-items: center;
            gap: 0.5rem;
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
        
        /* Container */
        .container {
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        /* Page Header */
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
        
        .btn-danger {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
        }
        
        .btn-small {
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
        }
        
        /* Alert Messages */
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
        
        /* Table Container */
        .table-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        /* Search Bar */
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
        
        /* Table Styles */
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
        
        /* Badge Styles */
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        .badge-admin {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .badge-staff {
            background: #fef3c7;
            color: #92400e;
        }
        
        .badge-guest {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-active {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-inactive {
            background: #fee2e2;
            color: #991b1b;
        }
        
        /* Action Buttons */
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
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6b7280;
        }
        
        .empty-state-icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        
        /* Responsive */
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
                min-width: 800px;
            }
        }
    </style>
    
    <script>
        function confirmDelete(userId, username) {
            if (confirm('Are you sure you want to delete user "' + username + '"? This action cannot be undone.')) {
                window.location.href = '<%= request.getContextPath() %>/admin/user/delete?id=' + userId;
            }
        }
        
        function searchUsers() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('userTable');
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
    </script>
</head>
<body>
    
    <!-- Navigation Bar -->
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - User Management</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/users">👥 Users</a>
            <a href="<%= request.getContextPath() %>/admin/rooms">🏠 Rooms</a>
            <a href="<%= request.getContextPath() %>/admin/roomtypes">🛏️ Room Types</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h2>👥 User Management</h2>
            <a href="<%= request.getContextPath() %>/admin/user/new" class="btn">➕ Add New User</a>
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
        
        <!-- Table Container -->
        <div class="table-container">
            <!-- Search Bar -->
            <div class="search-bar">
                <input type="text" 
                       id="searchInput" 
                       placeholder="🔍 Search users by name, email, username, role..." 
                       onkeyup="searchUsers()">
            </div>
            
            <!-- User Table -->
            <% if (users != null && !users.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Last Login</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="userTable">
                        <% for (User user : users) { %>
                            <tr>
                                <td><strong>#<%= user.getUserId() %></strong></td>
                                <td><%= user.getUsername() %></td>
                                <td><%= user.getFullName() %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getPhone() %></td>
                                <td>
                                    <% if ("ADMIN".equals(user.getRole())) { %>
                                        <span class="badge badge-admin">👑 ADMIN</span>
                                    <% } else if ("STAFF".equals(user.getRole())) { %>
                                        <span class="badge badge-staff">👔 STAFF</span>
                                    <% } else { %>
                                        <span class="badge badge-guest">👤 GUEST</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("ACTIVE".equals(user.getStatus())) { %>
                                        <span class="badge badge-active">✅ Active</span>
                                    <% } else { %>
                                        <span class="badge badge-inactive">❌ Inactive</span>
                                    <% } %>
                                </td>
                                <td><%= user.getLastLogin() != null ? user.getLastLogin() : "Never" %></td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="<%= request.getContextPath() %>/admin/user/edit?id=<%= user.getUserId() %>" 
                                           class="btn-edit">✏️ Edit</a>
                                        <a href="javascript:void(0);" 
                                           onclick="confirmDelete(<%= user.getUserId() %>, '<%= user.getUsername() %>')" 
                                           class="btn-delete">🗑️ Delete</a>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-state">
                    <div class="empty-state-icon">👥</div>
                    <h3>No Users Found</h3>
                    <p>Start by adding your first user</p>
                    <br>
                    <a href="<%= request.getContextPath() %>/admin/user/new" class="btn">➕ Add New User</a>
                </div>
            <% } %>
        </div>
    </div>
    
</body>
</html>
