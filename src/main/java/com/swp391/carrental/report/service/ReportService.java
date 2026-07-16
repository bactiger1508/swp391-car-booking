package com.swp391.carrental.report.service;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.LinkedHashMap;

/*
 * Name: ReportService
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for ReportService.
 */
/**
 * Service for generating reports.
 */
public class ReportService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CarDAO carDAO = new CarDAO();
    private final PaymentService paymentService = new PaymentService();
    private final BookingService bookingService = new BookingService();

    /**
     * Generate revenue report data for a date range. Returns a map with summary
     * fields.
     */
    public Map<String, Object> generateRevenueReport(LocalDate startDate, LocalDate endDate) {
        // TODO: Implement full revenue report with date filtering
        Map<String, Object> report = new HashMap<>();
        try {
            List<Payment> allPayments = paymentDAO.findAll();

            BigDecimal totalRevenue = BigDecimal.ZERO;
            int totalTransactions = 0;

            for (Payment p : allPayments) {
                if ("COMPLETED".equals(p.getStatus())) {
                    totalRevenue = totalRevenue.add(p.getAmount());
                    totalTransactions++;
                }
            }

            report.put("totalRevenue", totalRevenue);
            report.put("totalTransactions", totalTransactions);
            report.put("startDate", startDate);
            report.put("endDate", endDate);
            report.put("payments", allPayments);

        } catch (SQLException e) {
            throw new AppException("Failed to generate revenue report.", e);
        }
        return report;
    }

    /**
     * Generate vehicle utilization report. TODO: Implement with actual metrics
     * (days rented / total days).
     */
    public Map<String, Object> generateVehicleUtilizationReport() {
        Map<String, Object> report = new HashMap<>();
        // TODO: Calculate utilization per car
        // utilization = days_rented / total_days_in_period * 100
        report.put("message", "Vehicle utilization report - to be implemented");
        return report;
    }

    public BigDecimal getTotalRevenue(LocalDate fromDate, LocalDate toDate) {
        BigDecimal total = BigDecimal.ZERO;

        List<Payment> payments = paymentService.getAllPayments();

        for (Payment p : payments) {
            if (!"COMPLETED".equals(p.getStatus())) {
                continue;
            }

            LocalDate paymentDate = p.getPaidAt().toLocalDate();
            if ((paymentDate.isEqual(fromDate) || paymentDate.isAfter(fromDate))
                    && (paymentDate.isEqual(toDate) || paymentDate.isBefore(toDate))) {
                total = total.add(p.getAmount());
            }
        }
        return total;
    }

    public BigDecimal getRevenueByType(String paymentType, LocalDate fromDate, LocalDate toDate) {

        BigDecimal total = BigDecimal.ZERO;

        for (Payment p : paymentService.getAllPayments()) {

            if (!"COMPLETED".equals(p.getStatus())
                    || !paymentType.equals(p.getPaymentType())) {
                continue;
            }

            LocalDate paymentDate = p.getPaidAt().toLocalDate();

            if (!paymentDate.isBefore(fromDate)
                    && !paymentDate.isAfter(toDate)) {

                total = total.add(p.getAmount());
            }
        }

        return total;
    }

    public BigDecimal getDepositRevenue(LocalDate fromDate, LocalDate toDate) {
        BigDecimal deposit = BigDecimal.ZERO;

        for (Booking b : bookingService.getAllBookings()) {

            if (!"IN_PROGRESS".equals(b.getStatus())) {
                continue;
            }

            LocalDate bookingDate = b.getEndDate().toLocalDate();

            if (!bookingDate.isBefore(fromDate)
                    && !bookingDate.isAfter(toDate)) {

                deposit = deposit.add(b.getDepositAmount());
            }
        }
        return deposit;
    }

    public int getCompletedBooking(LocalDate fromDate, LocalDate toDate) {
        int totalBooking = 0;

        List<Booking> bookings = bookingService.getAllBookings();

        for (Booking b : bookings) {
            if (!"COMPLETED".equals(b.getStatus())) {
                continue;
            }

            LocalDate handoverDate = b.getEndDate().toLocalDate();

            if (!handoverDate.isBefore(fromDate) && !handoverDate.isAfter(toDate)) {

                totalBooking++;
            }
        }

        return totalBooking;
    }

    public double calculateGrowth(BigDecimal current, BigDecimal previous) {
        if (previous == null || previous.compareTo(BigDecimal.ZERO) == 0) {
            return 0;
        }
        return current.subtract(previous).multiply(BigDecimal.valueOf(100)).divide(previous, 2, RoundingMode.HALF_UP).doubleValue();
    }

    public Map<String, BigDecimal> getRevenueByCarSegment(LocalDate from, LocalDate to) throws SQLException {

        Map<String, BigDecimal> segmentRevenue = new LinkedHashMap<>();

        segmentRevenue.put("Sedan", BigDecimal.ZERO);
        segmentRevenue.put("SUV / Crossover", BigDecimal.ZERO);
        segmentRevenue.put("MPV gia đình", BigDecimal.ZERO);
        segmentRevenue.put("Xe bán tải / Pickup", BigDecimal.ZERO);
        segmentRevenue.put("Xe điện", BigDecimal.ZERO);

        List<Car> cars = carDAO.findAll();
        List<Booking> bookings = bookingDAO.findAll();

        for (Booking booking : bookings) {
            LocalDate bookingDate = booking.getStartDate().toLocalDate();

            if (bookingDate.isBefore(from) || bookingDate.isAfter(to)) {
                continue;
            }

            Car car = cars.stream().filter(c -> c.getCarId() == booking.getCarId()).findFirst().orElse(null);

            if (car == null) {
                continue;
            }

            String segment = classifyCar(car);

            BigDecimal revenue = booking.getTotalAmount();

            segmentRevenue.put(segment, segmentRevenue.get(segment).add(revenue));
        }
        return segmentRevenue;
    }

    private String classifyCar(Car car) {
        if ("ELECTRIC".equalsIgnoreCase(car.getFuelType())) {
            return "Xe điện";
        }

        String model = car.getModel().toLowerCase();

        if (model.contains("ranger") || model.contains("hilux") || model.contains("triton") || model.contains("navara") || model.contains("d-max")) {
            return "Xe bán tải / Pickup";
        }

        if (car.getSeats() == 7) {
            return "MPV gia đình";
        }

        if (car.getSeats() == 5) {
            return "SUV / Crossover";
        }

        if (car.getSeats() == 4) {
            return "Sedan";
        }

        return "Khác";
    }

    public List<Map<String, Object>> getRevenueChart(LocalDate from, LocalDate to, String type) {

        List<Map<String, Object>> chart = new ArrayList<>();

        if ("MONTH".equals(type)) {

            for (int week = 1; week <= 5; week++) {

                BigDecimal revenue = BigDecimal.ZERO;

                LocalDate start = from.plusDays((week - 1) * 7L);
                LocalDate end = start.plusDays(6);

                if (end.isAfter(to)) {
                    end = to;
                }

                for (Payment p : paymentService.getAllPayments()) {

                    if (!"COMPLETED".equals(p.getStatus())) {
                        continue;
                    }

                    LocalDate paid = p.getPaidAt().toLocalDate();

                    if (!paid.isBefore(start) && !paid.isAfter(end)) {
                        revenue = revenue.add(p.getAmount());
                    }
                }

                Map<String, Object> item = new HashMap<>();
                item.put("label", "T" + week);
                item.put("revenue", revenue);

                chart.add(item);
            }

        } else if ("QUARTER".equals(type)) {

            for (int i = 0; i < 3; i++) {

                LocalDate monthStart = from.plusMonths(i).withDayOfMonth(1);
                LocalDate monthEnd = monthStart.withDayOfMonth(monthStart.lengthOfMonth());

                BigDecimal revenue = BigDecimal.ZERO;

                for (Payment p : paymentService.getAllPayments()) {

                    if (!"COMPLETED".equals(p.getStatus())) {
                        continue;
                    }

                    LocalDate paid = p.getPaidAt().toLocalDate();

                    if (!paid.isBefore(monthStart) && !paid.isAfter(monthEnd)) {
                        revenue = revenue.add(p.getAmount());
                    }
                }

                Map<String, Object> item = new HashMap<>();

                item.put("label", "T" + monthStart.getMonthValue());
                item.put("revenue", revenue);

                chart.add(item);
            }

        } else {

            for (int month = 1; month <= 12; month++) {

                LocalDate monthStart = LocalDate.of(from.getYear(), month, 1);
                LocalDate monthEnd = monthStart.withDayOfMonth(monthStart.lengthOfMonth());

                BigDecimal revenue = BigDecimal.ZERO;

                for (Payment p : paymentService.getAllPayments()) {

                    if (!"COMPLETED".equals(p.getStatus())) {
                        continue;
                    }

                    LocalDate paid = p.getPaidAt().toLocalDate();

                    if (!paid.isBefore(monthStart) && !paid.isAfter(monthEnd)) {
                        revenue = revenue.add(p.getAmount());
                    }
                }

                Map<String, Object> item = new HashMap<>();
                item.put("label", "T" + month);
                item.put("revenue", revenue);

                chart.add(item);
            }

        }

        BigDecimal max = BigDecimal.ONE;

        for (Map<String, Object> c : chart) {
            BigDecimal r = (BigDecimal) c.get("revenue");
            if (r.compareTo(max) > 0) {
                max = r;
            }
        }

        for (Map<String, Object> c : chart) {
            BigDecimal r = (BigDecimal) c.get("revenue");
            double height = r.multiply(BigDecimal.valueOf(100)).divide(max, 2, RoundingMode.HALF_UP).doubleValue();
            c.put("height", height);
        }

        return chart;
    }

    public List<Map<String, Object>> getRecentTransactions(LocalDate from, LocalDate to) throws SQLException {

        List<Map<String, Object>> transactions = new ArrayList<>();

        List<Payment> payments = paymentDAO.findAll();

        for (Payment p : payments) {

            if (p.getPaidAt() == null) {
                continue;
            }

            LocalDate paidDate = p.getPaidAt().toLocalDate();

            // lọc theo tháng đang chọn
            if (paidDate.isBefore(from) || paidDate.isAfter(to)) {
                continue;
            }

            Booking booking = bookingDAO.findById(p.getBookingId());

            if (booking == null) {
                continue;
            }

            User customer = userDAO.findById(booking.getCustomerId());
            Car car = carDAO.findById(booking.getCarId());

            Map<String, Object> row = new HashMap<>();

            row.put("payment", p);
            row.put("booking", booking);
            row.put("customerName", customer != null ? customer.getFullName() : "Không xác định");
            row.put("carName", car != null ? car.getBrand() : "Không xác định");
            transactions.add(row);
        }
        return transactions;
    }
}
