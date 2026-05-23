package com.swp391.carrental.controller;

import com.swp391.carrental.service.ContractService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ContractManagementServlet", urlPatterns = {"/contracts", "/contracts/detail"})
public class ContractManagementServlet extends HttpServlet {
    private final ContractService contractService = new ContractService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/contracts/detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                request.setAttribute("contract", contractService.getContractById(Integer.parseInt(idStr)));
            }
            request.getRequestDispatcher("/WEB-INF/views/contract/contract-detail.jsp").forward(request, response);
        } else {
            request.setAttribute("contracts", contractService.getAllContracts());
            request.getRequestDispatcher("/WEB-INF/views/contract/contract-management.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Handle contract creation (BR-05) and status updates
        response.sendRedirect(request.getContextPath() + "/contracts");
    }
}

