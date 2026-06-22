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
                        if ("CUSTOMER".equals(currentUser.getRole()) && contract.getCustomerId() != currentUser.getUserId()) {
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
                        if ("CUSTOMER".equals(currentUser.getRole()) && contract.getCustomerId() != currentUser.getUserId()) {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập hợp đồng này.");
                            return;
                        }
                        booking = bookingService.getBookingById(contract.getBookingId());
                    } else {
                        // Draft contract - only staff/admin can create a contract
                        if ("CUSTOMER".equals(currentUser.getRole())) {
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
                }

            } catch (Exception e) {
                request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            }

            request.getRequestDispatcher("/WEB-INF/views/contract/contract-detail.jsp").forward(request, response);
        } // Display contract management page
        else {
            java.util.List<com.swp391.carrental.contract.model.RentalContract> contracts;
            if ("CUSTOMER".equals(currentUser.getRole())) {
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

        String action = request.getParameter("action");
        
        // Activate contract action
        if ("activate".equals(action)) {
            String contractIdStr = request.getParameter("contractId");
            try {
                if (contractIdStr != null && !contractIdStr.isEmpty()) {
                    int contractId = Integer.parseInt(contractIdStr);
                    boolean updated = contractService.updateContractStatus(contractId, com.swp391.carrental.contract.constant.ContractStatus.ACTIVE);
                    if (updated) {
                        // Cập nhật thành công trạng thái ACTIVE
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

        String bookingIdStr = request.getParameter("bookingId");
        String termsAndConditions = request.getParameter("termsAndConditions");
        
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
}
