package com.swp391.carrental;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;

import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.vehicle.dao.MaintenanceDAO;
import com.swp391.carrental.vehicle.dao.ReviewDAO;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.dao.VehicleImageDAO;
import com.swp391.carrental.vehicle.model.MaintenanceSchedule;
import com.swp391.carrental.vehicle.model.Review;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.model.VehicleImage;
import com.swp391.carrental.vehicle.service.AvailabilityService;
import com.swp391.carrental.vehicle.service.VehicleService;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class VehicleModuleIntegrationTest {

    private static final VehicleDAO vehicleDAO = new VehicleDAO();
    private static final VehicleImageDAO vehicleImageDAO = new VehicleImageDAO();
    private static final MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    private static final ReviewDAO reviewDAO = new ReviewDAO();
    private static final BookingDAO bookingDAO = new BookingDAO();
    private static final VehicleService vehicleService = new VehicleService();
    private static final AvailabilityService availabilityService = new AvailabilityService();

    // Track test created entities for automatic cleanup
    private static final List<Integer> createdVehicleIds = new ArrayList<>();
    private static final List<Integer> createdBookingIds = new ArrayList<>();

    public static void main(String[] args) {
        System.out.println("=========================================================");
        System.out.println("  STARTING VEHICLE MODULE STRICT VEHICLE_ID TEST SUITE   ");
        System.out.println("=========================================================");

        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        // 1. Vehicle CRUD Flow
        tests.add(new RunnableTest("TC-VEH-01: Happy Path - Create & Retrieve Vehicle by vehicleId", VehicleModuleIntegrationTest::testCreateVehicleAndFetchByVehicleId));
        tests.add(new RunnableTest("TC-VEH-02: Happy Path - Update Vehicle by vehicleId", VehicleModuleIntegrationTest::testUpdateVehicleByVehicleId));
        tests.add(new RunnableTest("TC-VEH-03: Happy Path - Update Vehicle Status by vehicleId", VehicleModuleIntegrationTest::testUpdateVehicleStatus));
        tests.add(new RunnableTest("TC-VEH-04: Edge Case - Get Vehicle by Non-Existent vehicleId", VehicleModuleIntegrationTest::testGetVehicleByNonExistentVehicleId));
        tests.add(new RunnableTest("TC-VEH-05: Edge Case - Vehicle with Extreme Mileage & Year", VehicleModuleIntegrationTest::testVehicleWithExtremeYearAndMileage));
        tests.add(new RunnableTest("TC-VEH-06: Negative Case - Duplicate License Plate", VehicleModuleIntegrationTest::testCreateVehicleWithDuplicateLicensePlate));
        tests.add(new RunnableTest("TC-VEH-07: Negative Case - Delete Vehicle Referenced by Active Entity (FK Safety)", VehicleModuleIntegrationTest::testDeleteVehicleReferencedByActiveEntity));

        // 2. Vehicle Images Flow
        tests.add(new RunnableTest("TC-IMG-01: Happy Path - Add & Retrieve Images by vehicleId", VehicleModuleIntegrationTest::testAddAndRetrieveVehicleImagesByVehicleId));
        tests.add(new RunnableTest("TC-IMG-02: Happy Path - Set Primary Image by vehicleId", VehicleModuleIntegrationTest::testSetPrimaryImageByVehicleId));
        tests.add(new RunnableTest("TC-IMG-03: Edge Case - Get Images for Vehicle with No Images", VehicleModuleIntegrationTest::testGetVehicleImagesForVehicleWithNoImages));
        tests.add(new RunnableTest("TC-IMG-04: Negative Case - Set Primary Image for Non-Existent vehicleId", VehicleModuleIntegrationTest::testSetPrimaryImageForNonExistentVehicleId));

        // 3. Maintenance Flow
        tests.add(new RunnableTest("TC-MNT-01: Happy Path - Add & Retrieve Maintenance by vehicleId", VehicleModuleIntegrationTest::testAddAndRetrieveMaintenanceByVehicleId));
        tests.add(new RunnableTest("TC-MNT-02: Edge Case - Get Maintenance for Vehicle with No History", VehicleModuleIntegrationTest::testGetMaintenanceForVehicleWithNoHistory));

        // 4. Review Flow
        tests.add(new RunnableTest("TC-REV-01: Happy Path - Retrieve and Count Reviews by vehicleId", VehicleModuleIntegrationTest::testRetrieveAndCountReviewsByVehicleId));
        tests.add(new RunnableTest("TC-REV-02: Edge Case - Count Reviews for Vehicle with Zero Reviews", VehicleModuleIntegrationTest::testCountReviewsForVehicleWithNoReviews));

        // 5. Availability Check Flow
        tests.add(new RunnableTest("TC-AVL-01: Happy Path - Check Vehicle Availability when Free", VehicleModuleIntegrationTest::testIsVehicleAvailableForRangeWhenFree));
        tests.add(new RunnableTest("TC-AVL-02: Negative Case - Check Vehicle Availability when Booked", VehicleModuleIntegrationTest::testIsVehicleAvailableForRangeWhenBooked));

        for (RunnableTest t : tests) {
            try {
                t.test.run();
                System.out.printf("| %-12s | %-65s | PASS |%n", t.id, t.description);
                passed++;
            } catch (Throwable e) {
                System.out.printf("| %-12s | %-65s | FAIL (%s) |%n", t.id, t.description, e.getMessage());
                failed++;
            } finally {
                cleanupTestData();
            }
        }

        System.out.println("=========================================================");
        System.out.println("  TEST SUITE RESULTS: Total: " + (passed + failed) + " | Passed: " + passed + " | Failed: " + failed);
        System.out.println("=========================================================");

        if (failed > 0) {
            System.exit(1);
        }
    }

    // Helper class for running tests
    private static class RunnableTest {
        String id;
        String description;
        TestTask test;
        RunnableTest(String name, TestTask test) {
            String[] parts = name.split(":", 2);
            this.id = parts[0].trim();
            this.description = parts.length > 1 ? parts[1].trim() : "";
            this.test = test;
        }
    }

    @FunctionalInterface
    private interface TestTask {
        void run() throws Throwable;
    }

    // --- TEST IMPLEMENTATIONS ---

    private static void testCreateVehicleAndFetchByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-001");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        if (vehicleId <= 0) throw new AssertionError("Vehicle ID must be > 0");

        Vehicle fetched = vehicleService.getVehicleById(vehicleId);
        if (fetched == null) throw new AssertionError("Fetched vehicle should not be null");
        if (fetched.getVehicleId() != vehicleId) throw new AssertionError("Vehicle ID mismatch");
        if (!"TEST-001".equals(fetched.getLicensePlate())) throw new AssertionError("License plate mismatch");
    }

    private static void testUpdateVehicleByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-002");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        v.setVehicleId(vehicleId);
        v.setColor("Red Sapphire");
        v.setDailyRate(new BigDecimal("1500000.00"));

        boolean updated = vehicleService.updateVehicle(v);
        if (!updated) throw new AssertionError("Update vehicle should return true");

        Vehicle fetched = vehicleService.getVehicleById(vehicleId);
        if (!"Red Sapphire".equals(fetched.getColor())) throw new AssertionError("Color not updated");
        if (fetched.getDailyRate().compareTo(new BigDecimal("1500000.00")) != 0) throw new AssertionError("Daily rate not updated");
    }

    private static void testUpdateVehicleStatus() throws Exception {
        Vehicle v = createSampleVehicle("TEST-003");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        boolean updated = vehicleService.updateVehicleStatus(vehicleId, "MAINTENANCE");
        if (!updated) throw new AssertionError("Update status should succeed");

        Vehicle fetched = vehicleService.getVehicleById(vehicleId);
        if (!"MAINTENANCE".equals(fetched.getStatus())) throw new AssertionError("Status should be MAINTENANCE");
    }

    private static void testGetVehicleByNonExistentVehicleId() {
        Vehicle fetched = vehicleService.getVehicleById(999999);
        if (fetched != null) throw new AssertionError("Non-existent vehicle ID should return null");
    }

    private static void testVehicleWithExtremeYearAndMileage() throws Exception {
        Vehicle v = createSampleVehicle("TEST-004");
        v.setYear(2026);
        v.setMileage(500000);
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        Vehicle fetched = vehicleService.getVehicleById(vehicleId);
        if (fetched.getYear() != 2026 || fetched.getMileage() != 500000) {
            throw new AssertionError("Extreme year/mileage values failed to persist");
        }
    }

    private static void testCreateVehicleWithDuplicateLicensePlate() throws Exception {
        Vehicle v1 = createSampleVehicle("TEST-DUP");
        int id1 = vehicleService.addVehicle(v1);
        createdVehicleIds.add(id1);

        Vehicle v2 = createSampleVehicle("TEST-DUP");
        try {
            vehicleService.addVehicle(v2);
            throw new AssertionError("Adding duplicate license plate should throw Exception");
        } catch (Exception e) {
            // Expected behavior
        }
    }

    private static void testDeleteVehicleReferencedByActiveEntity() throws Exception {
        Vehicle v = createSampleVehicle("TEST-005");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        // Add dummy booking referencing this vehicle
        Booking b = new Booking();
        b.setCustomerId(1); // Default customer ID
        b.setVehicleId(vehicleId);
        b.setStartDate(LocalDateTime.now().plusDays(1));
        b.setEndDate(LocalDateTime.now().plusDays(3));
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
        b.setDepositAmount(new BigDecimal("500000.00"));
        int bookingId = bookingDAO.insert(b);
        createdBookingIds.add(bookingId);

        try {
            vehicleService.deleteVehicle(vehicleId);
            throw new AssertionError("Deleting vehicle with active booking reference should fail due to FK constraint");
        } catch (Exception e) {
            if (!e.getMessage().contains("Không thể xóa xe") && !e.getMessage().contains("FK")) {
                throw new AssertionError("Unexpected error message: " + e.getMessage());
            }
        }
    }

    private static void testAddAndRetrieveVehicleImagesByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-006");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        VehicleImage img = new VehicleImage();
        img.setVehicleId(vehicleId);
        img.setImageUrl("/assets/images/vehicles/test_img.jpg");
        img.setCaption("Side View");
        img.setPrimary(false);

        int imgId = vehicleService.addVehicleImage(img);
        if (imgId <= 0) throw new AssertionError("Image ID should be > 0");

        List<VehicleImage> images = vehicleService.getVehicleImages(vehicleId);
        if (images.size() != 1) throw new AssertionError("Expected 1 image for vehicleId");
        if (!"/assets/images/vehicles/test_img.jpg".equals(images.get(0).getImageUrl())) {
            throw new AssertionError("Image URL mismatch");
        }
    }

    private static void testSetPrimaryImageByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-007");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        VehicleImage img = new VehicleImage();
        img.setVehicleId(vehicleId);
        img.setImageUrl("/assets/images/vehicles/test_primary.jpg");
        img.setPrimary(false);
        int imgId = vehicleService.addVehicleImage(img);

        boolean success = vehicleService.setPrimaryImage(vehicleId, imgId);
        if (!success) throw new AssertionError("Set primary image should succeed");

        String primaryUrl = vehicleService.resolvePrimaryImageUrl(vehicleId);
        if (!primaryUrl.contains("test_primary.jpg")) {
            throw new AssertionError("Resolved primary URL is incorrect: " + primaryUrl);
        }
    }

    private static void testGetVehicleImagesForVehicleWithNoImages() throws Exception {
        Vehicle v = createSampleVehicle("TEST-008");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        List<VehicleImage> images = vehicleService.getVehicleImages(vehicleId);
        if (images == null || !images.isEmpty()) {
            throw new AssertionError("Images list should be empty for new vehicle");
        }
    }

    private static void testSetPrimaryImageForNonExistentVehicleId() {
        boolean success = vehicleService.setPrimaryImage(999999, 999999);
        if (success) throw new AssertionError("Setting primary image for invalid vehicleId/imageId should return false");
    }

    private static void testAddAndRetrieveMaintenanceByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-009");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        MaintenanceSchedule ms = new MaintenanceSchedule();
        ms.setVehicleId(vehicleId);
        ms.setMaintenanceType("OIL_CHANGE");
        ms.setScheduledDate(java.time.LocalDate.now().plusDays(5));
        ms.setNotes("Regular 10k oil change");
        ms.setStatus("SCHEDULED");

        int mId = vehicleService.addMaintenanceSchedule(ms);
        if (mId <= 0) throw new AssertionError("Maintenance ID should be > 0");

        List<MaintenanceSchedule> list = vehicleService.getMaintenanceByVehicleId(vehicleId);
        if (list.size() != 1) throw new AssertionError("Expected 1 maintenance schedule");
        if (!"OIL_CHANGE".equals(list.get(0).getMaintenanceType())) throw new AssertionError("Maintenance type mismatch");
    }

    private static void testGetMaintenanceForVehicleWithNoHistory() throws Exception {
        Vehicle v = createSampleVehicle("TEST-010");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        List<MaintenanceSchedule> list = vehicleService.getMaintenanceByVehicleId(vehicleId);
        if (list == null || !list.isEmpty()) {
            throw new AssertionError("Maintenance list should be empty");
        }
    }

    private static void testRetrieveAndCountReviewsByVehicleId() throws Exception {
        Vehicle v = createSampleVehicle("TEST-011");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        int count = reviewDAO.countByVehicleId(vehicleId);
        List<Review> list = reviewDAO.findByVehicleId(vehicleId);

        if (count != 0 || !list.isEmpty()) {
            throw new AssertionError("New vehicle should have 0 reviews");
        }
    }

    private static void testCountReviewsForVehicleWithNoReviews() throws Exception {
        int count = reviewDAO.countByVehicleId(999999);
        if (count != 0) throw new AssertionError("Non-existent vehicle should have 0 reviews");
    }

    private static void testIsVehicleAvailableForRangeWhenFree() throws Exception {
        Vehicle v = createSampleVehicle("TEST-012");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        LocalDateTime start = LocalDateTime.now().plusDays(10);
        LocalDateTime end = LocalDateTime.now().plusDays(12);

        boolean available = availabilityService.isVehicleAvailableForRange(vehicleId, start, end);
        if (!available) throw new AssertionError("Vehicle should be available when no bookings exist");
    }

    private static void testIsVehicleAvailableForRangeWhenBooked() throws Exception {
        Vehicle v = createSampleVehicle("TEST-013");
        int vehicleId = vehicleService.addVehicle(v);
        createdVehicleIds.add(vehicleId);

        LocalDateTime start = LocalDateTime.now().plusDays(10);
        LocalDateTime end = LocalDateTime.now().plusDays(12);

        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(vehicleId);
        b.setStartDate(start);
        b.setEndDate(end);
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
        b.setDepositAmount(new BigDecimal("500000.00"));
        int bookingId = bookingDAO.insert(b);
        createdBookingIds.add(bookingId);

        boolean available = availabilityService.isVehicleAvailableForRange(vehicleId, start.plusHours(2), end.minusHours(2));
        if (available) throw new AssertionError("Vehicle should NOT be available during overlapping booking");
    }

    // --- HELPER & CLEANUP METHODS ---

    private static Vehicle createSampleVehicle(String plate) {
        Vehicle v = new Vehicle();
        v.setBrandId(1);
        v.setModelId(1);
        v.setYear(2024);
        v.setColor("White");
        v.setSeats(5);
        v.setTransmission("AUTOMATIC");
        v.setFuelType("PETROL");
        v.setDailyRate(new BigDecimal("1000000.00"));
        v.setDescription("Integration Test Vehicle");
        v.setLocation("Hanoi");
        v.setStatus("AVAILABLE");
        v.setMileage(1000);
        v.setLicensePlate(plate);
        return v;
    }

    private static void cleanupTestData() {
        for (int bookingId : createdBookingIds) {
            try {
                bookingDAO.delete(bookingId);
            } catch (Exception ignored) {}
        }
        createdBookingIds.clear();

        for (int vehicleId : createdVehicleIds) {
            try {
                vehicleImageDAO.deleteByVehicleId(vehicleId);
                maintenanceDAO.deleteByVehicleId(vehicleId);
                vehicleDAO.delete(vehicleId);
            } catch (Exception ignored) {}
        }
        createdVehicleIds.clear();
    }
}
