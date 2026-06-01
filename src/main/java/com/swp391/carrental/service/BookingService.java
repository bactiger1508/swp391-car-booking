/*
 * Name: BookingService
 * @Author: BacBXHE186736
 * Date: 29/05/2026
 * Version: 2.0
 * Description: Business logic for booking operations including create, view, approve, reject, cancel.
 */
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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for booking operations.
 */
public class BookingService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();

    /**
     * Get a single booking by ID.
     */
    public Booking getBookingById(int bookingId) {
        try {
            return bookingDAO.findById(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get booking.", e);
        }
    }

    /**
     * Get all bookings (Staff/Admin).
     */
    public List<Booking> getAllBookings() {
        try {
            return bookingDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings.", e);
        }
    }

    /**
     * Get bookings for a specific customer.
     */
    public List<Booking> getBookingsByCustomer(int customerId) {
        try {
            return bookingDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer bookings.", e);
        }
    }

    /**
     * Get bookings filtered by status.
     */
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
     * BR-02: No overlapping Pending/Confirmed/InProgress bookings.
     * BR-09: Car with Maintenance/Inactive/Rented status cannot be booked.
     */
    public int createBooking(Booking booking) {
        try {
            // BR-01: Validate dates
            if (booking.getEndDate().isBefore(booking.getStartDate())) {
                throw new AppException("Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
            }

            // Validate start date is not in the past
            if (booking.getStartDate().toLocalDate().isBefore(LocalDate.now())) {
                throw new AppException("Ngày bắt đầu không được trước ngày hiện tại.");
            }

            // BR-09: Check car status
            Car car = carDAO.findById(booking.getCarId());
            if (car == null) {
                throw new AppException("Xe không tồn tại.");
            }
            if (CarStatus.MAINTENANCE.equals(car.getStatus())) {
                throw new AppException("Xe đang bảo dưỡng, không thể đặt.");
            }
            if (CarStatus.INACTIVE.equals(car.getStatus())) {
                throw new AppException("Xe không khả dụng.");
            }
            if (CarStatus.RENTED.equals(car.getStatus())) {
                throw new AppException("Xe đang được thuê, không thể đặt.");
            }

            // BR-02: Check for overlapping bookings
            boolean hasOverlap = bookingDAO.hasOverlappingBooking(
                    booking.getCarId(),
                    Timestamp.valueOf(booking.getStartDate()),
                    Timestamp.valueOf(booking.getEndDate()),
                    null
            );
            if (hasOverlap) {
                throw new AppException("Xe đã có đặt chỗ trong khoảng thời gian này.");
            }

            booking.setStatus(BookingStatus.PENDING);
            return bookingDAO.insert(booking);
        } catch (SQLException e) {
            throw new AppException("Failed to create booking.", e);
        }
    }

    public boolean updateBooking(Booking booking) {
        try {
            // BR-01: Validate dates
            if (booking.getEndDate().isBefore(booking.getStartDate())) {
                throw new AppException("Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.");
            }

            // Validate start date is not in the past
            if (booking.getStartDate().toLocalDate().isBefore(LocalDate.now())) {
                throw new AppException("Ngày bắt đầu không được trước ngày hiện tại.");
            }

            // BR-02: Check for overlapping bookings (excluding this booking)
            boolean hasOverlap = bookingDAO.hasOverlappingBooking(
                    booking.getCarId(),
                    Timestamp.valueOf(booking.getStartDate()),
                    Timestamp.valueOf(booking.getEndDate()),
                    booking.getBookingId()
            );
            if (hasOverlap) {
                throw new AppException("Xe đã có đặt chỗ trong khoảng thời gian này.");
            }

            return bookingDAO.update(booking);
        } catch (SQLException e) {
            throw new AppException("Failed to update booking.", e);
        }
    }

    /**
     * Cancel a booking.
     * Only PENDING or CONFIRMED bookings can be cancelled.
     */
    public boolean cancelBooking(int bookingId, String reason) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                throw new AppException("Booking không tồn tại.");
            }

            String status = booking.getStatus();
            if (!BookingStatus.PENDING.equals(status) && !BookingStatus.CONFIRMED.equals(status)) {
                throw new AppException("Không thể hủy booking đang ở trạng thái " + status + ".");
            }

            return bookingDAO.cancel(bookingId, reason);
        } catch (SQLException e) {
            throw new AppException("Failed to cancel booking.", e);
        }
    }

    /**
     * Approve a booking (BR-04: Staff/Admin only).
     * Only PENDING bookings can be approved.
     */
    public boolean approveBooking(int bookingId, int approvedBy) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                throw new AppException("Booking không tồn tại.");
            }
            if (!BookingStatus.PENDING.equals(booking.getStatus())) {
                throw new AppException("Chỉ có thể duyệt booking đang ở trạng thái Chờ xử lý.");
            }
            
            boolean approved = bookingDAO.approve(bookingId, approvedBy);
            
            if (approved) {
                // Tự động tạo Hợp đồng khi duyệt booking thành công (BR-05)
                try {
                    com.swp391.carrental.dao.ContractDAO contractDAO = new com.swp391.carrental.dao.ContractDAO();
                    if (contractDAO.findByBookingId(bookingId) == null) {
                        com.swp391.carrental.model.RentalContract contract = new com.swp391.carrental.model.RentalContract();
                        contract.setBookingId(bookingId);
                        contract.setCustomerId(booking.getCustomerId());
                        contract.setCarId(booking.getCarId());
                        contract.setStartDate(booking.getStartDate());
                        contract.setEndDate(booking.getEndDate());
                        
                        Car car = carDAO.findById(booking.getCarId());
                        if (car != null) {
                            contract.setDailyRate(car.getDailyRate());
                        } else {
                            contract.setDailyRate(booking.getTotalAmount());
                        }
                        
                        contract.setTotalAmount(booking.getTotalAmount());
                        contract.setDepositAmount(booking.getDepositAmount());
                        contract.setStatus(com.swp391.carrental.constant.ContractStatus.ACTIVE);
                        contract.setTermsAndConditions("Điều khoản thuê xe tự lái mặc định của hệ thống CarPro.");
                        contract.setCreatedBy(approvedBy);
                        
                        String contractNumber = "CTR-"
                                + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy"))
                                + "-" + String.format("%04d", bookingId);
                        contract.setContractNumber(contractNumber);
                        
                        contractDAO.insert(contract);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            return approved;
        } catch (SQLException e) {
            throw new AppException("Failed to approve booking.", e);
        }
    }

    /**
     * Reject a booking (BR-04: Staff/Admin only).
     * Only PENDING bookings can be rejected.
     */
    public boolean rejectBooking(int bookingId, int rejectedBy, String reason) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                throw new AppException("Booking không tồn tại.");
            }
            if (!BookingStatus.PENDING.equals(booking.getStatus())) {
                throw new AppException("Chỉ có thể từ chối booking đang ở trạng thái Chờ xử lý.");
            }
            return bookingDAO.reject(bookingId, rejectedBy, reason);
        } catch (SQLException e) {
            throw new AppException("Failed to reject booking.", e);
        }
    }
}
