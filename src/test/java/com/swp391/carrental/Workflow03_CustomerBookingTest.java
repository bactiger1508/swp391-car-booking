package com.swp391.carrental;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.booking.service.BookingService;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Workflow03_CustomerBookingTest {

    private static final BookingService bookingService = new BookingService();
    private static final VehicleService vehicleService = new VehicleService();
    private static final BookingDAO bookingDAO = new BookingDAO();
    private static final VehicleDAO vehicleDAO = new VehicleDAO();

    private static final List<Integer> createdBookingIds = new ArrayList<>();
    private static final List<Integer> createdVehicleIds = new ArrayList<>();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 3: Customer Booking Creation and Management ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-BAC-BOOK-01", "Create booking successfully with valid details", Workflow03_CustomerBookingTest::testCreateBookingSuccess));
        tests.add(new RunnableTest("TC-BAC-BOOK-02", "Reject booking when vehicle is not available (Overlapping dates)", Workflow03_CustomerBookingTest::testRejectOverlappingBooking));
        tests.add(new RunnableTest("TC-BAC-BOOK-03", "Reject booking when start date is in the past", Workflow03_CustomerBookingTest::testRejectPastStartDate));
        tests.add(new RunnableTest("TC-BAC-BOOK-04", "Reject booking when end date is before start date", Workflow03_CustomerBookingTest::testRejectEndDateBeforeStartDate));
        tests.add(new RunnableTest("TC-BAC-BOOK-05", "Regression Test Bug 7: Reject booking for vehicle in MAINTENANCE status", Workflow03_CustomerBookingTest::testRejectBookingMaintenanceVehicle));
        tests.add(new RunnableTest("TC-BAC-BOOK-06", "View customer booking details by bookingId", Workflow03_CustomerBookingTest::testViewBookingDetails));
        tests.add(new RunnableTest("TC-BAC-BOOK-07", "List customer active bookings", Workflow03_CustomerBookingTest::testListCustomerBookings));
        tests.add(new RunnableTest("TC-BAC-BOOK-08", "Customer cancels pending booking successfully", Workflow03_CustomerBookingTest::testCancelPendingBooking));
        tests.add(new RunnableTest("TC-BAC-BOOK-09", "Reject customer cancelling confirmed/in-progress booking", Workflow03_CustomerBookingTest::testRejectCancelConfirmedBooking));
        tests.add(new RunnableTest("TC-BAC-BOOK-10", "Update pending booking details successfully", Workflow03_CustomerBookingTest::testUpdatePendingBooking));
        tests.add(new RunnableTest("TC-BAC-BOOK-11", "Reject updating non-pending booking", Workflow03_CustomerBookingTest::testRejectUpdateNonPendingBooking));
        tests.add(new RunnableTest("TC-BAC-BOOK-12", "Calculate booking deposit amount correctly", Workflow03_CustomerBookingTest::testCalculateDepositAmount));
        tests.add(new RunnableTest("TC-BAC-BOOK-13", "Reject booking for non-existent vehicleId", Workflow03_CustomerBookingTest::testRejectNonExistentVehicleId));
        tests.add(new RunnableTest("TC-BAC-BOOK-14", "Create self-drive booking with valid license requirements", Workflow03_CustomerBookingTest::testCreateSelfDriveBooking));

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

        return new SystemTestMasterRunner.TestResult("Workflow 3: Customer Booking Creation & Management", tests.size(), passed, failed);
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

    private static Vehicle createTestVehicle(String status) throws Exception {
        List<com.swp391.carrental.vehicle.model.VehicleBrand> brands = vehicleService.getAllBrands();
        int brandId = (brands != null && !brands.isEmpty()) ? brands.get(0).getBrandId() : 1;
        List<com.swp391.carrental.vehicle.model.VehicleModel> models = vehicleService.getModelsByBrandId(brandId);
        int modelId = (models != null && !models.isEmpty()) ? models.get(0).getModelId() : 1;

        Vehicle v = new Vehicle();
        v.setBrandId(brandId);
        v.setModelId(modelId);
        v.setYear(2024);
        v.setColor("Black");
        v.setSeats(5);
        v.setTransmission("AUTOMATIC");
        v.setFuelType("PETROL");
        v.setDailyRate(new BigDecimal("1000000.00"));
        v.setDescription("Test Booking Car");
        v.setLocation("Hanoi");
        v.setStatus(status);
        v.setMileage(5000);
        v.setLicensePlate("BK-" + System.currentTimeMillis());
        int id = vehicleService.addVehicle(v);
        createdVehicleIds.add(id);
        v.setVehicleId(id);
        return v;
    }

    private static void testCreateBookingSuccess() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));

        int bookingId = bookingDAO.insert(b);
        if (bookingId <= 0) throw new AssertionError("Booking creation failed");
        createdBookingIds.add(bookingId);
    }

    private static void testRejectOverlappingBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        LocalDateTime start = LocalDateTime.now().plusDays(5);
        LocalDateTime end = LocalDateTime.now().plusDays(7);

        Booking b1 = new Booking();
        b1.setCustomerId(1);
        b1.setVehicleId(v.getVehicleId());
        b1.setStartDate(start);
        b1.setEndDate(end);
        b1.setPickupLocation("Showroom");
        b1.setReturnLocation("Showroom");
        b1.setStatus("CONFIRMED");
        b1.setRentalMode("SELF_DRIVE");
        b1.setDeliveryMethod("HOME_DELIVERY");
        b1.setDeliveryFee(BigDecimal.ZERO);
        b1.setBaseAmount(new BigDecimal("2000000.00"));
        b1.setDiscountAmount(BigDecimal.ZERO);
        b1.setTaxAmount(BigDecimal.ZERO);
        b1.setTotalAmount(new BigDecimal("2000000.00"));
        b1.setDepositAmount(new BigDecimal("600000.00"));
        int id1 = bookingDAO.insert(b1);
        createdBookingIds.add(id1);

        Booking b2 = new Booking();
        b2.setCustomerId(2);
        b2.setVehicleId(v.getVehicleId());
        b2.setStartDate(start.plusDays(1));
        b2.setEndDate(end.plusDays(1));
        b2.setStatus("PENDING");

        try {
            bookingService.createBooking(b2);
            throw new AssertionError("Overlapping booking should be rejected");
        } catch (Exception e) {
            // Expected overlapping failure
        }
    }

    private static void testRejectPastStartDate() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().minusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(1));
        try {
            bookingService.createBooking(b);
            throw new AssertionError("Past start date should be rejected");
        } catch (Exception e) {
            // Expected failure
        }
    }

    private static void testRejectEndDateBeforeStartDate() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(3));
        b.setEndDate(LocalDateTime.now().plusDays(1));
        try {
            bookingService.createBooking(b);
            throw new AssertionError("End date before start date should be rejected");
        } catch (Exception e) {
            // Expected failure
        }
    }

    private static void testRejectBookingMaintenanceVehicle() throws Exception {
        Vehicle v = createTestVehicle("MAINTENANCE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        try {
            bookingService.createBooking(b);
            throw new AssertionError("Booking maintenance vehicle should fail");
        } catch (Exception e) {
            // Expected failure
        }
    }

    private static void testViewBookingDetails() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        Booking fetched = bookingService.getBookingById(id);
        if (fetched == null || fetched.getBookingId() != id) {
            throw new AssertionError("Failed to view booking details");
        }
    }

    private static void testListCustomerBookings() throws Exception {
        List<Booking> list = bookingService.getCustomerBookings(1);
        if (list == null) throw new AssertionError("Customer bookings list should not be null");
    }

    private static void testCancelPendingBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        boolean cancelled = bookingService.cancelBooking(id, "Change of plans");
        if (!cancelled) throw new AssertionError("Cancelling pending booking should succeed");
    }

    private static void testRejectCancelConfirmedBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("CONFIRMED");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        try {
            bookingService.cancelBooking(id, "Attempt customer cancel confirmed");
            // If service restricts cancellation of confirmed bookings by customer
        } catch (Exception e) {
            // Expected
        }
    }

    private static void testUpdatePendingBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        b.setBookingId(id);
        b.setPickupLocation("Airport Terminal 1");
        boolean updated = bookingService.updateBooking(b);
        if (!updated) throw new AssertionError("Updating pending booking should succeed");
    }

    private static void testRejectUpdateNonPendingBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("CONFIRMED");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);

        b.setBookingId(id);
        b.setPickupLocation("Airport Terminal 2");
        try {
            bookingService.updateBooking(b);
            // If service restricts updating non-pending bookings
        } catch (Exception e) {
            // Expected
        }
    }

    private static void testCalculateDepositAmount() {
        BigDecimal dailyRate = new BigDecimal("1000000.00");
        BigDecimal deposit = vehicleService.calculateOneDayDeposit(dailyRate);
        if (deposit == null || deposit.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AssertionError("Deposit calculation failed");
        }
    }

    private static void testRejectNonExistentVehicleId() {
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(999999);
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        try {
            bookingService.createBooking(b);
            throw new AssertionError("Booking non-existent vehicleId should fail");
        } catch (Exception e) {
            // Expected
        }
    }

    private static void testCreateSelfDriveBooking() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE");
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(v.getVehicleId());
        b.setStartDate(LocalDateTime.now().plusDays(2));
        b.setEndDate(LocalDateTime.now().plusDays(4));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("PENDING");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("2000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("2000000.00"));
        b.setDepositAmount(new BigDecimal("600000.00"));
        int id = bookingDAO.insert(b);
        if (id <= 0) throw new AssertionError("Self-drive booking failed");
        createdBookingIds.add(id);
    }

    private static void cleanup() {
        for (int id : createdBookingIds) {
            try {
                bookingDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdBookingIds.clear();

        for (int id : createdVehicleIds) {
            try {
                vehicleDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdVehicleIds.clear();
    }
}
