package com.swp391.carrental.vehicle.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.dao.VehicleImageDAO;
import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.dao.VehicleBrandDAO;
import com.swp391.carrental.vehicle.dao.VehicleModelDAO;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.model.VehicleImage;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;
import com.swp391.carrental.vehicle.model.VehicleBrand;
import com.swp391.carrental.vehicle.model.VehicleModel;

/*
 * Name: VehicleService
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for VehicleService.
 */



/**
 * Service for vehicle management operations.
 */
public class VehicleService {

    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final VehicleImageDAO carImageDAO = new VehicleImageDAO();
    private final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    private final VehicleBrandDAO vehicleBrandDAO = new VehicleBrandDAO();
    private final VehicleModelDAO vehicleModelDAO = new VehicleModelDAO();
    private final FeeCalculator feeCalculator = new FeeCalculator();
    private final PolicyService policyService = new PolicyService();

    /** Returns every active vehicle brand. */
    public List<VehicleBrand> getAllBrands() {
        try {
            return vehicleBrandDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle brands.", e);
        }
    }

    /** Returns every active model of a brand. */
    public List<VehicleModel> getModelsByBrandId(int brandId) {
        try {
            return vehicleModelDAO.findByBrandId(brandId);
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle models.", e);
        }
    }

    /** Returns every vehicle brand, active or not (for admin management screens). */
    public List<VehicleBrand> getAllBrandsIncludingInactive() {
        try {
            return vehicleBrandDAO.findAllIncludingInactive();
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle brands.", e);
        }
    }

    /** Returns every model of a brand, active or not (for admin management screens). */
    public List<VehicleModel> getModelsByBrandIdIncludingInactive(int brandId) {
        try {
            return vehicleModelDAO.findByBrandIdIncludingInactive(brandId);
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle models.", e);
        }
    }

    /** Adds a new vehicle brand after validating the name is non-empty and not a duplicate. */
    public int addBrand(String brandName) {
        try {
            if (brandName == null || brandName.trim().isEmpty()) {
                throw new AppException("Tên hãng xe không được trống.");
            }
            String trimmed = brandName.trim();
            if (vehicleBrandDAO.findByName(trimmed) != null) {
                throw new AppException("Hãng xe '" + trimmed + "' đã tồn tại.");
            }
            return vehicleBrandDAO.insert(trimmed);
        } catch (SQLException e) {
            throw new AppException("Failed to add vehicle brand.", e);
        }
    }

    /** Activates or deactivates (hides) a vehicle brand. */
    public void setBrandActive(int brandId, boolean active) {
        try {
            vehicleBrandDAO.updateActive(brandId, active);
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle brand.", e);
        }
    }

    /** Adds a new model under a brand after validating the brand exists and the model name is not a duplicate. */
    public int addModel(int brandId, String modelName) {
        try {
            if (modelName == null || modelName.trim().isEmpty()) {
                throw new AppException("Tên model không được trống.");
            }
            if (vehicleBrandDAO.findById(brandId) == null) {
                throw new AppException("Hãng xe không tồn tại.");
            }
            String trimmed = modelName.trim();
            if (vehicleModelDAO.findByBrandAndName(brandId, trimmed) != null) {
                throw new AppException("Model '" + trimmed + "' đã tồn tại cho hãng xe này.");
            }
            return vehicleModelDAO.insert(brandId, trimmed);
        } catch (SQLException e) {
            throw new AppException("Failed to add vehicle model.", e);
        }
    }

    /** Activates or deactivates (hides) a vehicle model. */
    public void setModelActive(int modelId, boolean active) {
        try {
            vehicleModelDAO.updateActive(modelId, active);
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle model.", e);
        }
    }

    /** Returns a vehicle by id, with its primary image URL resolved, or {@code null} if not found. */
    public Vehicle getVehicleById(int vehicleId) {
        try {
            Vehicle car = vehicleDAO.findById(vehicleId);
            if (car != null) {
                car.setPrimaryImageUrl(resolvePrimaryImageUrl(car.getVehicleId()));
            }
            return car;
        } catch (SQLException e) {
            throw new AppException("Failed to get car.", e);
        }
    }

    /** Returns a vehicle by license plate, with its primary image URL resolved, or {@code null} if not found. */
    public Vehicle getVehicleByLicensePlate(String licensePlate) {
        try {
            Vehicle car = vehicleDAO.findByLicensePlate(licensePlate);
            if (car != null) {
                car.setPrimaryImageUrl(resolvePrimaryImageUrl(car.getVehicleId()));
            }
            return car;
        } catch (SQLException e) {
            throw new AppException("Failed to get car by license plate.", e);
        }
    }

    /** Returns every vehicle, with primary image URLs resolved. */
    public List<Vehicle> getAllVehicles() {
        try {
            List<Vehicle> list = vehicleDAO.findAll();
            populatePrimaryImages(list);
            return list;
        } catch (SQLException e) {
            throw new AppException("Failed to get cars.", e);
        }
    }

    /** Returns every vehicle with the given status, with primary image URLs resolved. */
    public List<Vehicle> getVehiclesByStatus(String status) {
        try {
            List<Vehicle> list = vehicleDAO.findByStatus(status);
            populatePrimaryImages(list);
            return list;
        } catch (SQLException e) {
            throw new AppException("Failed to get cars by status.", e);
        }
    }

    /** Resolves and sets the primary image URL on every vehicle in the list, in place. */
    private void populatePrimaryImages(List<Vehicle> list) {
        if (list != null) {
            for (Vehicle v : list) {
                if (v != null) {
                    v.setPrimaryImageUrl(resolvePrimaryImageUrl(v.getVehicleId()));
                }
            }
        }
    }

    /** Returns every image of a vehicle, primary image first. */
    public List<VehicleImage> getVehicleImages(int vehicleId) {
        try {
            return carImageDAO.findByVehicleId(vehicleId);
        } catch (SQLException e) {
            throw new AppException("Failed to get car images.", e);
        }
    }

    /** Inserts a new vehicle and returns its generated id. */
    public int addVehicle(Vehicle car) {
        try {
            return vehicleDAO.insert(car);
        } catch (SQLException e) {
            throw new AppException("Failed to add car.", e);
        }
    }

    /** Updates every editable field of an existing vehicle. */
    public boolean updateVehicle(Vehicle car) {
        try {
            return vehicleDAO.update(car);
        } catch (SQLException e) {
            throw new AppException("Failed to update car.", e);
        }
    }

    /** Updates only a vehicle's status (AVAILABLE, RENTED, MAINTENANCE, INACTIVE). */
    public boolean updateVehicleStatus(int vehicleId, String status) {
        try {
            // BR-09: Validate status transitions if needed
            return vehicleDAO.updateStatus(vehicleId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update car status.", e);
        }
    }

    /** Permanently deletes a vehicle and its images/maintenance history; fails with a friendly message if still referenced by bookings/contracts. */
    public boolean deleteVehicle(int vehicleId) {
        try {
            carImageDAO.deleteByVehicleId(vehicleId);
            maintenanceDAO.deleteByVehicleId(vehicleId);
            return vehicleDAO.delete(vehicleId);
        } catch (SQLException e) {
            if (e.getErrorCode() == 547) {
                // SQL Server FK violation: car still referenced by bookings/contracts/handovers/returns/reviews
                throw new AppException("Không thể xóa xe này vì đã có lịch sử đặt xe, hợp đồng hoặc giao/nhận xe. "
                        + "Vui lòng chuyển trạng thái xe sang 'Ngừng hoạt động' thay vì xóa.", e);
            }
            throw new AppException("Failed to delete car.", e);
        }
    }

    /** Calculates the one-day deposit amount for a given daily rental rate, per current fee policy. */
    public BigDecimal calculateOneDayDeposit(BigDecimal dailyRate) {
        return feeCalculator.calculateDeposit(dailyRate);
    }

    /** Returns the configured deposit percentage policy value (defaults to "30" if unset). */
    public String getDepositPercentage() {
        return policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
    }

    /** Returns a map of vehicleId to resolved primary image URL, for a list of vehicles. */
    public Map<Integer, String> getPrimaryImageUrls(List<Vehicle> cars) {
        Map<Integer, String> urls = new HashMap<>();
        if (cars == null) return urls;
        for (Vehicle car : cars) {
            if (car == null) continue;
            String url = resolvePrimaryImageUrl(car.getVehicleId());
            urls.put(car.getVehicleId(), url);
        }
        return urls;
    }

    /** Resolves the display URL of a vehicle's primary image, falling back to any image, then a placeholder. */
    public String resolvePrimaryImageUrl(int vehicleId) {
        List<VehicleImage> images = getVehicleImages(vehicleId);
        if (images != null) {
            for (VehicleImage image : images) {
                if (image != null && image.isPrimary() && image.getImageUrl() != null && !image.getImageUrl().trim().isEmpty()) {
                    return formatImageUrl(image.getImageUrl());
                }
            }
            for (VehicleImage image : images) {
                if (image != null && image.getImageUrl() != null && !image.getImageUrl().trim().isEmpty()) {
                    return formatImageUrl(image.getImageUrl());
                }
            }
        }
        return "/assets/images/vehicles/placeholder.jpg";
    }

    /** Normalizes an image URL to an absolute path or external URL, falling back to a placeholder. */
    private String formatImageUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return "/assets/images/vehicles/placeholder.jpg";
        }
        String trimmed = url.trim();
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            return trimmed;
        }
        if (!trimmed.startsWith("/")) {
            trimmed = "/" + trimmed;
        }
        return trimmed;
    }

    /** Returns, per vehicle, the earliest still-SCHEDULED maintenance job (for dashboard display). */
    public Map<Integer, MaintenanceSchedule> getNextScheduledMaintenanceByVehicle() {
        try {
            Map<Integer, MaintenanceSchedule> nextByVehicle = new HashMap<>();
            for (MaintenanceSchedule schedule : maintenanceDAO.getAllMaintenanceSchedules()) {
                if (!"SCHEDULED".equals(schedule.getStatus())) {
                    continue;
                }
                MaintenanceSchedule existing = nextByVehicle.get(schedule.getVehicleId());
                if (existing == null || schedule.getScheduledDate().isBefore(existing.getScheduledDate())) {
                    nextByVehicle.put(schedule.getVehicleId(), schedule);
                }
            }
            return nextByVehicle;
        } catch (SQLException e) {
            throw new AppException("Failed to get maintenance schedules.", e);
        }
    }

    // Image management

    /** Adds a new image for a vehicle and returns its generated id. */
    public int addVehicleImage(VehicleImage image) {
        try {
            return carImageDAO.insert(image);
        } catch (SQLException e) {
            throw new AppException("Failed to add vehicle image.", e);
        }
    }

    /** Deletes a single vehicle image by id. */
    public boolean deleteCarImage(int imageId) {
        try {
            return carImageDAO.delete(imageId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete car image.", e);
        }
    }

    /** Sets an image as the vehicle's primary display image, clearing any previous primary. */
    public boolean setPrimaryImage(int vehicleId, int imageId) {
        try {
            carImageDAO.clearPrimaryByVehicleId(vehicleId);
            return carImageDAO.setPrimary(imageId, true);
        } catch (SQLException e) {
            throw new AppException("Failed to set primary image.", e);
        }
    }

    /** Clears the primary flag on every image of a vehicle. */
    public void clearPrimaryImages(int vehicleId) {
        try {
            carImageDAO.clearPrimaryByVehicleId(vehicleId);
        } catch (SQLException e) {
            throw new AppException("Failed to clear primary images.", e);
        }
    }

    // Maintenance management

    /** Returns every maintenance schedule of a vehicle. */
    public List<MaintenanceSchedule> getMaintenanceByVehicleId(int vehicleId) {
        try {
            return maintenanceDAO.getMaintenanceByVehicle(vehicleId);
        } catch (SQLException e) {
            throw new AppException("Failed to get maintenance schedules.", e);
        }
    }

    /** Creates a new maintenance schedule and puts the vehicle into MAINTENANCE status. */
    public int addMaintenanceSchedule(MaintenanceSchedule schedule) {
        try {
            int maintenanceId = maintenanceDAO.createMaintenance(schedule);
            if (maintenanceId > 0) {
                // Vehicle goes into maintenance as soon as a job is scheduled for it.
                vehicleDAO.updateStatus(schedule.getVehicleId(), "MAINTENANCE");
            }
            return maintenanceId;
        } catch (SQLException e) {
            throw new AppException("Failed to add maintenance schedule.", e);
        }
    }

    /**
     * Transition a maintenance job's status (SCHEDULED -> IN_PROGRESS -> COMPLETED, or -> CANCELLED)
     * and keep the vehicle's status in sync: COMPLETED/CANCELLED releases the vehicle back to
     * AVAILABLE only if no other job for that vehicle is still SCHEDULED/IN_PROGRESS.
     */
    public void updateMaintenanceStatus(int maintenanceId, String newStatus, String updatedBy) {
        try {
            MaintenanceSchedule schedule = maintenanceDAO.getMaintenanceById(maintenanceId);
            if (schedule == null) {
                throw new AppException("Bản ghi bảo trì không tồn tại.");
            }

            boolean updated;
            if ("COMPLETED".equals(newStatus)) {
                updated = maintenanceDAO.completeMaintenance(maintenanceId, updatedBy);
            } else if ("CANCELLED".equals(newStatus)) {
                updated = maintenanceDAO.cancelMaintenance(maintenanceId, updatedBy);
            } else {
                updated = maintenanceDAO.updateStatus(maintenanceId, newStatus, updatedBy);
            }

            if (!updated) {
                throw new AppException("Không thể cập nhật trạng thái bảo trì.");
            }

            if ("COMPLETED".equals(newStatus) || "CANCELLED".equals(newStatus)) {
                boolean hasOtherActiveJob = maintenanceDAO.getMaintenanceByVehicle(schedule.getVehicleId()).stream()
                        .anyMatch(m -> m.getMaintenanceId() != maintenanceId
                                && ("SCHEDULED".equals(m.getStatus()) || "IN_PROGRESS".equals(m.getStatus())));
                if (!hasOtherActiveJob) {
                    vehicleDAO.updateStatus(schedule.getVehicleId(), "AVAILABLE");
                }
            } else if ("IN_PROGRESS".equals(newStatus)) {
                vehicleDAO.updateStatus(schedule.getVehicleId(), "MAINTENANCE");
            }
        } catch (SQLException e) {
            throw new AppException("Failed to update maintenance status.", e);
        }
    }

}
