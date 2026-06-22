package com.swp391.carrental.user.controller;

import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.CustomerProfile;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.VerifyCustomerProfileService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Verify Customer Profile Controller
 */
@WebServlet("/user/customer-profiles")
public class VerifyCustomerProfileServlet extends HttpServlet {

    private final VerifyCustomerProfileService service
            = new VerifyCustomerProfileService();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser
                = (User) request.getSession().getAttribute("currentUser");

        if (currentUser == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login");
            return;

        }

        if (!"STAFF".equals(currentUser.getRole())
                && !"ADMIN".equals(currentUser.getRole())) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN);

            return;

        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }

        try {

            switch (action) {

                case "view":
                    showDetail(request, response);
                    break;

                default:
                    showList(request, response);
                    break;

            }

        } catch (AppException e) {

            request.setAttribute("error", e.getMessage());

            showList(request, response);

        }

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser
                = (User) request.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        int profileId
                = Integer.parseInt(request.getParameter("profileId"));

        try {

            if ("verify".equals(action)) {

                service.verifyProfile(
                        profileId,
                        currentUser.getUserId());

                response.sendRedirect(
                        request.getContextPath()
                        + "/user/customer-profiles?success=verified");

            } else if ("reject".equals(action)) {

                service.rejectProfile(
                        profileId,
                        currentUser.getUserId());

                response.sendRedirect(
                        request.getContextPath()
                        + "/user/customer-profiles?success=rejected");

            }

        } catch (AppException e) {
            try {
                CustomerProfile profile = service.getProfile(profileId);
                request.setAttribute("profile", profile);
                request.setAttribute("customerName", service.getCustomerName(profile.getUserId()));
                request.setAttribute("customerEmail", service.getCustomerEmail(profile.getUserId()));
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/WEB-INF/views/user/customer-profile-detail.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/user/customer-profiles?error=SystemError");
            }
        }
    }

    // Display list
    private void showList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");

        String status = request.getParameter("status");

        List<CustomerProfile> profiles;

        if (keyword != null && !keyword.trim().isEmpty()) {

            profiles = service.searchProfiles(keyword);

        } else if (status != null && !status.isEmpty()) {

            profiles = service.getProfilesByStatus(status);

        } else {

            profiles = service.getAllProfiles();

        }

        request.setAttribute("profiles", profiles);

        request.getRequestDispatcher(
                "/WEB-INF/views/user/customer-profile-management.jsp")
                .forward(request, response);

    }

    // View detail
    private void showDetail(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int profileId
                = Integer.parseInt(request.getParameter("id"));

        CustomerProfile profile
                = service.getProfile(profileId);

        request.setAttribute("profile", profile);

        request.setAttribute(
                "customerName",
                service.getCustomerName(profile.getUserId()));

        request.setAttribute(
                "customerEmail",
                service.getCustomerEmail(profile.getUserId()));

        request.getRequestDispatcher(
                "/WEB-INF/views/user/customer-profile-detail.jsp")
                .forward(request, response);

    }

}
