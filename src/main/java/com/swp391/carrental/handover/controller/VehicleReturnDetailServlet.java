package com.swp391.carrental.handover.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.math.BigDecimal;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.dao.*;
import com.swp391.carrental.handover.model.*;
import com.swp391.carrental.handover.service.ReturnService;
import com.swp391.carrental.notification.model.Notification;
import com.swp391.carrental.notification.service.NotificationService;
import com.swp391.carrental.policy.service.FeeCalculator;
import com.swp391.carrental.policy.service.PolicyService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;

/**
 * Name: VehicleReturnDetailServlet
 * @Author: TamTTMHE190340
 * Date: 21/06/2026
 * Version: 1.0
 * Description: Controller for inspecting, processing, and confirming vehicle returns and defect checklists.
 */
@WebServlet(name = "VehicleReturnDetailServlet", urlPatterns = {"/returns/detail"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 15
)
public class VehicleReturnDetailServlet extends HttpServlet {

    private final ReturnService returnService = new ReturnService();
    private final HandoverDAO handoverDAO = new HandoverDAO();
    private final ReturnDAO returnDAO = new ReturnDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String vehicleIdStr = request.getParameter("vehicleId");
            if (vehicleIdStr == null || vehicleIdStr.trim().isEmpty()) {
                vehicleIdStr = request.getParameter("carId");
            }

            if (bookingIdStr != null && vehicleIdStr != null) {
                int bookingId = Integer.parseInt(bookingIdStr);
                int vehicleId = Integer.parseInt(vehicleIdStr);

                Booking booking = bookingDAO.findById(bookingId);
                Vehicle vehicle = vehicleDAO.findById(vehicleId);
                Vehicle car = vehicle;
                RentalContract contract = contractDAO.findByBookingId(bookingId);
                VehicleHandover handover = getHandoverWithFallback(bookingId, vehicleId, contract, vehicle);
                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                int distanceDriven = 0;
                if (returns == null) {
                    returns = new VehicleReturn();
                    returns.setBookingId(bookingId);
                    returns.setVehicleId(vehicleId);
                    if (contract != null) {
                        returns.setContractId(contract.getContractId());
                    }
                    if (handover != null && handover.getHandoverId() > 0) {
                        returns.setHandoverId(handover.getHandoverId());
                    }
                    returns.setExteriorCondition("");
                    returns.setInteriorCondition("");
                    returns.setMechanicalCondition("");
                    returns.setFuelLevel("");
                    returns.setNotes("");
                    returns.setPhotosUrl("");
                    returns.setLateHours(BigDecimal.ZERO);
                    returns.setExtraKmFee(BigDecimal.ZERO);
                    returns.setDamageFee(BigDecimal.ZERO);
                    returns.setCleaningFee(BigDecimal.ZERO);
                    returns.setLostItemFee(BigDecimal.ZERO);
                    returns.setTotalAdditionalFee(BigDecimal.ZERO);
                } else {
                    int mReturn = returns.getMileageAtReturn();
                    int mHandover = handover != null ? handover.getMileageAtHandover() : 0;
                    if (mReturn > 0) {
                        distanceDriven = Math.max(0, mReturn - mHandover);
                    }
                }

                request.setAttribute("booking", booking);
                request.setAttribute("vehicle", vehicle);
                request.setAttribute("car", vehicle);
                request.setAttribute("contract", contract);
                request.setAttribute("handover", handover);
                request.setAttribute("returns", returns);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("vehicleId", vehicleId);
<<<<<<< HEAD
=======
                request.setAttribute("carId", vehicleId);
                boolean needsMaintenance = returns != null && returns.getNotes() != null && returns.getNotes().contains("[CẦN BẢO DƯỠNG]");
                request.setAttribute("needsMaintenance", needsMaintenance);
>>>>>>> origin/TamDev
                request.setAttribute("distanceDriven", distanceDriven);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }

                User staff = null;
                if (returns != null && returns.getReceivedBy() > 0) {
                    staff = userDAO.findById(returns.getReceivedBy());
                }
                if (staff == null && handover != null && handover.getHandedBy() > 0) {
                    staff = userDAO.findById(handover.getHandedBy());
                }
                if (staff == null) {
                    User currentUser = (User) request.getSession().getAttribute("currentUser");
                    if (currentUser != null) {
                        staff = currentUser;
                    }
                }
                request.setAttribute("staff", staff);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải thông tin: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("confirm".equals(action) || "calculate".equals(action)) {
            int bookingId = 0;
            int vehicleId = 0;
            try {
<<<<<<< HEAD
                bookingId = Integer.parseInt(request.getParameter("bookingId"));
                vehicleId = Integer.parseInt(request.getParameter("vehicleId"));
=======
                String bIdStr = request.getParameter("bookingId");
                String vIdStr = request.getParameter("vehicleId");
                if (vIdStr == null || vIdStr.trim().isEmpty()) {
                    vIdStr = request.getParameter("carId");
                }
                bookingId = Integer.parseInt(bIdStr);
                vehicleId = Integer.parseInt(vIdStr);
>>>>>>> origin/TamDev

                // ===== VALIDATION =====
                if (!validateOdo(request, response, bookingId, vehicleId)) {
                    return;
                }

                if (!validateFuel(request, response, bookingId, vehicleId)) {
                    return;
                }

                if (!validateImages(request, response, bookingId, vehicleId)) {
                    return;
                }

                // ===== GET EXISTING HANDOVER =====
                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                if (returns == null) {
                    returns = new VehicleReturn();
                    returns.setBookingId(bookingId);
                    returns.setVehicleId(vehicleId);
<<<<<<< HEAD
                    
=======

>>>>>>> origin/TamDev
                    RentalContract contract = contractDAO.findByBookingId(bookingId);
                    if (contract != null) {
                        returns.setContractId(contract.getContractId());
                    }

                    VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
                    if (handover != null) {
                        returns.setHandoverId(handover.getHandoverId());
                    }

                    Booking booking = bookingDAO.findById(bookingId);
                    if (booking != null) {
                        returns.setReturnedBy(booking.getCustomerId());
                    }

                    HttpSession session = request.getSession();
                    User currentUser = (User) session.getAttribute("currentUser");
                    if (currentUser != null) {
                        returns.setReceivedBy(currentUser.getUserId());
                    }

                    returns.setReturnDate(java.time.LocalDateTime.now());
                    returns.setLateHours(BigDecimal.ZERO);
                    returns.setExtraKmFee(BigDecimal.ZERO);
                    returns.setDamageFee(BigDecimal.ZERO);
                    returns.setCleaningFee(BigDecimal.ZERO);
                    returns.setLostItemFee(BigDecimal.ZERO);
                    returns.setTotalAdditionalFee(BigDecimal.ZERO);
                }

                // ===== FORM DATA =====
                int distanceDriven = Integer.parseInt(request.getParameter("currentOdo"));
                RentalContract contract = contractDAO.findByBookingId(bookingId);
                Vehicle vehicle = vehicleDAO.findById(vehicleId);
                VehicleHandover handover = getHandoverWithFallback(bookingId, vehicleId, contract, vehicle);
                int mileageAtHandover = handover.getMileageAtHandover();
                int mileage = mileageAtHandover + distanceDriven;

                String fuelLevel = request.getParameter("fuel");
                if ("F".equals(fuelLevel)) {
                    fuelLevel = "FULL";
                } else if ("E".equals(fuelLevel)) {
                    fuelLevel = "EMPTY";
                }

                boolean needsMaintenance = "true".equalsIgnoreCase(request.getParameter("needsMaintenance"));
                request.setAttribute("needsMaintenance", needsMaintenance);

                String notes = request.getParameter("notes");
                if (notes == null || notes.isBlank()) {
                    notes = "Đã kiểm tra và nhận lại xe";
                }
                if (needsMaintenance) {
                    if (!notes.contains("[CẦN BẢO DƯỠNG]")) {
                        notes = "[CẦN BẢO DƯỠNG] " + notes;
                    }
                } else {
                    notes = notes.replace("[CẦN BẢO DƯỠNG]", "").trim();
                }

                String exterior = buildExteriorCondition(request);
                String interior = buildInteriorCondition(request);
                String mechanical = buildMechanicalCondition(request);

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
                User currentUser = (User) request.getSession().getAttribute("currentUser");
                if (currentUser != null) {
                    returns.setReceivedBy(currentUser.getUserId());
                }
                returns.setMileageAtReturn(mileage);
                returns.setFuelLevel(fuelLevel);

                returns.setPhotosUrl(finalPhotos);
                returns.setNotes(notes);

                returns.setExteriorCondition(exterior);
                returns.setInteriorCondition(interior);
                returns.setMechanicalCondition(mechanical);

                // Auto-calculate default return fees (late fee & extra km fee)
                Booking booking = bookingDAO.findById(bookingId);
                PolicyService policyService = new PolicyService();

                BigDecimal lateHours = returns.getLateHours();
                BigDecimal lateFee = BigDecimal.ZERO;
                BigDecimal feePerHour = new BigDecimal(policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));

                if (lateHours == null || (returns.getReturnId() == 0 && lateHours.compareTo(BigDecimal.ZERO) == 0)) {
                    if (booking != null && booking.getEndDate() != null) {
                        java.time.LocalDateTime expectedReturn = booking.getEndDate();
                        java.time.LocalDateTime actualReturn = returns.getReturnDate() != null ? returns.getReturnDate() : java.time.LocalDateTime.now();
                        if (actualReturn.isAfter(expectedReturn)) {
                            long hours = java.time.Duration.between(expectedReturn, actualReturn).toHours();
                            if (hours < 1) {
                                hours = 1;
                            }
                            lateHours = BigDecimal.valueOf(hours);
                        } else {
                            lateHours = BigDecimal.ZERO;
                        }
                    } else {
                        lateHours = BigDecimal.ZERO;
                    }
                }
                lateFee = feePerHour.multiply(lateHours);

                BigDecimal extraKmFee = returns.getExtraKmFee();
                BigDecimal extraKmCost = BigDecimal.ZERO;
                BigDecimal rate = new BigDecimal(policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));

                if (booking != null) {
                    long days = 1;
                    if (booking.getStartDate() != null && booking.getEndDate() != null) {
                        days = java.time.temporal.ChronoUnit.DAYS.between(booking.getStartDate().toLocalDate(), booking.getEndDate().toLocalDate());
                        if (days < 1) {
                            days = 1;
                        }
                    }
                    FeeCalculator feeCalc = new FeeCalculator();
                    int kmLimit = (booking.getKmLimit() != null && booking.getKmLimit() > 0) ? booking.getKmLimit() : feeCalc.calculateKmLimit(booking.getRentalMode(), booking.getPricingPackage(), days);
                    int actualExtraKm = Math.max(0, distanceDriven - kmLimit);
                    int estimatedKm = booking.getEstimatedKm() != null ? booking.getEstimatedKm() : 0;
                    int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);
                    int additionalExtraKm = Math.max(0, actualExtraKm - alreadyPaidExtraKm);

                    if (extraKmFee == null || extraKmFee.compareTo(BigDecimal.ZERO) == 0 || "calculate".equals(action)) {
                        extraKmFee = BigDecimal.valueOf(additionalExtraKm);
                    }
                    extraKmCost = rate.multiply(extraKmFee);
                }

                BigDecimal damageFee = returns.getDamageFee() != null ? returns.getDamageFee() : BigDecimal.ZERO;
                BigDecimal cleaningFee = returns.getCleaningFee() != null ? returns.getCleaningFee() : BigDecimal.ZERO;
                BigDecimal lostItemFee = returns.getLostItemFee() != null ? returns.getLostItemFee() : BigDecimal.ZERO;
                BigDecimal totalAdditionalFee = lateFee.add(extraKmCost).add(damageFee).add(cleaningFee).add(lostItemFee);

                returns.setLateHours(lateHours);
                returns.setExtraKmFee(extraKmFee);
                returns.setTotalAdditionalFee(totalAdditionalFee);

                if ("calculate".equals(action)) {
                    if (returns.getReturnId() == 0) {
                        int returnIdVal = returnDAO.insert(returns);
                        returns.setReturnId(returnIdVal);
                    } else {
                        returnDAO.update(returns);
                    }
                    response.sendRedirect(request.getContextPath() + "/additional-fees?bookingId=" + bookingId + "&vehicleId=" + vehicleId);
                    return;
                } else {
                    // For "confirm" action, update details and finalize return
                    if (returns.getReturnId() == 0) {
                        int returnIdVal = returnDAO.insert(returns);
                        returns.setReturnId(returnIdVal);
                    } else {
                        returnDAO.update(returns);
                    }
                    returnService.returnVehicle(returns);
                    notifyVehicleReturned(returns, bookingId);
                    response.sendRedirect(request.getContextPath() + "/returns");
                }
            } catch (Exception e) {
                e.printStackTrace();
                loadDetailData(request, bookingId, vehicleId);
                request.setAttribute("error", "Lỗi bàn giao: " + e.getMessage());
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
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
        if (request.getParameter("chkExteriorScratch") != null) {
            list.add("Thân xe có vết trầy xước mới");
        }
        if (request.getParameter("chkWindshield") != null) {
            list.add("Kính chắn gió bị nứt hoặc vỡ");
        }
        if (request.getParameter("chkTires") != null) {
            list.add("Lốp xe mòn hoặc hư hỏng");
        }
        if (request.getParameter("chkExteriorMirror") != null) {
            list.add("Gương chiếu hậu hư hỏng");
        }
        if (request.getParameter("chkExteriorLights") != null) {
            list.add("Đèn ngoại thất hư hỏng");
        }
        return list.isEmpty() ? "Ngoại thất bình thường" : String.join(", ", list);
    }

    private String buildInteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        if (request.getParameter("chkCleanliness") != null) {
            list.add("Nội thất bẩn hoặc nhiều bụi");
        }
        if (request.getParameter("chkOdor") != null) {
            list.add("Có mùi hôi trong xe");
        }
        if (request.getParameter("chkMatsAccessories") != null) {
            list.add("Thiếu thảm hoặc phụ kiện");
        }
        if (request.getParameter("chkInteriorSeats") != null) {
            list.add("Ghế ngồi bị rách hoặc hư hỏng");
        }
        if (request.getParameter("chkInteriorDashboard") != null) {
            list.add("Taplo / bảng điều khiển hư hỏng");
        }
        return list.isEmpty() ? "Nội thất sạch sẽ/bình thường" : String.join(", ", list);
    }

    private String buildMechanicalCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        if (request.getParameter("chkEngine") != null) {
            list.add("Động cơ khởi động bất thường");
        }
        if (request.getParameter("chkDashboardLights") != null) {
            list.add("Có đèn cảnh báo trên bảng điều khiển");
        }
        if (request.getParameter("chkEngineNoise") != null) {
            list.add("Có tiếng ồn hoặc rung bất thường");
        }
        if (request.getParameter("chkEngineFluidLeak") != null) {
            list.add("Rò rỉ dầu hoặc nước làm mát");
        }
        return list.isEmpty() ? "Máy móc động cơ bình thường" : String.join(", ", list);
    }

    private boolean validateOdo(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException, SQLException {
        String currentOdo = request.getParameter("currentOdo");

        if (currentOdo == null || currentOdo.isBlank()) {
            loadDetailData(request, bookingId, vehicleId);
            request.setAttribute("currentOdoError", "Vui lòng không để trống thông tin");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
            return false;
        }

        try {
            int distanceDriven = Integer.parseInt(currentOdo);
            if (distanceDriven < 0) {
                loadDetailData(request, bookingId, vehicleId);
                request.setAttribute("currentOdoError", "Quãng đường đã đi không được nhỏ hơn 0");
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
                return false;
            }
        } catch (NumberFormatException e) {
            loadDetailData(request, bookingId, vehicleId);
            request.setAttribute("currentOdoError", "Vui lòng nhập số km hợp lệ");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private boolean validateFuel(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException {
        String fuelLevel = request.getParameter("fuel");

        if (fuelLevel == null || fuelLevel.isBlank()) {
            loadDetailData(request, bookingId, vehicleId);
            request.setAttribute("currentFuelLevelError", "Vui lòng chọn mức nhiên liệu");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private boolean validateImages(HttpServletRequest request, HttpServletResponse response, int bookingId, int vehicleId)
            throws ServletException, IOException {
        long MAX_SIZE = 10 * 1024 * 1024;

        for (Part part : request.getParts()) {
            if (!"evidencePhotos".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }

            if (part.getSize() > MAX_SIZE) {
                loadDetailData(request, bookingId, vehicleId);

                request.setAttribute(
                        "uploadPhotosError",
                        "Ảnh " + part.getSubmittedFileName() + " vượt quá dung lượng 10MB."
                );

                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
                return false;
            }
        }
        return true;
    }

<<<<<<< HEAD
    private void loadDetailData(HttpServletRequest request, int bookingId, int vehicleId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            Vehicle car = vehicleDAO.findById(vehicleId);
=======
    private VehicleHandover getHandoverWithFallback(int bookingId, int vehicleId, RentalContract contract, Vehicle vehicle) throws SQLException {
        VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
        if (handover == null) {
            handover = new VehicleHandover();
            handover.setBookingId(bookingId);
            handover.setVehicleId(vehicleId);
            if (contract != null) {
                handover.setContractId(contract.getContractId());
            }
            handover.setMileageAtHandover(vehicle != null ? vehicle.getMileage() : 0);
            handover.setFuelLevel("FULL");
        } else {
            if (handover.getMileageAtHandover() <= 0 && vehicle != null) {
                handover.setMileageAtHandover(vehicle.getMileage());
            }
            if (handover.getFuelLevel() == null || handover.getFuelLevel().isBlank()) {
                handover.setFuelLevel("FULL");
            }
        }
        return handover;
    }

    private void loadDetailData(HttpServletRequest request, int bookingId, int vehicleId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            Vehicle vehicle = vehicleDAO.findById(vehicleId);
>>>>>>> origin/TamDev
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            VehicleHandover handover = getHandoverWithFallback(bookingId, vehicleId, contract, vehicle);
            VehicleReturn returns = returnDAO.findByBookingId(bookingId);

            int distanceDriven = 0;
            if (returns == null) {
                returns = new VehicleReturn();
                returns.setBookingId(bookingId);
                returns.setVehicleId(vehicleId);
                if (contract != null) {
                    returns.setContractId(contract.getContractId());
                }
                if (handover != null && handover.getHandoverId() > 0) {
                    returns.setHandoverId(handover.getHandoverId());
                }
                returns.setExteriorCondition("");
                returns.setInteriorCondition("");
                returns.setMechanicalCondition("");
                returns.setFuelLevel("");
                returns.setNotes("");
                returns.setPhotosUrl("");
                returns.setLateHours(BigDecimal.ZERO);
                returns.setExtraKmFee(BigDecimal.ZERO);
                returns.setDamageFee(BigDecimal.ZERO);
                returns.setCleaningFee(BigDecimal.ZERO);
                returns.setLostItemFee(BigDecimal.ZERO);
                returns.setTotalAdditionalFee(BigDecimal.ZERO);
            } else {
                int mileageAtHandover = handover.getMileageAtHandover();
                distanceDriven = returns.getMileageAtReturn() - mileageAtHandover;
                if (distanceDriven < 0) {
                    distanceDriven = 0;
                }
            }

            request.setAttribute("booking", booking);
            request.setAttribute("vehicle", vehicle);
            request.setAttribute("contract", contract);
            request.setAttribute("handover", handover);
            request.setAttribute("returns", returns);
            request.setAttribute("bookingId", bookingId);
            request.setAttribute("vehicleId", vehicleId);
<<<<<<< HEAD
            
=======

>>>>>>> origin/TamDev
            String inputOdo = request.getParameter("currentOdo");
            if (inputOdo != null) {
                request.setAttribute("distanceDriven", inputOdo);
            } else {
                request.setAttribute("distanceDriven", distanceDriven);
            }

            if (booking != null) {
                User customer = userDAO.findById(booking.getCustomerId());
                request.setAttribute("customer", customer);
            }

            request.setAttribute("currentOdo", request.getParameter("currentOdo"));
            request.setAttribute("fuel", request.getParameter("fuel"));

            request.setAttribute("notes", request.getParameter("notes"));
            request.setAttribute("chkExteriorScratch", request.getParameter("chkExteriorScratch") != null);
            request.setAttribute("chkWindshield", request.getParameter("chkWindshield") != null);
            request.setAttribute("chkTires", request.getParameter("chkTires") != null);
            request.setAttribute("chkExteriorMirror", request.getParameter("chkExteriorMirror") != null);
            request.setAttribute("chkExteriorLights", request.getParameter("chkExteriorLights") != null);

            request.setAttribute("chkCleanliness", request.getParameter("chkCleanliness") != null);
            request.setAttribute("chkOdor", request.getParameter("chkOdor") != null);
            request.setAttribute("chkMatsAccessories", request.getParameter("chkMatsAccessories") != null);
            request.setAttribute("chkInteriorSeats", request.getParameter("chkInteriorSeats") != null);
            request.setAttribute("chkInteriorDashboard", request.getParameter("chkInteriorDashboard") != null);

            request.setAttribute("chkEngine", request.getParameter("chkEngine") != null);
            request.setAttribute("chkDashboardLights", request.getParameter("chkDashboardLights") != null);
            request.setAttribute("chkEngineNoise", request.getParameter("chkEngineNoise") != null);
            request.setAttribute("chkEngineFluidLeak", request.getParameter("chkEngineFluidLeak") != null);
        } catch (SQLException ex) {
            Logger.getLogger(VehicleHandoverDetailServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void notifyVehicleReturned(VehicleReturn returns, int bookingId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                return;
            }

            String title = "Xe đã được nhận lại";
            String message = "Xe cho booking #" + bookingId + " đã được nhận lại thành công.";
            if (returns.getTotalAdditionalFee() != null && returns.getTotalAdditionalFee().compareTo(java.math.BigDecimal.ZERO) > 0) {
                message += " Tổng phí phát sinh: " + returns.getTotalAdditionalFee() + " VNĐ.";
            }

            Notification notif = new Notification(booking.getCustomerId(), title, message, "RETURN");
            notif.setReferenceType("RETURN");
            notif.setReferenceId(returns.getReturnId());
            notificationService.createNotification(notif);
        } catch (Exception e) {
            System.err.println("Failed to send vehicle-returned notification: " + e.getMessage());
        }
    }
}
