package com.swp391.carrental.contract.service;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.constant.ContractStatus;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.core.exception.AppException;

/*
 * Name: ContractService
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for ContractService.
 */



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

    // Get contracts by customer ID
    public List<RentalContract> getContractsByCustomerId(int customerId) {
        try {
            return contractDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer contracts.", e);
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

    // Update contract details with validation
    public boolean updateContract(RentalContract contract, int editorId, String editorRole) {
        try {
            // BR7: Check if contract exists and is still editable
            RentalContract existing = contractDAO.findById(contract.getContractId());
            if (existing == null) {
                throw new AppException("Không tìm thấy hợp đồng.");
            }
            if (!ContractStatus.DRAFT.equals(existing.getStatus())) {
                throw new AppException("Hợp đồng đã ký kết hoặc hoàn tất, không thể chỉnh sửa.");
            }

            // BR6: Validate contract data
            if (contract.getStartDate() == null || contract.getEndDate() == null) {
                throw new AppException("Thời hạn thuê xe không được để trống.");
            }
            if (!contract.getEndDate().isAfter(contract.getStartDate())) {
                throw new AppException("Ngày trả xe phải sau ngày nhận xe.");
            }
            if (contract.getDailyRate() == null || contract.getDailyRate().compareTo(java.math.BigDecimal.ZERO) < 0) {
                throw new AppException("Đơn giá thuê ngày không hợp lệ.");
            }
            if (contract.getDepositAmount() == null || contract.getDepositAmount().compareTo(java.math.BigDecimal.ZERO) < 0) {
                throw new AppException("Tiền đặt cọc không hợp lệ.");
            }
            if (contract.getTotalAmount() == null || contract.getTotalAmount().compareTo(java.math.BigDecimal.ZERO) < 0) {
                throw new AppException("Tổng tiền hợp đồng không hợp lệ.");
            }

            boolean updated = contractDAO.update(contract);
            if (updated) {
                try {
                    com.swp391.carrental.core.dao.AuditLogDAO auditLogDAO = new com.swp391.carrental.core.dao.AuditLogDAO();
                    com.swp391.carrental.core.model.AuditLog log = new com.swp391.carrental.core.model.AuditLog();
                    log.setUserId(editorId);
                    log.setAction("UPDATE_CONTRACT");
                    log.setEntityType("CONTRACT");
                    log.setEntityId(contract.getContractId());
                    log.setDescription("Cập nhật thông tin hợp đồng #" + contract.getContractId() + " bởi " + editorRole);
                    auditLogDAO.insert(log);
                } catch (Exception ex) {
                    // Ignore audit log failure
                }
            }
            return updated;
        } catch (SQLException e) {
            throw new AppException("Lỗi cập nhật hợp đồng.", e);
        }
    }
}
