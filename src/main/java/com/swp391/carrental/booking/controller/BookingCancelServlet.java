package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.user.model.User;

/*
 * Name: BookingCancelServlet
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 1.0
 * Description: Controller to handle booking cancellation requests.
 */
@WebServlet(name = "BookingCancelServlet", urlPatterns = {"/bookings/cancel"})
public class BookingCancelServlet extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingIdStr = request.getParameter("bookingId");
        String reason = request.getParameter("reason");

        if (reason == null || reason.trim().isEmpty()) {
            reason = "Khách hàng tự hủy";
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            bookingService.cancelBooking(bookingId, reason.trim());
            request.getSession().setAttribute("successMessage", "Hủy đơn thuê #" + bookingId + " thành công.");
        } catch (AppException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMessage", "Mã booking không hợp lệ.");
        }

        if (bookingIdStr != null) {
            response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingIdStr);
        } else {
            response.sendRedirect(request.getContextPath() + "/bookings/my");
        }
    }
}
