package com.swp391.carrental.report.controller;

import com.swp391.carrental.report.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
 * Name: VehicleUtilizationReportServlet
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleUtilizationReportServlet.
 */
@WebServlet(name = "VehicleUtilizationReportServlet", urlPatterns = {"/reports/vehicle-utilization"})
public class VehicleUtilizationReportServlet extends HttpServlet {

    private final ReportService reportService = new ReportService();

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

        LocalDate fromDate;
        LocalDate toDate;

        switch (type) {

            case "YEAR":

                fromDate = LocalDate.of(year, 1, 1);
                toDate = LocalDate.of(year, 12, 31);
                break;

            case "QUARTER":

                int startMonth = (quarter - 1) * 3 + 1;

                fromDate = LocalDate.of(year, startMonth, 1);
                toDate = fromDate.plusMonths(3).minusDays(1);
                break;

            default:

                type = "MONTH";

                fromDate = LocalDate.of(year, month, 1);
                toDate = fromDate.withDayOfMonth(fromDate.lengthOfMonth());

                break;
        }

        LocalDate previousFrom;
        LocalDate previousTo;

        switch (type) {
            case "YEAR":
                previousFrom = fromDate.minusYears(1);
                previousTo = toDate.minusYears(1);
                break;

            case "QUARTER":
                previousFrom = fromDate.minusMonths(3);
                previousTo = fromDate.minusDays(1);
                break;

            default:
                previousFrom = fromDate.minusMonths(1);
                previousTo = previousFrom.withDayOfMonth(previousFrom.lengthOfMonth());
                break;
        }

        LocalDateTime from = fromDate.atStartOfDay();
        LocalDateTime to = toDate.atTime(LocalTime.MAX);
        LocalDateTime prevFrom = previousFrom.atStartOfDay();
        LocalDateTime prevTo = previousTo.atTime(LocalTime.MAX);

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

        try {

            // ===== KPI =====
            double averageUsage
                    = reportService.getAverageUsage(from, to);

            int totalUsedDays
                    = reportService.getTotalUsedDays(from, to);

            Map<String, Object> mostUsedCar
                    = reportService.getMostUsedCar(from, to);

            double previousUsage = reportService.getAverageUsage(prevFrom, prevTo);
            double usageGrowth = previousUsage == 0 
                ? 0 
                : (averageUsage - previousUsage) * 100.0 / previousUsage;

            // ===== Donut =====
            Map<String, Integer> segmentUsage
                    = reportService.getUsageBySegment(from, to);

            int total = 0;

            for (Integer value : segmentUsage.values()) {
                total += value;
            }

            String[] colors = {
                "var(--primary)",
                "var(--success)",
                "var(--warning)",
                "var(--error)",
                "var(--secondary)",
                "var(--outline)"
            };

            StringBuilder gradient
                    = new StringBuilder("conic-gradient(");

            double start = 0;
            int i = 0;

            for (Map.Entry<String, Integer> e
                    : segmentUsage.entrySet()) {

                double percent = total == 0
                        ? 0
                        : e.getValue() * 100.0 / total;

                gradient.append(colors[i % colors.length])
                        .append(" ")
                        .append(start)
                        .append("% ")
                        .append(start + percent)
                        .append("%");

                start += percent;

                if (i < segmentUsage.size() - 1) {
                    gradient.append(",");
                }

                i++;
            }

            gradient.append(")");

            // ===== Table =====
            List<Map<String, Object>> vehicleUsage
                    = reportService.getVehicleUsage(from, to);
            List<Map<String, Object>> chartData
                    = reportService.getUsageChart(from, to, type);
            request.setAttribute("averageUsage", averageUsage);
            request.setAttribute("usageGrowth", usageGrowth);
            request.setAttribute("totalUsedDays", totalUsedDays);
            request.setAttribute("mostUsedCar", mostUsedCar);

            request.setAttribute("segmentUsage", segmentUsage);
            request.setAttribute("segmentGradient", gradient.toString());
            request.setAttribute("segmentTotal", total);
            request.setAttribute("vehicleUsage", vehicleUsage);
            request.setAttribute("chartData", chartData);

        } catch (SQLException ex) {

            Logger.getLogger(
                    VehicleUtilizationReportServlet.class.getName())
                    .log(Level.SEVERE, null, ex);
        }

        request.setAttribute("compareLabel", compareLabel);

        request.setAttribute("type", type);
        request.setAttribute("month", month);
        request.setAttribute("quarter", quarter);
        request.setAttribute("year", year);

        request.getRequestDispatcher("/WEB-INF/views/report/vehicle-utilization-report.jsp").forward(request, response);
    }
}
