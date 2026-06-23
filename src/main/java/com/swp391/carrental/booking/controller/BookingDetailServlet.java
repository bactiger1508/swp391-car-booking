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
import com.swp391.carrental.vehicle.model.Car;
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

            // Security: Customer can only view own bookings
            boolean isStaffOrAdmin = Role.STAFF.equals(currentUser.getRole())
                    || Role.ADMIN.equals(currentUser.getRole());

            if (!isStaffOrAdmin && booking.getCustomerId() != currentUser.getUserId()) {
                request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                        .forward(request, response);
                return;
            }

            // Load related info
            Car car = vehicleService.getCarById(booking.getCarId());
            request.setAttribute("booking", booking);
            request.setAttribute("car", car);
            request.setAttribute("taxRate", policyService.getPolicyValue("TAX_RATE", "10"));

            // Fetch payments & contract info
            java.util.List<com.swp391.carrental.payment.model.Payment> payments = paymentService.getPaymentsByBooking(bookingId);
            boolean depositPaid = false;
            boolean rentalPaid = false;
            java.math.BigDecimal totalPaid = java.math.BigDecimal.ZERO;
            for (com.swp391.carrental.payment.model.Payment p : payments) {
                if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                    if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                        // Refunds reduce the net paid amount
                        totalPaid = totalPaid.subtract(p.getAmount());
                    } else {
                        totalPaid = totalPaid.add(p.getAmount());
                    }
                    if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                        depositPaid = true;
                    } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                        rentalPaid = true;
                    }
                }
            }
            request.setAttribute("payments", payments);
            request.setAttribute("depositPaid", depositPaid);
            request.setAttribute("rentalPaid", rentalPaid);
            request.setAttribute("totalPaid", totalPaid);
            // Fetch return details and calculate total required amount including additional fees
            com.swp391.carrental.handover.model.VehicleReturn vehicleReturn = null;
            try {
                vehicleReturn = new com.swp391.carrental.handover.dao.ReturnDAO().findByBookingId(bookingId);
            } catch (Exception e) {
                // ignore error
            }
            java.math.BigDecimal totalRequired = booking.getTotalAmount();
            if (vehicleReturn != null && vehicleReturn.getTotalAdditionalFee() != null) {
                totalRequired = totalRequired.add(vehicleReturn.getTotalAdditionalFee());
            }
            request.setAttribute("returns", vehicleReturn);
            request.setAttribute("totalRequired", totalRequired);
            request.setAttribute("remainingAmount", totalRequired.subtract(totalPaid));

            com.swp391.carrental.contract.model.RentalContract contract = contractService.getContractByBookingId(bookingId);
            request.setAttribute("contract", contract);

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
