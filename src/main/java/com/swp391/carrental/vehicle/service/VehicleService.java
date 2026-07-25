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

    public List<VehicleBrand> getAllBrands() {
        try {
            return vehicleBrandDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle brands.", e);
        }
    }

    public List<VehicleModel> getModelsByBrandId(int brandId) {
        try {
            return vehicleModelDAO.findByBrandId(brandId);
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle models.", e);
        }
    }

    public List<VehicleBrand> getAllBrandsIncludingInactive() {
        try {
            return vehicleBrandDAO.findAllIncludingInactive();
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle brands.", e);
        }
    }

    public List<VehicleModel> getModelsByBrandIdIncludingInactive(int brandId) {
        try {
            return vehicleModelDAO.findByBrandIdIncludingInactive(brandId);
        } catch (SQLException e) {
            throw new AppException("Failed to get vehicle models.", e);
        }
    }

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

    public void setBrandActive(int brandId, boolean active) {
        try {
            vehicleBrandDAO.updateActive(brandId, active);
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle brand.", e);
        }
    }

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

    public void setModelActive(int modelId, boolean active) {
        try {
            vehicleModelDAO.updateActive(modelId, active);
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle model.", e);
        }
    }

    public Vehicle getCarById(int carId) { return getVehicleById(carId); }
    public Vehicle getCarByLicensePlate(String licensePlate) { return getVehicleByLicensePlate(licensePlate); }
    public List<Vehicle> getAllCars() { return getAllVehicles(); }
    public List<Vehicle> getCarsByStatus(String status) { return getVehiclesByStatus(status); }
    public List<VehicleImage> getCarImages(int carId) { return getVehicleImages(carId); }
    public int addCar(Vehicle car) { return addVehicle(car); }
    public boolean updateCar(Vehicle car) { return updateVehicle(car); }
    public boolean updateCarStatus(int carId, String status) { return updateVehicleStatus(carId, status); }
    public boolean deleteCar(int carId) { return deleteVehicle(carId); }
    public Map<Integer, MaintenanceSchedule> getNextScheduledMaintenanceByCar() { return getNextScheduledMaintenanceByVehicle(); }

    public Vehicle getVehicleById(int carId) {
        try {
            Vehicle car = vehicleDAO.findById(carId);
            if (car != null) {
                car.setPrimaryImageUrl(resolvePrimaryImageUrl(car.getVehicleId()));
            }
            return car;
        } catch (SQLException e) {
            throw new AppException("Failed to get car.", e);
        }
    }

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

    public List<Vehicle> getAllVehicles() {
        try {
            List<Vehicle> list = vehicleDAO.findAll();
            populatePrimaryImages(list);
            return list;
        } catch (SQLException e) {
            throw new AppException("Failed to get cars.", e);
        }
    }

    public List<Vehicle> getVehiclesByStatus(String status) {
        try {
            List<Vehicle> list = vehicleDAO.findByStatus(status);
            populatePrimaryImages(list);
            return list;
        } catch (SQLException e) {
            throw new AppException("Failed to get cars by status.", e);
        }
    }

    private void populatePrimaryImages(List<Vehicle> list) {
        if (list != null) {
            for (Vehicle v : list) {
                if (v != null) {
                    v.setPrimaryImageUrl(resolvePrimaryImageUrl(v.getVehicleId()));
                }
            }
        }
    }

    public List<VehicleImage> getVehicleImages(int carId) {
        try {
            return carImageDAO.findByVehicleId(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get car images.", e);
        }
    }

    public int addVehicle(Vehicle car) {
        try {
            return vehicleDAO.insert(car);
        } catch (SQLException e) {
            throw new AppException("Failed to add car.", e);
        }
    }

    public boolean updateVehicle(Vehicle car) {
        try {
            return vehicleDAO.update(car);
        } catch (SQLException e) {
            throw new AppException("Failed to update car.", e);
        }
    }

    public boolean updateVehicleStatus(int carId, String status) {
        try {
            // BR-09: Validate status transitions if needed
            return vehicleDAO.updateStatus(carId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update car status.", e);
        }
    }

    public boolean deleteVehicle(int carId) {
        try {
            carImageDAO.deleteByVehicleId(carId);
            maintenanceDAO.deleteByVehicleId(carId);
            return vehicleDAO.delete(carId);
        } catch (SQLException e) {
            if (e.getErrorCode() == 547) {
                // SQL Server FK violation: car still referenced by bookings/contracts/handovers/returns/reviews
                throw new AppException("Không thể xóa xe này vì đã có lịch sử đặt xe, hợp đồng hoặc giao/nhận xe. "
                        + "Vui lòng chuyển trạng thái xe sang 'Ngừng hoạt động' thay vì xóa.", e);
            }
            throw new AppException("Failed to delete car.", e);
        }
    }

    public BigDecimal calculateOneDayDeposit(BigDecimal dailyRate) {
        return feeCalculator.calculateDeposit(dailyRate);
    }

    public String getDepositPercentage() {
        return policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
    }

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

    public String resolvePrimaryImageUrl(int carId) {
        List<VehicleImage> images = getVehicleImages(carId);
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
    public int addCarImage(VehicleImage image) { return addVehicleImage(image); }
    public int addVehicleImage(VehicleImage image) {
        try {
            return carImageDAO.insert(image);
        } catch (SQLException e) {
            throw new AppException("Failed to add vehicle image.", e);
        }
    }

    public boolean deleteCarImage(int imageId) {
        try {
            return carImageDAO.delete(imageId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete car image.", e);
        }
    }

    public boolean setPrimaryImage(int carId, int imageId) {
        try {
            carImageDAO.clearPrimaryByCarId(carId);
            return carImageDAO.setPrimary(imageId, true);
        } catch (SQLException e) {
            throw new AppException("Failed to set primary image.", e);
        }
    }

    public void clearPrimaryImages(int carId) {
        try {
            carImageDAO.clearPrimaryByCarId(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to clear primary images.", e);
        }
    }

    // Maintenance management
    public List<MaintenanceSchedule> getMaintenanceByCarId(int carId) {
        try {
            return maintenanceDAO.getMaintenanceByVehicle(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get maintenance schedules.", e);
        }
    }
    public List<MaintenanceSchedule> getMaintenanceByVehicleId(int vehicleId) {
        return getMaintenanceByCarId(vehicleId);
    }

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

    public boolean updateMaintenanceSchedule(MaintenanceSchedule schedule) {
        try {
            return maintenanceDAO.updateMaintenance(schedule);
        } catch (SQLException e) {
            throw new AppException("Failed to update maintenance schedule.", e);
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

    public boolean deleteMaintenanceSchedule(int maintenanceId) {
        try {
            return maintenanceDAO.deleteMaintenance(maintenanceId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete maintenance schedule.", e);
        }
    }
}
