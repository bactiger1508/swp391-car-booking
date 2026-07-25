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

/*
 * Name: HandoverService
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for HandoverService.
 */
/**
 * Service for vehicle handover operations. BR-06: Car becomes Rented after
 * handover.
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
     * Record vehicle handover. BR-06: Car becomes Rented after handover.
     */
    public int handoverVehicle(VehicleHandover handover) {
        try {
            int handoverId = handoverDAO.insert(handover);

            // BR-06: Update car status to RENTED
            vehicleDAO.updateStatus(handover.getVehicleId(), CarStatus.RENTED);

            // Update booking status to IN_PROGRESS
            bookingDAO.updateStatus(handover.getBookingId(), BookingStatus.IN_PROGRESS);

            //Update handover status
            handoverDAO.updateStatus(handoverId, HandoverStatus.IN_PROGRESS);

            return handoverId;
        } catch (SQLException e) {
            throw new AppException("Failed to record vehicle handover.", e);
        }
    }

    public void updateHandoverVehicle(VehicleHandover handover) {
        try {
            handoverDAO.update(handover);
            handoverDAO.updateStatus(handover.getHandoverId(), HandoverStatus.IN_PROGRESS);
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

    public void updateStatusConfirm(int handoverId) {
        try {
            handoverDAO.updateStatus(handoverId, HandoverStatus.COMPLETED);
        } catch (SQLException e) {
            throw new AppException("Failed to delete vehicle handover.", e);
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
