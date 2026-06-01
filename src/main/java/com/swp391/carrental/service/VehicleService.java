/*
 * Name: VehicleService
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for VehicleService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.dao.CarImageDAO;
import com.swp391.carrental.dao.MaintenanceDAO;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.CarImage;
import com.swp391.carrental.model.MaintenanceSchedule;
import com.swp391.carrental.exception.AppException;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for vehicle management operations.
 */
public class VehicleService {

    private final CarDAO carDAO = new CarDAO();
    private final CarImageDAO carImageDAO = new CarImageDAO();
    private final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    private final FeeCalculator feeCalculator = new FeeCalculator();
    private final PolicyService policyService = new PolicyService();

    public Car getCarById(int carId) {
        try {
            return carDAO.findById(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get car.", e);
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
            return carDAO.delete(carId);
        } catch (SQLException e) {
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
}
