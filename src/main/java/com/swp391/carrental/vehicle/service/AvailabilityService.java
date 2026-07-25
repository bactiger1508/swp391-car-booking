package com.swp391.carrental.vehicle.service;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;

/*
 * Name: AvailabilityService
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for AvailabilityService.
 */

/**
 * Service for checking vehicle availability.
 */
public class AvailabilityService {

    private final CarDAO carDAO = new CarDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    /**
     * Check if a specific car is available for a date range (combining Car status and Booking overlaps).
     * BR-02: No overlapping Pending/Confirmed/InProgress bookings.
     * BR-09: Car with Maintenance/Inactive/Rented status cannot be booked.
     */
    public boolean isCarAvailableForRange(int carId, LocalDateTime startDate, LocalDateTime endDate) {
        try {
            Car car = carDAO.findById(carId);
            if (car == null) return false;
            if (!"AVAILABLE".equals(car.getStatus())) return false;

            boolean hasOverlap = bookingDAO.hasOverlappingBooking(
                    carId,
                    Timestamp.valueOf(startDate),
                    Timestamp.valueOf(endDate),
                    null
            );
            return !hasOverlap;
        } catch (SQLException e) {
            throw new AppException("Failed to check car availability.", e);
        }
    }

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

