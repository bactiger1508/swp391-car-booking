package com.swp391.carrental.user.service;

import java.sql.SQLException;
import java.util.List;
import org.mindrot.jbcrypt.BCrypt;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;

/*
 * Name: UserService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for UserService.
 */
/**
 * Service for user management operations.
 */
public class UserService {

    private final UserDAO userDAO = new UserDAO();

    private boolean isValidVietnamPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        return phone.matches("^(03|05|07|08|09)\\d{8}$");
    }

    public User getUserById(int userId) {
        try {
            return userDAO.findById(userId);
        } catch (SQLException e) {
            throw new AppException("Không thể lấy thông tin người dùng.", e);
        }
    }

    public List<User> getAllUsers() {
        try {
            return userDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Không thể tải danh sách người dùng.", e);
        }
    }

    public List<User> getUsersByRole(String role) {
        try {
            return userDAO.findByRole(role);
        } catch (SQLException e) {
            throw new AppException("Không thể lấy danh sách người dùng theo vai trò.", e);
        }
    }

    public List<User> getFilteredUsers(String search, String role, String status, int page, int pageSize) {
        try {
            return userDAO.findFilteredUsers(search, role, status, page, pageSize);
        } catch (SQLException e) {
            throw new AppException("Không thể tìm kiếm người dùng.", e);
        }
    }

    public int countFilteredUsers(String search, String role, String status) {
        try {
            return userDAO.countFilteredUsers(search, role, status);
        } catch (SQLException e) {
            throw new AppException("Không thể đếm số lượng người dùng.", e);
        }
    }

    public User createUser(User user, String rawPassword) {
        try {
            if (userDAO.findByEmail(user.getEmail()) != null) {
                throw new AppException("Email đã được đăng ký.");
            }
            if (rawPassword == null || rawPassword.trim().length() < 6) {
                throw new AppException("Mật khẩu phải có ít nhất 6 ký tự.");
            }
            user.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt()));
            if (!isValidVietnamPhone(user.getPhone())) {
                throw new AppException(
                        "Số điện thoại phải gồm 10 chữ số và là số điện thoại Việt Nam.");
            }
            if (user.getRole() == null || user.getRole().isEmpty()) {
                user.setRole(Role.CUSTOMER);
            }
            if (user.getRole().equalsIgnoreCase(Role.CUSTOMER)) {
                user.setRole(Role.CUSTOMER);
            }
            int userId = userDAO.insert(user);
            if (userId <= 0) {
                throw new AppException("Không thể tạo tài khoản.");
            }
            user.setUserId(userId);
            return user;
        } catch (SQLException e) {
            throw new AppException("Có lỗi xảy ra khi tạo tài khoản.", e);
        }
    }

    public boolean updateUser(User user) {
        try {
            User existing = userDAO.findByEmail(user.getEmail());
            if (existing != null && existing.getUserId() != user.getUserId()) {
                throw new AppException("Email đã được sử dụng bởi tài khoản khác.");
            }
            return userDAO.update(user);
        } catch (SQLException e) {
            throw new AppException("Có lỗi xảy ra khi cập nhật tài khoản.", e);
        }
    }

    public boolean toggleUserActive(int userId) {
        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                throw new AppException("Không tìm thấy người dùng.");
            }
            user.setActive(!user.isActive());
            return userDAO.update(user);
        } catch (SQLException e) {
            throw new AppException("Không thể thay đổi trạng thái tài khoản.", e);
        }
    }

    public boolean deleteUser(int userId) {
        try {
            return userDAO.delete(userId);
        } catch (SQLException e) {
            throw new AppException("Không thể xóa người dùng.", e);
        }
    }
}
