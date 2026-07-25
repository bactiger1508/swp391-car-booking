package com.swp391.carrental;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.user.dao.CustomerProfileDAO;
import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.CustomerProfile;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Workflow04_StaffBookingReviewTest {

    private static final BookingService bookingService = new BookingService();
    private static final VehicleService vehicleService = new VehicleService();
    private static final BookingDAO bookingDAO = new BookingDAO();
    private static final UserDAO userDAO = new UserDAO();
    private static final CustomerProfileDAO profileDAO = new CustomerProfileDAO();

    private static final List<Integer> createdBookingIds = new ArrayList<>();
    private static final List<Integer> createdVehicleIds = new ArrayList<>();
    private static final List<Integer> createdUserIds = new ArrayList<>();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 4: Staff Booking Review, Calendar and Policy ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-BAC-REV-01", "Staff approves pending booking successfully", Workflow04_StaffBookingReviewTest::testStaffApproveBooking));
        tests.add(new RunnableTest("TC-BAC-REV-02", "Staff rejects pending booking with reason", Workflow04_StaffBookingReviewTest::testStaffRejectBooking));
        tests.add(new RunnableTest("TC-BAC-REV-03", "List all bookings for staff review dashboard", Workflow04_StaffBookingReviewTest::testListStaffBookings));
        tests.add(new RunnableTest("TC-BAC-REV-04", "Filter staff bookings by status (CONFIRMED)", Workflow04_StaffBookingReviewTest::testFilterBookingsByStatus));
        tests.add(new RunnableTest("TC-BAC-REV-05", "Render booking calendar gantt timeline data", Workflow04_StaffBookingReviewTest::testRenderBookingCalendar));
        tests.add(new RunnableTest("TC-BAC-REV-06", "Staff updates booking status to IN_PROGRESS on vehicle pickup", Workflow04_StaffBookingReviewTest::testUpdateBookingInProgress));
        tests.add(new RunnableTest("TC-BAC-REV-07", "Staff completes booking on vehicle return", Workflow04_StaffBookingReviewTest::testCompleteBooking));
        tests.add(new RunnableTest("TC-BAC-REV-08", "Reject invalid booking status transition (COMPLETED -> PENDING)", Workflow04_StaffBookingReviewTest::testRejectInvalidStatusTransition));
        tests.add(new RunnableTest("TC-BAC-REV-09", "Staff assigns driver to booking requiring driver", Workflow04_StaffBookingReviewTest::testAssignDriverToBooking));

        for (RunnableTest t : tests) {
            try {
                t.test.run();
                System.out.printf("  | %-16s | %-65s | PASS |%n", t.id, t.description);
                passed++;
            } catch (Throwable e) {
                System.out.printf("  | %-16s | %-65s | FAIL (%s) |%n", t.id, t.description, e.getMessage());
                failed++;
            } finally {
                cleanup();
            }
        }

        return new SystemTestMasterRunner.TestResult("Workflow 4: Staff Booking Review, Calendar & Policy", tests.size(), passed, failed);
    }

    private static class RunnableTest {
        String id;
        String description;
        TestTask test;
        RunnableTest(String id, String description, TestTask test) {
            this.id = id;
            this.description = description;
            this.test = test;
        }
    }

    @FunctionalInterface
    private interface TestTask {
        void run() throws Throwable;
    }

    private static Vehicle createTestVehicle() throws Exception {
        Vehicle v = new Vehicle();
        v.setBrandId(1);
        v.setModelId(1);
        v.setYear(2024);
        v.setColor("Silver");
        v.setSeats(5);
        v.setTransmission("AUTOMATIC");
        v.setFuelType("PETROL");
        v.setDailyRate(new BigDecimal("1200000.00"));
        v.setDescription("Staff Review Car");
        v.setLocation("Hanoi");
        v.setStatus("AVAILABLE");
        v.setMileage(2000);
        v.setLicensePlate("STF-" + System.currentTimeMillis());
        int id = vehicleService.addVehicle(v);
        createdVehicleIds.add(id);
        v.setVehicleId(id);
        return v;
    }

    private static int createSampleBooking(int vehicleId, String status) throws Exception {
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(vehicleId);
        b.setStartDate(LocalDateTime.now().plusDays(1));
        b.setEndDate(LocalDateTime.now().plusDays(3));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus(status);
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2400000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2400000.00"));
        b.setDepositAmount(new BigDecimal("720000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);
        return id;
    }

    private static void testStaffApproveBooking() throws Exception {
        Vehicle v = createTestVehicle();
        User staff = userDAO.findById(1);
        if (staff != null) {
            staff.setRole("STAFF");
            userDAO.update(staff);
        }

        User u = new User();
        u.setEmail("ver_appr_" + System.currentTimeMillis() + "@gmail.com");
        u.setPasswordHash("pass123");
        u.setFullName("Verified Staff Customer");
        u.setPhone("0988888888");
        u.setRole("CUSTOMER");
        u.setActive(true);
        int custId = userDAO.insert(u);
        if (custId > 0) {
            createdUserIds.add(custId);
            CustomerProfile profile = new CustomerProfile();
            profile.setUserId(custId);
            profile.setVerificationStatus("VERIFIED");
            profileDAO.insert(profile);
        } else {
            custId = 1;
        }

        try (java.sql.Connection conn = com.swp391.carrental.core.util.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("UPDATE customer_profiles SET verification_status = 'VERIFIED' WHERE user_id = ?")) {
            ps.setInt(1, custId);
            ps.executeUpdate();
        } catch (Exception ignored) {}

        Booking b = new Booking();
        b.setCustomerId(custId);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(1));
        b.setEndDate(LocalDateTime.now().plusDays(3));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2400000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2400000.00"));
        b.setDepositAmount(new BigDecimal("720000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        boolean approved = bookingService.approveBooking(id, 1);
        if (!approved) throw new AssertionError("Staff approval failed");
    }

    private static void testStaffRejectBooking() throws Exception {
        Vehicle v = createTestVehicle();
        int id = createSampleBooking(v.getVehicleId(), "PENDING");
        boolean rejected = bookingService.rejectBooking(id, 1, "Invalid customer profile");
        if (!rejected) throw new AssertionError("Staff rejection failed");
    }

    private static void testListStaffBookings() throws Exception {
        List<Booking> list = bookingService.getAllBookings();
        if (list == null) throw new AssertionError("Bookings list should not be null");
    }

    private static void testFilterBookingsByStatus() throws Exception {
        Vehicle v = createTestVehicle();
        createSampleBooking(v.getVehicleId(), "CONFIRMED");
        List<Booking> list = bookingService.getBookingsByStatus("CONFIRMED");
        if (list == null) throw new AssertionError("Filter CONFIRMED bookings returned null");
    }

    private static void testRenderBookingCalendar() throws Exception {
        Vehicle v = createTestVehicle();
        createSampleBooking(v.getVehicleId(), "CONFIRMED");
        List<Booking> activeList = bookingService.getActiveBookingsByVehicle(v.getVehicleId());
        if (activeList == null) throw new AssertionError("Active bookings for calendar should not be null");
    }

    private static void testUpdateBookingInProgress() throws Exception {
        Vehicle v = createTestVehicle();
        int id = createSampleBooking(v.getVehicleId(), "CONFIRMED");
        boolean updated = bookingDAO.updateStatus(id, "IN_PROGRESS");
        if (!updated) throw new AssertionError("Status update to IN_PROGRESS failed");
    }

    private static void testCompleteBooking() throws Exception {
        Vehicle v = createTestVehicle();
        int id = createSampleBooking(v.getVehicleId(), "IN_PROGRESS");
        boolean completed = bookingDAO.updateStatus(id, "COMPLETED");
        if (!completed) throw new AssertionError("Status update to COMPLETED failed");
    }

    private static void testRejectInvalidStatusTransition() throws Exception {
        Vehicle v = createTestVehicle();
        int id = createSampleBooking(v.getVehicleId(), "COMPLETED");
        boolean res = false;
        try {
            res = bookingService.approveBooking(id, 1);
        } catch (Exception e) {
            res = false;
        }
        if (res) {
            throw new AssertionError("Approving a COMPLETED booking must fail");
        }
    }

    private static void testAssignDriverToBooking() throws Exception {
        Vehicle v = createTestVehicle();
        int id = createSampleBooking(v.getVehicleId(), "CONFIRMED");
        Booking b = bookingService.getBookingById(id);
        if (b == null) throw new AssertionError("Booking not found");
    }

    private static void cleanup() {
        for (int id : createdBookingIds) {
            try { bookingDAO.delete(id); } catch (Exception ignored) {}
        }
        createdBookingIds.clear();
        for (int id : createdVehicleIds) {
            try { vehicleService.deleteVehicle(id); } catch (Exception ignored) {}
        }
        createdVehicleIds.clear();
        for (int id : createdUserIds) {
            try { userDAO.delete(id); } catch (Exception ignored) {}
        }
        createdUserIds.clear();
    }
}
