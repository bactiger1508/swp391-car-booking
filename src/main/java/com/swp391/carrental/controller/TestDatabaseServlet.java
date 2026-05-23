package com.swp391.carrental.controller;

import com.swp391.carrental.util.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

/**
 * Test servlet to verify database connectivity.
 * URL: /test-db
 */
@WebServlet(name = "TestDatabaseServlet", urlPatterns = {"/test-db"})
public class TestDatabaseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html><head><title>Database Connection Test</title>");
            out.println("<style>body{font-family:Arial,sans-serif;padding:40px;background:#f5f5f5;}");
            out.println(".card{background:white;padding:30px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);max-width:600px;margin:0 auto;}");
            out.println(".success{color:#28a745;}.error{color:#dc3545;}h1{margin-top:0;}</style></head><body>");
            out.println("<div class='card'>");

            try (Connection conn = DBContext.getConnection()) {
                DatabaseMetaData meta = conn.getMetaData();
                out.println("<h1 class='success'>&#10004; Database connected successfully!</h1>");
                out.println("<p><strong>Database:</strong> " + meta.getDatabaseProductName() + " " + meta.getDatabaseProductVersion() + "</p>");
                out.println("<p><strong>Database Name:</strong> " + conn.getCatalog() + "</p>");
                out.println("<p><strong>Driver:</strong> " + meta.getDriverName() + " " + meta.getDriverVersion() + "</p>");
                out.println("<p><strong>URL:</strong> " + meta.getURL() + "</p>");
            } catch (Exception e) {
                out.println("<h1 class='error'>&#10008; Database connection failed!</h1>");
                out.println("<p><strong>Error:</strong> " + e.getMessage() + "</p>");
                out.println("<h3>Troubleshooting:</h3>");
                out.println("<ul>");
                out.println("<li>Check that SQL Server is running</li>");
                out.println("<li>Check TCP/IP is enabled on port 1433</li>");
                out.println("<li>Check db.properties credentials</li>");
                out.println("<li>Check SQL Server Browser service is running</li>");
                out.println("</ul>");
            }

            out.println("<hr><p><a href='" + request.getContextPath() + "/home'>← Back to Home</a></p>");
            out.println("</div></body></html>");
        }
    }
}
