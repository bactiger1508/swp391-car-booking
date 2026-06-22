package com.swp391.carrental.booking.controller;

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
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;
import com.swp391.carrental.policy.service.FeeCalculator;

/*
 * Name: CreateBookingServlet
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 2.0
 * Description: Handles GET (load form) and POST (submit booking) for customer booking creation.
 */

/**
 * Handles customer booking creation.
 * URL: /bookings/create
 */
@WebServlet(name = "CreateBookingServlet", urlPatterns = {"/bookings/create"})
public class CreateBookingServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final PolicyService policyService = new PolicyService();
    private final FeeCalculator feeCalculator = new FeeCalculator();

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

        // Load all pricing policy configurations dynamically to pass to JSP
        request.setAttribute("depositPercentage", policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30"));
        request.setAttribute("taxRate", policyService.getPolicyValue("TAX_RATE", "10"));
        request.setAttribute("deliveryFeePerKm", policyService.getPolicyValue("DELIVERY_FEE_PER_KM", "15000"));
        request.setAttribute("tripKmLimit", policyService.getPolicyValue("TRIP_KM_LIMIT", "150"));
        request.setAttribute("combo7KmLimit", policyService.getPolicyValue("COMBO_7_KM_LIMIT", "1500"));
        request.setAttribute("combo10KmLimit", policyService.getPolicyValue("COMBO_10_KM_LIMIT", "2000"));
        request.setAttribute("combo30KmLimit", policyService.getPolicyValue("COMBO_30_KM_LIMIT", "5000"));
        request.setAttribute("kmLimitPerDay", policyService.getPolicyValue("KM_LIMIT_PER_DAY", "250"));
        request.setAttribute("discountLongTier", policyService.getPolicyValue("DISCOUNT_LONG_TIER", "20"));
        request.setAttribute("discountMediumTier", policyService.getPolicyValue("DISCOUNT_MEDIUM_TIER", "10"));
        request.setAttribute("discountShortTier", policyService.getPolicyValue("DISCOUNT_SHORT_TIER", "5"));
        request.setAttribute("lowMileageDiscountPercent", policyService.getPolicyValue("LOW_MILEAGE_DISCOUNT_PERCENT", "5"));
        request.setAttribute("extraKmFee", policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
        request.setAttribute("tripRateMultiplierPercent", policyService.getPolicyValue("TRIP_RATE_MULTIPLIER_PERCENT", "20"));
        request.setAttribute("combo7DiscountPercent", policyService.getPolicyValue("COMBO_7_DISCOUNT_PERCENT", "15"));
        request.setAttribute("combo10DiscountPercent", policyService.getPolicyValue("COMBO_10_DISCOUNT_PERCENT", "20"));
        request.setAttribute("combo30DiscountPercent", policyService.getPolicyValue("COMBO_30_DISCOUNT_PERCENT", "30"));
        
        request.setAttribute("tetStartDate", policyService.getPolicyValue("TET_START_DATE", "2026-02-12"));
        request.setAttribute("tetEndDate", policyService.getPolicyValue("TET_END_DATE", "2026-02-22"));
        request.setAttribute("tetSurchargePercent", policyService.getPolicyValue("TET_SURCHARGE_PERCENT", "20"));


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

            // Redesign fields
            String rentalMode = request.getParameter("rentalMode");
            if (rentalMode == null || rentalMode.trim().isEmpty()) {
                rentalMode = "DAILY";
            }
            String pricingPackage = request.getParameter("pricingPackage");
            if (pricingPackage != null && pricingPackage.trim().isEmpty()) {
                pricingPackage = null;
            }
            String deliveryMethod = request.getParameter("deliveryMethod");
            if (deliveryMethod == null || deliveryMethod.trim().isEmpty()) {
                deliveryMethod = "SHOWROOM";
            }
            String deliveryAddress = request.getParameter("deliveryAddress");
            String deliveryDistanceStr = request.getParameter("deliveryDistance");
            BigDecimal deliveryDistance = BigDecimal.ZERO;
            if (deliveryDistanceStr != null && !deliveryDistanceStr.trim().isEmpty()) {
                try {
                    deliveryDistance = new BigDecimal(deliveryDistanceStr);
                } catch (NumberFormatException e) {
                    // default to zero
                }
            }
            String estimatedKmStr = request.getParameter("estimatedKm");
            Integer estimatedKm = null;
            if (estimatedKmStr != null && !estimatedKmStr.trim().isEmpty()) {
                try {
                    estimatedKm = Integer.parseInt(estimatedKmStr);
                } catch (NumberFormatException e) {
                    // default to null
                }
            }

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
            java.time.LocalDateTime startDate = java.time.LocalDateTime.parse(startDateVal + "T" + startTimeVal);
            java.time.LocalDateTime endDate = java.time.LocalDateTime.parse(endDateVal + "T" + endTimeVal);

            // Time & Date Logical Validation
            java.time.LocalDate today = java.time.LocalDate.now();
            if (startDate.toLocalDate().isBefore(today)) {
                throw new AppException("Ngày bắt đầu không được ở quá khứ.");
            }
            if (endDate.isBefore(startDate)) {
                throw new AppException("Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.");
            }
            if (endDate.toLocalDate().isEqual(startDate.toLocalDate()) && !endDate.toLocalTime().isAfter(startDate.toLocalTime())) {
                throw new AppException("Giờ kết thúc phải lớn hơn giờ bắt đầu khi chọn cùng ngày.");
            }

            // Estimated KM Validation
            if (estimatedKm == null || estimatedKm <= 0) {
                throw new AppException("Vui lòng nhập số km di chuyển dự kiến hợp lệ (lớn hơn 0).");
            }

            // Delivery Specific Validation
            if ("DELIVERY".equalsIgnoreCase(deliveryMethod)) {
                if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
                    throw new AppException("Vui lòng nhập địa chỉ giao xe tận nơi.");
                }
                if (deliveryDistance == null || deliveryDistance.compareTo(BigDecimal.ZERO) <= 0) {
                    throw new AppException("Vui lòng nhập khoảng cách giao xe lớn hơn 0.");
                }
            }

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

            // Combo Package duration validation
            if ("COMBO_10_DAYS".equalsIgnoreCase(pricingPackage) && rentalDays != 10) {
                throw new AppException("Gói combo 10 ngày yêu cầu thời gian thuê chính xác là 10 ngày.");
            }
            if ("COMBO_7_DAYS".equalsIgnoreCase(pricingPackage) && rentalDays != 7) {
                throw new AppException("Gói combo tuần yêu cầu thời gian thuê chính xác là 7 ngày.");
            }
            if ("COMBO_30_DAYS".equalsIgnoreCase(pricingPackage) && rentalDays != 30) {
                throw new AppException("Gói combo tháng yêu cầu thời gian thuê chính xác là 30 ngày.");
            }

            // Perform calculations using FeeCalculator
            BigDecimal baseAmount = feeCalculator.calculateBaseAmount(car, rentalMode, pricingPackage, rentalDays);
            int kmLimit = feeCalculator.calculateKmLimit(rentalMode, pricingPackage, rentalDays);
            
            BigDecimal tierDiscount = feeCalculator.calculateTierDiscount(baseAmount, rentalMode, rentalDays);
            BigDecimal lowMileageDiscount = BigDecimal.ZERO;
            if (estimatedKm != null) {
                lowMileageDiscount = feeCalculator.calculateLowMileageDiscount(baseAmount, estimatedKm, kmLimit);
            }
            BigDecimal discountAmount = tierDiscount.add(lowMileageDiscount);

            BigDecimal estimatedSurcharge = BigDecimal.ZERO;
            if (estimatedKm != null) {
                estimatedSurcharge = feeCalculator.calculateEstimatedExtraKmFee(car, pricingPackage, estimatedKm, kmLimit);
            }

            BigDecimal deliveryFee = feeCalculator.calculateDeliveryFee(deliveryMethod, deliveryDistance);
            
            // Calculate Tet Surcharge
            BigDecimal tetSurcharge = feeCalculator.calculateTetSurcharge(car, startDate, endDate);
            
            BigDecimal subTotal = baseAmount.subtract(discountAmount).add(estimatedSurcharge).add(deliveryFee).add(tetSurcharge);
            if (subTotal.compareTo(BigDecimal.ZERO) < 0) {
                subTotal = BigDecimal.ZERO;
            }

            String taxRateStr = policyService.getPolicyValue("TAX_RATE", "10");
            BigDecimal taxRate = new BigDecimal(taxRateStr).divide(BigDecimal.valueOf(100));
            BigDecimal taxAmount = subTotal.multiply(taxRate).setScale(0, RoundingMode.HALF_UP);
            BigDecimal totalAmount = subTotal.add(taxAmount);
            BigDecimal depositAmount = feeCalculator.calculateDeposit(totalAmount).setScale(0, RoundingMode.HALF_UP);

            // Record Tet surcharge in notes
            if (tetSurcharge.compareTo(BigDecimal.ZERO) > 0) {
                String tetNote = "[Phụ thu Tết Nguyên Đán: +" + new java.text.DecimalFormat("#,###").format(tetSurcharge) + "đ]";
                notes = (notes != null && !notes.trim().isEmpty()) ? notes.trim() + " " + tetNote : tetNote;
            }

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

            // Add Redesign fields
            booking.setRentalMode(rentalMode);
            booking.setPricingPackage(pricingPackage);
            booking.setDeliveryMethod(deliveryMethod);
            booking.setDeliveryAddress(deliveryAddress != null ? deliveryAddress.trim() : null);
            booking.setDeliveryDistance(deliveryDistance);
            booking.setDeliveryFee(deliveryFee);
            booking.setKmLimit(kmLimit);
            booking.setEstimatedKm(estimatedKm);
            booking.setBaseAmount(baseAmount);
            booking.setDiscountAmount(discountAmount);
            booking.setTaxAmount(taxAmount);

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
