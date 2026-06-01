/*
 * Name: BookingDetailServlet
 * @Author: BacBui
 * Date: 29/05/2026
 * Version: 1.0
 * Description: Displays booking detail for Customer (read-only) or Staff/Admin (with approve/reject actions).
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.constant.Role;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

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

            // Calculate rental days for display
            if (booking.getStartDate() != null && booking.getEndDate() != null) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(
                        booking.getStartDate().toLocalDate(), booking.getEndDate().toLocalDate());
                if (days < 1) {
                    days = 1;
                }
                request.setAttribute("rentalDays", days);
            }

            // Transfer session success message
            String successMessage = (String) request.getSession().getAttribute("successMessage");
            if (successMessage != null) {
                request.setAttribute("success", successMessage);
                request.getSession().removeAttribute("successMessage");
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
