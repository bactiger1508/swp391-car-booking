package com.swp391.carrental.controller.booking;

import com.swp391.carrental.model.Car;
import com.swp391.carrental.service.VehicleService;
import com.swp391.carrental.util.DBContext;
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

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Car> featuredCars = vehicleService.getCarsByStatus("AVAILABLE");
        request.setAttribute("featuredCars", featuredCars);
        request.setAttribute("primaryImages", vehicleService.getPrimaryImageUrls(featuredCars));
        
        Map<String, Object> stats = getDashboardStats();
        request.setAttribute("stats", stats);
        
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


