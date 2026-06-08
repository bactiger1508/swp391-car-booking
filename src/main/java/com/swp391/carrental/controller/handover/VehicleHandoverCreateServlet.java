package com.swp391.carrental.controller.handover;

import com.swp391.carrental.dao.*;
import com.swp391.carrental.model.*;
import com.swp391.carrental.service.HandoverService;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "VehicleHandoverCreateServlet", urlPatterns = {"/handovers/create"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 15
)
public class VehicleHandoverCreateServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    // FIX: define upload path
    private static final String UPLOAD_DIR = "assets/images/handover";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");

            if (bookingIdStr != null && carIdStr != null) {

                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Car car = carDAO.findById(carId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
            }

        } catch (Exception e) {
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int carId = Integer.parseInt(request.getParameter("carId"));

            int mileage = Integer.parseInt(request.getParameter("currentOdo"));
            String fuelLevel = request.getParameter("fuel");

            // ===== EXTERIOR =====
            List<String> extList = new ArrayList<>();
            extList.add(request.getParameter("chkExteriorScratch") != null
                    ? "Không vết xước/lõm mới"
                    : "Có vết xước/lõm");

            extList.add(request.getParameter("chkWindshield") != null
                    ? "Kính chắn gió nguyên vẹn"
                    : "Kính chắn gió tổn hại");

            extList.add(request.getParameter("chkTires") != null
                    ? "Lốp xe tốt"
                    : "Lốp xe không tốt");

            String exterior = String.join(", ", extList);

            // ===== INTERIOR =====
            List<String> intList = new ArrayList<>();
            intList.add(request.getParameter("chkCleanliness") != null
                    ? "Sạch sẽ"
                    : "Nội thất bẩn");

            intList.add(request.getParameter("chkOdor") != null
                    ? "Không mùi"
                    : "Có mùi");

            intList.add(request.getParameter("chkMatsAccessories") != null
                    ? "Đủ phụ kiện"
                    : "Thiếu phụ kiện");

            String interior = String.join(", ", intList);

            // ===== MECHANICAL =====
            List<String> mechList = new ArrayList<>();
            mechList.add(request.getParameter("chkEngine") != null
                    ? "Động cơ bình thường"
                    : "Động cơ bất thường");

            mechList.add(request.getParameter("chkDashboardLights") != null
                    ? "Không cảnh báo"
                    : "Có cảnh báo");

            String accessories = String.join(", ", mechList);

            String notes = request.getParameter("notes");
            if (notes == null || notes.isBlank()) {
                notes = "Đã kiểm tra và bàn giao xe";
            }

            // ===== RELATION DATA =====
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            Integer contractId = (contract != null) ? contract.getContractId() : null;

            Booking booking = bookingDAO.findById(bookingId);
            int receivedBy = (booking != null) ? booking.getCustomerId() : 0;

            User currentUser = (User) request.getSession().getAttribute("currentUser");
            int handedBy = (currentUser != null) ? currentUser.getUserId() : 1;

            // ===== FILE UPLOAD FIX =====
            String realPath = request.getServletContext().getRealPath("/");
            String uploadPath = realPath + File.separator + UPLOAD_DIR;

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            List<String> photoUrls = new ArrayList<>();

            for (Part part : request.getParts()) {

                if (!"evidencePhotos".equals(part.getName()) || part.getSize() == 0) {
                    continue;
                }

                String fileName = part.getSubmittedFileName();
                if (fileName == null || fileName.isBlank()) {
                    continue;
                }

                String uniqueName = System.currentTimeMillis() + "_" + fileName;

                part.write(uploadPath + File.separator + uniqueName);

                photoUrls.add("/" + UPLOAD_DIR + "/" + uniqueName);
            }

            String photosUrl = String.join(",", photoUrls);

            // ===== CREATE ENTITY =====
            VehicleHandover handover = new VehicleHandover();
            handover.setBookingId(bookingId);
            handover.setContractId(contractId);
            handover.setCarId(carId);
            handover.setMileageAtHandover(mileage);
            handover.setFuelLevel(fuelLevel);
            handover.setExteriorCondition(exterior);
            handover.setInteriorCondition(interior);
            handover.setAccessoriesChecklist(accessories);
            handover.setPhotosUrl(photosUrl);
            handover.setNotes(notes);
            handover.setHandedBy(handedBy);
            handover.setReceivedBy(receivedBy);
            handover.setHandoverDate(LocalDateTime.now());

            handoverService.handoverVehicle(handover);

            response.sendRedirect(request.getContextPath() + "/handovers");

        } catch (Exception e) {

            request.setAttribute("error", "Lỗi bàn giao: " + e.getMessage());

            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp")
                    .forward(request, response);
        }
    }
}
