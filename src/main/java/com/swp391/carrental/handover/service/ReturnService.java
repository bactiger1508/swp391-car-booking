package com.swp391.carrental.handover.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.contract.constant.ContractStatus;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

/**
 * Name: ReturnService
 * @Author: TamTTMHE190340
 * Date: 19/06/2026
 * Version: 1.0
 * Description: Service layer handling vehicle return processing, surcharge evaluation, settlement status transitions, and final ODO synchronization.
 */
public class ReturnService {

    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

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
     * Record vehicle return. BR-07: Calculate additional fees. BR-08: Mark
     * booking as PENDING_SETTLEMENT (awaiting payment confirmation).
     */
    public int returnVehicle(VehicleReturn vehicleReturn) {
        try {
            VehicleReturn existing = returnDAO.findByBookingId(vehicleReturn.getBookingId());
            int returnId;

            if (existing == null) {
                returnId = returnDAO.insert(vehicleReturn);
            } else {
                vehicleReturn.setReturnId(existing.getReturnId());
                returnDAO.update(vehicleReturn);
                returnId = existing.getReturnId();
            }

            Booking booking = bookingDAO.findById(vehicleReturn.getBookingId());
            if (booking != null) {
                List<Payment> payments = paymentDAO.findByBookingId(vehicleReturn.getBookingId());
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        if ("DEDUCTION".equalsIgnoreCase(p.getPaymentMethod())) {
                            continue;
                        }
                        BigDecimal effectiveAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(effectiveAmt);
                        } else {
                            totalPaid = totalPaid.add(effectiveAmt);
                        }
                    }
                }

                BigDecimal depositAmt = booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO;
                BigDecimal pureRentalFee = booking.getTotalAmount().subtract(depositAmt);
                BigDecimal totalRequired = pureRentalFee;
                if (vehicleReturn.getTotalAdditionalFee() != null) {
                    totalRequired = totalRequired.add(vehicleReturn.getTotalAdditionalFee());
                }

                // ONLY mark COMPLETED if net totalPaid equals totalRequired exactly
                // If totalPaid > totalRequired (needs refund) OR totalPaid < totalRequired
                // (needs extra payment): set PENDING_SETTLEMENT!
                if (totalPaid.compareTo(totalRequired) == 0) {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.COMPLETED);
                    updateContractStatus(vehicleReturn.getBookingId(), ContractStatus.COMPLETED);

                    Vehicle vehicle = vehicleDAO.findById(vehicleReturn.getVehicleId());
                    if (vehicle != null) {
                        if (vehicleReturn.getMileageAtReturn() > vehicle.getMileage()) {
                            vehicle.setMileage(vehicleReturn.getMileageAtReturn());
                        }
                        if (vehicleReturn.getNotes() != null && vehicleReturn.getNotes().contains("[CẦN BẢO DƯỠNG]")) {
                            vehicle.setStatus(com.swp391.carrental.vehicle.constant.CarStatus.MAINTENANCE);
                        } else {
                            vehicle.setStatus(com.swp391.carrental.vehicle.constant.CarStatus.AVAILABLE);
                        }
                        vehicleDAO.update(vehicle);
                    }
                } else {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
                }
            } else {
                bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
            }

            return returnId;
        } catch (SQLException e) {
            throw new AppException("Failed to record vehicle return.", e);
        }
    }

    public void updateReturnVehicle(VehicleReturn returns) {
        try {
            returnDAO.update(returns);

            Booking booking = bookingDAO.findById(returns.getBookingId());
            if (booking != null) {
                bookingDAO.updateStatus(returns.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
            }
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle return.", e);
        }
    }

    private void updateContractStatus(int bookingId, String status) {
        try {
            ContractDAO contractDAO = new ContractDAO();
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            if (contract != null) {
                contractDAO.updateStatus(contract.getContractId(), status);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
