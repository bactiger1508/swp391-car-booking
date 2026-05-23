package com.swp391.carrental.service;

import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.dao.CarImageDAO;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.CarImage;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;

/**
 * Service for vehicle management operations.
 */
public class VehicleService {

    private final CarDAO carDAO = new CarDAO();
    private final CarImageDAO carImageDAO = new CarImageDAO();

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
}
