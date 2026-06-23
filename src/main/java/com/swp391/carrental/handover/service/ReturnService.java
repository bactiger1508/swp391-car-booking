package com.swp391.carrental.handover.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.vehicle.constant.CarStatus;
import com.swp391.carrental.vehicle.dao.CarDAO;

/*
 * Name: ReturnService
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for ReturnService.
 */
/**
 * Service for vehicle return operations. BR-07: Return fee includes late fee,
 * extra km fee, damage fee, cleaning fee, lost item fee. BR-08: Booking becomes
 * Completed only after vehicle return and required payments.
 */
public class ReturnService {

    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
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

            // Update car status to AVAILABLE and update its mileage to match return mileage
            com.swp391.carrental.vehicle.model.Car car = carDAO.findById(vehicleReturn.getCarId());
            if (car != null) {
                car.setStatus(CarStatus.AVAILABLE);
                car.setMileage(vehicleReturn.getMileageAtReturn());
                carDAO.update(car);
            }

            Booking booking = bookingDAO.findById(vehicleReturn.getBookingId());
            if (booking != null) {
                List<Payment> payments = paymentDAO.findByBookingId(vehicleReturn.getBookingId());
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(p.getAmount());
                        } else {
                            totalPaid = totalPaid.add(p.getAmount());
                        }
                    }
                }

                BigDecimal totalRequired = booking.getTotalAmount();
                if (vehicleReturn.getTotalAdditionalFee() != null) {
                    totalRequired = totalRequired.add(vehicleReturn.getTotalAdditionalFee());
                }

                if (totalPaid.compareTo(totalRequired) >= 0) {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.COMPLETED);
                } else {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
                }
            } else {
                if (vehicleReturn.getTotalAdditionalFee() != null && vehicleReturn.getTotalAdditionalFee().doubleValue() > 0) {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
                } else {
                    bookingDAO.updateStatus(vehicleReturn.getBookingId(), BookingStatus.COMPLETED);
                }
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
                List<Payment> payments = paymentDAO.findByBookingId(returns.getBookingId());
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(p.getAmount());
                        } else {
                            totalPaid = totalPaid.add(p.getAmount());
                        }
                    }
                }

                BigDecimal totalRequired = booking.getTotalAmount();
                if (returns.getTotalAdditionalFee() != null) {
                    totalRequired = totalRequired.add(returns.getTotalAdditionalFee());
                }

                if (totalPaid.compareTo(totalRequired) >= 0) {
                    bookingDAO.updateStatus(returns.getBookingId(), BookingStatus.COMPLETED);
                } else {
                    bookingDAO.updateStatus(returns.getBookingId(), BookingStatus.PENDING_SETTLEMENT);
                }
            }
        } catch (SQLException e) {
            throw new AppException("Failed to update vehicle handover.", e);
        }
    }
}
