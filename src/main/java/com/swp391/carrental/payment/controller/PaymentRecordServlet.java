package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.payment.constant.PaymentType;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.model.User;

/*
 * Name: PaymentRecordServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for PaymentRecordServlet.
 */



@WebServlet(name = "PaymentRecordServlet", urlPatterns = {"/payments/record"})
public class PaymentRecordServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();
    private final com.swp391.carrental.booking.service.BookingService bookingService = new com.swp391.carrental.booking.service.BookingService();
    private final com.swp391.carrental.vehicle.service.VehicleService vehicleService = new com.swp391.carrental.vehicle.service.VehicleService();
    private final com.swp391.carrental.user.service.UserService userService = new com.swp391.carrental.user.service.UserService();
    private final com.swp391.carrental.contract.service.ContractService contractService = new com.swp391.carrental.contract.service.ContractService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
            try {
                int bookingId = Integer.parseInt(bookingIdStr);
                com.swp391.carrental.booking.model.Booking booking = bookingService.getBookingById(bookingId);
                
                if (booking == null) {
                    request.setAttribute("errorMsg", "Không tìm thấy đơn đặt xe.");
                } else {
                    // Security Check: Customer can only view/pay their own bookings
                    if ("CUSTOMER".equals(currentUser.getRole()) && booking.getCustomerId() != currentUser.getUserId()) {
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập thanh toán cho đơn thuê này.");
                        return;
                    }

                    request.setAttribute("booking", booking);
                    com.swp391.carrental.vehicle.model.Car car = vehicleService.getCarById(booking.getCarId());
                    request.setAttribute("car", car);
                    if (car != null) {
                        request.setAttribute("carImageUrl", vehicleService.resolvePrimaryImageUrl(car.getCarId()));
                    }
                    request.setAttribute("customer", userService.getUserById(booking.getCustomerId()));
                    
                    // Contract Info
                    com.swp391.carrental.contract.model.RentalContract contract = contractService.getContractByBookingId(bookingId);
                    request.setAttribute("contract", contract);

                    // Compute payment metrics
                    java.util.List<Payment> payments = paymentService.getPaymentsByBooking(bookingId);
                    BigDecimal totalPaid = BigDecimal.ZERO;
                    boolean depositPaid = false;
                    boolean rentalPaid = false;
                    for (Payment p : payments) {
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
                    request.setAttribute("totalPaid", totalPaid);
                    request.setAttribute("depositPaid", depositPaid);
                    request.setAttribute("rentalPaid", rentalPaid);
                    
                    // Fetch vehicle return and include its totalAdditionalFee in totalAmount
                    com.swp391.carrental.handover.model.VehicleReturn vehicleReturn = null;
                    try {
                        vehicleReturn = new com.swp391.carrental.handover.dao.ReturnDAO().findByBookingId(bookingId);
                    } catch (Exception e) {
                        // ignore error
                    }
                    BigDecimal totalAmount = booking.getTotalAmount();
                    if (vehicleReturn != null && vehicleReturn.getTotalAdditionalFee() != null) {
                        totalAmount = totalAmount.add(vehicleReturn.getTotalAdditionalFee());
                    }
                    request.setAttribute("totalAmount", totalAmount);
                    request.setAttribute("returns", vehicleReturn);

                    BigDecimal remainingAmount = totalAmount.subtract(totalPaid);
                    BigDecimal excessAmount = BigDecimal.ZERO;
                    if (totalPaid.compareTo(totalAmount) > 0) {
                        excessAmount = totalPaid.subtract(totalAmount);
                    }
                    request.setAttribute("excessAmount", excessAmount);

                    if (remainingAmount.compareTo(BigDecimal.ZERO) < 0) {
                        remainingAmount = BigDecimal.ZERO;
                    }
                    request.setAttribute("remainingAmount", remainingAmount);

                    // Pre-select payment type based on current payment status
                    String defaultPaymentType = "DEPOSIT";
                    if (depositPaid) {
                        defaultPaymentType = "RENTAL";
                    }
                    if (rentalPaid) {
                        defaultPaymentType = "ADDITIONAL_FEE";
                    }
                    if (excessAmount.compareTo(BigDecimal.ZERO) > 0) {
                        defaultPaymentType = "REFUND";
                    }
                    request.setAttribute("defaultPaymentType", defaultPaymentType);

                    // Financial breakdown for "Booking Summary" on the right
                    long days = java.time.Duration.between(booking.getStartDate(), booking.getEndDate()).toDays();
                    if (days <= 0) days = 1;
                    request.setAttribute("rentalDays", days);
                }
            } catch (Exception e) {
                request.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            }
            // Always set enabledMethods for payment method dropdown
            request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
            request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
                   .forward(request, response);
            return;
        }

        // No bookingId: Customer is not allowed to view the global transactions log
        if ("CUSTOMER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/bookings/my");
            return;
        }

        // Staff/Admin: show global payment log
        request.setAttribute("payments",       paymentService.getAllPayments());
        request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
        request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Payment payment = buildPaymentFromRequest(request, currentUser.getUserId());
            // recordPayment() now calls validatePaymentMethod() + validateAmount() internally
            paymentService.recordPayment(payment);
            
            String redirectParam = request.getParameter("redirect");
            if ("booking".equals(redirectParam)) {
                request.getSession().setAttribute("successMessage", "Ghi nhận thanh toán thành công!");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + payment.getBookingId());
            } else {
                request.getSession().setAttribute("paymentSuccess", "Ghi nhận thanh toán thành công!");
                response.sendRedirect(request.getContextPath() + "/payments/record?bookingId=" + payment.getBookingId());
            }

        } catch (AppException e) {
            // Validation error — send user back with error message
            request.setAttribute("errorMsg",      e.getMessage());
            request.setAttribute("payments",       paymentService.getAllPayments());
            request.setAttribute("enabledMethods", paymentService.getEnabledMethods());
            request.getRequestDispatcher("/WEB-INF/views/payment/payment-record.jsp")
                   .forward(request, response);
        }
    }

    // ─── Helper ───────────────────────────────────────────────────────────────

    private Payment buildPaymentFromRequest(HttpServletRequest req, int userId) {
        Payment p = new Payment();
        p.setBookingId(Integer.parseInt(req.getParameter("bookingId")));

        String contractIdStr = req.getParameter("contractId");
        if (contractIdStr != null && !contractIdStr.isEmpty()) {
            p.setContractId(Integer.parseInt(contractIdStr));
        }

        p.setAmount(new BigDecimal(req.getParameter("amount")));
        p.setPaymentType(req.getParameter("paymentType"));
        p.setPaymentMethod(req.getParameter("paymentMethod"));
        p.setStatus("COMPLETED");
        p.setTransactionRef(req.getParameter("transactionRef"));
        p.setNotes(req.getParameter("notes"));
        p.setPaidAt(LocalDateTime.now());
        p.setRecordedBy(userId);
        return p;
    }
}

