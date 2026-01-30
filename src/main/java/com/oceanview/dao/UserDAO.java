package com.oceanview.dao;

import com.oceanview.model.User;
import java.util.List;

/**
 * UserDAO Interface
 * Defines CRUD operations for User entity
 */
public interface UserDAO {
    
    /**
     * Create a new user
     * @param user User object to create
     * @return Generated user ID
     */
    int create(User user) throws Exception;
    
    /**
     * Read user by ID
     * @param userId User ID
     * @return User object or null if not found
     */
    User read(int userId) throws Exception;
    
    /**
     * Update existing user
     * @param user User object with updated data
     * @return true if update successful
     */
    boolean update(User user) throws Exception;
    
    /**
     * Delete user by ID
     * @param userId User ID to delete
     * @return true if deletion successful
     */
    boolean delete(int userId) throws Exception;
    
    /**
     * Get all users
     * @return List of all users
     */
    List<User> getAll() throws Exception;
    
    /**
     * Find user by username
     * @param username Username to search
     * @return User object or null
     */
    User findByUsername(String username) throws Exception;
    
    /**
     * Find user by email
     * @param email Email to search
     * @return User object or null
     */
    User findByEmail(String email) throws Exception;
    
    /**
     * Get users by role
     * @param role User role (ADMIN, STAFF, GUEST)
     * @return List of users with specified role
     */
    List<User> getUsersByRole(String role) throws Exception;
    
    /**
     * Authenticate user login
     * @param username Username
     * @param password Password (hashed)
     * @return User object if credentials valid, null otherwise
     */
    User authenticate(String username, String password) throws Exception;
    
    /**
     * Authenticate user login by username or email
     * @param usernameOrEmail Username or email
     * @param password Password (hashed)
     * @return User object if credentials valid, null otherwise
     */
    User authenticateByUsernameOrEmail(String usernameOrEmail, String password) throws Exception;
    
    /**
     * Update last login timestamp
     * @param userId User ID
     * @return true if update successful
     */
    boolean updateLastLogin(int userId) throws Exception;
    
    /**
     * Change user status (ACTIVE/INACTIVE)
     * @param userId User ID
     * @param status New status
     * @return true if update successful
     */
    boolean updateStatus(int userId, String status) throws Exception;
}
