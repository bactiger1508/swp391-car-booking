package com.swp391.carrental.vehicle.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.dao.CarImageDAO;
import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.dao.VehicleBrandDAO;
import com.swp391.carrental.vehicle.dao.VehicleModelDAO;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.model.CarImage;
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

    private final CarDAO carDAO = new CarDAO();
    private final CarImageDAO carImageDAO = new CarImageDAO();
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

    public Car getCarById(int carId) {
        try {
            return carDAO.findById(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get car.", e);
        }
    }

    public Car getCarByLicensePlate(String licensePlate) {
        try {
            return carDAO.findByLicensePlate(licensePlate);
        } catch (SQLException e) {
            throw new AppException("Failed to get car by license plate.", e);
        }
    }

    public List<Car> getAllCars() {
        try {
            return carDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get cars.", e);
        }
    }

    public List<Car> getCarsByStatus(String status) {
        try {
            return carDAO.findByStatus(status);
        } catch (SQLException e) {
            throw new AppException("Failed to get cars by status.", e);
        }
    }

    public List<CarImage> getCarImages(int carId) {
        try {
            return carImageDAO.findByCarId(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get car images.", e);
        }
    }

    public int addCar(Car car) {
        try {
            return carDAO.insert(car);
        } catch (SQLException e) {
            throw new AppException("Failed to add car.", e);
        }
    }

    public boolean updateCar(Car car) {
        try {
            return carDAO.update(car);
        } catch (SQLException e) {
            throw new AppException("Failed to update car.", e);
        }
    }

    public boolean updateCarStatus(int carId, String status) {
        try {
            // BR-09: Validate status transitions if needed
            return carDAO.updateStatus(carId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update car status.", e);
        }
    }

    public boolean deleteCar(int carId) {
        try {
            carImageDAO.deleteByCarId(carId);
            maintenanceDAO.deleteByCarId(carId);
            return carDAO.delete(carId);
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

    public Map<Integer, String> getPrimaryImageUrls(List<Car> cars) {
        Map<Integer, String> urls = new HashMap<>();
        for (Car car : cars) {
            urls.put(car.getCarId(), resolvePrimaryImageUrl(car.getCarId()));
        }
        return urls;
    }

    public String resolvePrimaryImageUrl(int carId) {
        List<CarImage> images = getCarImages(carId);
        for (CarImage image : images) {
            if (image.isPrimary()) {
                return image.getImageUrl();
            }
        }
        if (!images.isEmpty()) {
            return images.get(0).getImageUrl();
        }
        return "/assets/images/cars/placeholder.jpg";
    }

    public Map<Integer, MaintenanceSchedule> getNextScheduledMaintenanceByCar() {
        try {
            Map<Integer, MaintenanceSchedule> nextByCar = new HashMap<>();
            for (MaintenanceSchedule schedule : maintenanceDAO.getAllMaintenanceSchedules()) {
                if (!"SCHEDULED".equals(schedule.getStatus())) {
                    continue;
                }
                MaintenanceSchedule existing = nextByCar.get(schedule.getVehicleId());
                if (existing == null || schedule.getScheduledDate().isBefore(existing.getScheduledDate())) {
                    nextByCar.put(schedule.getVehicleId(), schedule);
                }
            }
            return nextByCar;
        } catch (SQLException e) {
            throw new AppException("Failed to get maintenance schedules.", e);
        }
    }

    // Image management
    public int addCarImage(CarImage image) {
        try {
            return carImageDAO.insert(image);
        } catch (SQLException e) {
            throw new AppException("Failed to add car image.", e);
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

    public int addMaintenanceSchedule(MaintenanceSchedule schedule) {
        try {
            int maintenanceId = maintenanceDAO.createMaintenance(schedule);
            if (maintenanceId > 0) {
                // Vehicle goes into maintenance as soon as a job is scheduled for it.
                carDAO.updateStatus(schedule.getVehicleId(), "MAINTENANCE");
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
                    carDAO.updateStatus(schedule.getVehicleId(), "AVAILABLE");
                }
            } else if ("IN_PROGRESS".equals(newStatus)) {
                carDAO.updateStatus(schedule.getVehicleId(), "MAINTENANCE");
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
