package com.swp391.carrental.service;

import com.swp391.carrental.dao.ReturnDAO;
import com.swp391.carrental.dao.BookingDAO;
import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.model.VehicleReturn;
import com.swp391.carrental.constant.BookingStatus;
import com.swp391.carrental.constant.CarStatus;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;

/**
 * Service for vehicle return operations.
 * BR-07: Return fee includes late fee, extra km fee, damage fee, cleaning fee, lost item fee.
 * BR-08: Booking becomes Completed only after vehicle return and required payments.
 */
public class ReturnService {

    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();

    public VehicleReturn getReturnById(int returnId) {
        try {
            return returnDAO.findById(returnId);
        } catch (SQLException e) {
            throw new AppException("Failed to get return record.", e);
        }
    }

    public VehicleReturn getReturnByBookingId(int bookingId) {
        try {
            return returnDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get return record.", e);
        }
    }

    public List<VehicleReturn> getAllReturns() {
        try {
            return returnDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get return records.", e);
        }
    }

    /**
     * Record vehicle return.
     * BR-07: Calculate additional fees.
     * BR-08: Mark booking as PENDING_SETTLEMENT (awaiting payment confirmation).
     */
    public int returnVehicle(VehicleReturn vehicleReturn) {
        try {
            int returnId = returnDAO.insert(vehicleReturn);

            // Update car status back to AVAILABLE
            carDAO.updateStatus(vehicleReturn.getCarId(), CarStatus.AVAILABLE);

            // BR-08: If there are additional fees, set to PENDING_SETTLEMENT
            if (vehicleReturn.getTotalAdditionalFee() != null
                    && vehicleReturn.getTotalAdditionalFee().doubleValue() > 0) {
                bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
            } else {
                bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.COMPLETED);
            }

            return returnId;
        } catch (SQLException e) {
            throw new AppException("Failed to record vehicle return.", e);
        }
    }
}
