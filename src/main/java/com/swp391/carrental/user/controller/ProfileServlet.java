package com.swp391.carrental.user.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDate;
import com.swp391.carrental.user.dao.CustomerProfileDAO;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.CustomerProfile;
import com.swp391.carrental.user.model.User;
import java.util.regex.Pattern;

/*
 * Name: ProfileServlet
 * @Author: AnhNNHE160896
 * Date: 23/05/2026
 * Version: 1.1
 * Description: Handles HTTP requests and responses for ProfileServlet with status reset logic and multi-image uploads.
 */
/**
 * Handles user profile view and edit. URL: /profile
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 20 * 1024 * 1024
)
public class ProfileServlet extends HttpServlet {

    private final CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    private final UserDAO userDAO = new UserDAO();

    // Handles HTTP GET request to display the user profile page.
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

    // Handles HTTP POST request to update profile and upload images.
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
            // Validate phone number
            if (!isValidVietnamPhone(phone)) {
                request.setAttribute("error", "Số điện thoại phải gồm đúng 10 chữ số và là đầu số Việt Nam (03, 05, 07, 08, 09).");
                doGet(request, response);
                return;
            }
            String dobStr = request.getParameter("dateOfBirth");
            // Validate date of birth
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                LocalDate dob = LocalDate.parse(dobStr);

                if (dob.isAfter(LocalDate.now())) {
                    request.setAttribute("error",
                            "Ngày sinh không được lớn hơn ngày hiện tại.");
                    doGet(request, response);
                    return;
                }
            }
            String address = request.getParameter("address");
            String idCardNumber = request.getParameter("idCardNumber");
            String driverLicenseNumber = request.getParameter("driverLicenseNumber");
            String driverLicenseExpiryStr = request.getParameter("driverLicenseExpiry");
            Part licenseImagePart = request.getPart("driverLicenseImage");
            Part idCardFrontPart = request.getPart("idCardImageFront");
            Part idCardBackPart = request.getPart("idCardImageBack");

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

            if (dobStr != null && !dobStr.trim().isEmpty()) {
                profile.setDateOfBirth(LocalDate.parse(dobStr));
            } else {
                profile.setDateOfBirth(null);
            }
            profile.setAddress(address);
            profile.setIdCardNumber(idCardNumber);
            profile.setDriverLicenseNumber(driverLicenseNumber);
            if (driverLicenseExpiryStr != null && !driverLicenseExpiryStr.isEmpty()) {
                profile.setDriverLicenseExpiry(LocalDate.parse(driverLicenseExpiryStr));
            } else {
                profile.setDriverLicenseExpiry(null);
            }

            // Save ID card front image
            String savedFront = saveUploadedImage(idCardFrontPart, "front", currentUser.getUserId());
            if (savedFront != null) {
                profile.setIdCardImageFront(savedFront);
            }

            // Save ID card back image
            String savedBack = saveUploadedImage(idCardBackPart, "back", currentUser.getUserId());
            if (savedBack != null) {
                profile.setIdCardImageBack(savedBack);
            }

            // Save driver license image
            String savedLicense = saveUploadedImage(licenseImagePart, "license", currentUser.getUserId());
            if (savedLicense != null) {
                profile.setDriverLicenseImage(savedLicense);
            }

            // Automatically reset verification status to PENDING when user updates profile information
            profile.setVerificationStatus("PENDING");

            // Save changes to database
            profileDAO.update(profile);

            response.sendRedirect(request.getContextPath() + "/profile?success=true");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi: " + e.getMessage());
            doGet(request, response);
        }
    }
    // Vietnamese phone number:
    // Starts with 03,05,07,08,09 and has total 10 digits
    private static final Pattern VIETNAM_PHONE_PATTERN
            = Pattern.compile("^(03|05|07|08|09)\\d{8}$");

    private boolean isValidVietnamPhone(String phone) {
        return phone != null && VIETNAM_PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    // Saves uploaded image and returns its relative path or null if no file was uploaded.
    private String saveUploadedImage(Part part, String prefix, int userId) throws Exception {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String ct = part.getContentType();
        if (!"image/png".equals(ct) && !"image/jpeg".equals(ct)) {
            return null;
        }

        String uploadDir = getServletContext().getRealPath("/uploads");
        if (uploadDir == null) {
            uploadDir = System.getProperty("user.home") + File.separator + "car-rental-uploads";
        }
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String ext = original.contains(".") ? original.substring(original.lastIndexOf('.')) : ".jpg";
        String fileName = prefix + "_" + userId + "_" + System.currentTimeMillis() + ext;

        part.write(uploadDir + File.separator + fileName);
        return "uploads/" + fileName;
    }
}
