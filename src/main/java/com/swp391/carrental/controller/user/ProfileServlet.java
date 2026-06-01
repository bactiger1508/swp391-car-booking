/*
 * Name: ProfileServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for ProfileServlet.
 */
package com.swp391.carrental.controller.user;

import com.swp391.carrental.dao.CustomerProfileDAO;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.model.CustomerProfile;
import com.swp391.carrental.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Handles user profile view and edit.
 * URL: /profile
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            CustomerProfile profile = profileDAO.findByUserId(currentUser.getUserId());
            if (profile == null) {
                profile = new CustomerProfile();
                profile.setUserId(currentUser.getUserId());
                profile.setVerificationStatus("PENDING");
                int profileId = profileDAO.insert(profile);
                profile.setProfileId(profileId);
            }
            request.setAttribute("profile", profile);
            
            String success = request.getParameter("success");
            if (success != null) {
                request.setAttribute("success", "Cập nhật hồ sơ cá nhân thành công!");
            }
            
            request.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Read parameters
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String dobStr = request.getParameter("dateOfBirth");
            String address = request.getParameter("address");
            String idCardNumber = request.getParameter("idCardNumber");
            String driverLicenseNumber = request.getParameter("driverLicenseNumber");
            String driverLicenseExpiryStr = request.getParameter("driverLicenseExpiry");

            // Update user core info
            currentUser.setFullName(fullName);
            currentUser.setPhone(phone);
            userDAO.update(currentUser);
            request.getSession().setAttribute("currentUser", currentUser);

            // Update customer profile
            CustomerProfile profile = profileDAO.findByUserId(currentUser.getUserId());
            if (profile == null) {
                profile = new CustomerProfile();
                profile.setUserId(currentUser.getUserId());
                profile.setVerificationStatus("PENDING");
                int profileId = profileDAO.insert(profile);
                profile.setProfileId(profileId);
            }

            if (dobStr != null && !dobStr.isEmpty()) {
                profile.setDateOfBirth(LocalDate.parse(dobStr));
            }
            profile.setAddress(address);
            profile.setIdCardNumber(idCardNumber);
            profile.setDriverLicenseNumber(driverLicenseNumber);
            if (driverLicenseExpiryStr != null && !driverLicenseExpiryStr.isEmpty()) {
                profile.setDriverLicenseExpiry(LocalDate.parse(driverLicenseExpiryStr));
            }

            profileDAO.update(profile);

            response.sendRedirect(request.getContextPath() + "/profile?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
            doGet(request, response);
        }
    }
}

