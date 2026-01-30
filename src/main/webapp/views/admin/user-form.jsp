<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%
    // Check if user is logged in and is admin
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isAdmin(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User currentUser = SessionManager.getLoggedInUser(request);
    User user = (User) request.getAttribute("user");
    boolean isEdit = (user != null);
    String pageTitle = isEdit ? "Edit User" : "Add New User";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - Ocean View Resort</title>
    
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
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        /* Form Card */
        .form-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .form-header {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .form-header h2 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }
        
        .form-header p {
            opacity: 0.9;
        }
        
        .form-body {
            padding: 2rem;
        }
        
        /* Form Styles */
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-weight: 600;
        }
        
        .required {
            color: #dc2626;
        }
        
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="password"],
        select,
        textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        input:focus,
        select:focus,
        textarea:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        /* Help Text */
        .help-text {
            font-size: 0.85rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }
        
        /* Button Styles */
        .form-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            padding-top: 1rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }
        
        /* Alert Messages */
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
        }
        
        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border: 1px solid #93c5fd;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
    
    <script>
        function validateForm() {
            const username = document.getElementById('username').value.trim();
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const password = document.getElementById('password').value;
            const role = document.getElementById('role').value;
            const isEdit = <%= isEdit %>;
            
            // Username validation
            if (username === '') {
                alert('❌ Username is required!');
                document.getElementById('username').focus();
                return false;
            }
            
            if (username.length < 3 || username.length > 20) {
                alert('❌ Username must be 3-20 characters!');
                document.getElementById('username').focus();
                return false;
            }
            
            if (!/^[A-Za-z0-9_]+$/.test(username)) {
                alert('❌ Username can only contain letters, numbers, and underscores!');
                document.getElementById('username').focus();
                return false;
            }
            
            // Full name validation
            if (fullName === '') {
                alert('❌ Full name is required!');
                document.getElementById('fullName').focus();
                return false;
            }
            
            if (fullName.length < 3) {
                alert('❌ Full name must be at least 3 characters!');
                document.getElementById('fullName').focus();
                return false;
            }
            
            // Email validation
            if (email === '') {
                alert('❌ Email is required!');
                document.getElementById('email').focus();
                return false;
            }
            
            const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
            if (!emailRegex.test(email)) {
                alert('❌ Please enter a valid email address!');
                document.getElementById('email').focus();
                return false;
            }
            
            // Phone validation
            if (phone === '') {
                alert('❌ Phone number is required!');
                document.getElementById('phone').focus();
                return false;
            }
            
            const cleanPhone = phone.replace(/[\s\-()]/g, '');
            if (!/^[0-9]{10,15}$/.test(cleanPhone)) {
                alert('❌ Phone number must be 10-15 digits!');
                document.getElementById('phone').focus();
                return false;
            }
            
            // Password validation (only for new users or if password is provided for edit)
            if (!isEdit && password === '') {
                alert('❌ Password is required for new users!');
                document.getElementById('password').focus();
                return false;
            }
            
            if (password !== '' && password.length < 6) {
                alert('❌ Password must be at least 6 characters!');
                document.getElementById('password').focus();
                return false;
            }
            
            // Role validation
            if (role === '') {
                alert('❌ Please select a role!');
                document.getElementById('role').focus();
                return false;
            }
            
            return true;
        }
    </script>
</head>
<body>
    
    <!-- Navigation Bar -->
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - <%= pageTitle %></h1>
        <a href="<%= request.getContextPath() %>/admin/users">← Back to Users</a>
    </div>
    
    <div class="container">
        <!-- Form Card -->
        <div class="form-card">
            <div class="form-header">
                <h2><%= isEdit ? "✏️ Edit User" : "➕ Add New User" %></h2>
                <p><%= isEdit ? "Update user information" : "Fill in the details to create a new user" %></p>
            </div>
            
            <div class="form-body">
                <% if (isEdit) { %>
                    <div class="alert alert-info">
                        💡 Leave password field empty to keep the current password
                    </div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/admin/user/<%= isEdit ? "update" : "create" %>" 
                      method="post" 
                      onsubmit="return validateForm()">
                    
                    <% if (isEdit) { %>
                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                    <% } %>
                    
                    <!-- Username and Full Name -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="username">Username <span class="required">*</span></label>
                            <input type="text" 
                                   id="username" 
                                   name="username" 
                                   value="<%= isEdit ? user.getUsername() : "" %>"
                                   placeholder="Enter username"
                                   required
                                   minlength="3"
                                   maxlength="20"
                                   pattern="[A-Za-z0-9_]+">
                            <div class="help-text">3-20 characters, letters, numbers, underscore only</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="fullName">Full Name <span class="required">*</span></label>
                            <input type="text" 
                                   id="fullName" 
                                   name="fullName" 
                                   value="<%= isEdit ? user.getFullName() : "" %>"
                                   placeholder="Enter full name"
                                   required
                                   minlength="3"
                                   maxlength="100">
                            <div class="help-text">User's full name</div>
                        </div>
                    </div>
                    
                    <!-- Email and Phone -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email <span class="required">*</span></label>
                            <input type="email" 
                                   id="email" 
                                   name="email" 
                                   value="<%= isEdit ? user.getEmail() : "" %>"
                                   placeholder="user@example.com"
                                   required>
                            <div class="help-text">Valid email address</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="phone">Phone <span class="required">*</span></label>
                            <input type="tel" 
                                   id="phone" 
                                   name="phone" 
                                   value="<%= isEdit ? user.getPhone() : "" %>"
                                   placeholder="0771234567"
                                   required>
                            <div class="help-text">10-15 digits</div>
                        </div>
                    </div>
                    
                    <!-- Address -->
                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea id="address" 
                                  name="address" 
                                  placeholder="Enter address (optional)"
                                  maxlength="500"><%= isEdit ? (user.getAddress() != null ? user.getAddress() : "") : "" %></textarea>
                        <div class="help-text">Optional, max 500 characters</div>
                    </div>
                    
                    <!-- Password -->
                    <div class="form-group">
                        <label for="password">Password <span class="required"><%= isEdit ? "" : "*" %></span></label>
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="<%= isEdit ? "Leave empty to keep current password" : "Enter password (min 6 characters)" %>"
                               <%= isEdit ? "" : "required" %>
                               minlength="6">
                        <div class="help-text">
                            <%= isEdit ? "Leave empty to keep current password, or enter new password (min 6 characters)" : "Minimum 6 characters" %>
                        </div>
                    </div>
                    
                    <!-- Role and Status -->
                    <div class="form-row">
                        <div class="form-group">
                            <label for="role">Role <span class="required">*</span></label>
                            <select id="role" name="role" required>
                                <option value="">Select role</option>
                                <option value="ADMIN" <%= isEdit && "ADMIN".equals(user.getRole()) ? "selected" : "" %>>👑 Admin</option>
                                <option value="STAFF" <%= isEdit && "STAFF".equals(user.getRole()) ? "selected" : "" %>>👔 Staff</option>
                                <option value="GUEST" <%= isEdit && "GUEST".equals(user.getRole()) ? "selected" : "" %>>👤 Guest</option>
                            </select>
                            <div class="help-text">User's access level</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <select id="status" name="status" required>
                                <option value="ACTIVE" <%= isEdit && "ACTIVE".equals(user.getStatus()) ? "selected" : "selected" %>>✅ Active</option>
                                <option value="INACTIVE" <%= isEdit && "INACTIVE".equals(user.getStatus()) ? "selected" : "" %>>❌ Inactive</option>
                            </select>
                            <div class="help-text">Account status</div>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-secondary">
                            ← Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <%= isEdit ? "💾 Update User" : "➕ Create User" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
