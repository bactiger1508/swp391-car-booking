package com.swp391.carrental.auth.service;

import org.mindrot.jbcrypt.BCrypt;
import java.sql.SQLException;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.dao.CustomerProfileDAO;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.CustomerProfile;
import com.swp391.carrental.user.model.User;

/*
 * Name: AuthService
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for AuthService.
 */



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
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            throw new AppException("Email hoặc mật khẩu không đúng.");
        }
        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                throw new AppException("Email hoặc mật khẩu không đúng.");
            }
            if (!user.isActive()) {
                throw new AppException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ với quản lý");
            }
            if (!BCrypt.checkpw(password, user.getPasswordHash())) {
                throw new AppException("Email hoặc mật khẩu không đúng.");
            }
            return user;
        } catch (SQLException e) {
            throw new AppException("Đăng nhập không thành công do lỗi hệ thống.", e);
        }
    }

    /**
     * Register a new customer account.
     */
    public User register(String email, String fullName, String phone, String password) {
        if (email == null || email.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            throw new AppException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }

        // Validate email format
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            throw new AppException("Định dạng email không hợp lệ.");
        }

        // Validate password length
        if (password.length() < 8) {
            throw new AppException("Mật khẩu phải có độ dài tối thiểu 8 ký tự.");
        }

        try {
            // Check if email already exists
            User existing = userDAO.findByEmail(email);
            if (existing != null) {
                throw new AppException("Email đã được đăng ký.");
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
                throw new AppException("Tạo tài khoản không thành công.");
            }
            user.setUserId(userId);

            // Create empty customer profile
            CustomerProfile profile = new CustomerProfile();
            profile.setUserId(userId);
            profile.setVerificationStatus("PENDING");
            profileDAO.insert(profile);

            return user;
        } catch (SQLException e) {
            throw new AppException("Đăng ký không thành công do lỗi hệ thống.", e);
        }
    }
}
