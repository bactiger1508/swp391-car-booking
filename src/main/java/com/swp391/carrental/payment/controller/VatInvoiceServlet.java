package com.swp391.carrental.payment.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.contract.service.ContractService;
import com.swp391.carrental.payment.dao.VatInvoiceDAO;
import com.swp391.carrental.payment.model.Payment;
import com.swp391.carrental.payment.model.VatInvoice;
import com.swp391.carrental.payment.service.PaymentService;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;
import com.swp391.carrental.vehicle.service.VehicleService;

@WebServlet(name = "VatInvoiceServlet", urlPatterns = {"/contracts/vat-invoice/create", "/contracts/vat-invoice/detail"})
public class VatInvoiceServlet extends HttpServlet {

    private final ContractService contractService = new ContractService();
    private final PaymentService paymentService = new PaymentService();
    private final VatInvoiceDAO vatInvoiceDAO = new VatInvoiceDAO();
    private final PolicyService policyService = new PolicyService();
    private final UserService userService = new UserService();
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/contracts/vat-invoice/detail".equals(path)) {
            String contractIdStr = request.getParameter("contractId");
            if (contractIdStr == null || contractIdStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu mã hợp đồng.");
                return;
            }

            try {
                int contractId = Integer.parseInt(contractIdStr);
                RentalContract contract = contractService.getContractById(contractId);
                if (contract == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hợp đồng.");
                    return;
                }

                // Authorization check
                if ("CUSTOMER".equals(currentUser.getRole()) && contract.getCustomerId() != currentUser.getUserId()) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập hóa đơn này.");
                    return;
                }

                VatInvoice invoice = vatInvoiceDAO.findByContractId(contractId);
                if (invoice == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hóa đơn VAT cho hợp đồng này.");
                    return;
                }

                // Fetch payments included
                List<Payment> payments = paymentService.getPaymentsByBooking(contract.getBookingId());

                // Fetch extra policy details for invoice header/metadata
                String companyName = policyService.getPolicyValue("COMPANY_NAME", "CÔNG TY CỔ PHẦN CARPRO VIỆT NAM");
                String companyTaxId = policyService.getPolicyValue("COMPANY_TAX_ID", "0109876543");
                String companyAddress = policyService.getPolicyValue("COMPANY_ADDRESS", "Tầng 5, Tòa nhà CarPro, 123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh");

                request.setAttribute("contract", contract);
                request.setAttribute("invoice", invoice);
                request.setAttribute("payments", payments);
                request.setAttribute("customer", userService.getUserById(contract.getCustomerId()));
                request.setAttribute("car", vehicleService.getCarById(contract.getCarId()));
                request.setAttribute("companyName", companyName);
                request.setAttribute("companyTaxId", companyTaxId);
                request.setAttribute("companyAddress", companyAddress);

                request.getRequestDispatcher("/WEB-INF/views/payment/vat-invoice-detail.jsp").forward(request, response);

            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("currentUser");
        }
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Only Staff/Admin can generate VAT Invoice
        if (!"STAFF".equals(currentUser.getRole()) && !"ADMIN".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền lập hóa đơn VAT.");
            return;
        }

        String path = request.getServletPath();

        if ("/contracts/vat-invoice/create".equals(path)) {
            String contractIdStr = request.getParameter("contractId");
            if (contractIdStr == null || contractIdStr.isEmpty()) {
                if (session != null) {
                    session.setAttribute("errorMessage", "Mã hợp đồng không hợp lệ.");
                }
                response.sendRedirect(request.getContextPath() + "/contracts");
                return;
            }

            int contractId = Integer.parseInt(contractIdStr);
            try {
                RentalContract contract = contractService.getContractById(contractId);
                if (contract == null) {
                    if (session != null) {
                        session.setAttribute("errorMessage", "Không tìm thấy hợp đồng.");
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts");
                    return;
                }

                // Criteria 1: Contract status = COMPLETED
                if (!"COMPLETED".equalsIgnoreCase(contract.getStatus())) {
                    if (session != null) {
                        session.setAttribute("errorMessage", "Chỉ có thể tạo hóa đơn VAT cho hợp đồng đã HOÀN THÀNH.");
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                    return;
                }

                // Criteria 2: Check if VAT Invoice already exists
                VatInvoice existing = vatInvoiceDAO.findByContractId(contractId);
                if (existing != null) {
                    if (session != null) {
                        session.setAttribute("errorMessage", "Hóa đơn VAT cho hợp đồng này đã tồn tại.");
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                    return;
                }

                // Criteria 3: Total paid >= total contract amount
                List<Payment> payments = paymentService.getPaymentsByBooking(contract.getBookingId());
                BigDecimal totalPaid = BigDecimal.ZERO;
                for (Payment p : payments) {
                    if ("COMPLETED".equalsIgnoreCase(p.getStatus())) {
                        if ("REFUND".equalsIgnoreCase(p.getPaymentType())) {
                            totalPaid = totalPaid.subtract(p.getAmount());
                        } else {
                            totalPaid = totalPaid.add(p.getAmount());
                        }
                    }
                }

                if (totalPaid.compareTo(contract.getTotalAmount()) < 0) {
                    if (session != null) {
                        session.setAttribute("errorMessage", "Tổng tiền thanh toán chưa đủ để lập hóa đơn VAT.");
                    }
                    response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);
                    return;
                }

                // Get configured tax rate from policy_settings
                String taxRateStr = policyService.getPolicyValue("TAX_RATE", "10");
                BigDecimal taxRate = new BigDecimal(taxRateStr);

                // Calculations
                // totalAmount is the sum of all completed payments of the contract
                BigDecimal totalAmount = totalPaid;
                BigDecimal divisor = BigDecimal.ONE.add(taxRate.divide(new BigDecimal("100"), 4, RoundingMode.HALF_UP));
                BigDecimal amountBeforeTax = totalAmount.divide(divisor, 2, RoundingMode.HALF_UP);
                BigDecimal taxAmount = totalAmount.subtract(amountBeforeTax);

                // Build Invoice Code (Format: INV-VAT-CTR-{contractId})
                String invoiceCode = "INV-VAT-CTR-" + contractId;

                VatInvoice newInvoice = new VatInvoice();
                newInvoice.setContractId(contractId);
                newInvoice.setInvoiceCode(invoiceCode);
                newInvoice.setInvoiceDate(java.time.LocalDateTime.now());
                newInvoice.setInvoiceStatus("ISSUED");
                newInvoice.setAmountBeforeTax(amountBeforeTax);
                newInvoice.setTaxRate(taxRate);
                newInvoice.setTaxAmount(taxAmount);
                newInvoice.setTotalAmount(totalAmount);

                vatInvoiceDAO.insert(newInvoice);

                if (session != null) {
                    session.setAttribute("successMessage", "Đã tạo hóa đơn VAT thành công!");
                }
                response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractId);

            } catch (Exception e) {
                if (session != null) {
                    session.setAttribute("errorMessage", "Lỗi tạo hóa đơn VAT: " + e.getMessage());
                }
                response.sendRedirect(request.getContextPath() + "/contracts/detail?id=" + contractIdStr);
            }
        }
    }
}
