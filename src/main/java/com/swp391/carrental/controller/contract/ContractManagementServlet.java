/*
 * Name: ContractManagementServlet
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for ContractManagementServlet.
 */
package com.swp391.carrental.controller.contract;

import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.RentalContract;
import com.swp391.carrental.model.User;
import com.swp391.carrental.service.ContractService;
import com.swp391.carrental.service.UserService;
import com.swp391.carrental.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ContractManagementServlet", urlPatterns = {"/contracts", "/contracts/detail"})
public class ContractManagementServlet extends HttpServlet {
    private final ContractService contractService = new ContractService();
    private final UserService userService = new UserService();
    private final VehicleService vehicleService = new VehicleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/contracts/detail".equals(path)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                RentalContract contract = contractService.getContractById(Integer.parseInt(idStr));
                request.setAttribute("contract", contract);
                if (contract != null) {
                    request.setAttribute("customer", userService.getUserById(contract.getCustomerId()));
                    request.setAttribute("car", vehicleService.getCarById(contract.getCarId()));
                    request.setAttribute("creator", userService.getUserById(contract.getCreatedBy()));
                }
            }
            request.getRequestDispatcher("/WEB-INF/views/contract/contract-detail.jsp").forward(request, response);
        } else {
            List<RentalContract> contracts = contractService.getAllContracts();
            request.setAttribute("contracts", contracts);

            Map<Integer, User> userMap = new HashMap<>();
            Map<Integer, Car> carMap = new HashMap<>();

            for (RentalContract c : contracts) {
                if (!userMap.containsKey(c.getCustomerId())) {
                    User u = userService.getUserById(c.getCustomerId());
                    if (u != null) {
                        userMap.put(c.getCustomerId(), u);
                    }
                }
                if (!carMap.containsKey(c.getCarId())) {
                    Car car = vehicleService.getCarById(c.getCarId());
                    if (car != null) {
                        carMap.put(c.getCarId(), car);
                    }
                }
            }
            request.setAttribute("userMap", userMap);
            request.setAttribute("carMap", carMap);

            request.getRequestDispatcher("/WEB-INF/views/contract/contract-management.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Handle contract creation (BR-05) and status updates
        response.sendRedirect(request.getContextPath() + "/contracts");
    }
}

