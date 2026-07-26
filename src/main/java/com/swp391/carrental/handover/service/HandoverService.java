package com.swp391.carrental.handover.service;

import java.sql.SQLException;
import java.util.List;

import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.handover.constant.HandoverStatus;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.vehicle.constant.CarStatus;
import com.swp391.carrental.vehicle.dao.VehicleDAO;

/**
 * Name: HandoverService
 * @Author: TamTTMHE190340
 * Date: 19/06/2026
 * Version: 1.0
 * Description: Service layer handling vehicle handover recording, draft management, and confirmation-driven status transitions.
 */
public class HandoverService {

    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();

    public VehicleHandover getHandoverById(int handoverId) {
        try {
            return handoverDAO.findById(handoverId);
        } catch (SQLException e) {
            throw new AppException("Failed to get handover.", e);
        }
    }

    public VehicleHandover getHandoverByBookingId(int bookingId) {
        try {
            return handoverDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get handover.", e);
        }
    }

    public List<VehicleHandover> getAllHandovers() {
        try {
            return handoverDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get handovers.", e);
        }
    }

    /**
     * Record vehicle handover draft. Do NOT update car/booking status yet.
     */
    public int handoverVehicle(VehicleHandover handover) {
        try {
            if (handover.getStatus() == null || handover.getStatus().isBlank()) {
                handover.setStatus(HandoverStatus.IN_PROGRESS);
            }
            int handoverId = handoverDAO.insert(handover);
            return handoverId;
        } catch (SQLException e) {
            throw new AppException("Failed to record vehicle handover.", e);
        }
    }

    public void updateHandoverVehicle(VehicleHandover handover) {
        try {
            if (handover.getStatus() == null || handover.getStatus().isBlank()) {
                handover.setStatus(HandoverStatus.IN_PROGRESS);
            }
            handoverDAO.update(handover);
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle handover.", e);
        }
    }

    public void deleteHandoverVehicle(int handoverId) {
        try {
            handoverDAO.delete(handoverId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete vehicle handover.", e);
        }
    }

    /**
     * Confirm vehicle handover. Status changes to COMPLETED, car to RENTED,
     * booking to IN_PROGRESS.
     */
    public void updateStatusConfirm(int handoverId) {
        try {
            VehicleHandover handover = handoverDAO.findById(handoverId);
            if (handover != null) {
                handoverDAO.updateStatus(handoverId, HandoverStatus.COMPLETED);
                vehicleDAO.updateStatus(handover.getVehicleId(), CarStatus.RENTED);
                bookingDAO.updateStatus(handover.getBookingId(), BookingStatus.IN_PROGRESS);
            }
        } catch (SQLException e) {
            throw new AppException("Failed to confirm vehicle handover.", e);
        }
    }

    public void updateStatusRequired(int handoverId) {
        try {
            handoverDAO.updateStatus(handoverId, HandoverStatus.REQUIRED_UPDATE);
        } catch (SQLException e) {
            throw new AppException("Failed to delete vehicle handover.", e);
        }
    }
}
