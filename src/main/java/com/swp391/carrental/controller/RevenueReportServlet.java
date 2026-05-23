package com.swp391.carrental.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RevenueReportServlet", urlPatterns = {"/reports/revenue"})
public class RevenueReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO: Generate revenue report with date filters
        request.getRequestDispatcher("/WEB-INF/views/report/revenue-report.jsp").forward(request, response);
    }
}

