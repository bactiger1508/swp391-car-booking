package com.swp391.carrental.controller.handover;

import com.swp391.carrental.dao.BookingDAO;
import com.swp391.carrental.dao.CarDAO;
import com.swp391.carrental.dao.ContractDAO;
import com.swp391.carrental.dao.UserDAO;
import com.swp391.carrental.model.Booking;
import com.swp391.carrental.model.Car;
import com.swp391.carrental.model.RentalContract;
import com.swp391.carrental.model.User;
import com.swp391.carrental.model.VehicleHandover;
import com.swp391.carrental.service.HandoverService;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "VehicleHandoverCreateServlet", urlPatterns = {"/handovers/create"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 10,       // 10 MB
    maxRequestSize = 1024 * 1024 * 15     // 15 MB
)
public class VehicleHandoverCreateServlet extends HttpServlet {

    private final HandoverService handoverService = new HandoverService();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String carIdStr = request.getParameter("carId");

            if (bookingIdStr != null && carIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int carId = Integer.parseInt(carIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Car car = carDAO.findById(carId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi tải thông tin bàn giao: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        int carId = Integer.parseInt(request.getParameter("carId"));
        try {
            int mileage = Integer.parseInt(request.getParameter("currentOdo"));
            String fuelLevel = request.getParameter("fuel");

            // Combine Exterior conditions
            List<String> extList = new ArrayList<>();
            if (request.getParameter("chkExteriorScratch") != null) extList.add("Không vết xước/lõm mới"); else extList.add("Có vết xước/lõm");
            if (request.getParameter("chkWindshield") != null) extList.add("Kính chắn gió nguyên vẹn"); else extList.add("Kính chắn gió tổn hại");
            if (request.getParameter("chkTires") != null) extList.add("Lốp xe tốt"); else extList.add("Lốp xe không tốt");
            String exterior = String.join(", ", extList);

            // Combine Interior conditions
            List<String> intList = new ArrayList<>();
            if (request.getParameter("chkCleanliness") != null) intList.add("Sạch sẽ và được hút bụi"); else intList.add("Nội thất bẩn");
            if (request.getParameter("chkOdor") != null) intList.add("Không có mùi hôi"); else intList.add("Có mùi hôi");
            if (request.getParameter("chkMatsAccessories") != null) intList.add("Có đủ thảm và phụ kiện"); else intList.add("Thiếu thảm/phụ kiện");
            String interior = String.join(", ", intList);

            // Combine Mechanical conditions (accessories checklist)
            List<String> mechList = new ArrayList<>();
            if (request.getParameter("chkEngine") != null) mechList.add("Động cơ bình thường"); else mechList.add("Động cơ bất thường");
            if (request.getParameter("chkDashboardLights") != null) mechList.add("Không có đèn cảnh báo"); else mechList.add("Có đèn cảnh báo");
            String accessories = String.join(", ", mechList);

            String notes = request.getParameter("notes");
            if (notes == null) notes = "Đã kiểm tra và bàn giao xe";

            // Fetch contract and customer details
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            Integer contractId = (contract != null) ? contract.getContractId() : null;

            Booking booking = bookingDAO.findById(bookingId);
            int receivedBy = (booking != null) ? booking.getCustomerId() : 0;

            User currentUser = (User) request.getSession().getAttribute("currentUser");
            int handedBy = (currentUser != null) ? currentUser.getUserId() : 1; // Default to 1 if session is empty (e.g. during dev)

            // Handling photo upload path dummy (or read file name if uploaded)
            String photosUrl = "/assets/images/cars/placeholder.jpg";
            try {
                Part filePart = request.getPart("evidencePhotos");
                if (filePart != null && filePart.getSize() > 0) {
                    String submittedFileName = filePart.getSubmittedFileName();
                    if (submittedFileName != null && !submittedFileName.isEmpty()) {
                        photosUrl = "/assets/images/handover/" + submittedFileName;
                    }
                }
            } catch (Exception ignored) {}

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
            try {
                Booking booking = bookingDAO.findById(bookingId);
                Car car = carDAO.findById(carId);
                RentalContract contract = contractDAO.findByBookingId(bookingId);
                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
            } catch (Exception ignored) {}

            request.setAttribute("error", "Lỗi lập biên bản bàn giao: " + e.getMessage());
            request.setAttribute("bookingId", bookingId);
            request.setAttribute("carId", carId);
            request.setAttribute("currentOdo", request.getParameter("currentOdo"));
            request.setAttribute("fuel", request.getParameter("fuel"));
            request.setAttribute("notes", request.getParameter("notes"));
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-handover-create.jsp").forward(request, response);
        }
    }
}
