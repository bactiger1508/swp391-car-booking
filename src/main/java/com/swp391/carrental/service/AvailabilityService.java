package com.swp391.carrental.service;

import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for checking vehicle availability.
 */
public class AvailabilityService {

    private final CarDAO carDAO = new CarDAO();

    /**
     * Check if a specific car is available for a date range.
     * BR-02: No overlapping Confirmed/InProgress bookings.
     * BR-09: Car with Maintenance status cannot be booked.
     */
    public boolean checkAvailability(int carId, LocalDateTime startDate, LocalDateTime endDate) {
        try {
            Car car = carDAO.findById(carId);
            if (car == null) return false;
            if (!"AVAILABLE".equals(car.getStatus())) return false;

            List<Car> available = carDAO.findAvailable(
                    Timestamp.valueOf(startDate),
                    Timestamp.valueOf(endDate)
            );
            return available.stream().anyMatch(c -> c.getCarId() == carId);
        } catch (SQLException e) {
            throw new AppException("Failed to check availability.", e);
        }
    }

    /**
     * Get all available cars for a date range.
     */
    public List<Car> getAvailableCars(LocalDateTime startDate, LocalDateTime endDate) {
        try {
            return carDAO.findAvailable(
                    Timestamp.valueOf(startDate),
                    Timestamp.valueOf(endDate)
            );
        } catch (SQLException e) {
            throw new AppException("Failed to get available cars.", e);
        }
    }
}
