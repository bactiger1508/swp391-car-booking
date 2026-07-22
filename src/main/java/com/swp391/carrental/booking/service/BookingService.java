package com.swp391.carrental.booking.service;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.constant.ContractStatus;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.vehicle.constant.CarStatus;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.user.dao.CustomerProfileDAO;
import com.swp391.carrental.user.model.CustomerProfile;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import com.swp391.carrental.payment.dao.PaymentDAO;
import com.swp391.carrental.payment.model.Payment;

/*
 * Name: BookingService
 * @Author: BacBXHE186736
 * Date: 17/07/2026
 * Version: 2.1
 * Description: Business logic for booking operations including create, view, approve, reject, and cancellation deposit refund.
 */



/**
 * Service for booking operations.
 */
public class BookingService {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    /** Get a single booking by ID */
    public Booking getBookingById(int bookingId) {
        try {
            return bookingDAO.findById(bookingId);
        } catch (SQLException e) {
            throw new AppException("Failed to get booking.", e);
        }
    }

    /** Get active bookings for a specific car */
    public List<Booking> getActiveBookingsByCar(int carId) {
        try {
            return bookingDAO.findActiveBookingsByCarId(carId);
        } catch (SQLException e) {
            throw new AppException("Failed to get active bookings for car.", e);
        }
    }

    /** Get all bookings in the system */
    public List<Booking> getAllBookings() {
        try {
            return bookingDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings.", e);
        }
    }

    /** Get bookings for a specific customer */
    public List<Booking> getBookingsByCustomer(int customerId) {
        try {
            return bookingDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new AppException("Failed to get customer bookings.", e);
        }
    }

    /** Get bookings filtered by status */
    public List<Booking> getBookingsByStatus(String status) {
        try {
            return bookingDAO.findByStatus(status);
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings by status.", e);
        }
    }

    /** Get bookings overlapping with a date range (for calendar view) */
    public List<Booking> getBookingsByDateRange(java.time.LocalDateTime rangeStart, java.time.LocalDateTime rangeEnd) {
        try {
            return bookingDAO.findByDateRange(
                    Timestamp.valueOf(rangeStart),
                    Timestamp.valueOf(rangeEnd)
            );
        } catch (SQLException e) {
            throw new AppException("Failed to get bookings by date range.", e);
        }
    }

    /** Create a new booking with date, car status, and overlapping checks */
    public int createBooking(Booking booking) {
        try {
            // Verify customer profile is VERIFIED
            CustomerProfileDAO profileDAO = new CustomerProfileDAO();
            CustomerProfile profile = profileDAO.findByUserId(booking.getCustomerId());
            if (profile == null || !"VERIFIED".equals(profile.getVerificationStatus())) {
                throw new AppException("Khách hàng chưa xác minh hồ sơ, không thể đặt xe.");
            }

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
            int newBookingId = bookingDAO.insert(booking);

            if (newBookingId > 0) {
                try {
                    com.swp391.carrental.notification.dao.NotificationDAO notiDAO = new com.swp391.carrental.notification.dao.NotificationDAO();
                    com.swp391.carrental.user.dao.UserDAO uDAO = new com.swp391.carrental.user.dao.UserDAO();

                    // Notify Customer
                    com.swp391.carrental.notification.model.Notification notiCust = new com.swp391.carrental.notification.model.Notification();
                    notiCust.setUserId(booking.getCustomerId());
                    notiCust.setTitle("Đặt xe thành công #BK-" + newBookingId);
                    notiCust.setMessage("Yêu cầu đặt xe của bạn đã được khởi tạo thành công (Trạng thái: Chờ duyệt).");
                    notiCust.setNotificationType("BOOKING_CREATED");
                    notiCust.setReferenceType("BOOKING");
                    notiCust.setReferenceId(newBookingId);
                    notiDAO.insert(notiCust);

                    // Notify Staff & Admin
                    List<com.swp391.carrental.user.model.User> staffs = uDAO.findByRole("STAFF");
                    staffs.addAll(uDAO.findByRole("ADMIN"));
                    for (com.swp391.carrental.user.model.User st : staffs) {
                        com.swp391.carrental.notification.model.Notification notiStaff = new com.swp391.carrental.notification.model.Notification();
                        notiStaff.setUserId(st.getUserId());
                        notiStaff.setTitle("Đơn đặt xe mới #BK-" + newBookingId);
                        notiStaff.setMessage("Có đơn đặt xe mới từ khách hàng cần được duyệt.");
                        notiStaff.setNotificationType("NEW_BOOKING_ALERT");
                        notiStaff.setReferenceType("BOOKING");
                        notiStaff.setReferenceId(newBookingId);
                        notiDAO.insert(notiStaff);
                    }
                } catch (Exception ignored) {}
            }

            return newBookingId;
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

    /** Cancel PENDING or CONFIRMED booking and automatically calculate deposit refund */
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

            // Check if there are any completed deposit payments to calculate refund
            List<Payment> payments = paymentDAO.findByBookingId(bookingId);
            Payment completedDeposit = null;
            for (Payment p : payments) {
                if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType()) && "COMPLETED".equalsIgnoreCase(p.getStatus())) {
                    completedDeposit = p;
                    break;
                }
            }

            if (completedDeposit != null) {
                // Calculate hours between now and start date
                LocalDateTime now = LocalDateTime.now();
                LocalDateTime startDate = booking.getStartDate();
                long hours = ChronoUnit.HOURS.between(now, startDate);

                BigDecimal refundAmount = BigDecimal.ZERO;
                int refundPercent = 0;

                if (hours >= 48) {
                    refundPercent = 100;
                    refundAmount = completedDeposit.getAmount();
                } else if (hours >= 24) {
                    refundPercent = 50;
                    refundAmount = completedDeposit.getAmount().multiply(new BigDecimal("0.5"));
                } else {
                    refundPercent = 0;
                    refundAmount = BigDecimal.ZERO;
                }

                // If a refund is applicable, create a PENDING REFUND payment record
                if (refundAmount.compareTo(BigDecimal.ZERO) > 0) {
                    Payment refundPayment = new Payment();
                    refundPayment.setBookingId(bookingId);
                    refundPayment.setAmount(refundAmount);
                    refundPayment.setPaymentType("REFUND");
                    refundPayment.setStatus("PENDING");
                    refundPayment.setNotes("Hoàn tiền cọc " + refundPercent + "% do hủy đơn trước " + hours + " giờ. Lý do: " + reason);
                    paymentDAO.insert(refundPayment);
                    
                    // Mark the original deposit as REFUNDED to represent it clearly in payment lists
                    paymentDAO.updateStatus(completedDeposit.getPaymentId(), "REFUNDED");
                }
            }

            boolean cancelled = bookingDAO.cancel(bookingId, reason);
            if (cancelled) {
                try {
                    com.swp391.carrental.notification.dao.NotificationDAO notiDAO = new com.swp391.carrental.notification.dao.NotificationDAO();
                    com.swp391.carrental.notification.model.Notification noti = new com.swp391.carrental.notification.model.Notification();
                    noti.setUserId(booking.getCustomerId());
                    noti.setTitle("Đã hủy đơn đặt xe #BK-" + bookingId);
                    noti.setMessage("Đơn đặt xe #BK-" + bookingId + " đã được hủy thành công.");
                    noti.setNotificationType("BOOKING_CANCELLED");
                    noti.setReferenceType("BOOKING");
                    noti.setReferenceId(bookingId);
                    notiDAO.insert(noti);
                } catch (Exception ignored) {}
            }

            return cancelled;
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
            
            // Check if customer profile is verified
            CustomerProfileDAO profileDAO = new CustomerProfileDAO();
            CustomerProfile profile = profileDAO.findByUserId(booking.getCustomerId());
            if (profile == null || !"VERIFIED".equals(profile.getVerificationStatus())) {
                throw new AppException("Không thể duyệt booking: Hồ sơ khách hàng chưa được xác minh (VERIFIED).");
            }
            
            boolean approved = bookingDAO.approve(bookingId, approvedBy);
            if (approved) {
                try {
                    com.swp391.carrental.notification.dao.NotificationDAO notiDAO = new com.swp391.carrental.notification.dao.NotificationDAO();
                    com.swp391.carrental.notification.model.Notification noti = new com.swp391.carrental.notification.model.Notification();
                    noti.setUserId(booking.getCustomerId());
                    noti.setTitle("Đơn đặt xe đã duyệt #BK-" + bookingId);
                    noti.setMessage("Đơn đặt xe #BK-" + bookingId + " đã được nhân viên phê duyệt. Vui lòng tiến hành đặt cọc.");
                    noti.setNotificationType("BOOKING_APPROVED");
                    noti.setReferenceType("BOOKING");
                    noti.setReferenceId(bookingId);
                    notiDAO.insert(noti);
                } catch (Exception ignored) {}
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
            boolean rejected = bookingDAO.reject(bookingId, rejectedBy, reason);
            if (rejected) {
                try {
                    com.swp391.carrental.notification.dao.NotificationDAO notiDAO = new com.swp391.carrental.notification.dao.NotificationDAO();
                    com.swp391.carrental.notification.model.Notification noti = new com.swp391.carrental.notification.model.Notification();
                    noti.setUserId(booking.getCustomerId());
                    noti.setTitle("Đơn đặt xe bị từ chối #BK-" + bookingId);
                    noti.setMessage("Đơn đặt xe #BK-" + bookingId + " đã bị từ chối. Lý do: " + reason);
                    noti.setNotificationType("BOOKING_REJECTED");
                    noti.setReferenceType("BOOKING");
                    noti.setReferenceId(bookingId);
                    notiDAO.insert(noti);
                } catch (Exception ignored) {}
            }
            return rejected;
        } catch (SQLException e) {
            throw new AppException("Failed to reject booking.", e);
        }
    }
}
