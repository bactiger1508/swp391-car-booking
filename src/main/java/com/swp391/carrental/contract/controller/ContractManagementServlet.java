package com.swp391.carrental.contract.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.swp391.carrental.booking.constant.BookingStatus;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.contract.constant.ContractStatus;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.contract.service.ContractService;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;
import com.swp391.carrental.vehicle.model.Car;
import com.swp391.carrental.vehicle.service.VehicleService;

/*
 * Name: ContractManagementServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for ContractManagementServlet.
 */


@WebServlet(name = "ContractManagementServlet", urlPatterns = {"/contracts", "/contracts/detail"})
public class ContractManagementServlet extends HttpServlet {

    private final ContractService contractService = new ContractService();
    private final com.swp391.carrental.booking.service.BookingService bookingService = new com.swp391.carrental.booking.service.BookingService();
    private final com.swp391.carrental.user.service.UserService userService = new com.swp391.carrental.user.service.UserService();
    private final com.swp391.carrental.vehicle.service.VehicleService vehicleService = new com.swp391.carrental.vehicle.service.VehicleService();
    private final NotificationService notificationService = new NotificationService();

    // Handle GET requests for listing and details
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        com.swp391.carrental.user.model.User currentUser = null;
        if (session != null) {
            currentUser = (com.swp391.carrental.user.model.User) session.getAttribute("currentUser");
        }
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        // Display contract detail page
        if ("/contracts/detail".equals(path)) {
            String idStr = request.getParameter("id");
            String bookingIdStr = request.getParameter("bookingId");

            com.swp391.carrental.contract.model.RentalContract contract = null;
            com.swp391.carrental.booking.model.Booking booking = null;

            try {
                // View an existing contract by contract ID
                if (idStr != null && !idStr.isEmpty()) {
                    int contractId = Integer.parseInt(idStr);
                    contract = contractService.getContractById(contractId);
                    // Contract existing
                    if (contract != null) {
                        // Authorization check: CUSTOMER can only view their own contract
                        boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PREPARE_CONTRACT");
                        if (!isStaffOrAdmin && contract.getCustomerId() != currentUser.getUserId()) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập hợp đồng này.");
                            return;
                        }
                        booking = bookingService.getBookingById(contract.getBookingId());
                    }
                } // Create/View contract from booking ID 
                else if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
                    int bookingId = Integer.parseInt(bookingIdStr);
                    contract = contractService.getContractByBookingId(bookingId);
                    
                    // Booking have a contract
                    if (contract != null) {
                        // Authorization check: CUSTOMER can only view their own contract
                        boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PREPARE_CONTRACT");
                        if (!isStaffOrAdmin && contract.getCustomerId() != currentUser.getUserId()) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập hợp đồng này.");
                            return;
                        }
                        booking = bookingService.getBookingById(contract.getBookingId());
                    } else {
                        // Draft contract - only staff/admin can create a contract
                        boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PREPARE_CONTRACT");
                        if (!isStaffOrAdmin) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền lập hợp đồng mới.");
                            return;
                        }
                        booking = bookingService.getBookingById(bookingId);
                        // Only confirmed bookings are eligible for contract creation
                        if (booking != null && !com.swp391.carrental.booking.constant.BookingStatus.CONFIRMED.equals(booking.getStatus())) {
                            request.setAttribute("error", "Chỉ có thể soạn hợp đồng cho các đơn đặt xe đã Xác nhận (Confirmed).");
                        }
                    }
                }

                // Load booking-related information
                if (booking != null) {
                    request.setAttribute("booking", booking);
                    request.setAttribute("customer", userService.getUserById(booking.getCustomerId()));
                    request.setAttribute("car", vehicleService.getCarById(booking.getCarId()));
                    
                    try {
                        com.swp391.carrental.user.dao.CustomerProfileDAO profileDAO = new com.swp391.carrental.user.dao.CustomerProfileDAO();
                        com.swp391.carrental.user.model.CustomerProfile customerProfile = profileDAO.findByUserId(booking.getCustomerId());
                        if (customerProfile == null) {
                            customerProfile = new com.swp391.carrental.user.model.CustomerProfile();
                            customerProfile.setUserId(booking.getCustomerId());
                        }
                        request.setAttribute("customerProfile", customerProfile);
                    } catch (Exception ex) {
                        // fallback blank profile on failure
                        com.swp391.carrental.user.model.CustomerProfile customerProfile = new com.swp391.carrental.user.model.CustomerProfile();
                        customerProfile.setUserId(booking.getCustomerId());
                        request.setAttribute("customerProfile", customerProfile);
                    }
                }

                // Load contract-related information
                if (contract != null) {
                    request.setAttribute("contract", contract);
                    request.setAttribute("creator", userService.getUserById(contract.getCreatedBy()));
                    
                    // Load VAT Invoice and total completed payment amount
                    try {
                        com.swp391.carrental.payment.dao.VatInvoiceDAO vatInvoiceDAO = new com.swp391.carrental.payment.dao.VatInvoiceDAO();
                        com.swp391.carrental.payment.model.VatInvoice vatInvoice = vatInvoiceDAO.findByContractId(contract.getContractId());
                        request.setAttribute("vatInvoice", vatInvoice);
                        
                        com.swp391.carrental.payment.service.PaymentService paymentService = new com.swp391.carrental.payment.service.PaymentService();
                        java.util.List<com.swp391.carrental.payment.model.Payment> payments = paymentService.getPaymentsByBooking(contract.getBookingId());
                        java.math.BigDecimal totalPaid = java.math.BigDecimal.ZERO;
                        for (com.swp391.carrental.payment.model.Payment p : payments) {
                            if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                                if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                                    totalPaid = totalPaid.subtract(p.getAmount());
                                } else {
                                    totalPaid = totalPaid.add(p.getAmount());
                                }
                            }
                        }
                        request.setAttribute("totalPaid", totalPaid);
                    } catch (Exception ex) {
                        // ignore or log
                    }

                    // Handle edit mode
                    String editParam = request.getParameter("edit");
                    if ("true".equals(editParam)) {
                        if ("CUSTOMER".equals(currentUser.getRole())) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa hợp đồng.");
                            return;
                        }
                        if (!com.swp391.carrental.contract.constant.ContractStatus.DRAFT.equals(contract.getStatus())) {
                            request.setAttribute("error", "Chỉ có thể chỉnh sửa hợp đồng đang ở trạng thái Nháp (DRAFT).");
                        } else {
                            request.setAttribute("editMode", true);
                        }
                    }
                }

            } catch (Exception e) {
                request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            }

            request.getRequestDispatcher("/WEB-INF/views/contract/contract-detail.jsp").forward(request, response);
        } // Display contract management page
        else {
            java.util.List<com.swp391.carrental.contract.model.RentalContract> contracts;
            boolean isStaffOrAdmin = com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PREPARE_CONTRACT");
            if (!isStaffOrAdmin) {
                contracts = contractService.getContractsByCustomerId(currentUser.getUserId());
            } else {
                contracts = contractService.getAllContracts();
            }
            request.setAttribute("contracts", contracts);

            // Populate userMap and carMap
            java.util.Map<Integer, com.swp391.carrental.user.model.User> userMap = new java.util.HashMap<>();
            java.util.Map<Integer, com.swp391.carrental.vehicle.model.Car> carMap = new java.util.HashMap<>();
            for (com.swp391.carrental.contract.model.RentalContract c : contracts) {
                try {
                    if (c.getCustomerId() > 0 && !userMap.containsKey(c.getCustomerId())) {
                        userMap.put(c.getCustomerId(), userService.getUserById(c.getCustomerId()));
                    }
                    if (c.getCarId() > 0 && !carMap.containsKey(c.getCarId())) {
                        carMap.put(c.getCarId(), vehicleService.getCarById(c.getCarId()));
                    }
                } catch (Exception ex) {
                    // Skip individual lookup errors to avoid 500 on the whole page
                }
            }
            request.setAttribute("userMap", userMap);
            request.setAttribute("carMap", carMap);

            request.getRequestDispatcher("/WEB-INF/views/contract/contract-management.jsp").forward(request, response);
        }
    }

    // Handle POST requests for activation and creation
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        com.swp391.carrental.user.model.User currentUser = null;
        
        // Get currently logged-in user
        if (session != null) {
            currentUser = (com.swp391.carrental.user.model.User) session.getAttribute("currentUser");
        }
        
        // Require authentication
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (!com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "PREPARE_CONTRACT")
                && !com.swp391.carrental.core.util.SecurityUtils.hasPermission(request, "UPDATE_CONTRACT")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        String action = request.getParameter("action");
        
        // Activate contract action
        if ("activate".equals(action)) {
            String contractIdStr = request.getParameter("contractId");
            try {
                if (contractIdStr != null && !contractIdStr.isEmpty()) {
                    int contractId = Integer.parseInt(contractIdStr);
                    boolean updated = contractService.updateContractStatus(contractId, com.swp391.carrental.contract.constant.ContractStatus.ACTIVE);
                    if (updated) {
                        // Successfully updated status to ACTIVE
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                    return;
                }
            } catch (Exception e) {
                if (session != null) {
                    session.setAttribute("errorMessage", "Lỗi kích hoạt hợp đồng: " + e.getMessage());
                }
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }
        }

        // Update contract details action
        if ("update".equals(action)) {
            if ("CUSTOMER".equals(currentUser.getRole())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa hợp đồng.");
                return;
            }
            String contractIdStr = request.getParameter("contractId");
            try {
                if (contractIdStr == null || contractIdStr.isEmpty()) {
                    throw new com.swp391.carrental.core.exception.AppException("Không có mã hợp đồng.");
                }
                int contractId = Integer.parseInt(contractIdStr);
                
                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");
                String dailyRateStr = request.getParameter("dailyRate");
                String totalAmountStr = request.getParameter("totalAmount");
                String depositAmountStr = request.getParameter("depositAmount");
                String baseAmountStr = request.getParameter("baseAmount");
                String discountAmountStr = request.getParameter("discountAmount");
                String terms = request.getParameter("termsAndConditions");

                // Parsing values
                java.time.LocalDateTime startDate = null;
                java.time.LocalDateTime endDate = null;
                if (startDateStr != null && !startDateStr.isEmpty()) {
                    startDate = java.time.LocalDateTime.parse(startDateStr);
                }
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    endDate = java.time.LocalDateTime.parse(endDateStr);
                }

                java.math.BigDecimal dailyRate = dailyRateStr != null && !dailyRateStr.isEmpty() 
                        ? new java.math.BigDecimal(dailyRateStr.replace(",", "")) : java.math.BigDecimal.ZERO;
                java.math.BigDecimal totalAmount = totalAmountStr != null && !totalAmountStr.isEmpty() 
                        ? new java.math.BigDecimal(totalAmountStr.replace(",", "")) : java.math.BigDecimal.ZERO;
                java.math.BigDecimal depositAmount = depositAmountStr != null && !depositAmountStr.isEmpty() 
                        ? new java.math.BigDecimal(depositAmountStr.replace(",", "")) : java.math.BigDecimal.ZERO;
                java.math.BigDecimal baseAmount = baseAmountStr != null && !baseAmountStr.isEmpty() 
                        ? new java.math.BigDecimal(baseAmountStr.replace(",", "")) : java.math.BigDecimal.ZERO;
                java.math.BigDecimal discountAmount = discountAmountStr != null && !discountAmountStr.isEmpty() 
                        ? new java.math.BigDecimal(discountAmountStr.replace(",", "")) : java.math.BigDecimal.ZERO;

                com.swp391.carrental.contract.model.RentalContract contract = new com.swp391.carrental.contract.model.RentalContract();
                contract.setContractId(contractId);
                contract.setStartDate(startDate);
                contract.setEndDate(endDate);
                contract.setDailyRate(dailyRate);
                contract.setTotalAmount(totalAmount);
                contract.setDepositAmount(depositAmount);
                contract.setBaseAmount(baseAmount);
                contract.setDiscountAmount(discountAmount);
                contract.setTermsAndConditions(terms);

                boolean updated = contractService.updateContract(contract, currentUser.getUserId(), currentUser.getRole());
                if (updated) {
                    if (session != null) {
                        session.setAttribute("successMessage", "Cập nhật hợp đồng thành công!");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                return;
            } catch (Exception e) {
                if (session != null) {
                    session.setAttribute("errorMessage", "Lỗi cập nhật hợp đồng: " + e.getMessage());
                }
                response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractIdStr + "&edit=true");
                return;
            }
        }

        String bookingIdStr = request.getParameter("bookingId");
        String termsAndConditions = request.getParameter("termsAndConditions");

        // Activate contract notification
        if ("activate".equals(action)) {
            String contractIdStr = request.getParameter("contractId");
            try {
                if (contractIdStr != null && !contractIdStr.isEmpty()) {
                    int contractId = Integer.parseInt(contractIdStr);
                    com.swp391.carrental.contract.model.RentalContract activeContract = contractService.getContractById(contractId);
                    boolean updated = contractService.updateContractStatus(contractId, com.swp391.carrental.contract.constant.ContractStatus.ACTIVE);
                    if (updated && activeContract != null) {
                        notifyContractActivated(activeContract, contractId);
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                    return;
                }
            } catch (Exception e) {
                if (session != null) {
                    session.setAttribute("errorMessage", "Lỗi kích hoạt hợp đồng: " + e.getMessage());
                }
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }
        }
        
        // Booking ID is required for contract creation
        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/contracts");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            com.swp391.carrental.booking.model.Booking booking = bookingService.getBookingById(bookingId);
            
            // Not found booking
            if (booking == null) {
                throw new com.swp391.carrental.core.exception.AppException("Không tìm thấy đơn đặt xe.");
            }
            
            // Booking status is not confirmed
            if (!com.swp391.carrental.booking.constant.BookingStatus.CONFIRMED.equals(booking.getStatus())) {
                throw new com.swp391.carrental.core.exception.AppException("Trạng thái đặt xe phải là Đã xác nhận (Confirmed) để tạo hợp đồng.");
            }

            // Check if customer profile is verified
            com.swp391.carrental.user.dao.CustomerProfileDAO profileDAO = new com.swp391.carrental.user.dao.CustomerProfileDAO();
            com.swp391.carrental.user.model.CustomerProfile customerProfile = profileDAO.findByUserId(booking.getCustomerId());
            if (customerProfile == null || !"VERIFIED".equals(customerProfile.getVerificationStatus())) {
                throw new com.swp391.carrental.core.exception.AppException("Không thể lập hợp đồng: Hồ sơ khách hàng chưa được xác minh (VERIFIED).");
            }

            com.swp391.carrental.vehicle.model.Car car = vehicleService.getCarById(booking.getCarId());
            
            // Not found car
            if (car == null) {
                throw new com.swp391.carrental.core.exception.AppException("Không tìm thấy xe.");
            }

            com.swp391.carrental.contract.model.RentalContract contract = new com.swp391.carrental.contract.model.RentalContract();
            contract.setBookingId(bookingId);
            contract.setCustomerId(booking.getCustomerId());
            contract.setCarId(booking.getCarId());
            contract.setStartDate(booking.getStartDate());
            contract.setEndDate(booking.getEndDate());
            contract.setDailyRate(car.getDailyRate());
            contract.setTotalAmount(booking.getTotalAmount());
            contract.setDepositAmount(booking.getDepositAmount());
            contract.setTermsAndConditions(termsAndConditions);
            contract.setCreatedBy(currentUser.getUserId());

            int contractId = contractService.createContract(contract);
            if (contractId > 0) {
                notifyContractPrepared(contract, contractId, booking.getCustomerId());
                response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
            } else {
                throw new com.swp391.carrental.core.exception.AppException("Không thể lưu hợp đồng vào cơ sở dữ liệu.");
            }
        } catch (Exception e) {
            if (session != null) {
                session.setAttribute("errorMessage", "Lỗi tạo hợp đồng: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/contracts");
        }
    }

    private void notifyContractPrepared(RentalContract contract, int contractId, int customerId) {
        try {
            Notification notif = new Notification(customerId,
                    "Hợp đồng đã được chuẩn bị",
                    "Hợp đồng #" + contractId + " cho booking #" + contract.getBookingId() + " đã được soạn thảo. Vui lòng kiểm tra và ký kết.",
                    "CONTRACT");
            notif.setReferenceType("CONTRACT");
            notif.setReferenceId(contractId);
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send contract-prepared notification: " + e.getMessage());
        }
    }

    private void notifyContractActivated(RentalContract contract, int contractId) {
        try {
            Notification notif = new Notification(contract.getCustomerId(),
                    "Hợp đồng đã được kích hoạt",
                    "Hợp đồng #" + contractId + " đã được ký kết và kích hoạt. Bạn có thể tiến hành bàn giao xe.",
                    "CONTRACT");
            notif.setReferenceType("CONTRACT");
            notif.setReferenceId(contractId);
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send contract-activated notification: " + e.getMessage());
        }
    }
}
