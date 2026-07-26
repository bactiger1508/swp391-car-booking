package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.handover.service.ReturnService;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

import com.swp391.carrental.vehicle.service.VehicleService;
import java.math.BigDecimal;
import java.util.List;
import java.io.IOException;

/**
 * Name: AdditionalFeesServlet
 * @Author: TamTTMHE190340
 * Date: 19/06/2026
 * Version: 1.0
 * Description: Controller for calculating, previewing, and applying additional fees (late fees, extra km fees, damage, cleaning).
 */
@WebServlet(name = "AdditionalFeesServlet", urlPatterns = {"/additional-fees"})
public class AdditionalFeesServlet extends HttpServlet {

    private final ReturnService returnService = new ReturnService();
    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final VehicleService vehicleService = new VehicleService();
    private final UserDAO userDAO = new UserDAO();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final FeeCalculator feeCalculator = new FeeCalculator();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String vehicleIdStr = request.getParameter("vehicleId");

            if (bookingIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                Booking booking = bookingDAO.findById(bookingId);
                int vehicleId = (vehicleIdStr != null && !vehicleIdStr.trim().isEmpty())
                        ? Integer.parseInt(vehicleIdStr)
                        : (booking != null ? booking.getVehicleId() : 0);

                Vehicle car = vehicleService.getVehicleById(vehicleId);
                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("vehicle", car);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("vehicleId", vehicleId);

                // Calculate total paid so far
                PaymentService paymentService = new PaymentService();
                List<Payment> payments = paymentService.getPaymentsByBooking(bookingId);
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        BigDecimal amt = (p.getAmountPaid() != null && p.getAmountPaid().compareTo(BigDecimal.ZERO) > 0) ? p.getAmountPaid() : p.getAmount();
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(amt);
                        } else {
                            totalPaid = totalPaid.add(amt);
                        }
                    }
                }
                request.setAttribute("totalPaid", totalPaid);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }

                // Load rates dynamically from policy settings
                PolicyService policyService = new PolicyService();
                request.setAttribute("extraKmFeeRate", policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
                request.setAttribute("lateFeePerHour", policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));

                VehicleReturn returns = returnDAO.findByBookingId(bookingId);
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
                if (handover == null && car != null) {
                    handover = new VehicleHandover();
                    handover.setBookingId(bookingId);
                    handover.setVehicleId(vehicleId);
                    handover.setMileageAtHandover(car.getMileage());
                    handover.setFuelLevel("FULL");
                } else if (handover != null && handover.getMileageAtHandover() <= 0 && car != null) {
                    handover.setMileageAtHandover(car.getMileage());
                }

                if (returns != null) {
                    request.setAttribute("lateHours", returns.getLateHours());
                    request.setAttribute("extraKmFee", returns.getExtraKmFee());
                    request.setAttribute("damageFee", returns.getDamageFee());
                    request.setAttribute("cleaningFee", returns.getCleaningFee());
                    request.setAttribute("lostItemFee", returns.getLostItemFee());
                    request.setAttribute("deposit", booking != null ? booking.getDepositAmount() : BigDecimal.ZERO);
                    request.setAttribute("totalAdditionalFee", returns.getTotalAdditionalFee());
                    request.setAttribute("returns", returns);

                    long days = 1;
                    if (booking != null && booking.getStartDate() != null && booking.getEndDate() != null) {
                        days = java.time.temporal.ChronoUnit.DAYS.between(booking.getStartDate().toLocalDate(), booking.getEndDate().toLocalDate());
                        if (days < 1) days = 1;
                    }

                    com.swp391.carrental.policy.service.FeeCalculator feeCalc = new com.swp391.carrental.policy.service.FeeCalculator();
                    int kmLimit = (booking != null && booking.getKmLimit() != null && booking.getKmLimit() > 0)
                            ? booking.getKmLimit()
                            : (booking != null ? feeCalc.calculateKmLimit(booking.getRentalMode(), booking.getPricingPackage(), days) : 250);
                    int estimatedKm = (booking != null && booking.getEstimatedKm() != null) ? booking.getEstimatedKm() : 0;
                    int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);

                    if (handover != null) {
                        int mileageAtHandover = handover.getMileageAtHandover();
                        int mileageAtReturn = returns.getMileageAtReturn();
                        int actualKm = 0;
                        if (mileageAtReturn > 0) {
                            if (mileageAtReturn >= mileageAtHandover && mileageAtHandover > 0) {
                                actualKm = mileageAtReturn - mileageAtHandover;
                            } else {
                                actualKm = mileageAtReturn;
                            }
                        }
                        int actualExtraKm = Math.max(0, actualKm - kmLimit);
                        request.setAttribute("actualKm", actualKm);
                        request.setAttribute("kmLimit", kmLimit);
                        request.setAttribute("estimatedKm", estimatedKm);
                        request.setAttribute("alreadyPaidExtraKm", alreadyPaidExtraKm);
                        request.setAttribute("actualExtraKm", actualExtraKm);
                    }
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi tải dữ liệu phụ thu: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/additional-fees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("save".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                String vehicleIdStr = request.getParameter("vehicleId");
                int vehicleId = Integer.parseInt(vehicleIdStr);

                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                if (returns == null) {
                    throw new ServletException("Return record not found");
                }

                String lateHoursStr = request.getParameter("lateHours");
                String extraKmFeeStr = request.getParameter("extraKmFee");
                String damageFeeStr = request.getParameter("damageFee");
                String cleaningFeeStr = request.getParameter("cleaningFee");
                String lostItemFeeStr = request.getParameter("lostItemFee");
                String totalAdditionalFeeStr = request.getParameter("totalAdditionalFee");

                BigDecimal lateHours = safeBigDecimal(lateHoursStr);
                BigDecimal extraKmFee = safeBigDecimal(extraKmFeeStr);
                BigDecimal damageFee = safeBigDecimal(damageFeeStr);
                BigDecimal cleaningFee = safeBigDecimal(cleaningFeeStr);
                BigDecimal lostItemFee = safeBigDecimal(lostItemFeeStr);
                BigDecimal totalAdditionalFee = safeBigDecimal(totalAdditionalFeeStr);

                returns.setLateHours(lateHours);
                returns.setExtraKmFee(extraKmFee);
                returns.setDamageFee(damageFee);
                returns.setCleaningFee(cleaningFee);
                returns.setLostItemFee(lostItemFee);
                returns.setTotalAdditionalFee(totalAdditionalFee);

                returnService.updateReturnVehicle(returns);
                request.getSession().setAttribute("notification", "Đã lưu và áp dụng phụ thu vào đơn hàng!");

                response.sendRedirect(request.getContextPath() + "/returns/detail?bookingId=" + bookingId + "&vehicleId=" + vehicleId);
                return;
            } catch (Exception e) {
                e.printStackTrace();
                throw new ServletException(e);
            }
        }
    }

    private BigDecimal safeBigDecimal(String value) {
        if (value == null || value.trim().isEmpty()) {
            return BigDecimal.ZERO;
        }
        return new BigDecimal(value);
    }
}
