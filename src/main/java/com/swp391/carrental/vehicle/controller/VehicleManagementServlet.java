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
import com.swp391.carrental.audit.service.AuditLogService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.model.CarImage;
import com.swp391.carrental.vehicle.model.VehicleModel;
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
    private final AuditLogService auditLogService = new AuditLogService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getCarImages".equals(action)) {
            handleGetCarImages(request, response);
            return;
        }

        if ("getModelsByBrand".equals(action)) {
            handleGetModelsByBrand(request, response);
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
        request.setAttribute("brands", vehicleService.getAllBrands());
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
        boolean isAjax = "create".equals(action) || "update".equals(action) || "delete".equals(action) || "hide".equals(action) || "show".equals(action);

        try {
            if ("create".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "ADD_VEHICLE")) {
                    if (isAjax) {
                        sendJsonResponse(response, false, "Bạn không có quyền thêm xe mới.");
                    } else {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    }
                    return;
                }
                handleCreateCar(request, response, currentUser);
                if (isAjax) {
                    sendJsonResponse(response, true, "Tạo xe thành công!");
                } else {
                    response.sendRedirect(request.getContextPath() + "/vehicles/manage");
                }
            } else if ("update".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "EDIT_VEHICLE")) {
                    if (isAjax) {
                        sendJsonResponse(response, false, "Bạn không có quyền chỉnh sửa thông tin xe.");
                    } else {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    }
                    return;
                }
                handleUpdateCar(request, response, currentUser);
                if (isAjax) {
                    sendJsonResponse(response, true, "Cập nhật xe thành công!");
                } else {
                    response.sendRedirect(request.getContextPath() + "/vehicles/manage");
                }
            } else if ("delete".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "DELETE_VEHICLE")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                handleDeleteCar(request, response, currentUser);
                sendJsonResponse(response, true, "Xóa xe thành công!");
            } else if ("hide".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "EDIT_VEHICLE")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                handleHideCar(request, response, currentUser);
                sendJsonResponse(response, true, "Ẩn xe thành công!");
            } else if ("show".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "EDIT_VEHICLE")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                handleShowCar(request, response, currentUser);
                sendJsonResponse(response, true, "Hiện xe thành công!");
            } else if ("deleteImage".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "EDIT_VEHICLE")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                handleDeleteImage(request, response);
            } else if ("setPrimaryImage".equals(action)) {
                if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "EDIT_VEHICLE")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
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
        } catch (Exception e) {
            if (isAjax) {
                sendJsonResponse(response, false, "Lỗi hệ thống: " + e.getMessage());
            } else {
                request.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
                doGet(request, response);
            }
        }
    }

    // Creates new vehicle with validation, license plate uniqueness check, and image upload handling.
    private void handleCreateCar(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String licensePlate = request.getParameter("licensePlate");

        if (licensePlate == null || licensePlate.trim().isEmpty()) {
            throw new AppException("Biển số xe không được trống.");
        }

        Car existingCar = vehicleService.getCarByLicensePlate(licensePlate.trim());
        if (existingCar != null) {
            throw new AppException("Biển số xe '" + licensePlate + "' đã tồn tại. Vui lòng sử dụng biển số khác.");
        }

        String modelIdStr = request.getParameter("modelId");
        if (modelIdStr == null || modelIdStr.trim().isEmpty()) {
            throw new AppException("Vui lòng chọn hãng xe và mẫu xe.");
        }

        Car car = new Car();
        car.setLicensePlate(licensePlate.trim());
        car.setModelId(Integer.parseInt(modelIdStr.trim()));
        car.setYear(Integer.parseInt(request.getParameter("year")));
        car.setColor(request.getParameter("color"));
        car.setSeats(Integer.parseInt(request.getParameter("seats")));
        car.setTransmission(request.getParameter("transmission"));
        car.setFuelType(request.getParameter("fuelType"));
        BigDecimal dailyRate = new BigDecimal(request.getParameter("dailyRate"));
        if (dailyRate.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Giá thuê phải lớn hơn 0.");
        }
        car.setDailyRate(dailyRate);
        car.setDescription(request.getParameter("description"));
        car.setLocation(request.getParameter("location"));
        car.setFeatures(request.getParameter("features"));
        car.setStatus(request.getParameter("status") != null ? request.getParameter("status") : "AVAILABLE");
        
        String mileageStr = request.getParameter("mileage");
        int mileage = 0;
        if (mileageStr != null && !mileageStr.trim().isEmpty()) {
            mileage = Integer.parseInt(mileageStr.trim());
        }
        car.setMileage(mileage);

        int carId = vehicleService.addCar(car);

        // Handle image uploads
        try {
            saveSingleImage(carId, request, "primaryImage", true);
            saveMultipleImages(carId, request, "secondaryImages");
        } catch (Exception e) {
            System.err.println("Error uploading images for car " + carId + ": " + e.getMessage());
            e.printStackTrace();
            throw new AppException("Lỗi khi upload ảnh: " + e.getMessage(), e);
        }

        Car created = vehicleService.getCarById(carId);
        String carName = created != null ? (created.getBrand() + " " + created.getModel()) : "";
        logVehicleAudit(request, currentUser, "CREATE", carId,
                "Tạo mới xe " + carName + " - Biển số " + licensePlate.trim() + " (#" + carId + ")");
    }

    // Updates vehicle details with license plate uniqueness check and image management (add/remove/reorder).
    private void handleUpdateCar(HttpServletRequest request, HttpServletResponse response, User currentUser)
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

        String modelIdStr = request.getParameter("modelId");
        if (modelIdStr == null || modelIdStr.trim().isEmpty()) {
            throw new AppException("Vui lòng chọn hãng xe và mẫu xe.");
        }

        car.setLicensePlate(licensePlate);
        car.setModelId(Integer.parseInt(modelIdStr.trim()));
        car.setYear(Integer.parseInt(request.getParameter("year")));
        car.setColor(request.getParameter("color"));
        car.setSeats(Integer.parseInt(request.getParameter("seats")));
        car.setTransmission(request.getParameter("transmission"));
        car.setFuelType(request.getParameter("fuelType"));
        BigDecimal dailyRate = new BigDecimal(request.getParameter("dailyRate"));
        if (dailyRate.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Giá thuê phải lớn hơn 0.");
        }
        car.setDailyRate(dailyRate);
        car.setDescription(request.getParameter("description"));
        car.setLocation(request.getParameter("location"));
        car.setFeatures(request.getParameter("features"));
        car.setStatus(request.getParameter("status"));

        String mileageStr = request.getParameter("mileage");
        int mileage = car.getMileage();
        if (mileageStr != null && !mileageStr.trim().isEmpty()) {
            mileage = Integer.parseInt(mileageStr.trim());
        }
        car.setMileage(mileage);

        vehicleService.updateCar(car);

        // Handle new image uploads
        try {
            saveSingleImage(carId, request, "newPrimaryImage", true);
            saveMultipleImages(carId, request, "newSecondaryImages");
        } catch (Exception e) {
            System.err.println("Error uploading images for car " + carId + ": " + e.getMessage());
            e.printStackTrace();
            throw new AppException("Lỗi khi upload ảnh: " + e.getMessage(), e);
        }

        Car updatedCar = vehicleService.getCarById(carId);
        String carName = updatedCar != null ? (updatedCar.getBrand() + " " + updatedCar.getModel()) : "";
        logVehicleAudit(request, currentUser, "UPDATE", carId,
                "Cập nhật xe " + carName + " - Biển số " + licensePlate + " (#" + carId + ")");
    }

    // Deletes vehicle permanently (ADMIN only, cannot delete RENTED vehicles).
    private void handleDeleteCar(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        // Only ADMIN can delete vehicles
        if (!"ADMIN".equals(currentUser.getRole())) {
            throw new AppException("Chỉ quản trị viên mới được phép xóa xe. STAFF có thể ẩn xe bằng nút 'Ẩn'.");
        }

        int carId = Integer.parseInt(request.getParameter("carId"));

        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            throw new AppException("Xe không tồn tại.");
        }

        // Cannot delete rented vehicles
        if ("RENTED".equals(car.getStatus())) {
            throw new AppException("Không thể xóa xe đã cho thuê. Chỉ có thể ẩn xe bằng nút 'Ẩn'.");
        }

        String carName = car.getBrand() + " " + car.getModel();
        String licensePlate = car.getLicensePlate();

        boolean deleted = vehicleService.deleteCar(carId);
        if (!deleted) {
            throw new AppException("Không tìm thấy xe để xóa.");
        }

        logVehicleAudit(request, currentUser, "DELETE", carId,
                "Xóa xe " + carName + " - Biển số " + licensePlate + " (#" + carId + ")");
    }

    // Hides vehicle by setting status to INACTIVE (invisible to customers, staff can still manage).
    private void handleHideCar(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        int carId = Integer.parseInt(request.getParameter("carId"));

        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            throw new AppException("Xe không tồn tại.");
        }

        String carName = car.getBrand() + " " + car.getModel();
        String licensePlate = car.getLicensePlate();

        // Update car status to INACTIVE
        boolean updated = vehicleService.updateCarStatus(carId, "INACTIVE");
        if (!updated) {
            throw new AppException("Không thể ẩn xe.");
        }

        logVehicleAudit(request, currentUser, "HIDE", carId,
                "Ẩn xe " + carName + " - Biển số " + licensePlate + " (#" + carId + ")");
    }

    // Shows hidden vehicle by setting status to AVAILABLE (makes it visible to customers again).
    private void handleShowCar(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        int carId = Integer.parseInt(request.getParameter("carId"));

        Car car = vehicleService.getCarById(carId);
        if (car == null) {
            throw new AppException("Xe không tồn tại.");
        }

        String carName = car.getBrand() + " " + car.getModel();
        String licensePlate = car.getLicensePlate();

        // Update car status to AVAILABLE
        boolean updated = vehicleService.updateCarStatus(carId, "AVAILABLE");
        if (!updated) {
            throw new AppException("Không thể hiện xe.");
        }

        logVehicleAudit(request, currentUser, "SHOW", carId,
                "Hiện xe " + carName + " - Biển số " + licensePlate + " (#" + carId + ")");
    }

    // Records vehicle audit entry with rich details (name, plate) and prevents duplicate logging.
    private void logVehicleAudit(HttpServletRequest request, User currentUser, String action, int carId, String description) {
        auditLogService.logAction(currentUser.getUserId(), action, "VEHICLE", carId, description);
        request.setAttribute("auditLogged", Boolean.TRUE);
    }

    // Resolves upload directory path for vehicle images and creates it if missing.
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

        // Copy to target/deployment directory (so it is visible immediately in the running app)
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, filePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
        }

        // Also duplicate to source directory src/main/webapp (so it is persisted in the codebase)
        try {
            String realPath = getServletContext().getRealPath("");
            if (realPath != null && realPath.contains("target")) {
                String srcPathStr = realPath.substring(0, realPath.indexOf("target")) + "src/main/webapp/assets/images/cars";
                Path srcPath = Paths.get(srcPathStr);
                if (Files.exists(srcPath.getParent())) {
                    if (!Files.exists(srcPath)) {
                        Files.createDirectories(srcPath);
                    }
                    Path srcFilePath = srcPath.resolve(uniqueFileName);
                    Files.copy(filePath, srcFilePath, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                }
            }
        } catch (Exception e) {
            System.err.println("[VehicleManagementServlet] Failed to duplicate upload to source folder: " + e.getMessage());
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

    // Retrieves vehicle images as JSON for image management modal display.
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

    // Retrieves vehicle models for selected brand as JSON for form dropdown population.
    private void handleGetModelsByBrand(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String brandIdStr = request.getParameter("brandId");
        response.setContentType("application/json; charset=UTF-8");

        if (brandIdStr == null || brandIdStr.isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        try {
            int brandId = Integer.parseInt(brandIdStr);
            List<VehicleModel> models = vehicleService.getModelsByBrandId(brandId);

            if (models == null) {
                models = new java.util.ArrayList<>();
            }

            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < models.size(); i++) {
                VehicleModel m = models.get(i);
                json.append("{")
                    .append("\"modelId\":").append(m.getModelId()).append(",")
                    .append("\"modelName\":\"").append(escapeJson(m.getModelName())).append("\"")
                    .append("}");
                if (i < models.size() - 1) json.append(",");
            }
            json.append("]");

            response.getWriter().write(json.toString());
        } catch (Exception e) {
            System.err.println("Error loading models for brand " + brandIdStr + ": " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    // Deletes vehicle image file from storage and removes record from database.
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

    // Sets selected image as primary vehicle display image for catalog listings.
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

    // Escapes special characters in text for safe JSON response output (prevents XSS).
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
