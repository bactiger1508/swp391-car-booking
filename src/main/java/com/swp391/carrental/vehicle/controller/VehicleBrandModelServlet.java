package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.VehicleBrand;
import com.swp391.carrental.vehicle.model.VehicleModel;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: VehicleBrandModelServlet
 * Description: Manage vehicle brands & models (lookup tables used by Add/Edit Vehicle).
 */

@WebServlet(name = "VehicleBrandModelServlet", urlPatterns = {"/vehicles/brands"})
public class VehicleBrandModelServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!("ADMIN".equals(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        List<VehicleBrand> brands = vehicleService.getAllBrandsIncludingInactive();
        request.setAttribute("brands", brands);
        request.getRequestDispatcher("/WEB-INF/views/vehicle/brand-model-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!("ADMIN".equals(currentUser.getRole()))) {
            sendJsonResponse(response, false, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("addBrand".equals(action)) {
                handleAddBrand(request, response);
            } else if ("toggleBrandActive".equals(action)) {
                handleToggleBrandActive(request, response);
            } else if ("addModel".equals(action)) {
                handleAddModel(request, response);
            } else if ("toggleModelActive".equals(action)) {
                handleToggleModelActive(request, response);
            } else if ("getModels".equals(action)) {
                handleGetModelsForBrand(request, response);
            } else {
                sendJsonResponse(response, false, "Hành động không hợp lệ.");
            }
        } catch (AppException e) {
            sendJsonResponse(response, false, e.getMessage());
        } catch (Exception e) {
            sendJsonResponse(response, false, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    private void handleAddBrand(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String brandName = request.getParameter("brandName");
        vehicleService.addBrand(brandName);
        sendJsonResponse(response, true, "Đã thêm hãng xe '" + brandName.trim() + "'.");
    }

    private void handleToggleBrandActive(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int brandId = Integer.parseInt(request.getParameter("brandId"));
        boolean active = "true".equals(request.getParameter("active"));
        vehicleService.setBrandActive(brandId, active);
        sendJsonResponse(response, true, active ? "Đã hiện hãng xe." : "Đã ẩn hãng xe.");
    }

    private void handleAddModel(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int brandId = Integer.parseInt(request.getParameter("brandId"));
        String modelName = request.getParameter("modelName");
        vehicleService.addModel(brandId, modelName);
        sendJsonResponse(response, true, "Đã thêm model '" + modelName.trim() + "'.");
    }

    private void handleToggleModelActive(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int modelId = Integer.parseInt(request.getParameter("modelId"));
        boolean active = "true".equals(request.getParameter("active"));
        vehicleService.setModelActive(modelId, active);
        sendJsonResponse(response, true, active ? "Đã hiện model." : "Đã ẩn model.");
    }

    private void handleGetModelsForBrand(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int brandId = Integer.parseInt(request.getParameter("brandId"));
        List<VehicleModel> models = vehicleService.getModelsByBrandIdIncludingInactive(brandId);

        StringBuilder json = new StringBuilder("{\"success\":true,\"models\":[");
        for (int i = 0; i < models.size(); i++) {
            VehicleModel m = models.get(i);
            json.append("{")
                .append("\"modelId\":").append(m.getModelId()).append(",")
                .append("\"modelName\":\"").append(escapeJson(m.getModelName())).append("\",")
                .append("\"isActive\":").append(m.isActive())
                .append("}");
            if (i < models.size() - 1) json.append(",");
        }
        json.append("]}");

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(json.toString());
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        String json = "{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}";
        if (!success) {
            json = json.replace("\"message\"", "\"error\"");
        }
        response.getWriter().write(json);
    }
}
