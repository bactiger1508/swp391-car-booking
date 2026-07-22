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
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;

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
    private final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    private final PaymentService paymentService = new PaymentService();
    private final BookingService bookingService = new BookingService();

    /**
     * Generate revenue report data for a date range. Returns a map with summary
     * fields.
     */
    public Map<String, Object> generateRevenueReport(LocalDate startDate, LocalDate endDate) {
        Map<String, Object> report = new HashMap<>();
        try {
            List<Payment> allPayments = paymentDAO.findAll();
            List<Payment> filteredPayments = new ArrayList<>();
            BigDecimal totalRevenue = BigDecimal.ZERO;
            int totalTransactions = 0;

            for (Payment p : allPayments) {
                LocalDateTime dt = p.getPaidAt() != null ? p.getPaidAt() : (p.getCreatedAt() != null ? p.getCreatedAt() : LocalDateTime.now());
                LocalDate paymentDate = dt.toLocalDate();

                boolean withinRange = true;
                if (startDate != null && paymentDate.isBefore(startDate)) {
                    withinRange = false;
                }
                if (endDate != null && paymentDate.isAfter(endDate)) {
                    withinRange = false;
                }

                if (withinRange) {
                    filteredPayments.add(p);
                    if ("COMPLETED".equals(p.getStatus())) {
                        totalRevenue = totalRevenue.add(p.getAmount());
                        totalTransactions++;
                    }
                }
            }

            report.put("totalRevenue", totalRevenue);
            report.put("totalTransactions", totalTransactions);
            report.put("startDate", startDate);
            report.put("endDate", endDate);
            report.put("payments", filteredPayments);

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

        List<Car> cars = carDAO.findAll();
        List<Booking> bookings = bookingDAO.findAll();

        for (Car car : cars) {
            segmentRevenue.put(car.getBrand(), BigDecimal.ZERO);
        }

        for (Booking booking : bookings) {
            LocalDate bookingDate = booking.getStartDate().toLocalDate();

            if (bookingDate.isBefore(from) || bookingDate.isAfter(to)) {
                continue;
            }

            Car car = cars.stream().filter(c -> c.getCarId() == booking.getCarId()).findFirst().orElse(null);

            if (car == null) {
                continue;
            }

            String segment = car.getBrand();

            BigDecimal revenue = booking.getTotalAmount();

            segmentRevenue.put(segment, segmentRevenue.get(segment).add(revenue));
        }
        return segmentRevenue;
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
                item.put("label", "Tuần " + week);
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

                item.put("label", "Tháng " + monthStart.getMonthValue());
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
                item.put("label", "Tháng " + month);
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

    public Map<String, Integer> getUsageBySegment(LocalDateTime from,
            LocalDateTime to) throws SQLException {

        Map<String, Integer> result = new LinkedHashMap<>();

        List<Car> cars = carDAO.findAll();
        List<Booking> bookings = bookingDAO.findAll();

        for (Car car : cars) {
            result.put(car.getBrand(), 0);
        }

        for (Booking b : bookings) {

            if (!"COMPLETED".equals(b.getStatus())
                    && !"IN_PROGRESS".equals(b.getStatus())) {
                continue;
            }

            LocalDateTime start = b.getStartDate();
            LocalDateTime end = b.getEndDate();

            if (end.isBefore(from) || start.isAfter(to)) {
                continue;
            }

            LocalDateTime actualStart = start.isBefore(from)
                    ? from
                    : start;

            LocalDateTime actualEnd = end.isAfter(to)
                    ? to
                    : end;

            int days = (int) ChronoUnit.DAYS.between(actualStart, actualEnd) + 1;

            Car car = cars.stream()
                    .filter(c -> c.getCarId() == b.getCarId())
                    .findFirst()
                    .orElse(null);

            if (car == null) {
                continue;
            }

            String segment = car.getBrand();

            result.put(segment,
                    result.get(segment) + days);
        }

        return result;
    }

    public List<Map<String, Object>> getVehicleUsage(
            LocalDateTime from,
            LocalDateTime to) throws SQLException {

        List<Map<String, Object>> result = new ArrayList<>();

        List<Car> cars = carDAO.findAll();
        List<Booking> bookings = bookingDAO.findAll();

        long totalDays = ChronoUnit.DAYS.between(from, to) + 1;

        for (Car car : cars) {

            int usedDays = 0;

            for (Booking b : bookings) {

                if (b.getCarId() != car.getCarId()) {
                    continue;
                }

                if (!"COMPLETED".equals(b.getStatus())
                        && !"IN_PROGRESS".equals(b.getStatus())) {
                    continue;
                }

                LocalDateTime start = b.getStartDate();
                LocalDateTime end = b.getEndDate();

                if (end.isBefore(from) || start.isAfter(to)) {
                    continue;
                }

                LocalDateTime actualStart = start.isBefore(from)
                        ? from
                        : start;

                LocalDateTime actualEnd = end.isAfter(to)
                        ? to
                        : end;

                usedDays += ChronoUnit.DAYS.between(actualStart, actualEnd) + 1;
            }

            double percent = totalDays == 0
                    ? 0
                    : usedDays * 100.0 / totalDays;

            Map<String, Object> row = new HashMap<>();

            row.put("car", car);
            row.put("usedDays", usedDays);
            row.put("percent", percent);

            result.add(row);
        }

        result.sort((a, b) -> Double.compare(
                (Double) b.get("percent"),
                (Double) a.get("percent")));

        return result;
    }

    public double getAverageUsage(LocalDateTime from,
            LocalDateTime to) throws SQLException {

        List<Map<String, Object>> list
                = getVehicleUsage(from, to);

        if (list.isEmpty()) {
            return 0;
        }

        double total = 0;

        for (Map<String, Object> row : list) {
            total += (Double) row.get("percent");
        }

        return total / list.size();
    }

    public int getTotalUsedDays(LocalDateTime from, LocalDateTime to) throws SQLException {
        int total = 0;
        List<Booking> bookings = bookingDAO.findAll();
        for (Booking b : bookings) {
            if (!"COMPLETED".equals(b.getStatus())
                    && !"IN_PROGRESS".equals(b.getStatus())) {
                continue;
            }
            LocalDateTime start = b.getStartDate();
            LocalDateTime end = b.getEndDate();

            if (end.isBefore(from) || start.isAfter(to)) {
                continue;
            }

            LocalDateTime actualStart
                    = start.isBefore(from) ? from : start;

            LocalDateTime actualEnd
                    = end.isAfter(to) ? to : end;

            total += ChronoUnit.DAYS.between(actualStart, actualEnd) + 1;
        }

        return total;
    }

    public Map<String, Object> getMostUsedCar(
            LocalDateTime from,
            LocalDateTime to) throws SQLException {

        List<Map<String, Object>> list
                = getVehicleUsage(from, to);

        if (list.isEmpty()) {
            return null;
        }

        return list.get(0);
    }

    public List<Map<String, Object>> getUsageChart(
            LocalDateTime from,
            LocalDateTime to,
            String type) throws SQLException {

        List<Map<String, Object>> chart = new ArrayList<>();
        List<Car> cars = carDAO.findAll();
        int totalCars = cars.isEmpty() ? 1 : cars.size();

        if (type.equals("MONTH")) {

            for (int week = 1; week <= 5; week++) {

                LocalDateTime start
                        = from.plusDays((week - 1) * 7);

                LocalDateTime end
                        = start.plusDays(6);

                if (end.isAfter(to)) {
                    end = to;
                }

                int days = 0;

                for (Booking b : bookingDAO.findAll()) {

                    if (!"COMPLETED".equals(b.getStatus())
                            && !"IN_PROGRESS".equals(b.getStatus())) {
                        continue;
                    }

                    LocalDateTime bs = b.getStartDate();
                    LocalDateTime be = b.getEndDate();

                    if (be.isBefore(start)
                            || bs.isAfter(end)) {
                        continue;
                    }

                    LocalDateTime s
                            = bs.isBefore(start) ? start : bs;

                    LocalDateTime e
                            = be.isAfter(end) ? end : be;

                    days += ChronoUnit.DAYS
                            .between(s, e) + 1;

                }

                long periodDays = ChronoUnit.DAYS.between(start, end) + 1;
                double usagePercent = (days * 100.0) / (totalCars * periodDays);
                if (usagePercent > 100.0) {
                    usagePercent = 100.0;
                }

                Map<String, Object> item = new HashMap<>();

                item.put("label", "Tuần " + week);
                item.put("usage", usagePercent);
                item.put("height", usagePercent);

                chart.add(item);
            }

        } // QUARTER
        else if (type.equals("QUARTER")) {

            for (int i = 0; i < 3; i++) {

                LocalDateTime start
                        = from.plusMonths(i)
                                .withDayOfMonth(1)
                                .toLocalDate()
                                .atStartOfDay();

                LocalDateTime end
                        = start.plusMonths(1)
                                .minusSeconds(1);

                int days = calculateUsedDays(
                        start, end);

                long periodDays = ChronoUnit.DAYS.between(start, end) + 1;
                double usagePercent = (days * 100.0) / (totalCars * periodDays);
                if (usagePercent > 100.0) {
                    usagePercent = 100.0;
                }

                Map<String, Object> item = new HashMap<>();

                item.put("label",
                        "Tháng " + start.getMonthValue());

                item.put("usage", usagePercent);
                item.put("height", usagePercent);

                chart.add(item);

            }

        } // YEAR
        else {

            for (int m = 1; m <= 12; m++) {

                LocalDateTime start
                        = LocalDate.of(
                                from.getYear(),
                                m,
                                1)
                                .atStartOfDay();

                LocalDateTime end
                        = start.plusMonths(1)
                                .minusSeconds(1);

                int days
                        = calculateUsedDays(start, end);

                long periodDays = ChronoUnit.DAYS.between(start, end) + 1;
                double usagePercent = (days * 100.0) / (totalCars * periodDays);
                if (usagePercent > 100.0) {
                    usagePercent = 100.0;
                }

                Map<String, Object> item
                        = new HashMap<>();

                item.put(
                        "label",
                        "Tháng " + m);

                item.put("usage", usagePercent);
                item.put("height", usagePercent);

                chart.add(item);
            }

        }

        return chart;
    }
    
    private int calculateUsedDays(
        LocalDateTime from,
        LocalDateTime to)
        throws SQLException{


    int total=0;


    for(Booking b:bookingDAO.findAll()){


        if(!"COMPLETED".equals(b.getStatus())
           &&
           !"IN_PROGRESS".equals(b.getStatus())){
            continue;
        }


        if(b.getEndDate().isBefore(from)
          ||
          b.getStartDate().isAfter(to)){
            continue;
        }


        LocalDateTime start =
            b.getStartDate().isBefore(from)
            ?from:b.getStartDate();


        LocalDateTime end =
            b.getEndDate().isAfter(to)
            ?to:b.getEndDate();


        total += ChronoUnit.DAYS
                .between(start,end)+1;

    }


    return total;
}

    public BigDecimal getTotalMaintenanceCost(LocalDate from, LocalDate to) throws SQLException {
        BigDecimal total = BigDecimal.ZERO;
        List<MaintenanceSchedule> schedules = maintenanceDAO.getAllMaintenanceSchedules();
        for (MaintenanceSchedule s : schedules) {
            if (!"COMPLETED".equals(s.getStatus())) {
                continue;
            }
            LocalDate date = s.getCompletedDate() != null ? s.getCompletedDate() : s.getScheduledDate();
            if (date != null && !date.isBefore(from) && !date.isAfter(to)) {
                total = total.add(BigDecimal.valueOf(s.getCost()));
            }
        }
        return total;
    }
}
