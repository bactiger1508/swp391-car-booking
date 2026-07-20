package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: BookingCalendarServlet
 * @Author: BacBXHE186736
 * Date: 16/07/2026
 * Version: 3.0
 * Description: Gantt-style timeline calendar for Staff/Admin. Supports month navigation
 *              and AJAX JSON responses for dynamic calendar updates.
 */



/**
 * Booking calendar view for Staff/Admin — Gantt Timeline style.
 * URL: /bookings/calendar
 *
 * Normal page request: renders JSP with initial data for the current month.
 * AJAX request (?ajax=true&month=M&year=Y): returns JSON for dynamic month switching.
 */
@WebServlet(name = "BookingCalendarServlet", urlPatterns = {"/bookings/calendar"})
public class BookingCalendarServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final VehicleService vehicleService = new VehicleService();
    private final UserService userService = new UserService();

    /** Hiển thị lịch đặt xe dạng biểu đồ Gantt Timeline cho Staff/Admin và trả về JSON cho AJAX */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Parse month/year from request, default to current month
        int month, year;
        try {
            month = Integer.parseInt(request.getParameter("month"));
        } catch (Exception e) {
            month = LocalDate.now().getMonthValue();
        }
        try {
            year = Integer.parseInt(request.getParameter("year"));
        } catch (Exception e) {
            year = LocalDate.now().getYear();
        }

        // Clamp values
        if (month < 1) month = 1;
        if (month > 12) month = 12;
        if (year < 2020) year = 2020;
        if (year > 2030) year = 2030;

        YearMonth ym = YearMonth.of(year, month);
        LocalDateTime rangeStart = ym.atDay(1).atStartOfDay();
        LocalDateTime rangeEnd = ym.atEndOfMonth().atTime(23, 59, 59);

        boolean isAjax = "true".equals(request.getParameter("ajax"));

        try {
            // Load bookings for this month range
            List<Booking> bookings = bookingService.getBookingsByDateRange(rangeStart, rangeEnd);

            // Load all cars
            List<Car> allCars = vehicleService.getAllCars();

            if (isAjax) {
                // Return JSON response
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print(buildJson(bookings, allCars, ym));
                out.flush();
                return;
            }

            // Normal page render
            request.setAttribute("bookings", bookings != null ? bookings : new java.util.ArrayList<>());
            request.setAttribute("cars", allCars != null ? allCars : new java.util.ArrayList<>());

            // Build car map
            Map<Integer, Car> carMap = new HashMap<>();
            if (allCars != null) {
                for (Car car : allCars) {
                    carMap.put(car.getCarId(), car);
                }
            }
            request.setAttribute("carMap", carMap);

            // Build user map
            List<User> allUsers = userService.getAllUsers();
            Map<Integer, User> userMap = new HashMap<>();
            if (allUsers != null) {
                for (User u : allUsers) {
                    userMap.put(u.getUserId(), u);
                }
            }
            request.setAttribute("userMap", userMap);

            request.setAttribute("calMonth", month);
            request.setAttribute("calYear", year);
            request.setAttribute("daysInMonth", ym.lengthOfMonth());

        } catch (Exception e) {
            System.err.println("[BookingCalendarServlet] Error loading calendar data: " + e.getMessage());
            e.printStackTrace();
            if (isAjax) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
                return;
            }
            if (request.getAttribute("bookings") == null) request.setAttribute("bookings", new java.util.ArrayList<>());
            if (request.getAttribute("cars") == null) request.setAttribute("cars", new java.util.ArrayList<>());
            if (request.getAttribute("carMap") == null) request.setAttribute("carMap", new HashMap<>());
            if (request.getAttribute("userMap") == null) request.setAttribute("userMap", new HashMap<>());
            request.setAttribute("calMonth", month);
            request.setAttribute("calYear", year);
            request.setAttribute("daysInMonth", ym.lengthOfMonth());
            request.setAttribute("errorMessage", "Không thể tải dữ liệu lịch. Vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("/WEB-INF/views/booking/booking-calendar.jsp")
                .forward(request, response);
    }

    /**
     * Build a JSON string with bookings and cars data for AJAX calendar updates.
     */
    private String buildJson(List<Booking> bookings, List<Car> cars, YearMonth ym) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"month\":").append(ym.getMonthValue()).append(",");
        sb.append("\"year\":").append(ym.getYear()).append(",");
        sb.append("\"daysInMonth\":").append(ym.lengthOfMonth()).append(",");

        // Cars array
        sb.append("\"cars\":[");
        if (cars != null) {
            for (int i = 0; i < cars.size(); i++) {
                Car c = cars.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"carId\":").append(c.getCarId());
                sb.append(",\"brand\":\"").append(escapeJson(c.getBrand())).append("\"");
                sb.append(",\"model\":\"").append(escapeJson(c.getModel())).append("\"");
                sb.append(",\"licensePlate\":\"").append(escapeJson(c.getLicensePlate())).append("\"");
                sb.append(",\"status\":\"").append(escapeJson(c.getStatus())).append("\"");
                sb.append("}");
            }
        }
        sb.append("],");

        // Bookings array
        sb.append("\"bookings\":[");
        if (bookings != null) {
            for (int i = 0; i < bookings.size(); i++) {
                Booking b = bookings.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"bookingId\":").append(b.getBookingId());
                sb.append(",\"carId\":").append(b.getCarId());
                sb.append(",\"customerId\":").append(b.getCustomerId());
                sb.append(",\"status\":\"").append(escapeJson(b.getStatus())).append("\"");
                if (b.getStartDate() != null) {
                    sb.append(",\"startDate\":\"").append(b.getStartDate().toString()).append("\"");
                }
                if (b.getEndDate() != null) {
                    sb.append(",\"endDate\":\"").append(b.getEndDate().toString()).append("\"");
                }
                if (b.getTotalAmount() != null) {
                    sb.append(",\"totalAmount\":").append(b.getTotalAmount());
                }
                sb.append("}");
            }
        }
        sb.append("]");

        sb.append("}");
        return sb.toString();
    }

    /** Simple JSON string escape */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
