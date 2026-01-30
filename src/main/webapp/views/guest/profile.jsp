<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%@ page import="com.oceanview.model.User" %>
<%
    if (!SessionManager.isLoggedIn(request) || !SessionManager.isGuest(request)) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    
    User user = (User) request.getAttribute("user");
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Ocean View Resort</title>
    
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
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .profile-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .profile-avatar {
            width: 100px;
            height: 100px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            margin: 0 auto 1rem;
        }
        
        .profile-header h2 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }
        
        .profile-body { padding: 2rem; }
        
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
        
        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border: 1px solid #93c5fd;
        }
        
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
        
        .form-group { margin-bottom: 1.5rem; }
        
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
        
        .required { color: #dc2626; }
        
        input, textarea {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
            font-family: inherit;
        }
        
        input:focus, textarea:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .help-text {
            font-size: 0.85rem;
            color: #6b7280;
            margin-top: 0.25rem;
        }
        
        .form-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            padding-top: 1rem;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s;
        }
        
        .btn:hover { transform: translateY(-2px); }
        
        .btn-primary {
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }
        
        @media (max-width: 768px) {
            .form-row { grid-template-columns: 1fr; }
            .form-actions { flex-direction: column; }
            .btn { width: 100%; }
        }
    </style>
    
    <script>
        function validateForm() {
            const fullName = document.getElementById('fullName').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const newPassword = document.getElementById('newPassword').value;
            const currentPassword = document.getElementById('currentPassword').value;
            
            if (!fullName || fullName.length < 3) {
                alert('❌ Full name must be at least 3 characters!');
                return false;
            }
            
            if (!email || !email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
                alert('❌ Please enter a valid email address!');
                return false;
            }
            
            if (!phone || !phone.match(/^[0-9\s\-()]{10,15}$/)) {
                alert('❌ Please enter a valid phone number (10-15 digits)!');
                return false;
            }
            
            if (newPassword && newPassword.length > 0) {
                if (!currentPassword) {
                    alert('❌ Current password is required to change password!');
                    return false;
                }
                if (newPassword.length < 6) {
                    alert('❌ New password must be at least 6 characters!');
                    return false;
                }
            }
            
            return true;
        }
    </script>
</head>
<body>
    
    <div class="navbar">
        <h1>🏖️ Ocean View Resort - My Profile</h1>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/guest/dashboard">📊 Dashboard</a>
            <a href="<%= request.getContextPath() %>/guest/reservations">📋 My Reservations</a>
            <a href="<%= request.getContextPath() %>/guest/profile">👤 Profile</a>
            <a href="<%= request.getContextPath() %>/logout">🚪 Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar">👤</div>
                <h2><%= user.getFullName() %></h2>
                <p>@<%= user.getUsername() %></p>
            </div>
            
            <div class="profile-body">
                <% if (errorMessage != null) { %>
                    <div class="alert alert-error">❌ <%= errorMessage %></div>
                <% } %>
                
                <% if (successMessage != null) { %>
                    <div class="alert alert-success">✅ <%= successMessage %></div>
                <% } %>
                
                <form action="<%= request.getContextPath() %>/guest/updateProfile" 
                      method="post" 
                      onsubmit="return validateForm()">
                    
                    <!-- Personal Information -->
                    <div class="section">
                        <h3 class="section-title">👤 Personal Information</h3>
                        
                        <div class="form-group">
                            <label for="fullName">Full Name <span class="required">*</span></label>
                            <input type="text" 
                                   id="fullName" 
                                   name="fullName" 
                                   value="<%= user.getFullName() %>"
                                   required
                                   minlength="3"
                                   maxlength="100">
                            <div class="help-text">Your full name as it appears on documents</div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                <label for="email">Email <span class="required">*</span></label>
                                <input type="email" 
                                       id="email" 
                                       name="email" 
                                       value="<%= user.getEmail() %>"
                                       required>
                                <div class="help-text">We'll send booking confirmations here</div>
                            </div>
                            
                            <div class="form-group">
                                <label for="phone">Phone <span class="required">*</span></label>
                                <input type="tel" 
                                       id="phone" 
                                       name="phone" 
                                       value="<%= user.getPhone() %>"
                                       required>
                                <div class="help-text">10-15 digits</div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="address">Address</label>
                            <textarea id="address" 
                                      name="address" 
                                      maxlength="500"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                            <div class="help-text">Optional: Your mailing address</div>
                        </div>
                    </div>
                    
                    <!-- Change Password -->
                    <div class="section">
                        <h3 class="section-title">🔒 Change Password</h3>
                        
                        <div class="alert alert-info">
                            💡 Leave password fields empty to keep your current password
                        </div>
                        
                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" 
                                   id="currentPassword" 
                                   name="currentPassword" 
                                   placeholder="Enter current password"
                                   minlength="6">
                            <div class="help-text">Required to change password</div>
                        </div>
                        
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" 
                                   id="newPassword" 
                                   name="newPassword" 
                                   placeholder="Enter new password (min 6 characters)"
                                   minlength="6">
                            <div class="help-text">Minimum 6 characters</div>
                        </div>
                    </div>
                    
                    <!-- Form Actions -->
                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/guest/dashboard" class="btn btn-secondary">
                            Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            💾 Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
</body>
</html>
