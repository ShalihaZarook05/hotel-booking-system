<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oceanview.util.PasswordUtil" %>
<%@ page import="com.oceanview.dao.UserDAO" %>
<%@ page import="com.oceanview.dao.DAOFactory" %>
<%@ page import="com.oceanview.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <title>Password Hash Test</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .container { background: white; padding: 20px; border-radius: 10px; max-width: 800px; margin: 0 auto; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        pre { background: #f0f0f0; padding: 10px; border-radius: 5px; overflow-x: auto; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #1e3a8a; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Password Hash Debug Tool</h1>
        
        <h2>Test 1: Hash Generation</h2>
        <%
        String testPassword = "password123";
        String hashedPassword = PasswordUtil.hashPassword(testPassword);
        %>
        <table>
            <tr><th>Input</th><th>Output</th></tr>
            <tr><td>Plain Password</td><td><code><%= testPassword %></code></td></tr>
            <tr><td>SHA-256 Hash</td><td><code><%= hashedPassword %></code></td></tr>
            <tr><td>Hash Length</td><td><%= hashedPassword.length() %> characters</td></tr>
        </table>
        
        <h2>Test 2: Database User Passwords</h2>
        <%
        try {
            UserDAO userDAO = DAOFactory.getUserDAO();
            User admin = userDAO.findByUsername("admin");
            User staff1 = userDAO.findByUsername("staff1");
            User guest1 = userDAO.findByUsername("guest1");
        %>
        <table>
            <tr>
                <th>Username</th>
                <th>Password Hash in DB</th>
                <th>Hash Length</th>
            </tr>
            <% if (admin != null) { %>
            <tr>
                <td>admin</td>
                <td><code><%= admin.getPassword() %></code></td>
                <td><%= admin.getPassword().length() %></td>
            </tr>
            <% } %>
            <% if (staff1 != null) { %>
            <tr>
                <td>staff1</td>
                <td><code><%= staff1.getPassword() %></code></td>
                <td><%= staff1.getPassword().length() %></td>
            </tr>
            <% } %>
            <% if (guest1 != null) { %>
            <tr>
                <td>guest1</td>
                <td><code><%= guest1.getPassword() %></code></td>
                <td><%= guest1.getPassword().length() %></td>
            </tr>
            <% } %>
        </table>
        
        <h2>Test 3: Password Verification</h2>
        <%
        if (admin != null) {
            String dbHash = admin.getPassword();
            String generatedHash = PasswordUtil.hashPassword("password123");
            boolean matches = dbHash.equals(generatedHash);
        %>
        <table>
            <tr><th>Test</th><th>Result</th></tr>
            <tr>
                <td>DB Hash</td>
                <td><code><%= dbHash %></code></td>
            </tr>
            <tr>
                <td>Generated Hash</td>
                <td><code><%= generatedHash %></code></td>
            </tr>
            <tr>
                <td>Hashes Match?</td>
                <td class="<%= matches ? "success" : "error" %>">
                    <%= matches ? "✅ YES - Login should work!" : "❌ NO - This is the problem!" %>
                </td>
            </tr>
        </table>
        
        <% if (!matches) { %>
        <div style="background: #fee; padding: 15px; border-left: 4px solid #f00; margin: 20px 0;">
            <h3>❌ Problem Identified!</h3>
            <p>The password hash in the database does NOT match what the code generates.</p>
            <p><strong>Solution:</strong> You need to update the database passwords.</p>
        </div>
        <% } %>
        
        <h3>Fix: Update Database Password</h3>
        <p>Run this SQL command to fix admin password:</p>
        <pre>UPDATE users SET password = '<%= generatedHash %>' WHERE username = 'admin';</pre>
        
        <% } %>
        
        <% } catch (Exception e) { %>
        <div class="error">
            <h3>❌ Error:</h3>
            <p><%= e.getMessage() %></p>
            <pre><% e.printStackTrace(new java.io.PrintWriter(out)); %></pre>
        </div>
        <% } %>
        
        <h2>Test 4: Authentication Test</h2>
        <%
        try {
            UserDAO userDAO = DAOFactory.getUserDAO();
            String testHash = PasswordUtil.hashPassword("password123");
            User authenticated = userDAO.authenticate("admin", testHash);
            
            if (authenticated != null) {
                out.println("<p class='success'>✅ Authentication WORKS! User: " + authenticated.getFullName() + "</p>");
            } else {
                out.println("<p class='error'>❌ Authentication FAILED! Check password hash in database.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>❌ Error: " + e.getMessage() + "</p>");
        }
        %>
        
        <hr>
        <h2>Quick Fix SQL</h2>
        <p>Copy and run this in MySQL to fix all user passwords:</p>
        <pre>
USE ocean_view_resort;

-- Update all users to use password123 with correct hash
UPDATE users SET password = '<%= PasswordUtil.hashPassword("password123") %>' 
WHERE username IN ('admin', 'staff1', 'staff2', 'guest1', 'guest2', 'guest3', 'guest4', 'guest5');

-- Verify
SELECT username, password, role FROM users;
        </pre>
        
        <hr>
        <p><a href="<%= request.getContextPath() %>/">← Back to Home</a></p>
    </div>
</body>
</html>
