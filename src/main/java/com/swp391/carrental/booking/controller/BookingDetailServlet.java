package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: BookingDetailServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 1.0
 * Description: Displays booking detail for Customer (read-only) or Staff/Admin (with approve/reject actions).
 */



/**
 * Shows booking detail page.
 * Customer: read-only view of own booking.
 * Staff/Admin: full view with approve/reject actions.
 * URL: /bookings/detail
 */
@WebServlet(name = "BookingDetailServlet", urlPatterns = {"/bookings/detail"})
public class BookingDetailServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserDAO userDAO = new UserDAO();
    private final com.swp391.carrental.policy.service.PolicyService policyService = new com.swp391.carrental.policy.service.PolicyService();
    private final com.swp391.carrental.payment.service.PaymentService paymentService = new com.swp391.carrental.payment.service.PaymentService();
    private final com.swp391.carrental.contract.service.ContractService contractService = new com.swp391.carrental.contract.service.ContractService();

    /** Display booking detail page (view details, schedule, contract, payment status) */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            request.getRequestDispatcher("/WEB-INF/views/error/404.jsp")
                    .forward(request, response);
            return;
        }

        try {
            int bookingId = Integer.parseInt(idParam);
            Booking booking = bookingService.getBookingById(bookingId);

            if (booking == null) {
                request.getRequestDispatcher("/WEB-INF/views/error/404.jsp")
                        .forward(request, response);
                return;
            }

            if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "VIEW_BOOKING")
                    && !com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_BOOKING_REQUEST")) {
                request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                        .forward(request, response);
                return;
            }

            boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PROCESS_BOOKING_REQUEST");

            if (!isStaffOrAdmin && booking.getCustomerId() != currentUser.getUserId()) {
                request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                        .forward(request, response);
                return;
            }

            // Load related info
            Vehicle car = vehicleService.getVehicleById(booking.getVehicleId());
            request.setAttribute("booking", booking);
            request.setAttribute("car", car);
            request.setAttribute("taxRate", policyService.getPolicyValue("TAX_RATE", "10"));

            // Fetch payments & contract info
            java.util.List<com.swp391.carrental.payment.model.Payment> payments = paymentService.getPaymentsByBooking(bookingId);
            boolean depositPaid = false;
            boolean rentalPaid = false;
            java.math.BigDecimal totalPaid = java.math.BigDecimal.ZERO;
            java.math.BigDecimal depositPaidAmt = java.math.BigDecimal.ZERO;
            java.math.BigDecimal rentalPaidAmt = java.math.BigDecimal.ZERO;

            for (com.swp391.carrental.payment.model.Payment p : payments) {
                if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                    if ("DEDUCTION".equalsIgnoreCase(p.getPaymentMethod())) {
                        continue;
                    }
                    java.math.BigDecimal effectiveAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                    if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                        totalPaid = totalPaid.subtract(effectiveAmt);
                    } else {
                        totalPaid = totalPaid.add(effectiveAmt);
                    }

                    if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                        depositPaidAmt = depositPaidAmt.add(effectiveAmt);
                    } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                        rentalPaidAmt = rentalPaidAmt.add(effectiveAmt);
                    }
                }
            }

            if (booking.getDepositAmount() != null && depositPaidAmt.compareTo(booking.getDepositAmount()) >= 0) {
                depositPaid = true;
            }
            java.math.BigDecimal excessDeposit = java.math.BigDecimal.ZERO;
            if (booking.getTotalAmount() != null && booking.getDepositAmount() != null) {
                java.math.BigDecimal rentalRequired = booking.getTotalAmount().subtract(booking.getDepositAmount());
                if (depositPaidAmt.compareTo(booking.getDepositAmount()) > 0) {
                    excessDeposit = depositPaidAmt.subtract(booking.getDepositAmount());
                }
                java.math.BigDecimal effectiveRentalPaid = rentalPaidAmt;
                if (excessDeposit.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    effectiveRentalPaid = effectiveRentalPaid.add(excessDeposit);
                }
                if (effectiveRentalPaid.compareTo(rentalRequired) >= 0) {
                    rentalPaid = true;
                }
            }
            request.setAttribute("excessDeposit", excessDeposit);
            // Calculate refund and forfeiture for cancelled bookings
            java.math.BigDecimal refundAmt = java.math.BigDecimal.ZERO;
            for (com.swp391.carrental.payment.model.Payment p : payments) {
                if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                    java.math.BigDecimal effectiveAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                    refundAmt = refundAmt.add(effectiveAmt);
                }
            }

            boolean isForfeited = false;
            java.math.BigDecimal forfeitedAmount = java.math.BigDecimal.ZERO;
            if ("CANCELLED".equalsIgnoreCase(booking.getStatus())) {
                if (depositPaidAmt.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    if (refundAmt.compareTo(java.math.BigDecimal.ZERO) == 0) {
                        isForfeited = true;
                        forfeitedAmount = depositPaidAmt;
                    } else if (refundAmt.compareTo(depositPaidAmt) < 0) {
                        isForfeited = true;
                        forfeitedAmount = depositPaidAmt.subtract(refundAmt);
                    }
                }
            }

            com.swp391.carrental.policy.service.PolicyService policyService = new com.swp391.carrental.policy.service.PolicyService();
            int cancelFreeHours = Integer.parseInt(policyService.getPolicyValue("CANCEL_FREE_HOURS", "48"));
            int cancelPartialHours = Integer.parseInt(policyService.getPolicyValue("CANCEL_PARTIAL_HOURS", "24"));
            int cancelPartialRefundPercent = Integer.parseInt(policyService.getPolicyValue("CANCEL_PARTIAL_REFUND_PERCENT", "50"));

            int refundPercent = 100;
            int cancelHoursThreshold = cancelFreeHours;
            if (depositPaidAmt.compareTo(java.math.BigDecimal.ZERO) > 0 && refundAmt.compareTo(java.math.BigDecimal.ZERO) > 0) {
                if (refundAmt.compareTo(depositPaidAmt) < 0) {
                    refundPercent = cancelPartialRefundPercent;
                    cancelHoursThreshold = cancelPartialHours;
                }
            }

            request.setAttribute("payments", payments);
            request.setAttribute("depositPaid", depositPaid);
            request.setAttribute("rentalPaid", rentalPaid);
            request.setAttribute("totalPaid", totalPaid);
            request.setAttribute("refundAmt", refundAmt);
            request.setAttribute("refundPercent", refundPercent);
            request.setAttribute("cancelHoursThreshold", cancelHoursThreshold);
            request.setAttribute("cancelFreeHours", cancelFreeHours);
            request.setAttribute("cancelPartialHours", cancelPartialHours);
            request.setAttribute("isForfeited", isForfeited);
            request.setAttribute("forfeitedAmount", forfeitedAmount);
            request.setAttribute("depositPaidAmt", depositPaidAmt);
            // Fetch return details and calculate total required amount including additional fees
            com.swp391.carrental.handover.model.VehicleReturn vehicleReturn = null;
            try {
                vehicleReturn = new com.swp391.carrental.handover.dao.ReturnDAO().findByBookingId(bookingId);
            } catch (Exception e) {
                // ignore error
            }
            java.math.BigDecimal totalAdditionalFeeRequiredFromPayments = java.math.BigDecimal.ZERO;
            for (com.swp391.carrental.payment.model.Payment p : payments) {
                if ("ADDITIONAL_FEE".equalsIgnoreCase(p.getPaymentType())) {
                    totalAdditionalFeeRequiredFromPayments = totalAdditionalFeeRequiredFromPayments.add(p.getAmount());
                }
            }

            java.math.BigDecimal totalRequired = booking.getTotalAmount();
            if ("CANCELLED".equalsIgnoreCase(booking.getStatus()) || "REJECTED".equalsIgnoreCase(booking.getStatus())) {
                totalRequired = java.math.BigDecimal.ZERO;
            } else {
                java.math.BigDecimal returnAdditionalFee = java.math.BigDecimal.ZERO;
                if (vehicleReturn != null && vehicleReturn.getTotalAdditionalFee() != null) {
                    returnAdditionalFee = vehicleReturn.getTotalAdditionalFee();
                }
                
                if (totalAdditionalFeeRequiredFromPayments.compareTo(returnAdditionalFee) > 0) {
                    totalRequired = totalRequired.add(totalAdditionalFeeRequiredFromPayments);
                } else {
                    totalRequired = totalRequired.add(returnAdditionalFee);
                }
            }
            request.setAttribute("returns", vehicleReturn);
            request.setAttribute("totalRequired", totalRequired);
            request.setAttribute("remainingAmount", totalRequired.subtract(totalPaid));

            com.swp391.carrental.contract.model.RentalContract contract = contractService.getContractByBookingId(bookingId);
            request.setAttribute("contract", contract);

            com.swp391.carrental.handover.model.VehicleHandover handover = null;
            try {
                handover = new com.swp391.carrental.handover.dao.HandoverDAO().findByBookingId(bookingId);
            } catch (Exception e) {
                // ignore
            }
            request.setAttribute("handover", handover);

            // Calculate rental days for display
            if (booking.getStartDate() != null && booking.getEndDate() != null) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(
                        booking.getStartDate().toLocalDate(), booking.getEndDate().toLocalDate());
                if (days < 1) {
                    days = 1;
                }
                request.setAttribute("rentalDays", days);
            }

            // Transfer session messages
            String successMessage = (String) request.getSession().getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("success", successMessage);
                request.getSession().removeAttribute("successMessage");
            }
            String errorMessage = (String) request.getSession().getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("error", errorMessage);
                request.getSession().removeAttribute("errorMessage");
            }

            if (isStaffOrAdmin) {
                // Load customer info for staff view
                try {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                } catch (Exception e) {
                    // Continue without customer info
                }
                request.getRequestDispatcher("/WEB-INF/views/booking/booking-detail-staff.jsp")
                        .forward(request, response);
            } else {
                request.getRequestDispatcher("/WEB-INF/views/booking/booking-detail.jsp")
                        .forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.getRequestDispatcher("/WEB-INF/views/error/404.jsp")
                    .forward(request, response);
        }
    }
}
