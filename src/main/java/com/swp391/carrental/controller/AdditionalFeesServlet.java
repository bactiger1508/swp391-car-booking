package com.swp391.carrental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdditionalFeesServlet", urlPatterns = {"/additional-fees"})
public class AdditionalFeesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Load additional fees for a booking/return
        request.getRequestDispatcher("/WEB-INF/views/handover/additional-fees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Calculate and save additional fees (BR-07)
        response.sendRedirect(request.getContextPath() + "/additional-fees");
    }
}

