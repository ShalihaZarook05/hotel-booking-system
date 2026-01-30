package com.oceanview.controller;

import com.oceanview.dao.UserDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.User;
import com.oceanview.service.ValidationService;
import com.oceanview.util.PasswordUtil;
import com.oceanview.util.SessionManager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * LoginServlet
 * Handles user authentication and login
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = DAOFactory.getUserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to login page
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parameters and trim
        String usernameOrEmail = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Trim parameters
        if (usernameOrEmail != null) usernameOrEmail = usernameOrEmail.trim();
        if (password != null) password = password.trim();
        
        // Validate username/email
        String usernameError = ValidationService.validateRequired(usernameOrEmail, "Username or Email");
        if (usernameError != null) {
            SessionManager.setErrorMessage(request, usernameError);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Basic validation - check if it's not empty and has minimum length
        if (usernameOrEmail.length() < 3) {
            SessionManager.setErrorMessage(request, "Username or Email must be at least 3 characters!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Validate password
        String passwordError = ValidationService.validateRequired(password, "Password");
        if (passwordError != null) {
            SessionManager.setErrorMessage(request, passwordError);
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        // Validate password length
        if (password.length() < 6) {
            SessionManager.setErrorMessage(request, "Password must be at least 6 characters!");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Hash the password
            String hashedPassword = PasswordUtil.hashPassword(password);
            
            // Authenticate user by username or email
            User user = userDAO.authenticateByUsernameOrEmail(usernameOrEmail, hashedPassword);
            
            if (user != null) {
                // Update last login
                userDAO.updateLastLogin(user.getUserId());
                
                // Create session
                SessionManager.createSession(request, user);
                
                // Redirect based on role
                String redirectUrl = getRedirectUrlByRole(user.getRole());
                response.sendRedirect(request.getContextPath() + redirectUrl);
                
            } else {
                SessionManager.setErrorMessage(request, "Invalid username/email or password!");
                response.sendRedirect(request.getContextPath() + "/login");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Login failed: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }
    
    /**
     * Get redirect URL based on user role
     */
    private String getRedirectUrlByRole(String role) {
        switch (role) {
            case User.ROLE_ADMIN:
                return "/admin/dashboard";
            case User.ROLE_STAFF:
                return "/staff/dashboard";
            case User.ROLE_GUEST:
                return "/guest/dashboard";
            default:
                return "/login";
        }
    }
}
