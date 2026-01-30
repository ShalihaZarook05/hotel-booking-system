package com.oceanview.service;

import com.oceanview.dao.UserDAO;
import com.oceanview.dao.DAOFactory;
import com.oceanview.model.User;
import com.oceanview.util.PasswordUtil;

import java.util.List;

/**
 * UserService
 * Business logic for user operations
 */
public class UserService {
    
    private UserDAO userDAO;
    
    public UserService() {
        this.userDAO = DAOFactory.getUserDAO();
    }
    
    /**
     * Register a new user
     * @param user User object with plain text password
     * @return User ID if successful, 0 otherwise
     * @throws Exception if registration fails
     */
    public int registerUser(User user) throws Exception {
        // Validate user data
        validateUserData(user);
        
        // Check if username already exists
        User existingUser = userDAO.findByUsername(user.getUsername());
        if (existingUser != null) {
            throw new Exception("Username already exists!");
        }
        
        // Check if email already exists
        existingUser = userDAO.findByEmail(user.getEmail());
        if (existingUser != null) {
            throw new Exception("Email already registered!");
        }
        
        // Hash the password
        String hashedPassword = PasswordUtil.hashPassword(user.getPassword());
        user.setPassword(hashedPassword);
        
        // Set default status
        if (user.getStatus() == null || user.getStatus().isEmpty()) {
            user.setStatus(User.STATUS_ACTIVE);
        }
        
        // Create user
        return userDAO.create(user);
    }
    
    /**
     * Authenticate user login
     * @param username Username
     * @param password Plain text password
     * @return User object if authentication successful, null otherwise
     * @throws Exception if authentication fails
     */
    public User authenticateUser(String username, String password) throws Exception {
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            throw new Exception("Username and password are required!");
        }
        
        // Hash the password
        String hashedPassword = PasswordUtil.hashPassword(password);
        
        // Authenticate
        User user = userDAO.authenticate(username, hashedPassword);
        
        if (user != null) {
            // Update last login
            userDAO.updateLastLogin(user.getUserId());
        }
        
        return user;
    }
    
    /**
     * Get user by ID
     * @param userId User ID
     * @return User object
     * @throws Exception if user not found
     */
    public User getUserById(int userId) throws Exception {
        User user = userDAO.read(userId);
        if (user == null) {
            throw new Exception("User not found!");
        }
        return user;
    }
    
    /**
     * Get user by username
     * @param username Username
     * @return User object
     * @throws Exception if user not found
     */
    public User getUserByUsername(String username) throws Exception {
        User user = userDAO.findByUsername(username);
        if (user == null) {
            throw new Exception("User not found!");
        }
        return user;
    }
    
    /**
     * Get all users
     * @return List of all users
     * @throws Exception if operation fails
     */
    public List<User> getAllUsers() throws Exception {
        return userDAO.getAll();
    }
    
    /**
     * Get users by role
     * @param role User role
     * @return List of users with specified role
     * @throws Exception if operation fails
     */
    public List<User> getUsersByRole(String role) throws Exception {
        return userDAO.getUsersByRole(role);
    }
    
    /**
     * Update user profile
     * @param user User object with updated data
     * @return true if update successful
     * @throws Exception if update fails
     */
    public boolean updateUser(User user) throws Exception {
        // Validate user data
        validateUserData(user);
        
        // Check if user exists
        User existingUser = userDAO.read(user.getUserId());
        if (existingUser == null) {
            throw new Exception("User not found!");
        }
        
        // Check if new username conflicts with another user
        if (!existingUser.getUsername().equals(user.getUsername())) {
            User userWithSameUsername = userDAO.findByUsername(user.getUsername());
            if (userWithSameUsername != null && userWithSameUsername.getUserId() != user.getUserId()) {
                throw new Exception("Username already exists!");
            }
        }
        
        // Check if new email conflicts with another user
        if (!existingUser.getEmail().equals(user.getEmail())) {
            User userWithSameEmail = userDAO.findByEmail(user.getEmail());
            if (userWithSameEmail != null && userWithSameEmail.getUserId() != user.getUserId()) {
                throw new Exception("Email already registered!");
            }
        }
        
        return userDAO.update(user);
    }
    
    /**
     * Change user password
     * @param userId User ID
     * @param currentPassword Current password (plain text)
     * @param newPassword New password (plain text)
     * @return true if password changed successfully
     * @throws Exception if password change fails
     */
    public boolean changePassword(int userId, String currentPassword, String newPassword) throws Exception {
        // Get user
        User user = userDAO.read(userId);
        if (user == null) {
            throw new Exception("User not found!");
        }
        
        // Verify current password
        String hashedCurrentPassword = PasswordUtil.hashPassword(currentPassword);
        if (!hashedCurrentPassword.equals(user.getPassword())) {
            throw new Exception("Current password is incorrect!");
        }
        
        // Validate new password
        if (newPassword == null || newPassword.length() < 6) {
            throw new Exception("New password must be at least 6 characters!");
        }
        
        // Hash and update new password
        user.setPassword(PasswordUtil.hashPassword(newPassword));
        return userDAO.update(user);
    }
    
    /**
     * Activate user account
     * @param userId User ID
     * @return true if activation successful
     * @throws Exception if activation fails
     */
    public boolean activateUser(int userId) throws Exception {
        return userDAO.updateStatus(userId, User.STATUS_ACTIVE);
    }
    
    /**
     * Deactivate user account
     * @param userId User ID
     * @return true if deactivation successful
     * @throws Exception if deactivation fails
     */
    public boolean deactivateUser(int userId) throws Exception {
        return userDAO.updateStatus(userId, User.STATUS_INACTIVE);
    }
    
    /**
     * Delete user
     * @param userId User ID
     * @return true if deletion successful
     * @throws Exception if deletion fails
     */
    public boolean deleteUser(int userId) throws Exception {
        User user = userDAO.read(userId);
        if (user == null) {
            throw new Exception("User not found!");
        }
        return userDAO.delete(userId);
    }
    
    /**
     * Validate user data
     * @param user User object
     * @throws Exception if validation fails
     */
    private void validateUserData(User user) throws Exception {
        if (user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            throw new Exception("Username is required!");
        }
        
        if (user.getUsername().length() < 3) {
            throw new Exception("Username must be at least 3 characters!");
        }
        
        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            throw new Exception("Full name is required!");
        }
        
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new Exception("Email is required!");
        }
        
        if (!isValidEmail(user.getEmail())) {
            throw new Exception("Invalid email format!");
        }
        
        if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
            throw new Exception("Phone number is required!");
        }
        
        if (user.getRole() == null || user.getRole().trim().isEmpty()) {
            throw new Exception("User role is required!");
        }
    }
    
    /**
     * Validate email format
     * @param email Email address
     * @return true if valid email format
     */
    private boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email.matches(emailRegex);
    }
}
