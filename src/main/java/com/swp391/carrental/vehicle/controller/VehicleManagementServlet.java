package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.model.CarImage;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: VehicleManagementServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Manage vehicles (CRUD operations for staff/admin).
 */

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 50 * 1024 * 1024
)
@WebServlet(name = "VehicleManagementServlet", urlPatterns = {"/vehicles/manage"})
public class VehicleManagementServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getCarImages".equals(action)) {
            handleGetCarImages(request, response);
            return;
        }

        List<Car> cars = vehicleService.getAllCars();

        Map<Integer, BigDecimal> depositAmounts = new HashMap<>();
        for (Car car : cars) {
            depositAmounts.put(car.getCarId(), vehicleService.calculateOneDayDeposit(car.getDailyRate()));
        }

        request.setAttribute("cars", cars);
        request.setAttribute("depositAmounts", depositAmounts);
        request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
        request.setAttribute("nextMaintenance", vehicleService.getNextScheduledMaintenanceByCar());
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(cars));
        request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) (session != null ? session.getAttribute("currentUser") : null);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        boolean isAjax = "create".equals(action) || "update".equals(action);

        try {
            if ("create".equals(action)) {
                handleCreateCar(request, response);
                if (isAjax) {
                    sendJsonResponse(response, true, "Tạo xe thành công!");
                } else {
                    response.sendRedirect(request.getContextPath() + "/vehicles/manage");
                }
            } else if ("update".equals(action)) {
                handleUpdateCar(request, response);
                if (isAjax) {
                    sendJsonResponse(response, true, "Cập nhật xe thành công!");
                } else {
                    response.sendRedirect(request.getContextPath() + "/vehicles/manage");
                }
            } else if ("delete".equals(action)) {
                handleDeleteCar(request, response);
            } else if ("deleteImage".equals(action)) {
                handleDeleteImage(request, response);
            } else if ("setPrimaryImage".equals(action)) {
                handleSetPrimaryImage(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/vehicles/manage");
            }
        } catch (AppException e) {
            if (isAjax) {
                sendJsonResponse(response, false, e.getMessage());
            } else {
                request.setAttribute("error", e.getMessage());
                doGet(request, response);
            }
        }
    }

    private void handleCreateCar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String licensePlate = request.getParameter("licensePlate");

        if (licensePlate == null || licensePlate.trim().isEmpty()) {
            throw new AppException("Biển số xe không được trống.");
        }

        Car existingCar = vehicleService.getCarByLicensePlate(licensePlate.trim());
        if (existingCar != null) {
            throw new AppException("Biển số xe '" + licensePlate + "' đã tồn tại. Vui lòng sử dụng biển số khác.");
        }

        Car car = new Car();
        car.setLicensePlate(licensePlate.trim());
        car.setBrand(request.getParameter("brand"));
        car.setModel(request.getParameter("model"));
        car.setYear(Integer.parseInt(request.getParameter("year")));
        car.setColor(request.getParameter("color"));
        car.setSeats(Integer.parseInt(request.getParameter("seats")));
        car.setTransmission(request.getParameter("transmission"));
        car.setFuelType(request.getParameter("fuelType"));
        car.setDailyRate(new BigDecimal(request.getParameter("dailyRate")));
        car.setDescription(request.getParameter("description"));
        car.setLocation(request.getParameter("location"));
        car.setFeatures(request.getParameter("features"));
        car.setStatus(request.getParameter("status") != null ? request.getParameter("status") : "AVAILABLE");
        car.setMileage(Integer.parseInt(request.getParameter("mileage") != null ? request.getParameter("mileage") : "0"));

        int carId = vehicleService.addCar(car);

        // Handle image uploads
        try {
            saveSingleImage(carId, request, "primaryImage", true);
            saveMultipleImages(carId, request, "secondaryImages");
        } catch (Exception e) {
            // Continue even if image upload fails
        }

        request.setAttribute("success", "Tạo xe thành công!");
        response.sendRedirect(request.getContextPath() + "/vehicles/manage");
    }

    private void handleUpdateCar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int carId = Integer.parseInt(request.getParameter("carId"));
        Car car = vehicleService.getCarById(carId);

        if (car == null) {
            throw new AppException("Xe không tồn tại.");
        }

        String licensePlate = request.getParameter("licensePlate");
        if (licensePlate == null || licensePlate.trim().isEmpty()) {
            throw new AppException("Biển số xe không được trống.");
        }

        licensePlate = licensePlate.trim();
        if (!licensePlate.equals(car.getLicensePlate())) {
            Car existingCar = vehicleService.getCarByLicensePlate(licensePlate);
            if (existingCar != null) {
                throw new AppException("Biển số xe '" + licensePlate + "' đã tồn tại. Vui lòng sử dụng biển số khác.");
            }
        }

        car.setLicensePlate(licensePlate);
        car.setBrand(request.getParameter("brand"));
        car.setModel(request.getParameter("model"));
        car.setYear(Integer.parseInt(request.getParameter("year")));
        car.setColor(request.getParameter("color"));
        car.setSeats(Integer.parseInt(request.getParameter("seats")));
        car.setTransmission(request.getParameter("transmission"));
        car.setFuelType(request.getParameter("fuelType"));
        car.setDailyRate(new BigDecimal(request.getParameter("dailyRate")));
        car.setDescription(request.getParameter("description"));
        car.setLocation(request.getParameter("location"));
        car.setFeatures(request.getParameter("features"));
        car.setStatus(request.getParameter("status"));
        car.setMileage(Integer.parseInt(request.getParameter("mileage")));

        boolean updated = vehicleService.updateCar(car);

        // Handle new image uploads
        try {
            saveSingleImage(carId, request, "newPrimaryImage", true);
            saveMultipleImages(carId, request, "newSecondaryImages");
        } catch (Exception e) {
            // Continue even if image upload fails
        }

        if (updated) {
            request.setAttribute("success", "Cập nhật xe thành công!");
        }
        response.sendRedirect(request.getContextPath() + "/vehicles/manage");
    }

    private void handleDeleteCar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int carId = Integer.parseInt(request.getParameter("carId"));

        boolean deleted = vehicleService.deleteCar(carId);
        if (deleted) {
            request.setAttribute("success", "Xóa xe thành công!");
        }
        response.sendRedirect(request.getContextPath() + "/vehicles/manage");
    }

    private Path resolveUploadPath() throws IOException {
        String uploadDir = getServletContext().getRealPath("") + "/assets/images/cars";
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        return uploadPath;
    }

    private CarImage storeImagePart(Part part, int carId, Path uploadPath, int sortOrder, boolean isPrimary) throws IOException {
        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String sanitizedFileName = fileName.replaceAll("[^a-zA-Z0-9._-]", "_");
        String uniqueFileName = System.currentTimeMillis() + "_" + sanitizedFileName;
        Path filePath = uploadPath.resolve(uniqueFileName);

        try (InputStream input = part.getInputStream()) {
            Files.copy(input, filePath);
        }

        CarImage image = new CarImage();
        image.setCarId(carId);
        image.setImageUrl("/assets/images/cars/" + uniqueFileName);
        image.setCaption(fileName);
        image.setPrimary(isPrimary);
        image.setSortOrder(sortOrder);
        return image;
    }

    private void saveSingleImage(int carId, HttpServletRequest request, String partName, boolean makePrimary)
            throws IOException, ServletException {
        Part part = request.getPart(partName);
        if (part == null || part.getSize() == 0) {
            return;
        }

        Path uploadPath = resolveUploadPath();
        if (makePrimary) {
            vehicleService.clearPrimaryImages(carId);
        }

        int sortOrder = vehicleService.getCarImages(carId).size();
        CarImage image = storeImagePart(part, carId, uploadPath, sortOrder, makePrimary);
        vehicleService.addCarImage(image);
    }

    private void saveMultipleImages(int carId, HttpServletRequest request, String partName)
            throws IOException, ServletException {
        Path uploadPath = resolveUploadPath();
        int sortOrder = vehicleService.getCarImages(carId).size();

        for (Part part : request.getParts()) {
            if (part.getName().equals(partName) && part.getSize() > 0) {
                CarImage image = storeImagePart(part, carId, uploadPath, sortOrder++, false);
                vehicleService.addCarImage(image);
            }
        }
    }

    private void handleGetCarImages(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String carIdStr = request.getParameter("carId");
        if (carIdStr == null || carIdStr.isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("[]");
            return;
        }

        int carId = Integer.parseInt(carIdStr);
        List<CarImage> images = vehicleService.getCarImages(carId);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < images.size(); i++) {
            CarImage img = images.get(i);
            json.append("{")
                .append("\"imageId\":").append(img.getImageId()).append(",")
                .append("\"imageUrl\":\"").append(img.getImageUrl()).append("\",")
                .append("\"caption\":\"").append(escapeJson(img.getCaption())).append("\",")
                .append("\"isPrimary\":").append(img.isPrimary())
                .append("}");
            if (i < images.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json");
        response.getWriter().write(json.toString());
    }

    private void handleDeleteImage(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String imageIdStr = request.getParameter("imageId");
        if (imageIdStr == null || imageIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int imageId = Integer.parseInt(imageIdStr);
        boolean deleted = vehicleService.deleteCarImage(imageId);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + deleted + "}");
    }

    private void handleSetPrimaryImage(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String imageIdStr = request.getParameter("imageId");
        String carIdStr = request.getParameter("carId");

        if (imageIdStr == null || carIdStr == null || imageIdStr.isEmpty() || carIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int imageId = Integer.parseInt(imageIdStr);
        int carId = Integer.parseInt(carIdStr);
        boolean success = vehicleService.setPrimaryImage(carId, imageId);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\":" + success + "}");
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
