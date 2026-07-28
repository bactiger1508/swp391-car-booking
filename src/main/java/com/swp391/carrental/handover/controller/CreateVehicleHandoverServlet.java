package com.swp391.carrental.handover.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.service.HandoverService;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;
import java.math.BigDecimal;

/**
 * Name: CreateVehicleHandoverServlet
 *
 * @Author: TamTTMHE190340 Date: 19/06/2026 Version: 1.0 Description: Controller
 * for initializing and creating new vehicle handover records.
 */
@WebServlet(name = "CreateVehicleHandoverServlet", urlPatterns = {"/handovers/create"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 1, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 15)
public class CreateVehicleHandoverServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final VehicleService vehicleService = new VehicleService();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String vehicleIdStr = request.getParameter("vehicleId");
            if (bookingIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                Booking booking = bookingDAO.findById(bookingId);
                if (booking == null) {
                    response.sendRedirect(request.getContextPath() + "/bookings/manage");
                    return;
                }

                int vehicleId = (vehicleIdStr != null && !vehicleIdStr.isEmpty()) ? Integer.parseInt(vehicleIdStr) : booking.getVehicleId();
                Vehicle car = vehicleService.getVehicleById(vehicleId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);

                VehicleHandover existingHandover = handoverService.getHandoverByBookingId(bookingId);
                if (existingHandover != null) {
                    request.getSession().setAttribute("infoMessage",
                            "Biên bản bàn giao xe cho đơn #" + bookingId + " đã tồn tại.");
                    response.sendRedirect(
                            request.getContextPath() + "/handovers/detail?bookingId=" + bookingId + "&vehicleId=" + vehicleId);
                    return;
                }

                // Support both ACTIVE and SIGNED contract statuses
                if (contract == null || (!"ACTIVE".equals(contract.getStatus()) && !"SIGNED".equals(contract.getStatus()))) {
                    // If contract exists with signatures, auto update status if needed
                    if (contract == null) {
                        request.getSession().setAttribute("errorMessage",
                                "Không thể bàn giao xe: Đơn chưa được tạo hợp đồng.");
                        response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                        return;
                    }
                }

                PaymentService paymentService = new PaymentService();
                List<Payment> payments = paymentService.getPaymentsByBooking(bookingId);
                BigDecimal depositPaidAmt = BigDecimal.ZERO;
                BigDecimal rentalPaidAmt = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        BigDecimal completedAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                        if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                            depositPaidAmt = depositPaidAmt.add(completedAmt);
                        } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                            rentalPaidAmt = rentalPaidAmt.add(completedAmt);
                        }
                    }
                }
                boolean depositPaid = booking.getDepositAmount() != null && depositPaidAmt.compareTo(booking.getDepositAmount()) >= 0;

                BigDecimal rentalRequired = booking.getTotalAmount().subtract(booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO);
                BigDecimal excessDeposit = depositPaidAmt.subtract(booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO);
                BigDecimal effectiveRentalPaid = rentalPaidAmt;
                if (excessDeposit.compareTo(BigDecimal.ZERO) > 0) {
                    effectiveRentalPaid = effectiveRentalPaid.add(excessDeposit);
                }
                boolean rentalPaid = effectiveRentalPaid.compareTo(rentalRequired) >= 0;
                if (!depositPaid) {
                    request.getSession().setAttribute("errorMessage",
                            "Không thể bàn giao xe: Đơn đặt xe chưa được thanh toán tiền đặt cọc (Deposit).");
                    response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                    return;
                }
                if (!rentalPaid) {
                    request.getSession().setAttribute("errorMessage",
                            "Không thể bàn giao xe: Đơn đặt xe chưa được thanh toán tiền thuê xe (Rental). Vui lòng ghi nhận thanh toán tiền thuê xe trước khi bàn giao.");
                    response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                    return;
                }

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("vehicleId", vehicleId);
                if (car != null) {
                    request.setAttribute("currentOdo", car.getMileage());
                }

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int vehicleId = Integer.parseInt(request.getParameter("vehicleId"));

            VehicleHandover existingHandover = handoverService.getHandoverByBookingId(bookingId);
            if (existingHandover != null) {
                request.getSession().setAttribute("errorMessage",
                        "Không thể tạo thêm: Biên bản bàn giao xe cho đơn #" + bookingId + " đã tồn tại.");
                response.sendRedirect(
                        request.getContextPath() + "/handovers/detail?bookingId=" + bookingId + "&vehicleId=" + vehicleId);
                return;
            }

            // Enforce Handover Validation Checks in POST
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                request.getSession().setAttribute("errorMessage", "Không tìm thấy đơn đặt xe.");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            }
            if (contract == null || !"ACTIVE".equals(contract.getStatus())) {
                request.getSession().setAttribute("errorMessage",
                        "Không thể bàn giao xe: Hợp đồng cho đơn này chưa được ký kết hoặc kích hoạt (phải ở trạng thái ACTIVE).");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            }

            PaymentService paymentService = new PaymentService();
            List<Payment> payments = paymentService.getPaymentsByBooking(bookingId);
            BigDecimal depositPaidAmt = BigDecimal.ZERO;
            BigDecimal rentalPaidAmt = BigDecimal.ZERO;
            for (Payment p : payments) {
                if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                    BigDecimal completedAmt = p.getAmountPaid() != null ? p.getAmountPaid() : p.getAmount();
                    if ("DEPOSIT".equalsIgnoreCase(p.getPaymentType())) {
                        depositPaidAmt = depositPaidAmt.add(completedAmt);
                    } else if ("RENTAL".equalsIgnoreCase(p.getPaymentType())) {
                        rentalPaidAmt = rentalPaidAmt.add(completedAmt);
                    }
                }
            }
            boolean depositPaid = booking.getDepositAmount() != null && depositPaidAmt.compareTo(booking.getDepositAmount()) >= 0;

            BigDecimal rentalRequired = booking.getTotalAmount().subtract(booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO);
            BigDecimal excessDeposit = depositPaidAmt.subtract(booking.getDepositAmount() != null ? booking.getDepositAmount() : BigDecimal.ZERO);
            BigDecimal effectiveRentalPaid = rentalPaidAmt;
            if (excessDeposit.compareTo(BigDecimal.ZERO) > 0) {
                effectiveRentalPaid = effectiveRentalPaid.add(excessDeposit);
            }
            boolean rentalPaid = effectiveRentalPaid.compareTo(rentalRequired) >= 0;
            if (!depositPaid) {
                request.getSession().setAttribute("errorMessage",
                        "Không thể bàn giao xe: Đơn đặt xe chưa được thanh toán tiền đặt cọc (Deposit).");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            }
            if (!rentalPaid) {
                request.getSession().setAttribute("errorMessage",
                        "Không thể bàn giao xe: Đơn đặt xe chưa được thanh toán tiền thuê xe (Rental). Vui lòng ghi nhận thanh toán tiền thuê xe trước khi bàn giao.");
                response.sendRedirect(request.getContextPath() + "/bookings/detail?id=" + bookingId);
                return;
            }

            // ===== VALIDATION =====
            if (!validateOdo(request, response, bookingId, vehicleId)) {
                return;
            }

            if (!validateFuel(request, response, bookingId, vehicleId)) {
                return;
            }

            if (!validateImages(request, response, bookingId, vehicleId)) {
                return;
            }

            // ===== FORM DATA =====
            int mileage = Integer.parseInt(request.getParameter("currentOdo"));

            String fuelLevel = request.getParameter("fuel");

            switch (fuelLevel) {
                case "E":
                    fuelLevel = "EMPTY";
                    break;
                case "F":
                    fuelLevel = "FULL";
                    break;
            }

            String exterior = buildExteriorCondition(request);
            String interior = buildInteriorCondition(request);
            String accessories = buildMechanicalCondition(request);

            String notes = request.getParameter("notes");

            if (notes == null || notes.isBlank()) {
                notes = "Đã kiểm tra và bàn giao xe";
            }

            String status = "CHƯA KÝ NHẬN";

            // ===== RELATION DATA =====
            Integer contractId = contract != null ? contract.getContractId() : null;

            booking = bookingDAO.findById(bookingId);

            int receivedBy = booking != null ? booking.getCustomerId() : null;

            User currentUser = (User) request.getSession().getAttribute("currentUser");

            int handedBy = currentUser != null ? currentUser.getUserId() : null;

            // ===== PHOTOS =====
            String photosUrl = saveImages(request, bookingId);

            // ===== CREATE ENTITY =====
            VehicleHandover handover = new VehicleHandover();

            handover.setBookingId(bookingId);
            handover.setContractId(contractId);
            handover.setVehicleId(vehicleId);

            handover.setMileageAtHandover(mileage);
            handover.setFuelLevel(fuelLevel);

            handover.setExteriorCondition(exterior);
            handover.setInteriorCondition(interior);
            handover.setMechanicalCondition(accessories);

            handover.setPhotosUrl(photosUrl);
            handover.setNotes(notes);
            handover.setStatus(status);

            handover.setHandedBy(handedBy);
            handover.setReceivedBy(receivedBy);

            handover.setHandoverDate(LocalDateTime.now());

            int handoverId = handoverService.handoverVehicle(handover);

            notifyVehicleHandedOver(booking, handoverId);
            if (request.getSession() != null) {
                request.getSession().setAttribute("successMessage",
                        "Lập biên bản bàn giao xe thành công! Đang chờ khách hàng kiểm tra và ký nhận.");
            }

            response.sendRedirect(request.getContextPath() + "/handovers");

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi bàn giao: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request,
                    response);
        }
    }

    private String saveImages(HttpServletRequest request, int bookingId)
            throws IOException, ServletException {
        String uploadPath = request.getServletContext().getRealPath("") + File.separator + "assets/images/handover";

        File folder = new File(uploadPath);
        if (!folder.exists()) {
            folder.mkdirs();
        }

        List<String> urls = new ArrayList<>();

        for (Part part : request.getParts()) {
            if (!"evidencePhotos".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }

            String fileName = bookingId + "_" + System.currentTimeMillis()
                    + "_" + part.getSubmittedFileName();

            part.write(uploadPath + File.separator + fileName);

            urls.add("/assets/images/handover/" + fileName);
        }

        return String.join(",", urls);
    }

    private String buildExteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkExteriorScratch") != null ? "Không vết xước/lõm mới" : "Có vết xước/lõm");
        list.add(request.getParameter("chkWindshield") != null ? "Kính chắn gió nguyên vẹn" : "Kính chắn gió tổn hại");
        list.add(request.getParameter("chkTires") != null ? "Lốp xe tốt" : "Lốp xe không tốt");
        return String.join(", ", list);
    }

    private String buildInteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkCleanliness") != null ? "Sạch sẽ" : "Nội thất bẩn");
        list.add(request.getParameter("chkOdor") != null ? "Không mùi" : "Có mùi");
        list.add(request.getParameter("chkMatsAccessories") != null ? "Đủ phụ kiện" : "Thiếu phụ kiện");
        return String.join(", ", list);
    }

    private String buildMechanicalCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkEngine") != null ? "Động cơ bình thường" : "Động cơ bất thường");
        list.add(request.getParameter("chkDashboardLights") != null ? "Không cảnh báo" : "Có cảnh báo");
        return String.join(", ", list);
    }

    private boolean validateOdo(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException, SQLException {
        String currentOdo = request.getParameter("currentOdo");

        if (currentOdo == null || currentOdo.isBlank()) {
            loadCreateData(request, bookingId, vehicleId);
            request.setAttribute("currentOdoError", "Vui lòng không để trống thông tin");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request,
                    response);
            return false;
        }

        Vehicle car = vehicleService.getVehicleById(vehicleId);
        int mileage = Integer.parseInt(currentOdo);

        if (mileage < car.getMileage()) {
            loadCreateData(request, bookingId, vehicleId);
            request.setAttribute("currentOdoError", "Vui lòng nhập số km hợp lệ");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request,
                    response);
            return false;
        }
        return true;
    }

    private boolean validateFuel(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException {
        String fuelLevel = request.getParameter("fuel");

        if (fuelLevel == null || fuelLevel.isBlank()) {
            loadCreateData(request, bookingId, vehicleId);
            request.setAttribute("currentFuelLevelError", "Vui lòng chọn mức nhiên liệu");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request,
                    response);
            return false;
        }
        return true;
    }

    private boolean validateImages(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException {
        long MAX_SIZE = 10 * 1024 * 1024;

        for (Part part : request.getParts()) {
            if (!"evidencePhotos".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }

            if (part.getSize() > MAX_SIZE) {
                loadCreateData(request, bookingId, vehicleId);

                request.setAttribute(
                        "uploadPhotosError",
                        "Ảnh " + part.getSubmittedFileName() + " vượt quá dung lượng 10MB.");

                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request,
                        response);
                return false;
            }
        }
        return true;
    }

    private void loadCreateData(HttpServletRequest request, int bookingId, int vehicleId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            Vehicle car = vehicleService.getVehicleById(vehicleId);
            RentalContract contract = contractDAO.findByBookingId(bookingId);

            request.setAttribute("booking", booking);
            request.setAttribute("car", car);
            request.setAttribute("contract", contract);
            request.setAttribute("bookingId", bookingId);
            request.setAttribute("vehicleId", vehicleId);

            if (booking != null) {
                User customer = userDAO.findById(booking.getCustomerId());
                request.setAttribute("customer", customer);
            }

            // Keep form data
            request.setAttribute("currentOdo", request.getParameter("currentOdo"));
            request.setAttribute("fuel", request.getParameter("fuel"));

            request.setAttribute("notes", request.getParameter("notes"));

            request.setAttribute("chkExteriorScratch", request.getParameter("chkExteriorScratch") != null);
            request.setAttribute("chkWindshield", request.getParameter("chkWindshield") != null);
            request.setAttribute("chkTires", request.getParameter("chkTires") != null);

            request.setAttribute("chkCleanliness", request.getParameter("chkCleanliness") != null);
            request.setAttribute("chkOdor", request.getParameter("chkOdor") != null);
            request.setAttribute("chkMatsAccessories", request.getParameter("chkMatsAccessories") != null);

            request.setAttribute("chkEngine", request.getParameter("chkEngine") != null);
            request.setAttribute("chkDashboardLights", request.getParameter("chkDashboardLights") != null);
        } catch (SQLException ex) {
            Logger.getLogger(CreateVehicleHandoverServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /** Notifies the customer that a handover record has been prepared and needs their sign-off. */
    private void notifyVehicleHandedOver(Booking booking, int handoverId) {
        try {
            Vehicle vehicle = vehicleDAO.findById(booking.getVehicleId());
            String vehicleInfo = vehicle != null ? "biển số " + vehicle.getLicensePlate() : "xe #" + booking.getVehicleId();

            Notification notif = new Notification(booking.getCustomerId(),
                    "Biên bản bàn giao xe đã được tạo",
                    "Biên bản bàn giao xe cho đơn đặt xe #" + booking.getBookingId() + " (" + vehicleInfo
                            + ") đã được nhân viên lập thành công. Vui lòng kiểm tra thông tin và thực hiện ký nhận bàn giao xe.",
                    "HANDOVER");
            notif.setReferenceType("HANDOVER");
            notif.setReferenceId(handoverId);
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send vehicle-handed-over notification: " + e.getMessage());
        }
    }
}
