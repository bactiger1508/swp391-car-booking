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
 * Created: 23/05/2026 
 * Description: Contains business logic and operations for managing Rental Contracts.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (04/06/2026): refactor: apply coding conventions and improve code docum...
 * - v1.3 (09/06/2026): docs(contract): add simple english comments to contract m...
 * - v1.4 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.5 (21/06/2026): feat: implement booking workflow with contract creation a...
 * - v1.6 (08/07/2026): feat: implement update contract
 * - v1.7 (21/07/2026): feat: update rental contract workflow to require customer...
 * - v1.8 (22/07/2026): Fix: complete Java backend bug fixes and UI settings impr...
 * - v1.9 (23/07/2026): Added Javadoc and method comments.
 */

/**
 * Service for rental contract operations. BR-05: Contract can only be created
 * from Confirmed booking.
 */
public class ContractService {

    private final ContractDAO contractDAO = new ContractDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    /**
     * Get a contract by its database primary ID.
     */
    public RentalContract getContractById(int contractId) {
        try {
            return contractDAO.findById(contractId);
        } catch (SQLException e) {
            throw new AppException("Failed to get contract.", e);
        }
    }

    /**
     * Get a contract associated with a specific booking.
     */
    public RentalContract getContractByBookingId(int bookingId) {
        try {
            return contractDAO.findByBookingId(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get contract.", e);
        }
    }

    /**
     * Retrieve all contracts in the system.
     */
    public List<RentalContract> getAllContracts() {
        try {
            return contractDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get contracts.", e);
        }
    }

    /**
     * Retrieve all contracts belonging to a specific customer.
     */
    public List<RentalContract> getContractsByCustomerId(int customerId) {
        try {
            return contractDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer contracts.", e);
        }
    }

    /**
     * Create a new contract from a confirmed booking and verified customer profile.
     */
    public int createContract(RentalContract contract) {
        try {
            // UC 2.2.1 Step 3 / Alt 1: Verify booking is CONFIRMED
            Booking booking = bookingDAO.findById(contract.getBookingId());
            if (booking == null) {
                throw new AppException("Không tìm thấy đơn đặt xe.");
            }
            if (!BookingStatus.CONFIRMED.equals(booking.getStatus())) {
                throw new AppException("Chỉ có thể soạn hợp đồng cho các đơn đặt xe đã Xác nhận (Confirmed).");
            }

            // Verify customer is VERIFIED
            com.swp391.carrental.user.dao.CustomerProfileDAO profileDAO = new com.swp391.carrental.user.dao.CustomerProfileDAO();
            com.swp391.carrental.user.model.CustomerProfile profile = profileDAO.findByUserId(contract.getCustomerId());
            if (profile == null || !"VERIFIED".equals(profile.getVerificationStatus())) {
                throw new AppException("Khách hàng chưa xác minh hồ sơ, không thể lập hợp đồng.");
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

    /**
     * Process electronic signature by staff member.
     */
    public boolean signByStaff(int contractId) {
        try {
            return contractDAO.signContractByStaff(contractId);
        } catch (SQLException e) {
            throw new AppException("Lỗi khi nhân viên ký hợp đồng.", e);
        }
    }

    /**
     * Process electronic signature by customer.
     */
    public boolean signByCustomer(int contractId) {
        try {
            return contractDAO.signContractByCustomer(contractId);
        } catch (SQLException e) {
            throw new AppException("Lỗi khi khách hàng ký hợp đồng.", e);
        }
    }

    /**
     * Update status of a contract.
     */
    public boolean updateContractStatus(int contractId, String status) {
        try {
            return contractDAO.updateStatus(contractId, status);
        } catch (SQLException e) {
            throw new AppException("Failed to update contract status.", e);
        }
    }

    /**
     * Update draft contract details with valid date range and prices, logging the audit.
     */
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
