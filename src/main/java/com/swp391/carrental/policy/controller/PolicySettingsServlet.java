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
 * Created: 23/05/2026 
 * Description: Controller handling HTTP GET and POST requests for viewing, creating, and updating system policies.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.3 (21/06/2026): feat: standard combo packages, dynamic tet surcharge and ...
 * - v1.4 (17/07/2026): UpdUpdate PolicySettingsServlet
 * - v1.5 (17/07/2026): feat: refine payment and policy settings configuration
 * - v1.6 (17/07/2026): docs(convention): update header comments and versions for...
 * - v1.7 (23/07/2026): Added Javadoc and method comments.
 */
@WebServlet(name = "PolicySettingsServlet", urlPatterns = { "/policies" })
public class PolicySettingsServlet extends HttpServlet {
    private final PolicyService policyService = new PolicyService();

    /**
     * Handles HTTP GET requests to display policy settings list.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("policies", policyService.getAllPolicies());
        request.getRequestDispatcher("/WEB-INF/views/policy/policy-settings.jsp").forward(request, response);
    }

    /**
     * Handles HTTP POST requests to create or update a system policy setting.
     */
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
