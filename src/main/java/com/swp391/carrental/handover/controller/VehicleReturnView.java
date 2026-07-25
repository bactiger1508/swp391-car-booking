package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.math.BigDecimal;
import java.io.IOException;
import java.util.List;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

/**
 * Name: VehicleReturnView
 * 
 * @Author: TamTTMHE190340
 *          Date: 22/06/2026
 *          Version: 1.0
 *          Description: Controller for viewing read-only vehicle return
 *          inspection details.
 */
@WebServlet(name = "VehicleReturnView", urlPatterns = { "/return/view" })
public class VehicleReturnView extends HttpServlet {

    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("vehicleId");
            if (carIdStr == null || carIdStr.trim().isEmpty()) {
                carIdStr = request.getParameter("carId");
            }

            if (bookingIdStr != null && carIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Vehicle car = vehicleDAO.findById(carId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
                if (handover == null) {
                    handover = new VehicleHandover();
                    handover.setBookingId(bookingId);
                    handover.setVehicleId(carId);
                    if (contract != null) {
                        handover.setContractId(contract.getContractId());
                    }
                    handover.setMileageAtHandover(car != null ? car.getMileage() : 0);
                    handover.setFuelLevel("FULL");
                } else {
                    if (handover.getMileageAtHandover() <= 0 && car != null) {
                        handover.setMileageAtHandover(car.getMileage());
                    }
                    if (handover.getFuelLevel() == null || handover.getFuelLevel().isBlank()) {
                        handover.setFuelLevel("FULL");
                    }
                }
                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                PolicyService policyService = new PolicyService();
                FeeCalculator feeCalculator = new FeeCalculator();
                request.setAttribute("extraKmFeeRate", policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
                request.setAttribute("lateFeePerHour", policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));

                long days = 1;
                if (booking != null && booking.getStartDate() != null && booking.getEndDate() != null) {
                    days = java.time.temporal.ChronoUnit.DAYS.between(booking.getStartDate().toLocalDate(),
                            booking.getEndDate().toLocalDate());
                    if (days < 1) {
                        days = 1;
                    }
                }

                int kmLimit = (booking != null && booking.getKmLimit() != null && booking.getKmLimit() > 0)
                        ? booking.getKmLimit()
                        : (booking != null
                                ? feeCalculator.calculateKmLimit(booking.getRentalMode(), booking.getPricingPackage(),
                                        days)
                                : 250);

                int distanceDriven = 0;
                int actualExtraKm = 0;
                int estimatedKm = (booking != null && booking.getEstimatedKm() != null) ? booking.getEstimatedKm() : 0;
                int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);
                int additionalExtraKm = 0;

                if (returns != null && handover != null) {
                    int mReturn = returns.getMileageAtReturn();
                    int mHandover = handover.getMileageAtHandover();
                    if (mReturn > 0) {
                        if (mReturn >= mHandover && mHandover > 0) {
                            distanceDriven = mReturn - mHandover;
                        } else if (mReturn < mHandover) {
                            distanceDriven = mReturn;
                        } else {
                            distanceDriven = 0;
                        }
                    }
                    actualExtraKm = Math.max(0, distanceDriven - kmLimit);
                    additionalExtraKm = Math.max(0, actualExtraKm - alreadyPaidExtraKm);
                }

                BigDecimal rateLate = new BigDecimal(policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));
                BigDecimal rateKm = new BigDecimal(policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));

                BigDecimal lateHours = (returns != null && returns.getLateHours() != null) ? returns.getLateHours()
                        : BigDecimal.ZERO;
                BigDecimal extraKmFeeQty = (returns != null && returns.getExtraKmFee() != null)
                        ? returns.getExtraKmFee()
                        : BigDecimal.valueOf(additionalExtraKm);
                BigDecimal cleaningFee = (returns != null && returns.getCleaningFee() != null)
                        ? returns.getCleaningFee()
                        : BigDecimal.ZERO;
                BigDecimal damageFee = (returns != null && returns.getDamageFee() != null) ? returns.getDamageFee()
                        : BigDecimal.ZERO;
                BigDecimal lostItemFee = (returns != null && returns.getLostItemFee() != null)
                        ? returns.getLostItemFee()
                        : BigDecimal.ZERO;

                BigDecimal lateFeeCost = lateHours.multiply(rateLate);
                BigDecimal extraKmCost = extraKmFeeQty.multiply(rateKm);
                BigDecimal totalAdditionalFee = (returns != null && returns.getTotalAdditionalFee() != null
                        && returns.getTotalAdditionalFee().compareTo(BigDecimal.ZERO) > 0)
                                ? returns.getTotalAdditionalFee()
                                : lateFeeCost.add(extraKmCost).add(cleaningFee).add(damageFee).add(lostItemFee);

                PaymentDAO paymentDAO = new PaymentDAO();
                List<Payment> payments = paymentDAO.findByBookingId(bookingId);
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
                if (totalPaid.compareTo(BigDecimal.ZERO) == 0 && booking != null
                        && booking.getDepositAmount() != null) {
                    totalPaid = booking.getDepositAmount();
                }

                BigDecimal initialTotal = (booking != null && booking.getTotalAmount() != null)
                        ? booking.getTotalAmount()
                        : BigDecimal.ZERO;
                BigDecimal grandTotal = initialTotal.add(totalAdditionalFee);

                BigDecimal refund = BigDecimal.ZERO;
                BigDecimal extraPayment = BigDecimal.ZERO;

                if (totalPaid.compareTo(grandTotal) >= 0) {
                    refund = totalPaid.subtract(grandTotal);
                } else {
                    extraPayment = grandTotal.subtract(totalPaid);
                }

                request.setAttribute("lateFeeCost", lateFeeCost);
                request.setAttribute("extraKmCost", extraKmCost);
                request.setAttribute("cleaningFee", cleaningFee);
                request.setAttribute("damageFee", damageFee);
                request.setAttribute("lostItemFee", lostItemFee);
                request.setAttribute("totalAdditionalFee", totalAdditionalFee);
                request.setAttribute("refund", refund);
                request.setAttribute("extraPayment", extraPayment);
                request.setAttribute("totalPaid", totalPaid);
                User staff = null;
                if (returns != null && returns.getReceivedBy() > 0) {
                    staff = userDAO.findById(returns.getReceivedBy());
                }
                if (staff == null && handover != null && handover.getHandedBy() > 0) {
                    staff = userDAO.findById(handover.getHandedBy());
                }
                if (staff == null) {
                    staff = currentUser;
                }

                request.setAttribute("staff", staff);
                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("vehicle", car);
                request.setAttribute("contract", contract);
                request.setAttribute("handover", handover);
                request.setAttribute("returns", returns);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);
                request.setAttribute("vehicleId", carId);
                request.setAttribute("distanceDriven", distanceDriven);
                request.setAttribute("kmLimit", kmLimit);
                request.setAttribute("actualKm", distanceDriven);
                request.setAttribute("actualExtraKm", actualExtraKm);
                request.setAttribute("estimatedKm", estimatedKm);
                request.setAttribute("alreadyPaidExtraKm", alreadyPaidExtraKm);
                request.setAttribute("autoExtraKm", additionalExtraKm);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-view.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
    }
}
