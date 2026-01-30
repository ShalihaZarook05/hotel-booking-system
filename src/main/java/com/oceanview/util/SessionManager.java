package com.oceanview.util;

import com.oceanview.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * SessionManager
 * Utility class for managing user sessions
 */
public class SessionManager {
    
    // Session attribute keys
    public static final String USER_SESSION = "loggedInUser";
    public static final String USER_ID = "userId";
    public static final String USERNAME = "username";
    public static final String USER_ROLE = "userRole";
    public static final String FULL_NAME = "fullName";
    
    /**
     * Create user session after login
     * @param request HTTP request
     * @param user Logged in user
     */
    public static void createSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute(USER_SESSION, user);
        session.setAttribute(USER_ID, user.getUserId());
        session.setAttribute(USERNAME, user.getUsername());
        session.setAttribute(USER_ROLE, user.getRole());
        session.setAttribute(FULL_NAME, user.getFullName());
        session.setMaxInactiveInterval(30 * 60); // 30 minutes
    }
    
    /**
     * Get logged in user from session
     * @param request HTTP request
     * @return User object or null
     */
    public static User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute(USER_SESSION);
        }
        return null;
    }
    
    /**
     * Check if user is logged in
     * @param request HTTP request
     * @return true if user is logged in
     */
    public static boolean isLoggedIn(HttpServletRequest request) {
        return getLoggedInUser(request) != null;
    }
    
    /**
     * Get user ID from session
     * @param request HTTP request
     * @return User ID or 0 if not logged in
     */
    public static int getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer userId = (Integer) session.getAttribute(USER_ID);
            return userId != null ? userId : 0;
        }
        return 0;
    }
    
    /**
     * Get user role from session
     * @param request HTTP request
     * @return User role or null
     */
    public static String getUserRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (String) session.getAttribute(USER_ROLE);
        }
        return null;
    }
    
    /**
     * Check if user is Admin
     * @param request HTTP request
     * @return true if user is admin
     */
    public static boolean isAdmin(HttpServletRequest request) {
        return User.ROLE_ADMIN.equals(getUserRole(request));
    }
    
    /**
     * Check if user is Staff
     * @param request HTTP request
     * @return true if user is staff
     */
    public static boolean isStaff(HttpServletRequest request) {
        return User.ROLE_STAFF.equals(getUserRole(request));
    }
    
    /**
     * Check if user is Guest
     * @param request HTTP request
     * @return true if user is guest
     */
    public static boolean isGuest(HttpServletRequest request) {
        return User.ROLE_GUEST.equals(getUserRole(request));
    }
    
    /**
     * Destroy user session (logout)
     * @param request HTTP request
     */
    public static void destroySession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
    
    /**
     * Set success message in session
     * @param request HTTP request
     * @param message Success message
     */
    public static void setSuccessMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("successMessage", message);
    }
    
    /**
     * Set error message in session
     * @param request HTTP request
     * @param message Error message
     */
    public static void setErrorMessage(HttpServletRequest request, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("errorMessage", message);
    }
    
    /**
     * Get and clear success message
     * @param request HTTP request
     * @return Success message or null
     */
    public static String getSuccessMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute("successMessage");
            session.removeAttribute("successMessage");
            return message;
        }
        return null;
    }
    
    /**
     * Get and clear error message
     * @param request HTTP request
     * @return Error message or null
     */
    public static String getErrorMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String message = (String) session.getAttribute("errorMessage");
            session.removeAttribute("errorMessage");
            return message;
        }
        return null;
    }
}
