/*
 * Name: AuthService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for AuthService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.dao.CustomerProfileDAO;
import com.swp391.carrental.model.User;
import com.swp391.carrental.model.CustomerProfile;
import com.swp391.carrental.constant.Role;
import com.swp391.carrental.exception.AppException;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.SQLException;

/**
 * Service for authentication (login, register).
 */
public class AuthService {

    private final UserDAO userDAO = new UserDAO();
    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();

    /**
     * Authenticate user by email and password.
     * @return User object if credentials are valid
     * @throws AppException if login fails
     */
    public User login(String email, String password) {
        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                throw new AppException("Invalid email or password.");
            }
            if (!user.isActive()) {
                throw new AppException("Your account has been deactivated. Please contact admin.");
            }
            
            // Check password (BCrypt with fallback to plaintext for testing)
            boolean passwordMatch = false;
            try {
                passwordMatch = BCrypt.checkpw(password, user.getPasswordHash());
            } catch (IllegalArgumentException e) {
                // Fallback: if BCrypt fails, try plaintext comparison
                passwordMatch = password.equals(user.getPasswordHash());
            }
            
            if (!passwordMatch) {
                throw new AppException("Invalid email or password.");
            }
            return user;
        } catch (SQLException e) {
            throw new AppException("Login failed due to system error.", e);
        }
    }

    /**
     * Register a new customer account.
     */
    public User register(String email, String fullName, String phone, String password) {
        try {
            // Check if email already exists
            User existing = userDAO.findByEmail(email);
            if (existing != null) {
                throw new AppException("Email is already registered.");
            }

            // Create user
            User user = new User();
            user.setEmail(email);
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
            user.setRole(Role.CUSTOMER);
            user.setActive(true);

            int userId = userDAO.insert(user);
            if (userId <= 0) {
                throw new AppException("Failed to create account.");
            }
            user.setUserId(userId);

            // Create empty customer profile
            CustomerProfile profile = new CustomerProfile();
            profile.setUserId(userId);
            profile.setVerificationStatus("PENDING");
            profileDAO.insert(profile);

            return user;
        } catch (SQLException e) {
            throw new AppException("Registration failed due to system error.", e);
        }
    }
}
