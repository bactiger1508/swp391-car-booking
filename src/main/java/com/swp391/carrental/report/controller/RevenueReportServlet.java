package com.swp391.carrental.report.controller;

import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.report.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
 * Name: RevenueReportServlet
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for RevenueReportServlet.
 */
@WebServlet(name = "RevenueReportServlet", urlPatterns = {"/reports/revenue"})
public class RevenueReportServlet extends HttpServlet {

    private final ReportService reportService = new ReportService();
    private final Booking bookings = new Booking();
    private final Payment payments = new Payment();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        LocalDate today = LocalDate.now();

        String type = request.getParameter("type");
        String monthParam = request.getParameter("month");
        String quarterParam = request.getParameter("quarter");
        String yearParam = request.getParameter("year");

        if (type == null || type.isBlank()) {
            if (quarterParam != null && !quarterParam.isBlank()) {
                type = "QUARTER";
            } else if (monthParam != null && !monthParam.isBlank()) {
                type = "MONTH";
            } else {
                type = "MONTH";
            }
        }

        int year = (yearParam == null || yearParam.isBlank())
                ? today.getYear()
                : Integer.parseInt(yearParam);

        int quarter;
        if (quarterParam != null && !quarterParam.isBlank()) {
            quarter = Integer.parseInt(quarterParam);
        } else if (monthParam != null && !monthParam.isBlank()) {
            int m = Integer.parseInt(monthParam);
            quarter = (m - 1) / 3 + 1;
        } else if (year == today.getYear()) {
            quarter = (today.getMonthValue() - 1) / 3 + 1;
        } else {
            quarter = 1;
        }

        int month;
        if (monthParam != null && !monthParam.isBlank()) {
            month = Integer.parseInt(monthParam);
        } else if (quarterParam != null && !quarterParam.isBlank()) {
            int q = Integer.parseInt(quarterParam);
            month = (q - 1) * 3 + 1;
        } else if (year == today.getYear()) {
            month = today.getMonthValue();
        } else {
            month = 1;
        }

        LocalDate currentDate;
        LocalDate toDate;

        switch (type) {
            case "YEAR":
                currentDate = LocalDate.of(year, 1, 1);
                toDate = LocalDate.of(year, 12, 31);
                break;

            case "QUARTER":
                int startMonth = (quarter - 1) * 3 + 1;
                currentDate = LocalDate.of(year, startMonth, 1);
                toDate = currentDate.plusMonths(3).minusDays(1);
                break;

            default:
                type = "MONTH";
                currentDate = LocalDate.of(year, month, 1);
                toDate = currentDate.withDayOfMonth(currentDate.lengthOfMonth());
                break;
        }

        LocalDate previousFrom;
        LocalDate previousTo;

        switch (type) {
            case "YEAR":
                previousFrom = currentDate.minusYears(1);
                previousTo = toDate.minusYears(1);
                break;

            case "QUARTER":
                previousFrom = currentDate.minusMonths(3);
                previousTo = currentDate.minusDays(1);
                break;

            default:
                previousFrom = currentDate.minusMonths(1);
                previousTo = previousFrom.withDayOfMonth(previousFrom.lengthOfMonth());
                break;
        }

        String compareLabel;
        switch (type) {
            case "YEAR":
                compareLabel = "năm trước";
                break;
            case "QUARTER":
                compareLabel = "quý trước";
                break;
            default:
                compareLabel = "tháng trước";
                break;
        }

        Map<String, BigDecimal> segmentRevenue = new LinkedHashMap<>();
        try {
            segmentRevenue = reportService.getRevenueByCarSegment(currentDate, toDate);
        } catch (SQLException ex) {
            Logger.getLogger(RevenueReportServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
        //Donut chart
        BigDecimal total = BigDecimal.ZERO;

        for (BigDecimal value : segmentRevenue.values()) {
            total = total.add(value);
        }

        String[] colors = {"var(--primary)", "var(--success)", "var(--warning)", "var(--error)", "var(--secondary)", "var(--outline)"};

        StringBuilder gradient = new StringBuilder("conic-gradient(");

        double start = 0;
        int i = 0;

        for (Map.Entry<String, BigDecimal> e : segmentRevenue.entrySet()) {
            double percent = total.compareTo(BigDecimal.ZERO) == 0 ? 0 : e.getValue().multiply(BigDecimal.valueOf(100)).divide(total, 2, RoundingMode.HALF_UP).doubleValue();

            gradient.append(colors[i % colors.length]).append(" ").append(start).append("% ").append(start + percent).append("%");

            start += percent;

            if (i < segmentRevenue.size() - 1) {
                gradient.append(",");
            }
            i++;
        }
        gradient.append(")");

        //Max Value in Chart
        List<Map<String, Object>> chartData = reportService.getRevenueChart(currentDate, toDate, type);

        BigDecimal maxRevenue = BigDecimal.ZERO;

        for (Map<String, Object> c : chartData) {
            BigDecimal revenue = (BigDecimal) c.get("revenue");
            if (revenue.compareTo(maxRevenue) > 0) {
                maxRevenue = revenue;
            }
        }

        long max = maxRevenue.longValue();
        long chartMax = ((max + 4_999_999) / 5_000_000) * 5_000_000;
        long step = chartMax / 5;
        chartMax += 5_000_000;

        request.setAttribute("chartMax", chartMax);

        for (Map<String, Object> c : chartData) {
            BigDecimal revenue = (BigDecimal) c.get("revenue");
            double height = revenue.doubleValue() * 100 / chartMax;
            c.put("height", height);
        }

        // ================= KPI =================
        BigDecimal totalRevenue = reportService.getTotalRevenue(currentDate, toDate);
        BigDecimal rentalRevenue = reportService.getRevenueByType("RENTAL", currentDate, toDate);
        BigDecimal rentalRatio = totalRevenue.compareTo(BigDecimal.ZERO) == 0 
            ? BigDecimal.ZERO 
            : rentalRevenue.divide(totalRevenue, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal additionalRevenue = reportService.getRevenueByType("ADDITIONAL_FEE", currentDate, toDate);
        BigDecimal additionalRatio = totalRevenue.compareTo(BigDecimal.ZERO) == 0 
            ? BigDecimal.ZERO 
            : additionalRevenue.divide(totalRevenue, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);
        BigDecimal depositRevenue = reportService.getDepositRevenue(currentDate, toDate);
        BigDecimal depositRatio = totalRevenue.compareTo(BigDecimal.ZERO) == 0 
            ? BigDecimal.ZERO 
            : depositRevenue.divide(totalRevenue, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);

        int completedBooking = reportService.getCompletedBooking(currentDate, toDate);

        BigDecimal previousRevenue = reportService.getTotalRevenue(previousFrom, previousTo);
        BigDecimal previousAdditionalRevenue = reportService.getRevenueByType("ADDITIONAL_FEE", previousFrom, previousTo);
        BigDecimal previousDepositRevenue = reportService.getDepositRevenue(previousFrom, previousTo);

        int previousBooking = reportService.getCompletedBooking(previousFrom, previousTo);

        double revenueGrowth = reportService.calculateGrowth(totalRevenue, previousRevenue);
        double additionalFeeGrowth = reportService.calculateGrowth(additionalRevenue, previousAdditionalRevenue);
        double depositGrowth = reportService.calculateGrowth(depositRevenue, previousDepositRevenue);
        double bookingGrowth = reportService.calculateGrowth(BigDecimal.valueOf(completedBooking), BigDecimal.valueOf(previousBooking));

        BigDecimal maintenanceCost = BigDecimal.ZERO;
        BigDecimal netProfit = totalRevenue;
        double netProfitGrowth = 0.0;
        try {
            maintenanceCost = reportService.getTotalMaintenanceCost(currentDate, toDate);
            netProfit = totalRevenue.subtract(maintenanceCost);
            BigDecimal previousMaintenanceCost = reportService.getTotalMaintenanceCost(previousFrom, previousTo);
            BigDecimal previousNetProfit = previousRevenue.subtract(previousMaintenanceCost);
            netProfitGrowth = reportService.calculateGrowth(netProfit, previousNetProfit);
        } catch (SQLException ex) {
            Logger.getLogger(RevenueReportServlet.class.getName()).log(Level.SEVERE, null, ex);
        }

        List<Map<String, Object>> transactions = new ArrayList<>();

        try {
            transactions = reportService.getRecentTransactions(currentDate, toDate);
        } catch (SQLException ex) {
            Logger.getLogger(RevenueReportServlet.class.getName()).log(Level.SEVERE, null, ex);
        }

        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("rentalRevenue", rentalRevenue);
        request.setAttribute("rentalRatio", rentalRatio);
        request.setAttribute("depositRevenue", depositRevenue);
        request.setAttribute("depositRatio", depositRatio);
        request.setAttribute("additionalRevenue", additionalRevenue);
        request.setAttribute("additionalRatio", additionalRatio);
        request.setAttribute("maintenanceCost", maintenanceCost);
        request.setAttribute("netProfit", netProfit);
        request.setAttribute("completedBooking", completedBooking);
        request.setAttribute("revenueGrowth", revenueGrowth);
        request.setAttribute("additionalFeeGrowth", additionalFeeGrowth);
        request.setAttribute("depositGrowth", depositGrowth);
        request.setAttribute("bookingGrowth", bookingGrowth);
        request.setAttribute("netProfitGrowth", netProfitGrowth);
        request.setAttribute("compareLabel", compareLabel);
        request.setAttribute("transactions", transactions);
        request.setAttribute("segmentRevenue", segmentRevenue);
        request.setAttribute("segmentGradient", gradient.toString());
        request.setAttribute("segmentTotal", total);
        request.setAttribute("chartData", chartData);
        request.setAttribute("maxRevenue", maxRevenue);
        request.setAttribute("step", step);

        // ================= Filter =================
        request.setAttribute("type", type);
        request.setAttribute("month", month);
        request.setAttribute("quarter", quarter);
        request.setAttribute("year", year);
        request.getRequestDispatcher("/WEB-INF/views/report/revenue-report.jsp").forward(request, response);
    }
}
