<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%
    // Redirect if already logged in
    if (SessionManager.isLoggedIn(request)) {
        String role = SessionManager.getUserRole(request);
        if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if ("STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/guest/dashboard");
        }
        return;
    }
    
    String errorMessage = SessionManager.getErrorMessage(request);
    String successMessage = SessionManager.getSuccessMessage(request);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .login-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            width: 100%;
            max-width: 900px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 550px;
        }
        
        .login-left {
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.9), rgba(13, 148, 136, 0.9)),
                        url('https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800') center/cover;
            padding: 3rem;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .login-left h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        
        .login-left p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .feature-list {
            list-style: none;
        }
        
        .feature-list li {
            padding: 0.5rem 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .feature-list li:before {
            content: "✓";
            background: #f59e0b;
            width: 25px;
            height: 25px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }
        
        .login-right {
            padding: 3rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .logo h2 {
            color: #1e3a8a;
            font-size: 1.8rem;
        }
        
        .logo span {
            color: #f59e0b;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #374151;
            font-weight: 500;
        }
        
        .form-group input {
            width: 100%;
            padding: 0.8rem;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #1e3a8a;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            font-weight: 500;
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
        
        .btn-login {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, #1e3a8a, #0d9488);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(30, 58, 138, 0.3);
        }
        
        .form-footer {
            text-align: center;
            margin-top: 1.5rem;
            color: #6b7280;
        }
        
        .form-footer a {
            color: #1e3a8a;
            text-decoration: none;
            font-weight: 600;
        }
        
        .form-footer a:hover {
            color: #0d9488;
        }
        
        @media (max-width: 768px) {
            .login-container {
                grid-template-columns: 1fr;
            }
            
            .login-left {
                display: none;
            }
        }
    </style>
</head>
<body>
    
    <div class="login-container">
        <!-- LEFT SIDE -->
        <div class="login-left">
            <h1>🏖️ Ocean View Resort</h1>
            <p>Your gateway to paradise awaits</p>
            <ul class="feature-list">
                <li>Easy online booking</li>
                <li>Secure payment processing</li>
                <li>24/7 customer support</li>
                <li>Best price guarantee</li>
                <li>Flexible cancellation</li>
            </ul>
        </div>
        
        <!-- RIGHT SIDE - LOGIN FORM -->
        <div class="login-right">
            <div class="logo">
                <h2>Welcome <span>Back</span></h2>
                <p style="color: #6b7280;">Login to manage your bookings</p>
            </div>
            
            <!-- Error/Success Messages -->
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
            
            <!-- Login Form -->
            <form action="<%= request.getContextPath() %>/login" method="post" onsubmit="return validateLogin()" novalidate>
                <div class="form-group">
                    <label for="username">Username or Email</label>
                    <input type="text" 
                           id="username" 
                           name="username" 
                           placeholder="Enter your username or email" 
                           required
                           minlength="3"
                           title="Enter your username or email address"
                           autocomplete="username">
                    <small style="color: #6b7280; font-size: 0.85rem; margin-top: 0.25rem; display: block;">
                        💡 You can login with either your username or email address
                    </small>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           placeholder="Enter your password" 
                           required
                           minlength="6"
                           title="Password must be at least 6 characters"
                           autocomplete="current-password">
                </div>
                
                <button type="submit" class="btn-login">Login</button>
            </form>
            
            <div class="form-footer">
                <p>Don't have an account? <a href="<%= request.getContextPath() %>/register">Register Here</a></p>
                <p style="margin-top: 1rem;"><a href="<%= request.getContextPath() %>/views/landing.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    
    <script>
        function validateLogin() {
            const usernameOrEmail = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value.trim();
            
            // Clear any previous custom validation
            document.getElementById('username').setCustomValidity('');
            document.getElementById('password').setCustomValidity('');
            
            // Validate username or email
            if (usernameOrEmail === '') {
                alert('❌ Please enter your username or email');
                document.getElementById('username').focus();
                return false;
            }
            
            if (usernameOrEmail.length < 3) {
                alert('❌ Username or Email must be at least 3 characters');
                document.getElementById('username').focus();
                return false;
            }
            
            // Validate password
            if (password === '') {
                alert('❌ Please enter your password');
                document.getElementById('password').focus();
                return false;
            }
            
            if (password.length < 6) {
                alert('❌ Password must be at least 6 characters');
                document.getElementById('password').focus();
                return false;
            }
            
            return true;
        }
        
        // Add real-time validation feedback
        document.addEventListener('DOMContentLoaded', function() {
            const usernameInput = document.getElementById('username');
            const passwordInput = document.getElementById('password');
            
            usernameInput.addEventListener('input', function() {
                const value = this.value.trim();
                if (value.length > 0 && value.length < 3) {
                    this.setCustomValidity('Username or Email must be at least 3 characters');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            passwordInput.addEventListener('input', function() {
                const value = this.value;
                if (value.length > 0 && value.length < 6) {
                    this.setCustomValidity('Password must be at least 6 characters');
                } else {
                    this.setCustomValidity('');
                }
            });
        });
    </script>
    
</body>
</html>
