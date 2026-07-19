package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();
    private final com.swp391.carrental.policy.service.PolicyService policyService = new com.swp391.carrental.policy.service.PolicyService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Car> featuredCars = vehicleService.getCarsByStatus("AVAILABLE");
        request.setAttribute("featuredCars", featuredCars);
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(featuredCars));
        
        Map<String, Object> stats = getDashboardStats();
        request.setAttribute("stats", stats);

        // Load pricing policy values for the pricing banner
        request.setAttribute("taxRate", policyService.getPolicyValue("TAX_RATE", "10"));
        request.setAttribute("depositPercentage", policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30"));
        request.setAttribute("deliveryFeePerKm", policyService.getPolicyValue("DELIVERY_FEE_PER_KM", "15000"));
        request.setAttribute("extraKmFee", policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
        request.setAttribute("kmLimitPerDay", policyService.getPolicyValue("KM_LIMIT_PER_DAY", "250"));
        request.setAttribute("tripKmLimit", policyService.getPolicyValue("TRIP_KM_LIMIT", "150"));
        request.setAttribute("tripRateMultiplierPercent", policyService.getPolicyValue("TRIP_RATE_MULTIPLIER_PERCENT", "20"));
        request.setAttribute("combo7DiscountPercent", policyService.getPolicyValue("COMBO_7_DISCOUNT_PERCENT", "15"));
        request.setAttribute("combo10DiscountPercent", policyService.getPolicyValue("COMBO_10_DISCOUNT_PERCENT", "20"));
        request.setAttribute("combo30DiscountPercent", policyService.getPolicyValue("COMBO_30_DISCOUNT_PERCENT", "30"));
        request.setAttribute("combo7KmLimit", policyService.getPolicyValue("COMBO_7_KM_LIMIT", "1500"));
        request.setAttribute("combo10KmLimit", policyService.getPolicyValue("COMBO_10_KM_LIMIT", "2000"));
        request.setAttribute("combo30KmLimit", policyService.getPolicyValue("COMBO_30_KM_LIMIT", "5000"));
        request.setAttribute("discountShortTier", policyService.getPolicyValue("DISCOUNT_SHORT_TIER", "5"));
        request.setAttribute("discountMediumTier", policyService.getPolicyValue("DISCOUNT_MEDIUM_TIER", "10"));
        request.setAttribute("discountLongTier", policyService.getPolicyValue("DISCOUNT_LONG_TIER", "20"));
        request.setAttribute("lowMileageDiscountPercent", policyService.getPolicyValue("LOW_MILEAGE_DISCOUNT_PERCENT", "5"));
        
        request.getRequestDispatcher("/WEB-INF/views/booking/home.jsp").forward(request, response);
    }

    private Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        // Default fallback values
        stats.put("availableCars", 0);
        stats.put("pendingBookings", 0);
        stats.put("activeBookings", 0);
        stats.put("monthlyRevenue", BigDecimal.ZERO);

        String sqlCars = "SELECT COUNT(*) FROM cars WHERE status = 'AVAILABLE'";
        String sqlPending = "SELECT COUNT(*) FROM bookings WHERE status = 'PENDING'";
        String sqlActive = "SELECT COUNT(*) FROM bookings WHERE status IN ('CONFIRMED', 'IN_PROGRESS')";
        String sqlRevenue = "SELECT SUM(amount) FROM payments WHERE status = 'COMPLETED'";

        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlCars);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("availableCars", rs.getInt(1));
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlPending);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("pendingBookings", rs.getInt(1));
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlActive);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("activeBookings", rs.getInt(1));
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlRevenue);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getBigDecimal(1) != null) {
                    stats.put("monthlyRevenue", rs.getBigDecimal(1));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
}


