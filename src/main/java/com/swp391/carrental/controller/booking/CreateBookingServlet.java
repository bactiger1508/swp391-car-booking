/*
 * Name: CreateBookingServlet
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Handles GET (load form) and POST (submit booking) for customer booking creation.
 */
package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.BookingService;
import com.swp391.carrental.service.PolicyService;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.constant.Role;
import com.swp391.carrental.exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;

/**
 * Handles customer booking creation.
 * URL: /bookings/create
 */
@WebServlet(name = "CreateBookingServlet", urlPatterns = {"/bookings/create"})
public class CreateBookingServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final PolicyService policyService = new PolicyService();

    /**
     * Show the create booking form.
     * Requires carId query parameter to pre-load car info.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !Role.CUSTOMER.equals(user.getRole())) {
            request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                    .forward(request, response);
            return;
        }

        // Always load available cars for dropdown
        List<Car> availableCars = vehicleService.getCarsByStatus("AVAILABLE");
        request.setAttribute("cars", availableCars);
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(availableCars));

        String carIdParam = request.getParameter("carId");
        if (carIdParam != null && !carIdParam.isEmpty()) {
            try {
                int carId = Integer.parseInt(carIdParam);
                request.setAttribute("selectedCarId", carId);
                Car car = vehicleService.getCarById(carId);
                if (car != null) {
                    request.setAttribute("car", car);
                } else {
                    request.setAttribute("error", "Xe không tồn tại.");
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Mã xe không hợp lệ.");
            }
        }

        // Load deposit percentage from policy
        String depositPct = policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
        request.setAttribute("depositPercentage", depositPct);

        request.getRequestDispatcher("/WEB-INF/views/booking/create-booking.jsp")
                .forward(request, response);
    }

    /**
     * Process booking form submission.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("currentUser");
        if (user == null || !Role.CUSTOMER.equals(user.getRole())) {
            request.getRequestDispatcher("/WEB-INF/views/error/access-denied.jsp")
                    .forward(request, response);
            return;
        }

        try {
            // Parse form parameters
            String carIdStr = request.getParameter("carId");
            String startDateVal = request.getParameter("startDate");
            String startTimeVal = request.getParameter("startTime");
            String endDateVal = request.getParameter("endDate");
            String endTimeVal = request.getParameter("endTime");
            String pickupLocation = request.getParameter("pickupLocation");
            String returnLocation = request.getParameter("returnLocation");
            String notes = request.getParameter("notes");

            // Basic validation
            if (carIdStr == null || carIdStr.isEmpty()) {
                throw new AppException("Vui lòng chọn xe.");
            }
            if (startDateVal == null || startDateVal.isEmpty()) {
                throw new AppException("Vui lòng chọn ngày bắt đầu.");
            }
            if (endDateVal == null || endDateVal.isEmpty()) {
                throw new AppException("Vui lòng chọn ngày kết thúc.");
            }
            if (pickupLocation == null || pickupLocation.trim().isEmpty()) {
                throw new AppException("Vui lòng nhập địa điểm nhận xe.");
            }
            if (returnLocation == null || returnLocation.trim().isEmpty()) {
                throw new AppException("Vui lòng nhập địa điểm trả xe.");
            }

            if (startTimeVal == null || startTimeVal.isEmpty()) {
                startTimeVal = "08:00";
            }
            if (endTimeVal == null || endTimeVal.isEmpty()) {
                endTimeVal = "08:00";
            }

            int carId = Integer.parseInt(carIdStr);
            LocalDateTime startDate = LocalDateTime.parse(startDateVal + "T" + startTimeVal);
            LocalDateTime endDate = LocalDateTime.parse(endDateVal + "T" + endTimeVal);

            // Load car to calculate costs
            Car car = vehicleService.getCarById(carId);
            if (car == null) {
                throw new AppException("Xe không tồn tại.");
            }

            // Calculate rental days (minimum 1 day)
            long rentalDays = ChronoUnit.DAYS.between(startDate.toLocalDate(), endDate.toLocalDate());
            if (rentalDays < 1) {
                rentalDays = 1;
            }

            // Calculate amounts
            BigDecimal dailyRate = car.getDailyRate();
            BigDecimal totalAmount = dailyRate.multiply(BigDecimal.valueOf(rentalDays));

            String depositPctStr = policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
            BigDecimal depositPct = new BigDecimal(depositPctStr);
            BigDecimal depositAmount = totalAmount.multiply(depositPct)
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.CEILING);

            // Build booking object
            Booking booking = new Booking();
            booking.setCustomerId(user.getUserId());
            booking.setCarId(carId);
            booking.setStartDate(startDate);
            booking.setEndDate(endDate);
            booking.setPickupLocation(pickupLocation.trim());
            booking.setReturnLocation(returnLocation.trim());
            booking.setNotes(notes != null ? notes.trim() : null);
            booking.setTotalAmount(totalAmount);
            booking.setDepositAmount(depositAmount);

            // Create booking (service handles all business rule validation)
            int bookingId = bookingService.createBooking(booking);

            request.getSession().setAttribute("successMessage",
                    "Đặt xe thành công! Mã booking: #" + bookingId + ". Vui lòng chờ xác nhận.");
            response.sendRedirect(request.getContextPath() + "/bookings/my");

        } catch (AppException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (DateTimeParseException e) {
            request.setAttribute("error", "Định dạng ngày không hợp lệ.");
            doGet(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Dữ liệu không hợp lệ.");
            doGet(request, response);
        }
    }
}
