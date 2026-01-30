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
 * RegisterServlet
 * Handles user registration (Guest users)
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        userDAO = DAOFactory.getUserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Forward to registration page
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get form parameters and trim
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        
        // Trim all parameters
        if (username != null) username = username.trim();
        if (password != null) password = password.trim();
        if (confirmPassword != null) confirmPassword = confirmPassword.trim();
        if (fullName != null) fullName = fullName.trim();
        if (email != null) email = email.trim();
        if (phone != null) phone = phone.trim();
        if (address != null) address = address.trim();
        
        // === VALIDATION ===
        
        // Validate Full Name
        String fullNameError = ValidationService.validateRequired(fullName, "Full Name");
        if (fullNameError != null) {
            SessionManager.setErrorMessage(request, fullNameError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        String fullNameLengthError = ValidationService.validateLength(fullName, "Full Name", 3, 100);
        if (fullNameLengthError != null) {
            SessionManager.setErrorMessage(request, fullNameLengthError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Username
        String usernameError = ValidationService.validateUsername(username);
        if (usernameError != null) {
            SessionManager.setErrorMessage(request, usernameError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Email
        String emailError = ValidationService.validateEmail(email);
        if (emailError != null) {
            SessionManager.setErrorMessage(request, emailError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Phone
        String phoneError = ValidationService.validatePhone(phone);
        if (phoneError != null) {
            SessionManager.setErrorMessage(request, phoneError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Password
        String passwordError = ValidationService.validatePassword(password);
        if (passwordError != null) {
            SessionManager.setErrorMessage(request, passwordError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Password Confirmation
        String passwordMatchError = ValidationService.validatePasswordMatch(password, confirmPassword);
        if (passwordMatchError != null) {
            SessionManager.setErrorMessage(request, passwordMatchError);
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }
        
        // Validate Address (optional but limit length if provided)
        if (address != null && !address.isEmpty()) {
            String addressLengthError = ValidationService.validateLength(address, "Address", 0, 500);
            if (addressLengthError != null) {
                SessionManager.setErrorMessage(request, addressLengthError);
                response.sendRedirect(request.getContextPath() + "/register");
                return;
            }
        }
        
        try {
            // Check if username already exists
            User existingUser = userDAO.findByUsername(username);
            if (existingUser != null) {
                SessionManager.setErrorMessage(request, "Username already exists! Please choose a different username.");
                response.sendRedirect(request.getContextPath() + "/register");
                return;
            }
            
            // Check if email already exists
            existingUser = userDAO.findByEmail(email);
            if (existingUser != null) {
                SessionManager.setErrorMessage(request, "Email already registered! Please use a different email or login.");
                response.sendRedirect(request.getContextPath() + "/register");
                return;
            }
            
            // Hash the password
            String hashedPassword = PasswordUtil.hashPassword(password);
            
            // Create new user (default role: GUEST)
            User newUser = new User(username, hashedPassword, fullName, email, phone, address, User.ROLE_GUEST);
            
            // Save to database
            int userId = userDAO.create(newUser);
            
            if (userId > 0) {
                SessionManager.setSuccessMessage(request, "Registration successful! You can now login with your credentials.");
                response.sendRedirect(request.getContextPath() + "/login");
            } else {
                SessionManager.setErrorMessage(request, "Registration failed! Please try again.");
                response.sendRedirect(request.getContextPath() + "/register");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            SessionManager.setErrorMessage(request, "Registration error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/register");
        }
    }
}
