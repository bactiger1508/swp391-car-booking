package com.swp391.carrental.controller.handover;

import com.swp391.carrental.dao.*;
import com.swp391.carrental.model.*;
import com.swp391.carrental.service.HandoverService;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.awt.image.BufferedImage;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;

@WebServlet(name = "HandoverDetailServlet", urlPatterns = {"/handovers/detail"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 15
)

public class HandoverDetailServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();
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
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("handover", handover);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("delete".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));

                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (handover != null) {
                    handoverService.deleteHandoverVehicle(handover.getHandoverId());
                }

                response.sendRedirect(request.getContextPath() + "/handovers");
                return;
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        if ("save".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                int carId = Integer.parseInt(request.getParameter("carId"));

                // ===== VALIDATION =====
                if (!validateOdo(request, response, bookingId, carId)) {
                    return;
                }

                if (!validateFuel(request, response, bookingId, carId)) {
                    return;
                }

                if (!validateImages(request, response, bookingId, carId)) {
                    return;
                }

                // ===== GET EXISTING HANDOVER =====
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

                if (handover == null) {
                    request.setAttribute("error", "Không tìm thấy bản ghi bàn giao để cập nhật.");
                    request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
                    return;
                }

                // ===== FORM DATA =====
                int mileage = Integer.parseInt(request.getParameter("currentOdo"));

                String fuelLevel = request.getParameter("fuel");
                if ("F".equals(fuelLevel)) {
                    fuelLevel = "FULL";
                } else if ("E".equals(fuelLevel)) {
                    fuelLevel = "EMPTY";
                }

                String notes = request.getParameter("notes");
                if (notes == null || notes.isBlank()) {
                    notes = "Đã kiểm tra và bàn giao xe";
                }

                String exterior = buildExteriorCondition(request);
                String interior = buildInteriorCondition(request);
                String accessories = buildMechanicalCondition(request);

                String newPhotos = saveImages(request, bookingId);
                String remainingPhotos = request.getParameter("remainingPhotos");

                String finalPhotos = "";
                if (remainingPhotos != null && !remainingPhotos.isEmpty()) {
                    finalPhotos = remainingPhotos;
                }

                if (newPhotos != null && !newPhotos.isEmpty()) {
                    if (!finalPhotos.isEmpty()) {
                        finalPhotos += "," + newPhotos;
                    } else {
                        finalPhotos = newPhotos;
                    }
                }

                // ===== UPDATE OBJECT =====
                handover.setMileageAtHandover(mileage);
                handover.setFuelLevel(fuelLevel);

                handover.setPhotosUrl(finalPhotos);
                handover.setNotes(notes);

                handover.setExteriorCondition(exterior);
                handover.setInteriorCondition(interior);
                handover.setAccessoriesChecklist(accessories);

                handoverService.updateHandoverVehicle(handover);

                response.sendRedirect(request.getContextPath() + "/handovers");
                return;
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi bàn giao: " + e.getMessage());
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
            }
        }
    }

    private String saveImages(HttpServletRequest request, int bookingId)
            throws IOException, ServletException {

        String uploadPath = request.getServletContext().getRealPath("")
                + File.separator + "assets/images/handover";

        File folder = new File(uploadPath);
        if (!folder.exists()) {
            folder.mkdirs();
        }

        List<String> urls = new ArrayList<>();

        for (Part part : request.getParts()) {
            if (part == null || !"evidencePhotos".equals(part.getName()) || part.getSize() <= 0) {
                continue;
            }

            String fileName = bookingId + "_" + System.currentTimeMillis()
                    + "_" + part.getSubmittedFileName();

            part.write(uploadPath + File.separator + fileName);

            urls.add("/assets/images/handover/" + fileName);
        }

        return String.join(",", urls);
    }

    private String buildExteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkExteriorScratch") != null ? "Không vết xước/lõm mới" : "Có vết xước/lõm");
        list.add(request.getParameter("chkWindshield") != null ? "Kính chắn gió nguyên vẹn" : "Kính chắn gió tổn hại");
        list.add(request.getParameter("chkTires") != null ? "Lốp xe tốt" : "Lốp xe không tốt");
        return String.join(", ", list);
    }

    private String buildInteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkCleanliness") != null ? "Sạch sẽ" : "Nội thất bẩn");
        list.add(request.getParameter("chkOdor") != null ? "Không mùi" : "Có mùi");
        list.add(request.getParameter("chkMatsAccessories") != null ? "Đủ phụ kiện" : "Thiếu phụ kiện");
        return String.join(", ", list);
    }

    private String buildMechanicalCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkEngine") != null ? "Động cơ bình thường" : "Động cơ bất thường");
        list.add(request.getParameter("chkDashboardLights") != null ? "Không cảnh báo" : "Có cảnh báo");
        return String.join(", ", list);
    }

    private boolean validateOdo(HttpServletRequest request, HttpServletResponse response, int bookingId, int carId)
            throws ServletException, IOException, SQLException {
        String currentOdo = request.getParameter("currentOdo");

        if (currentOdo == null || currentOdo.isBlank()) {
            loadDetailData(request, bookingId, carId);
            request.setAttribute("currentOdoError", "Vui lòng không để trống thông tin");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
            return false;
        }

        Car car = carDAO.findById(carId);
        int mileage = Integer.parseInt(currentOdo);

        if (mileage < car.getMileage()) {
            loadDetailData(request, bookingId, carId);
            request.setAttribute("currentOdoError", "Vui lòng nhập số km hợp lệ");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private boolean validateFuel(HttpServletRequest request, HttpServletResponse response, int bookingId, int carId)
            throws ServletException, IOException {
        String fuelLevel = request.getParameter("fuel");

        if (fuelLevel == null || fuelLevel.isBlank()) {
            loadDetailData(request, bookingId, carId);
            request.setAttribute("currentFuelLevelError", "Vui lòng chọn mức nhiên liệu");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private boolean validateImages(HttpServletRequest request, HttpServletResponse response, int bookingId, int carId)
            throws ServletException, IOException {
        for (Part part : request.getParts()) {
            if (!"evidencePhotos".equals(part.getName())
                    || part.getSize() == 0) {
                continue;
            }

            BufferedImage img = ImageIO.read(part.getInputStream());

            if (img == null) {
                loadDetailData(request, bookingId, carId);
                request.setAttribute("uploadPhotosError", "File tải lên không phải ảnh hợp lệ.");
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
                return false;
            }

            if (img.getWidth() > 800 || img.getHeight() > 400) {
                loadDetailData(request, bookingId, carId);
                request.setAttribute("error", "Ảnh vượt quá kích thước 800x400px");
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-detail.jsp").forward(request, response);
                return false;
            }
        }
        return true;
    }

    private void loadDetailData(HttpServletRequest request, int bookingId, int carId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            Car car = carDAO.findById(carId);
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            VehicleHandover handover = handoverDAO.findByBookingId(bookingId);

            request.setAttribute("booking", booking);
            request.setAttribute("car", car);
            request.setAttribute("contract", contract);
            request.setAttribute("handover", handover);
            request.setAttribute("bookingId", bookingId);
            request.setAttribute("carId", carId);

            if (booking != null) {
                User customer = userDAO.findById(booking.getCustomerId());
                request.setAttribute("customer", customer);
            }

            // Giữ lại dữ liệu form - ghi đè lên handover
            request.setAttribute("currentOdo", request.getParameter("currentOdo"));
            request.setAttribute("fuel", request.getParameter("fuel"));
            request.setAttribute("notes", request.getParameter("notes"));
            request.setAttribute("chkExteriorScratch", request.getParameter("chkExteriorScratch") != null);
            request.setAttribute("chkWindshield", request.getParameter("chkWindshield") != null);
            request.setAttribute("chkTires", request.getParameter("chkTires") != null);
            request.setAttribute("chkCleanliness", request.getParameter("chkCleanliness") != null);
            request.setAttribute("chkOdor", request.getParameter("chkOdor") != null);
            request.setAttribute("chkMatsAccessories", request.getParameter("chkMatsAccessories") != null);
            request.setAttribute("chkEngine", request.getParameter("chkEngine") != null);
            request.setAttribute("chkDashboardLights", request.getParameter("chkDashboardLights") != null);

        } catch (SQLException ex) {
            Logger.getLogger(HandoverDetailServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
