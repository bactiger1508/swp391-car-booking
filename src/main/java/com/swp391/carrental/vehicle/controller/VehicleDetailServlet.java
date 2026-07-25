package com.swp391.carrental.vehicle.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;
import java.util.List;

/*
 * Name: VehicleDetailServlet
 * @Author: TinhHNHE172394
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleDetailServlet.
 */

@WebServlet(name = "VehicleDetailServlet", urlPatterns = {"/vehicles/detail"})
public class VehicleDetailServlet extends HttpServlet {
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String vehicleIdStr = request.getParameter("id");
        if (vehicleIdStr != null) {
            int vehicleId = Integer.parseInt(vehicleIdStr);
            Vehicle car = vehicleService.getVehicleById(vehicleId);
            request.setAttribute("car", car);
            request.setAttribute("images", vehicleService.getVehicleImages(vehicleId));
            
            // Query active bookings of the car to display in a modal calendar/schedule
            com.swp391.carrental.booking.service.BookingService bookingService = new com.swp391.carrental.booking.service.BookingService();
            List<com.swp391.carrental.booking.model.Booking> activeBookings = bookingService.getActiveBookingsByVehicle(vehicleId);
            request.setAttribute("activeBookings", activeBookings);
            
            // Query maintenance schedules of the car
            com.swp391.carrental.vehicle.dao.MaintenanceDAO maintenanceDAO = new com.swp391.carrental.vehicle.dao.MaintenanceDAO();
            try {
                List<com.swp391.carrental.vehicle.model.MaintenanceSchedule> maintenances = maintenanceDAO.getMaintenanceByVehicle(vehicleId);
                java.util.List<com.swp391.carrental.vehicle.model.MaintenanceSchedule> scheduledMaintenances = new java.util.ArrayList<>();
                if (maintenances != null) {
                    for (com.swp391.carrental.vehicle.model.MaintenanceSchedule ms : maintenances) {
                        if ("SCHEDULED".equalsIgnoreCase(ms.getStatus())) {
                            scheduledMaintenances.add(ms);
                        }
                    }
                }
                request.setAttribute("maintenances", scheduledMaintenances);
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // Deposit configuration context
            request.setAttribute("depositPercentage", vehicleService.getDepositPercentage());
            if (car != null) {
                request.setAttribute("depositAmount", vehicleService.calculateOneDayDeposit(car.getDailyRate()));
            }

            // Reviews & Ratings with Pagination
            com.swp391.carrental.vehicle.dao.ReviewDAO reviewDAO = new com.swp391.carrental.vehicle.dao.ReviewDAO();
            try {
                int reviewPage = 1;
                String reviewPageStr = request.getParameter("reviewPage");
                if (reviewPageStr != null && !reviewPageStr.trim().isEmpty()) {
                    try {
                        reviewPage = Integer.parseInt(reviewPageStr.trim());
                        if (reviewPage < 1) reviewPage = 1;
                    } catch (NumberFormatException e) {
                        reviewPage = 1;
                    }
                }
                int pageSize = 5;
                int totalReviews = reviewDAO.countByVehicleId(vehicleId);
                int totalPages = (int) Math.ceil((double) totalReviews / pageSize);
                if (totalPages < 1) totalPages = 1;
                if (reviewPage > totalPages) reviewPage = totalPages;

                int offset = (reviewPage - 1) * pageSize;
                List<com.swp391.carrental.vehicle.model.Review> reviews = reviewDAO.findByVehicleId(vehicleId, offset, pageSize);
                double avgRating = reviewDAO.getAverageRating(vehicleId);

                request.setAttribute("reviews", reviews);
                request.setAttribute("avgRating", String.format(java.util.Locale.US, "%.1f", avgRating));
                request.setAttribute("reviewCount", totalReviews);
                request.setAttribute("currentReviewPage", reviewPage);
                request.setAttribute("totalReviewPages", totalPages);

                // Check login status & completed bookings
                com.swp391.carrental.user.model.User currentUser = (com.swp391.carrental.user.model.User) request.getSession().getAttribute("currentUser");
                if (currentUser == null) {
                    currentUser = (com.swp391.carrental.user.model.User) request.getSession().getAttribute("user");
                }
                boolean isLoggedIn = (currentUser != null);
                boolean canReview = false;
                int reviewBookingId = 0;

                if (isLoggedIn) {
                    List<com.swp391.carrental.booking.model.Booking> userBookings = bookingService.getCustomerBookings(currentUser.getUserId());
                    if (userBookings != null) {
                        for (com.swp391.carrental.booking.model.Booking b : userBookings) {
                            if (b.getVehicleId() == vehicleId && "COMPLETED".equalsIgnoreCase(b.getStatus())) {
                                canReview = true;
                                reviewBookingId = b.getBookingId();
                                break;
                            }
                        }
                    }
                }
                request.setAttribute("isLoggedIn", isLoggedIn);
                request.setAttribute("canReview", canReview);
                request.setAttribute("reviewBookingId", reviewBookingId);
            } catch (Exception e) {
                e.printStackTrace();
            }

            request.getRequestDispatcher("/WEB-INF/views/vehicle/vehicle-detail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/vehicles");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("addReview".equals(action)) {
            com.swp391.carrental.user.model.User currentUser = (com.swp391.carrental.user.model.User) request.getSession().getAttribute("currentUser");
            if (currentUser == null) {
                currentUser = (com.swp391.carrental.user.model.User) request.getSession().getAttribute("user");
            }
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");

            com.swp391.carrental.vehicle.model.Review review = new com.swp391.carrental.vehicle.model.Review();
            review.setBookingId(bookingId);
            review.setCustomerId(currentUser.getUserId());
            review.setVehicleId(vehicleId);
            review.setRating(rating);
            review.setComment(comment != null ? comment.trim() : "");
            review.setVisible(true);

            com.swp391.carrental.vehicle.dao.ReviewDAO reviewDAO = new com.swp391.carrental.vehicle.dao.ReviewDAO();
            try {
                reviewDAO.insert(review);
                request.getSession().setAttribute("successMessage", "Cảm ơn bạn đã gửi đánh giá cho xe!");
            } catch (Exception e) {
                request.getSession().setAttribute("errorMessage", "Không thể gửi đánh giá: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/vehicles/detail?id=" + vehicleId);
        }
    }
}
