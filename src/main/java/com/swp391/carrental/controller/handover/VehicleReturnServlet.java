/*
 * Name: VehicleReturnServlet
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles HTTP requests and responses for VehicleReturnServlet.
 */
package com.swp391.carrental.controller.handover;

import com.swp391.carrental.service.ReturnService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "VehicleReturnServlet", urlPatterns = {"/returns"})
public class VehicleReturnServlet extends HttpServlet {
    private final ReturnService returnService = new ReturnService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("doGet");
        request.setAttribute("returns", returnService.getAllReturns());
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Record return (BR-07, BR-08)
        response.sendRedirect(request.getContextPath() + "/returns");
    }
}

