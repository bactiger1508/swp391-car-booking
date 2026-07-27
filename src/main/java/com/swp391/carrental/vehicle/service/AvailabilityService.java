package com.swp391.carrental.vehicle.service;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

/*
 * Name: AvailabilityService
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 2.0
 * Description: Handles availability check logic for vehicles.
 */

/**
 * Checks vehicle availability against status and existing bookings for a given date range.
 */
public class AvailabilityService {

    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    /** Returns true if a vehicle is AVAILABLE and has no overlapping booking in the given date range. */
    public boolean isVehicleAvailableForRange(int vehicleId, LocalDateTime startDate, LocalDateTime endDate) {
        try {
            Vehicle vehicle = vehicleDAO.findById(vehicleId);
            if (vehicle == null) return false;
            if (!"AVAILABLE".equals(vehicle.getStatus())) return false;

            return !bookingDAO.hasOverlappingBooking(
                    vehicleId,
                    Timestamp.valueOf(startDate),
                    Timestamp.valueOf(endDate),
                    null
            );
        } catch (SQLException e) {
            throw new AppException("Failed to check vehicle availability.", e);
        }
    }

    /** Returns every vehicle available (by status and booking overlap) in the given date range, with primary images resolved. */
    public List<Vehicle> getAvailableVehicles(LocalDateTime startDate, LocalDateTime endDate) {
        try {
            List<Vehicle> list = vehicleDAO.findAvailable(
                    Timestamp.valueOf(startDate),
                    Timestamp.valueOf(endDate)
            );
            // Populate primaryImageUrl for each vehicle
            VehicleService vs = new VehicleService();
            for (Vehicle v : list) {
                if (v != null) {
                    v.setPrimaryImageUrl(vs.resolvePrimaryImageUrl(v.getVehicleId()));
                }
            }
            return list;
        } catch (SQLException e) {
            throw new AppException("Failed to get available vehicles.", e);
        }
    }


}
