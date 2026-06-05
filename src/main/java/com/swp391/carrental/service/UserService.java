/*
 * Name: UserService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for UserService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.model.User;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;

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

    public boolean updateUser(User user) {
        try {
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
