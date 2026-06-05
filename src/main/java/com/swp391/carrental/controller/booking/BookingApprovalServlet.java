/*
 * Name: BookingApprovalServlet
 * @Author: BacBui
 * @Author: TungNLHE186756
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Handles booking approval/rejection by Staff/Admin. GET shows pending list, POST processes actions.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.constant.BookingStatus;
import com.swp391.carrental.constant.Role;
import com.swp391.carrental.exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Staff/Admin booking approval page.
 * URL: /bookings/approval
 */
@WebServlet(name = "BookingApprovalServlet", urlPatterns = {"/bookings/approval"})
public class BookingApprovalServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Booking> pendingBookings = bookingService.getBookingsByStatus(BookingStatus.PENDING);
        request.setAttribute("pendingBookings", pendingBookings);

        // Build user and car maps
        Map<Integer, User> userMap = new HashMap<>();
        Map<Integer, Car> carMap = new HashMap<>();
        for (Booking b : pendingBookings) {
            if (!userMap.containsKey(b.getCustomerId())) {
                try {
                    User u = userDAO.findById(b.getCustomerId());
                    if (u != null) {
                        userMap.put(b.getCustomerId(), u);
                    }
                } catch (Exception e) {
                    // Skip
                }
            }
            if (!carMap.containsKey(b.getCarId())) {
                Car car = vehicleService.getCarById(b.getCarId());
                if (car != null) {
                    carMap.put(b.getCarId(), car);
                }
            }
        }
        request.setAttribute("userMap", userMap);
        request.setAttribute("carMap", carMap);

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

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-approval.jsp")
                .forward(request, response);
    }

    /**
     * Process approve/reject actions.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null || (!Role.STAFF.equals(currentUser.getRole())
                && !Role.ADMIN.equals(currentUser.getRole()))) {
            request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                    .forward(request, response);
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String action = request.getParameter("action");

        try {
            int bookingId = Integer.parseInt(bookingIdStr);

            if ("approve".equals(action)) {
                bookingService.approveBooking(bookingId, currentUser.getUserId());
                request.getSession().setAttribute("successMessage",
                        "Đã duyệt booking #" + bookingId + " thành công.");
            } else if ("reject".equals(action)) {
                String reason = request.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Không đạt yêu cầu";
                }
                bookingService.rejectBooking(bookingId, currentUser.getUserId(), reason.trim());
                request.getSession().setAttribute("successMessage",
                        "Đã từ chối booking #" + bookingId + ".");
            }
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Mã booking không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/bookings/approval");
    }
}
