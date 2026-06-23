package com.swp391.carrental.handover.controller;

import com.swp391.carrental.booking.dao.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.handover.service.ReturnService;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;
import java.math.BigDecimal;
import java.sql.SQLException;

/*
 * Name: AdditionalFeesServlet
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for AdditionalFeesServlet.
 */
@WebServlet(name = "AdditionalFeesServlet", urlPatterns = {"/additional-fees"})
public class AdditionalFeesServlet extends HttpServlet {

    private final ReturnService returnService = new ReturnService();
    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final UserDAO userDAO = new UserDAO();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final FeeCalculator feeCalculator = new FeeCalculator();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");

            if (bookingIdStr != null && carIdStr != null) {

                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Car car = carDAO.findById(carId);
                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);

                // Calculate total paid so far
                com.swp391.carrental.payment.service.PaymentService paymentService = new com.swp391.carrental.payment.service.PaymentService();
                java.util.List<com.swp391.carrental.payment.model.Payment> payments = paymentService.getPaymentsByBooking(bookingId);
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (com.swp391.carrental.payment.model.Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(p.getAmount());
                        } else {
                            totalPaid = totalPaid.add(p.getAmount());
                        }
                    }
                }
                request.setAttribute("totalPaid", totalPaid);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }

                // Load rates dynamically from policy settings
                com.swp391.carrental.policy.service.PolicyService policyService = new com.swp391.carrental.policy.service.PolicyService();
                request.setAttribute("extraKmFeeRate", policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
                request.setAttribute("lateFeePerHour", policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));

                VehicleReturn returns = returnDAO.findByBookingId(bookingId);
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (returns != null) {
                    request.setAttribute("lateHours", returns.getLateHours());
                    request.setAttribute("extraKmFee", returns.getExtraKmFee());
                    request.setAttribute("damageFee", returns.getDamageFee());
                    request.setAttribute("cleaningFee", returns.getCleaningFee());
                    request.setAttribute("lostItemFee", returns.getLostItemFee());
                    request.setAttribute("deposit", booking != null ? booking.getDepositAmount() : BigDecimal.ZERO);
                    request.setAttribute("totalAdditionalFee", returns.getTotalAdditionalFee());
                    request.setAttribute("returns", returns);

                    // Automatically calculate extra km fee
                    // Only auto-fill if extraKmFee has not been entered manually (== 0 or null)
                    boolean extraKmNotSetYet = returns.getExtraKmFee() == null
                            || returns.getExtraKmFee().compareTo(BigDecimal.ZERO) == 0;

                    if (extraKmNotSetYet && handover != null && booking != null) {
                        int mileageAtHandover = handover.getMileageAtHandover();
                        int mileageAtReturn   = returns.getMileageAtReturn();
                        int actualKm          = Math.max(0, mileageAtReturn - mileageAtHandover);

                        int kmLimit = booking.getKmLimit() != null ? booking.getKmLimit() : 0;

                        // Actual extra km (total)
                        int actualExtraKm = Math.max(0, actualKm - kmLimit);

                        // Extra km paid in advance during booking (estimatedKm - kmLimit)
                        int estimatedKm = booking.getEstimatedKm() != null ? booking.getEstimatedKm() : 0;
                        int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);

                        // Only charge the difference
                        int additionalExtraKm = Math.max(0, actualExtraKm - alreadyPaidExtraKm);

                        request.setAttribute("autoExtraKm", additionalExtraKm);
                        request.setAttribute("actualKm", actualKm);
                        request.setAttribute("kmLimit", kmLimit);
                        request.setAttribute("estimatedKm", estimatedKm);
                        request.setAttribute("alreadyPaidExtraKm", alreadyPaidExtraKm);
                        request.setAttribute("actualExtraKm", actualExtraKm);
                    } else {
                        // Already entered manually - pass mileage information for JSP reference
                        if (handover != null && booking != null) {
                            int mileageAtHandover = handover.getMileageAtHandover();
                            int mileageAtReturn   = returns.getMileageAtReturn();
                            int actualKm          = Math.max(0, mileageAtReturn - mileageAtHandover);
                            int kmLimit = booking.getKmLimit() != null ? booking.getKmLimit() : 0;
                            int estimatedKm = booking.getEstimatedKm() != null ? booking.getEstimatedKm() : 0;
                            int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);
                            int actualExtraKm = Math.max(0, actualKm - kmLimit);
                            request.setAttribute("actualKm", actualKm);
                            request.setAttribute("kmLimit", kmLimit);
                            request.setAttribute("estimatedKm", estimatedKm);
                            request.setAttribute("alreadyPaidExtraKm", alreadyPaidExtraKm);
                            request.setAttribute("actualExtraKm", actualExtraKm);
                        }
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
        System.out.println("bookingId = " + request.getParameter("bookingId"));
        System.out.println("carId = " + request.getParameter("carId"));
        String action = request.getParameter("action");
        if ("save".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                int carId = Integer.parseInt(request.getParameter("carId"));

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

                response.sendRedirect(request.getContextPath() + "/returns/detail?bookingId=" + bookingId + "&carId=" + carId);
            } catch (SQLException e) {
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
