/*
 * Name: ContractService
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for ContractService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.ContractDAO;
import com.swp391.carrental.dao.BookingDAO;
import com.swp391.carrental.model.RentalContract;
import com.swp391.carrental.model.Booking;
import com.swp391.carrental.constant.BookingStatus;
import com.swp391.carrental.constant.ContractStatus;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Service for rental contract operations. BR-05: Contract can only be created
 * from Confirmed booking.
 */
public class ContractService {

    private final ContractDAO contractDAO = new ContractDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    // Get contract by ID
    public RentalContract getContractById(int contractId) {
        try {
            return contractDAO.findById(contractId);
        } catch (SQLException e) {
            throw new AppException("Failed to get contract.", e);
        }
    }

    // Get contract by booking ID
    public RentalContract getContractByBookingId(int bookingId) {
        try {
            return contractDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get contract.", e);
        }
    }

    // Get all contracts
    public List<RentalContract> getAllContracts() {
        try {
            return contractDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get contracts.", e);
        }
    }

    // Create contract from confirmed booking
    public int createContract(RentalContract contract) {
        try {
            // BR-05: Verify booking is CONFIRMED
            Booking booking = bookingDAO.findById(contract.getBookingId());
            if (booking == null) {
                throw new AppException("Booking not found.");
            }
            if (!BookingStatus.CONFIRMED.equals(booking.getStatus())) {
                throw new AppException("Contract can only be created from a Confirmed booking.");
            }

            // Generate contract number
            String contractNumber = "CTR-"
                    + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy"))
                    + "-" + String.format("%04d", contract.getBookingId());
            contract.setContractNumber(contractNumber);
            contract.setStatus(ContractStatus.DRAFT);

            return contractDAO.insert(contract);
        } catch (SQLException e) {
            throw new AppException("Failed to create contract.", e);
        }
    }

    // Update contract status
    public boolean updateContractStatus(int contractId, String status) {
        try {
            return contractDAO.updateStatus(contractId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update contract status.", e);
        }
    }
}
