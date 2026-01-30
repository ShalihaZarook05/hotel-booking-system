<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.SessionManager" %>
<%
    // Redirect if already logged in
    if (SessionManager.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/guest/dashboard");
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
    <title>Register - Ocean View Resort</title>
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0d9488 0%, #1e3a8a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .register-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            width: 100%;
            max-width: 1000px;
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            min-height: 650px;
        }
        
        .register-left {
            background: linear-gradient(135deg, rgba(30, 58, 138, 0.95), rgba(13, 148, 136, 0.95)),
                        url('https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800') center/cover;
            padding: 3rem;
            color: #fff;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .register-left h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }
        
        .register-left p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .benefits-list {
            list-style: none;
        }
        
        .benefits-list li {
            padding: 0.8rem 0;
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 1rem;
        }
        
        .benefits-list li:before {
            content: "🎁";
            font-size: 1.5rem;
        }
        
        .register-right {
            padding: 2.5rem;
            overflow-y: auto;
            max-height: 650px;
        }
        
        .logo {
            text-align: center;
            margin-bottom: 1.5rem;
        }
        
        .logo h2 {
            color: #1e3a8a;
            font-size: 1.8rem;
        }
        
        .logo span {
            color: #f59e0b;
        }
        
        .form-group {
            margin-bottom: 1.2rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.4rem;
            color: #374151;
            font-weight: 500;
            font-size: 0.95rem;
        }
        
        .form-group input {
            width: 100%;
            padding: 0.7rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #1e3a8a;
        }
        
        .form-group textarea {
            width: 100%;
            padding: 0.7rem;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 0.95rem;
            resize: vertical;
            min-height: 80px;
            font-family: inherit;
        }
        
        .form-group textarea:focus {
            outline: none;
            border-color: #1e3a8a;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        .alert {
            padding: 0.8rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-weight: 500;
            font-size: 0.9rem;
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
        
        .password-strength {
            height: 5px;
            background: #e5e7eb;
            border-radius: 5px;
            margin-top: 5px;
            overflow: hidden;
        }
        
        .password-strength-bar {
            height: 100%;
            width: 0%;
            transition: width 0.3s, background 0.3s;
        }
        
        .password-strength-weak {
            background: #ef4444;
            width: 33%;
        }
        
        .password-strength-medium {
            background: #f59e0b;
            width: 66%;
        }
        
        .password-strength-strong {
            background: #10b981;
            width: 100%;
        }
        
        .btn-register {
            width: 100%;
            padding: 0.9rem;
            background: linear-gradient(135deg, #0d9488, #1e3a8a);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.3s, box-shadow 0.3s;
            margin-top: 1rem;
        }
        
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(13, 148, 136, 0.3);
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
        
        .required {
            color: #ef4444;
        }
        
        @media (max-width: 768px) {
            .register-container {
                grid-template-columns: 1fr;
            }
            
            .register-left {
                display: none;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    
    <div class="register-container">
        <!-- LEFT SIDE -->
        <div class="register-left">
            <h1>🏖️ Join Us Today</h1>
            <p>Create your account and enjoy exclusive benefits</p>
            <ul class="benefits-list">
                <li>Easy online booking</li>
                <li>Exclusive member discounts</li>
                <li>Early access to special offers</li>
                <li>Free room upgrades on availability</li>
                <li>Loyalty rewards program</li>
                <li>Priority customer support</li>
            </ul>
        </div>
        
        <!-- RIGHT SIDE - REGISTRATION FORM -->
        <div class="register-right">
            <div class="logo">
                <h2>Create <span>Account</span></h2>
                <p style="color: #6b7280;">Join Ocean View Resort family</p>
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
            
            <!-- Registration Form -->
            <form action="<%= request.getContextPath() %>/register" method="post" onsubmit="return validateRegistration()" novalidate>
                
                <div class="form-group">
                    <label for="fullName">Full Name <span class="required">*</span></label>
                    <input type="text" 
                           id="fullName" 
                           name="fullName" 
                           placeholder="Enter your full name" 
                           required
                           minlength="3"
                           maxlength="100"
                           title="Full name must be 3-100 characters"
                           autocomplete="name">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="username">Username <span class="required">*</span></label>
                        <input type="text" 
                               id="username" 
                               name="username" 
                               placeholder="Choose username" 
                               required
                               minlength="3"
                               maxlength="20"
                               pattern="[A-Za-z0-9_]+"
                               title="Username must be 3-20 characters (letters, numbers, underscore only)"
                               autocomplete="username">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               placeholder="your@email.com" 
                               required
                               pattern="[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
                               title="Please enter a valid email address"
                               autocomplete="email">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="phone">Phone Number <span class="required">*</span></label>
                    <input type="tel" 
                           id="phone" 
                           name="phone" 
                           placeholder="0771234567" 
                           required
                           pattern="[0-9\s\-()]{10,15}"
                           title="Phone number must be 10-15 digits"
                           autocomplete="tel">
                </div>
                
                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" 
                              name="address" 
                              placeholder="Enter your address (optional)"
                              maxlength="500"
                              autocomplete="street-address"></textarea>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password <span class="required">*</span></label>
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="Min. 6 characters" 
                               required
                               minlength="6"
                               title="Password must be at least 6 characters"
                               autocomplete="new-password"
                               onkeyup="checkPasswordStrength()">
                        <div class="password-strength">
                            <div class="password-strength-bar" id="strengthBar"></div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password <span class="required">*</span></label>
                        <input type="password" 
                               id="confirmPassword" 
                               name="confirmPassword" 
                               placeholder="Re-enter password" 
                               required
                               minlength="6"
                               title="Please confirm your password"
                               autocomplete="new-password">
                    </div>
                </div>
                
                <button type="submit" class="btn-register">Create Account</button>
            </form>
            
            <div class="form-footer">
                <p>Already have an account? <a href="<%= request.getContextPath() %>/login">Login Here</a></p>
                <p style="margin-top: 1rem;"><a href="<%= request.getContextPath() %>/views/landing.jsp">← Back to Home</a></p>
            </div>
        </div>
    </div>
    
    <script>
        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const strengthBar = document.getElementById('strengthBar');
            
            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 8) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            strengthBar.className = 'password-strength-bar';
            
            if (strength <= 2) {
                strengthBar.classList.add('password-strength-weak');
            } else if (strength <= 3) {
                strengthBar.classList.add('password-strength-medium');
            } else {
                strengthBar.classList.add('password-strength-strong');
            }
        }
        
        function validateRegistration() {
            const fullName = document.getElementById('fullName').value.trim();
            const username = document.getElementById('username').value.trim();
            const email = document.getElementById('email').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const address = document.getElementById('address').value.trim();
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            // Clear custom validations
            document.getElementById('fullName').setCustomValidity('');
            document.getElementById('username').setCustomValidity('');
            document.getElementById('email').setCustomValidity('');
            document.getElementById('phone').setCustomValidity('');
            document.getElementById('password').setCustomValidity('');
            document.getElementById('confirmPassword').setCustomValidity('');
            
            // Full Name validation
            if (fullName === '') {
                alert('❌ Please enter your full name');
                document.getElementById('fullName').focus();
                return false;
            }
            
            if (fullName.length < 3) {
                alert('❌ Full name must be at least 3 characters');
                document.getElementById('fullName').focus();
                return false;
            }
            
            if (fullName.length > 100) {
                alert('❌ Full name must not exceed 100 characters');
                document.getElementById('fullName').focus();
                return false;
            }
            
            // Username validation
            if (username === '') {
                alert('❌ Please enter a username');
                document.getElementById('username').focus();
                return false;
            }
            
            if (username.length < 3) {
                alert('❌ Username must be at least 3 characters');
                document.getElementById('username').focus();
                return false;
            }
            
            if (username.length > 20) {
                alert('❌ Username must not exceed 20 characters');
                document.getElementById('username').focus();
                return false;
            }
            
            if (!/^[a-zA-Z0-9_]+$/.test(username)) {
                alert('❌ Username can only contain letters, numbers, and underscores');
                document.getElementById('username').focus();
                return false;
            }
            
            // Email validation
            if (email === '') {
                alert('❌ Please enter your email');
                document.getElementById('email').focus();
                return false;
            }
            
            const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
            if (!emailRegex.test(email)) {
                alert('❌ Please enter a valid email address (e.g., user@example.com)');
                document.getElementById('email').focus();
                return false;
            }
            
            // Phone validation
            if (phone === '') {
                alert('❌ Please enter your phone number');
                document.getElementById('phone').focus();
                return false;
            }
            
            const cleanPhone = phone.replace(/[\s\-()]/g, '');
            const phoneRegex = /^[0-9]{10,15}$/;
            if (!phoneRegex.test(cleanPhone)) {
                alert('❌ Please enter a valid phone number (10-15 digits)');
                document.getElementById('phone').focus();
                return false;
            }
            
            // Address validation (optional, but limit if provided)
            if (address.length > 500) {
                alert('❌ Address must not exceed 500 characters');
                document.getElementById('address').focus();
                return false;
            }
            
            // Password validation
            if (password === '') {
                alert('❌ Please enter a password');
                document.getElementById('password').focus();
                return false;
            }
            
            if (password.length < 6) {
                alert('❌ Password must be at least 6 characters long');
                document.getElementById('password').focus();
                return false;
            }
            
            // Confirm password validation
            if (confirmPassword === '') {
                alert('❌ Please confirm your password');
                document.getElementById('confirmPassword').focus();
                return false;
            }
            
            if (password !== confirmPassword) {
                alert('❌ Passwords do not match!');
                document.getElementById('confirmPassword').focus();
                return false;
            }
            
            return true;
        }
        
        // Add real-time validation feedback
        document.addEventListener('DOMContentLoaded', function() {
            const fullNameInput = document.getElementById('fullName');
            const usernameInput = document.getElementById('username');
            const emailInput = document.getElementById('email');
            const phoneInput = document.getElementById('phone');
            const addressInput = document.getElementById('address');
            const passwordInput = document.getElementById('password');
            const confirmPasswordInput = document.getElementById('confirmPassword');
            
            // Full Name validation
            fullNameInput.addEventListener('input', function() {
                const value = this.value.trim();
                if (value.length > 0 && value.length < 3) {
                    this.setCustomValidity('Full name must be at least 3 characters');
                } else if (value.length > 100) {
                    this.setCustomValidity('Full name must not exceed 100 characters');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            // Username validation
            usernameInput.addEventListener('input', function() {
                const value = this.value.trim();
                if (value.length > 0 && value.length < 3) {
                    this.setCustomValidity('Username must be at least 3 characters');
                } else if (value.length > 20) {
                    this.setCustomValidity('Username must not exceed 20 characters');
                } else if (value.length > 0 && !/^[a-zA-Z0-9_]+$/.test(value)) {
                    this.setCustomValidity('Only letters, numbers, and underscores allowed');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            // Email validation
            emailInput.addEventListener('input', function() {
                const value = this.value.trim();
                const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
                if (value.length > 0 && !emailRegex.test(value)) {
                    this.setCustomValidity('Please enter a valid email address');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            // Phone validation
            phoneInput.addEventListener('input', function() {
                const value = this.value.replace(/[\s\-()]/g, '');
                const phoneRegex = /^[0-9]{10,15}$/;
                if (value.length > 0 && !phoneRegex.test(value)) {
                    this.setCustomValidity('Phone must be 10-15 digits');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            // Address validation
            addressInput.addEventListener('input', function() {
                const value = this.value.trim();
                if (value.length > 500) {
                    this.setCustomValidity('Address must not exceed 500 characters');
                } else {
                    this.setCustomValidity('');
                }
            });
            
            // Password validation
            passwordInput.addEventListener('input', function() {
                const value = this.value;
                if (value.length > 0 && value.length < 6) {
                    this.setCustomValidity('Password must be at least 6 characters');
                } else {
                    this.setCustomValidity('');
                }
                
                // Check password match
                const confirmValue = confirmPasswordInput.value;
                if (confirmValue.length > 0) {
                    if (value !== confirmValue) {
                        confirmPasswordInput.setCustomValidity('Passwords do not match');
                    } else {
                        confirmPasswordInput.setCustomValidity('');
                    }
                }
            });
            
            // Confirm password validation
            confirmPasswordInput.addEventListener('input', function() {
                const value = this.value;
                const passwordValue = passwordInput.value;
                if (value.length > 0 && value !== passwordValue) {
                    this.setCustomValidity('Passwords do not match');
                } else {
                    this.setCustomValidity('');
                }
            });
        });
    </script>
    
</body>
</html>
