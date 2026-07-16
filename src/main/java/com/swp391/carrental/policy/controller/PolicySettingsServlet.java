package com.swp391.carrental.policy.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.constant.Role;

/*
 * Name: PolicySettingsServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for PolicySettingsServlet.
 */

@WebServlet(name = "PolicySettingsServlet", urlPatterns = { "/policies" })
public class PolicySettingsServlet extends HttpServlet {
    private final PolicyService policyService = new PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("policies", policyService.getAllPolicies());
        request.getRequestDispatcher("/WEB-INF/views/policy/policy-settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || (!Role.ADMIN.equals(user.getRole()) && !Role.STAFF.equals(user.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");

        if ("create".equalsIgnoreCase(action)) {
            String policyKey = request.getParameter("policyKey");
            String policyValue = request.getParameter("policyValue");
            String description = request.getParameter("description");
            String category = request.getParameter("category");

            if (policyKey != null && !policyKey.trim().isEmpty() && policyValue != null && !policyValue.trim().isEmpty()) {
                try {
                    com.swp391.carrental.policy.model.PolicySetting ps = new com.swp391.carrental.policy.model.PolicySetting();
                    ps.setPolicyKey(policyKey.trim().toUpperCase());
                    ps.setPolicyValue(policyValue.trim());
                    ps.setDescription(description != null ? description.trim() : "");
                    ps.setCategory(category != null ? category.trim().toUpperCase() : "GENERAL");
                    ps.setUpdatedBy(user.getUserId());

                    policyService.deletePolicy(0); // Dummy check/dummy operation to keep service import if needed
                    com.swp391.carrental.policy.dao.PolicySettingDAO dao = new com.swp391.carrental.policy.dao.PolicySettingDAO();
                    dao.insert(ps);

                    request.getSession().setAttribute("successMessage", "Tạo chính sách mới '" + policyKey.toUpperCase() + "' thành công!");
                } catch (Exception e) {
                    request.getSession().setAttribute("errorMessage", "Lỗi khi tạo chính sách: " + e.getMessage());
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Các trường mã chính sách và giá trị không được rỗng.");
            }
        } else {
            String policyKey = request.getParameter("policyKey");
            String policyValue = request.getParameter("policyValue");

            if (policyKey != null && !policyKey.trim().isEmpty() && policyValue != null && !policyValue.trim().isEmpty()) {
                try {
                    policyService.updatePolicy(policyKey.trim(), policyValue.trim(), user.getUserId());
                    request.getSession().setAttribute("successMessage", "Cập nhật chính sách '" + policyKey + "' thành công!");
                } catch (Exception e) {
                    request.getSession().setAttribute("errorMessage", "Lỗi cập nhật: " + e.getMessage());
                }
            } else {
                request.getSession().setAttribute("errorMessage", "Dữ liệu không được để trống.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/policies");
    }
}
