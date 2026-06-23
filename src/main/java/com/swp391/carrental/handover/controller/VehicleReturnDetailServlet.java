package com.swp391.carrental.handover.controller;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.contract.dao.ContractDAO;
import com.swp391.carrental.contract.model.RentalContract;
import com.swp391.carrental.handover.dao.*;
import com.swp391.carrental.handover.model.*;
import com.swp391.carrental.handover.service.ReturnService;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.CarDAO;
import com.swp391.carrental.vehicle.model.Car;
 
import java.math.BigDecimal;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

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
    private final CarDAO carDAO = new CarDAO();
    private final ContractDAO contractDAO = new ContractDAO();
    private final UserDAO userDAO = new UserDAO();

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
                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                int distanceDriven = 0;
                if (returns == null) {
                    returns = new VehicleReturn();
                    returns.setBookingId(bookingId);
                    returns.setCarId(carId);
                    if (contract != null) {
                        returns.setContractId(contract.getContractId());
                    }
                    if (handover != null) {
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
                    int mileageAtHandover = handover != null ? handover.getMileageAtHandover() : 0;
                    distanceDriven = returns.getMileageAtReturn() - mileageAtHandover;
                    if (distanceDriven < 0) distanceDriven = 0;
                }

                request.setAttribute("booking", booking);
                request.setAttribute("car", car);
                request.setAttribute("contract", contract);
                request.setAttribute("handover", handover);
                request.setAttribute("returns", returns);
                request.setAttribute("bookingId", bookingId);
                request.setAttribute("carId", carId);
                request.setAttribute("distanceDriven", distanceDriven);

                if (booking != null) {
                    User customer = userDAO.findById(booking.getCustomerId());
                    request.setAttribute("customer", customer);
                }
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
            int carId = 0;
            try {
                bookingId = Integer.parseInt(request.getParameter("bookingId"));
                carId = Integer.parseInt(request.getParameter("carId"));

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
                VehicleReturn returns = returnDAO.findByBookingId(bookingId);

                if (returns == null) {
                    returns = new VehicleReturn();
                    returns.setBookingId(bookingId);
                    returns.setCarId(carId);
                    
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
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
                int mileageAtHandover = handover != null ? handover.getMileageAtHandover() : 0;
                int mileage = mileageAtHandover + distanceDriven;

                String fuelLevel = request.getParameter("fuel");
                if ("F".equals(fuelLevel)) {
                    fuelLevel = "FULL";
                } else if ("E".equals(fuelLevel)) {
                    fuelLevel = "EMPTY";
                }

                String notes = request.getParameter("notes");
                if (notes == null || notes.isBlank()) {
                    notes = "Đã kiểm tra và nhận lại xe";
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
                returns.setMileageAtReturn(mileage);
                returns.setFuelLevel(fuelLevel);

                returns.setPhotosUrl(finalPhotos);
                returns.setNotes(notes);

                returns.setExteriorCondition(exterior);
                returns.setInteriorCondition(interior);
                returns.setMechanicalCondition(mechanical);

                // Auto-calculate default return fees (late fee & extra km fee) only during "calculate" step.
                // This prevents overwriting manual adjustments made in additional-fees page when confirming.
                if ("calculate".equals(action)) {
                    Booking booking = bookingDAO.findById(bookingId);
                    com.swp391.carrental.policy.service.PolicyService policyService = new com.swp391.carrental.policy.service.PolicyService();

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

                    BigDecimal extraKmFee = BigDecimal.ZERO;
                    BigDecimal extraKmCost = BigDecimal.ZERO;
                    if (booking != null) {
                        int kmLimit = booking.getKmLimit() != null ? booking.getKmLimit() : 0;
                        int actualExtraKm = Math.max(0, distanceDriven - kmLimit);
                        int estimatedKm = booking.getEstimatedKm() != null ? booking.getEstimatedKm() : 0;
                        int alreadyPaidExtraKm = Math.max(0, estimatedKm - kmLimit);
                        int additionalExtraKm = Math.max(0, actualExtraKm - alreadyPaidExtraKm);
                        extraKmFee = BigDecimal.valueOf(additionalExtraKm);
                        BigDecimal rate = new BigDecimal(policyService.getPolicyValue("EXTRA_KM_FEE", "4000"));
                        extraKmCost = rate.multiply(extraKmFee);
                    }

                    BigDecimal damageFee = returns.getDamageFee() != null ? returns.getDamageFee() : BigDecimal.ZERO;
                    BigDecimal cleaningFee = returns.getCleaningFee() != null ? returns.getCleaningFee() : BigDecimal.ZERO;
                    BigDecimal lostItemFee = returns.getLostItemFee() != null ? returns.getLostItemFee() : BigDecimal.ZERO;
                    BigDecimal totalAdditionalFee = lateFee.add(extraKmCost).add(damageFee).add(cleaningFee).add(lostItemFee);

                    returns.setLateHours(lateHours);
                    returns.setExtraKmFee(extraKmFee);
                    returns.setTotalAdditionalFee(totalAdditionalFee);

                    if (returns.getReturnId() == 0) {
                        int returnIdVal = returnDAO.insert(returns);
                        returns.setReturnId(returnIdVal);
                    } else {
                        returnDAO.update(returns);
                    }
                    response.sendRedirect(request.getContextPath() + "/additional-fees?bookingId=" + bookingId + "&carId=" + carId);
                    return;
                } else {
                    // For "confirm" action, update the check details and proceed to finalize without modifying fees
                    if (returns.getReturnId() == 0) {
                        int returnIdVal = returnDAO.insert(returns);
                        returns.setReturnId(returnIdVal);
                    } else {
                        returnDAO.update(returns);
                    }
                    returnService.returnVehicle(returns);
                    response.sendRedirect(request.getContextPath() + "/returns");
                }
            } catch (Exception e) {
                e.printStackTrace();
                loadDetailData(request, bookingId, carId);
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
        list.add(request.getParameter("chkExteriorScratch") != null ? "Không vết xước/lõm mới" : "Có vết xước/lõm");
        list.add(request.getParameter("chkExteriorBumper") != null ? "Cản trước và cản sau nguyên vẹn" : "Cản trước hoặc cản sau hư hỏng");
        list.add(request.getParameter("chkExteriorGlass") != null ? "Kính chắn gió và cửa kính không nứt vỡ" : "Kính chắn gió hoặc cửa kính bị nứt vỡ");
        list.add(request.getParameter("chkExteriorLights") != null ? "Đèn pha, đèn hậu hoạt động bình thường" : "Đèn pha hoặc đèn hậu không hoạt động");
        list.add(request.getParameter("chkExteriorMirror") != null ? "Gương chiếu hậu đầy đủ, không hư hỏng" : "Gương chiếu hậu bị thiếu hoặc hư hỏng");
        list.add(request.getParameter("chkExteriorTireWheel") != null ? "Lốp xe và mâm xe trong tình trạng tốt" : "Lốp xe hoặc mâm xe có hư hỏng");
        list.add(request.getParameter("chkExteriorLicensePlate") != null ? "Biển số xe đầy đủ và rõ ràng" : "Biển số xe thiếu hoặc không rõ ràng");
        return String.join(", ", list);
    }

    private String buildInteriorCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkInteriorSeats") != null ? "Ghế ngồi sạch sẽ, không rách hỏng" : "Ghế ngồi bị bẩn hoặc rách hỏng");
        list.add(request.getParameter("chkInteriorDashboard") != null ? "Taplo và bảng điều khiển hoạt động bình thường" : "Taplo hoặc bảng điều khiển có lỗi");
        list.add(request.getParameter("chkInteriorAirConditioner") != null ? "Điều hòa hoạt động tốt" : "Điều hòa hoạt động không bình thường");
        list.add(request.getParameter("chkInteriorAudioSystem") != null ? "Hệ thống âm thanh hoạt động bình thường" : "Hệ thống âm thanh gặp sự cố");
        list.add(request.getParameter("chkInteriorCleanliness") != null ? "Không có mùi lạ hoặc rác thải trong xe" : "Có mùi lạ hoặc rác thải trong xe");
        list.add(request.getParameter("chkInteriorAccessories") != null ? "Đầy đủ phụ kiện đi kèm" : "Thiếu phụ kiện đi kèm");
        return String.join(", ", list);
    }

    private String buildMechanicalCondition(HttpServletRequest request) {
        List<String> list = new ArrayList<>();
        list.add(request.getParameter("chkEngineStart") != null ? "Động cơ khởi động bình thường" : "Động cơ khởi động bất thường");
        list.add(request.getParameter("chkEngineWarningLight") != null ? "Không có đèn cảnh báo trên bảng đồng hồ" : "Có đèn cảnh báo trên bảng đồng hồ");
        list.add(request.getParameter("chkEngineFuelLevel") != null ? "Mức nhiên liệu đúng theo ghi nhận" : "Mức nhiên liệu không khớp ghi nhận");
        list.add(request.getParameter("chkEngineNoise") != null ? "Không phát hiện tiếng ồn bất thường" : "Phát hiện tiếng ồn bất thường");
        list.add(request.getParameter("chkEngineBrakeSystem") != null ? "Hệ thống phanh hoạt động bình thường" : "Hệ thống phanh có dấu hiệu bất thường");
        list.add(request.getParameter("chkEngineFluidLeak") != null ? "Không phát hiện rò rỉ dầu hoặc chất lỏng" : "Phát hiện rò rỉ dầu hoặc chất lỏng");
        return String.join(", ", list);
    }

    private boolean validateOdo(HttpServletRequest request, HttpServletResponse response, int bookingId, int carId)
            throws ServletException, IOException, SQLException {
        String currentOdo = request.getParameter("currentOdo");

        if (currentOdo == null || currentOdo.isBlank()) {
            loadDetailData(request, bookingId, carId);
            request.setAttribute("currentOdoError", "Vui lòng không để trống thông tin");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
            return false;
        }

        try {
            int distanceDriven = Integer.parseInt(currentOdo);
            if (distanceDriven < 0) {
                loadDetailData(request, bookingId, carId);
                request.setAttribute("currentOdoError", "Quãng đường đã đi không được nhỏ hơn 0");
                request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
                return false;
            }
        } catch (NumberFormatException e) {
            loadDetailData(request, bookingId, carId);
            request.setAttribute("currentOdoError", "Vui lòng nhập số km hợp lệ");
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
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
            request.getRequestDispatcher("/WEB-INF/views/handover/vehicle-return-detail.jsp").forward(request, response);
            return false;
        }
        return true;
    }

    private boolean validateImages(HttpServletRequest request, HttpServletResponse response, int bookingId, int carId)
            throws ServletException, IOException {
        long MAX_SIZE = 10 * 1024 * 1024;

        for (Part part : request.getParts()) {
            if (!"evidencePhotos".equals(part.getName()) || part.getSize() == 0) {
                continue;
            }

            if (part.getSize() > MAX_SIZE) {
                loadDetailData(request, bookingId, carId);

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

    private void loadDetailData(HttpServletRequest request, int bookingId, int carId) {
        try {
            Booking booking = bookingDAO.findById(bookingId);
            Car car = carDAO.findById(carId);
            RentalContract contract = contractDAO.findByBookingId(bookingId);
            VehicleReturn returns = returnDAO.findByBookingId(bookingId);

            int distanceDriven = 0;
            if (returns == null) {
                returns = new VehicleReturn();
                returns.setBookingId(bookingId);
                returns.setCarId(carId);
                if (contract != null) {
                    returns.setContractId(contract.getContractId());
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
                VehicleHandover handover = handoverDAO.findByBookingId(bookingId);
                int mileageAtHandover = handover != null ? handover.getMileageAtHandover() : 0;
                distanceDriven = returns.getMileageAtReturn() - mileageAtHandover;
                if (distanceDriven < 0) distanceDriven = 0;
            }

            request.setAttribute("booking", booking);
            request.setAttribute("car", car);
            request.setAttribute("contract", contract);
//            request.setAttribute("handover", handover);
            request.setAttribute("returns", returns);
            request.setAttribute("bookingId", bookingId);
            request.setAttribute("carId", carId);
            
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
            request.setAttribute("chkExteriorBumper", request.getParameter("chkExteriorBumper") != null);
            request.setAttribute("chkExteriorGlass", request.getParameter("chkExteriorGlass") != null);
            request.setAttribute("chkExteriorLights", request.getParameter("chkExteriorLights") != null);
            request.setAttribute("chkExteriorMirror", request.getParameter("chkExteriorMirror") != null);
            request.setAttribute("chkExteriorTireWheel", request.getParameter("chkExteriorTireWheel") != null);
            request.setAttribute("chkExteriorLicensePlate", request.getParameter("chkExteriorLicensePlate") != null);

            request.setAttribute("chkInteriorSeats", request.getParameter("chkInteriorSeats") != null);
            request.setAttribute("chkInteriorDashboard", request.getParameter("chkInteriorDashboard") != null);
            request.setAttribute("chkInteriorAirConditioner", request.getParameter("chkInteriorAirConditioner") != null);
            request.setAttribute("chkInteriorAudioSystem", request.getParameter("chkInteriorAudioSystem") != null);
            request.setAttribute("chkInteriorCleanliness", request.getParameter("chkInteriorCleanliness") != null);
            request.setAttribute("chkInteriorAccessories", request.getParameter("chkInteriorAccessories") != null);

            request.setAttribute("chkEngineStart", request.getParameter("chkEngineStart") != null);
            request.setAttribute("chkEngineWarningLight", request.getParameter("chkEngineWarningLight") != null);
            request.setAttribute("chkEngineFuelLevel", request.getParameter("chkEngineFuelLevel") != null);
            request.setAttribute("chkEngineNoise", request.getParameter("chkEngineNoise") != null);
            request.setAttribute("chkEngineBrakeSystem", request.getParameter("chkEngineBrakeSystem") != null);
            request.setAttribute("chkEngineFluidLeak", request.getParameter("chkEngineFluidLeak") != null);
        } catch (SQLException ex) {
            Logger.getLogger(VehicleHandoverDetailServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
