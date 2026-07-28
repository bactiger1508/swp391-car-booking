package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.handover.service.ReturnService;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;

/**
 * Name: VehicleReturnListServlet
 *
 * @Author: TamTTMHE190340 Date: 28/07/2026 Version: 1.0 Description: Controller
 * for displaying the list of all vehicle returns, distance driven, and refund
 * calculations.
 */
@WebServlet(name = "VehicleReturnListServlet", urlPatterns = {"/returns"})
public class VehicleReturnListServlet extends HttpServlet {

    private final ReturnService returnService = new ReturnService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final HandoverDAO handoverDAO = new HandoverDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<VehicleReturn> returns = returnService.getAllReturns();
            Map<Integer, BigDecimal> refundsMap = new HashMap<>();
            Map<Integer, Integer> distanceDrivenMap = new HashMap<>();
            Map<Integer, Booking> bookings = new HashMap<>();

            for (VehicleReturn r : returns) {
                Booking booking = bookingDAO.findById(r.getBookingId());

                if (booking != null) {
                    BigDecimal surcharge = r.getTotalAdditionalFee() != null ? r.getTotalAdditionalFee() : BigDecimal.ZERO;

                    PaymentDAO paymentDAO = new PaymentDAO();
                    List<Payment> payments = paymentDAO.findByBookingId(r.getBookingId());
                    BigDecimal grossPaid = BigDecimal.ZERO;
                    BigDecimal completedRefunds = BigDecimal.ZERO;
                    for (Payment p : payments) {
                        if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                            if ("DEDUCTION".equalsIgnoreCase(p.getPaymentMethod())) {
                                continue;
                            }
                            BigDecimal effectiveAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                            if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                                completedRefunds = completedRefunds.add(effectiveAmt);
                            } else {
                                grossPaid = grossPaid.add(effectiveAmt);
                            }
                        }
                    }

                    BigDecimal depositAmt = booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO;
                    BigDecimal pureRentalFee = booking.getTotalAmount().subtract(depositAmt);
                    BigDecimal totalRequired = pureRentalFee.add(surcharge);

                    BigDecimal netRefund = BigDecimal.ZERO;
                    if (completedRefunds.compareTo(BigDecimal.ZERO) > 0) {
                        netRefund = completedRefunds;
                    } else if (grossPaid.compareTo(totalRequired) > 0) {
                        netRefund = grossPaid.subtract(totalRequired);
                    }

                    VehicleHandover handover = handoverDAO.findByBookingId(r.getBookingId());
                    int mHandover = handover != null ? handover.getMileageAtHandover() : 0;
                    int mReturn = r.getMileageAtReturn();
                    int driven = 0;
                    if (mReturn > 0) {
                        if (mHandover > 0 && mReturn >= mHandover) {
                            driven = mReturn - mHandover;
                        } else {
                            driven = mReturn;
                        }
                    }

                    refundsMap.put(r.getBookingId(), netRefund);
                    distanceDrivenMap.put(r.getBookingId(), driven);
                    bookings.put(r.getBookingId(), booking);
                }
            }

            request.setAttribute("returns", returns);
            request.setAttribute("refundsMap", refundsMap);
            request.setAttribute("distanceDrivenMap", distanceDrivenMap);
            request.setAttribute("bookings", bookings);

            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Record return (BR-07, BR-08)
        response.sendRedirect(request.getContextPath() + "/returns");
    }
}
