package com.swp391.carrental.service;

import com.swp391.carrental.dao.BookingDAO;
import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.constant.BookingStatus;
import com.swp391.carrental.constant.CarStatus;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for booking operations.
 */
public class BookingService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();

    public Booking getBookingById(int bookingId) {
        try {
            return bookingDAO.findById(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get booking.", e);
        }
    }

    public List<Booking> getAllBookings() {
        try {
            return bookingDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings.", e);
        }
    }

    public List<Booking> getBookingsByCustomer(int customerId) {
        try {
            return bookingDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer bookings.", e);
        }
    }

    public List<Booking> getBookingsByStatus(String status) {
        try {
            return bookingDAO.findByStatus(status);
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings by status.", e);
        }
    }

    /**
     * Create a new booking.
     * BR-01: End date must be after or equal to start date.
     * BR-02: No overlapping Confirmed/InProgress bookings.
     * BR-09: Car with Maintenance status cannot be booked.
     */
    public int createBooking(Booking booking) {
        try {
            // BR-01: Validate dates
            if (booking.getEndDate().isBefore(booking.getStartDate())) {
                throw new AppException("End date must be after or equal to start date.");
            }

            // BR-09: Check car status
            Car car = carDAO.findById(booking.getCarId());
            if (car == null) {
                throw new AppException("Car not found.");
            }
            if (CarStatus.MAINTENANCE.equals(car.getStatus())) {
                throw new AppException("This car is currently under maintenance and cannot be booked.");
            }
            if (CarStatus.INACTIVE.equals(car.getStatus())) {
                throw new AppException("This car is not available for booking.");
            }

            // BR-02: Check for overlapping bookings
            boolean hasOverlap = bookingDAO.hasOverlappingBooking(
                    booking.getCarId(),
                    Timestamp.valueOf(booking.getStartDate()),
                    Timestamp.valueOf(booking.getEndDate()),
                    null
            );
            if (hasOverlap) {
                throw new AppException("This car is already booked for the selected dates.");
            }

            booking.setStatus(BookingStatus.PENDING);
            return bookingDAO.insert(booking);
        } catch (SQLException e) {
            throw new AppException("Failed to create booking.", e);
        }
    }

    /**
     * Update an existing booking.
     */
    public boolean updateBooking(Booking booking) {
        try {
            // BR-01: Validate dates
            if (booking.getEndDate().isBefore(booking.getStartDate())) {
                throw new AppException("End date must be after or equal to start date.");
            }
            return bookingDAO.update(booking);
        } catch (SQLException e) {
            throw new AppException("Failed to update booking.", e);
        }
    }

    /**
     * Cancel a booking.
     */
    public boolean cancelBooking(int bookingId, String reason) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) throw new AppException("Booking not found.");

            String status = booking.getStatus();
            if (BookingStatus.COMPLETED.equals(status) || BookingStatus.IN_PROGRESS.equals(status)) {
                throw new AppException("Cannot cancel a booking that is " + status + ".");
            }

            booking.setStatus(BookingStatus.CANCELLED);
            booking.setCancelReason(reason);
            booking.setCancelledAt(LocalDateTime.now());
            return bookingDAO.update(booking);
        } catch (SQLException e) {
            throw new AppException("Failed to cancel booking.", e);
        }
    }

    /**
     * Approve a booking (BR-04: Staff/Admin only).
     */
    public boolean approveBooking(int bookingId, int approvedBy) {
        try {
            return bookingDAO.approve(bookingId, approvedBy);
        } catch (SQLException e) {
            throw new AppException("Failed to approve booking.", e);
        }
    }

    /**
     * Reject a booking (BR-04: Staff/Admin only).
     */
    public boolean rejectBooking(int bookingId, int rejectedBy, String reason) {
        try {
            return bookingDAO.reject(bookingId, rejectedBy, reason);
        } catch (SQLException e) {
            throw new AppException("Failed to reject booking.", e);
        }
    }
}
