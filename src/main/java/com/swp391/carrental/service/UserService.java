/*
 * Name: UserService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for UserService.
 */
package com.swp391.carrental.service;

import java.sql.SQLException;
import java.util.List;

import org.mindrot.jbcrypt.BCrypt;

import com.swp391.carrental.constant.Role;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.exception.AppException;
import com.swp391.carrental.model.User;

/**
 * Service for user management operations.
 */
public class UserService {

    private final UserDAO userDAO = new UserDAO();

    public User getUserById(int userId) {
        try {
            return userDAO.findById(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to get user.", e);
        }
    }

    public List<User> getAllUsers() {
        try {
            return userDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get users.", e);
        }
    }

    public List<User> getUsersByRole(String role) {
        try {
            return userDAO.findByRole(role);
        } catch (SQLException e) {
            throw new AppException("Failed to get users by role.", e);
        }
    }

    public List<User> getFilteredUsers(String search, String role, String status, int page, int pageSize) {
        try {
            return userDAO.findFilteredUsers(search, role, status, page, pageSize);
        } catch (SQLException e) {
            throw new AppException("Failed to get filtered users.", e);
        }
    }

    public int countFilteredUsers(String search, String role, String status) {
        try {
            return userDAO.countFilteredUsers(search, role, status);
        } catch (SQLException e) {
            throw new AppException("Failed to count users.", e);
        }
    }

    public User createUser(User user, String rawPassword) {
        try {
            if (userDAO.findByEmail(user.getEmail()) != null) {
                throw new AppException("Email is already registered.");
            }
            if (rawPassword == null || rawPassword.trim().length() < 6) {
                throw new AppException("Password must be at least 6 characters long.");
            }
            user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));
            if (user.getRole() == null || user.getRole().isEmpty()) {
                user.setRole(Role.CUSTOMER);
            }
            if (user.getRole().equalsIgnoreCase(Role.CUSTOMER)) {
                user.setRole(Role.CUSTOMER);
            }
            int userId = userDAO.insert(user);
            if (userId <= 0) {
                throw new AppException("Failed to create user account.");
            }
            user.setUserId(userId);
            return user;
        } catch (SQLException e) {
            throw new AppException("Failed to create user.", e);
        }
    }

    public boolean updateUser(User user) {
        try {
            User existing = userDAO.findByEmail(user.getEmail());
            if (existing != null && existing.getUserId() != user.getUserId()) {
                throw new AppException("Email is already registered by another account.");
            }
            return userDAO.update(user);
        } catch (SQLException e) {
            throw new AppException("Failed to update user.", e);
        }
    }

    public boolean toggleUserActive(int userId) {
        try {
            User user = userDAO.findById(userId);
            if (user == null) throw new AppException("User not found.");
            user.setActive(!user.isActive());
            return userDAO.update(user);
        } catch (SQLException e) {
            throw new AppException("Failed to toggle user status.", e);
        }
    }

    public boolean deleteUser(int userId) {
        try {
            return userDAO.delete(userId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete user.", e);
        }
    }
}
