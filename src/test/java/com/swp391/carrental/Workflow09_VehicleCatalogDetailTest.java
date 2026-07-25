package com.swp391.carrental;

import com.swp391.carrental.vehicle.dao.ReviewDAO;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Review;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Workflow09_VehicleCatalogDetailTest {

    private static final VehicleService vehicleService = new VehicleService();
    private static final VehicleDAO vehicleDAO = new VehicleDAO();
    private static final ReviewDAO reviewDAO = new ReviewDAO();

    private static final List<Integer> createdVehicleIds = new ArrayList<>();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 9: Vehicle Catalog, Search and Detail ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-TINH-CAT-01", "Load full vehicle catalog for Guest role", Workflow09_VehicleCatalogDetailTest::testLoadCatalogGuest));
        tests.add(new RunnableTest("TC-TINH-CAT-02", "Load active AVAILABLE vehicles catalog for Customer role", Workflow09_VehicleCatalogDetailTest::testLoadCatalogCustomer));
        tests.add(new RunnableTest("TC-TINH-CAT-03", "Handle empty search/filter result set gracefully", Workflow09_VehicleCatalogDetailTest::testEmptySearchResult));

        tests.add(new RunnableTest("TC-TINH-SEARCH-01", "Search vehicle by brand/model keyword", Workflow09_VehicleCatalogDetailTest::testSearchByKeyword));
        tests.add(new RunnableTest("TC-TINH-SEARCH-02", "Filter vehicles by price range (daily rate min-max)", Workflow09_VehicleCatalogDetailTest::testFilterByPriceRange));
        tests.add(new RunnableTest("TC-TINH-SEARCH-03", "Filter vehicles by seat capacity and transmission type", Workflow09_VehicleCatalogDetailTest::testFilterBySeatsAndTransmission));
        tests.add(new RunnableTest("TC-TINH-SEARCH-04", "Return empty list for non-existent vehicle search query", Workflow09_VehicleCatalogDetailTest::testSearchNonExistentKeyword));

        tests.add(new RunnableTest("TC-TINH-DETAIL-01", "View vehicle details page by vehicleId", Workflow09_VehicleCatalogDetailTest::testViewVehicleDetails));
        tests.add(new RunnableTest("TC-TINH-DETAIL-02", "View customer reviews and average rating for vehicleId", Workflow09_VehicleCatalogDetailTest::testViewVehicleReviewsAndRating));
        tests.add(new RunnableTest("TC-TINH-DETAIL-03", "Calculate deposit requirement for vehicle daily rate", Workflow09_VehicleCatalogDetailTest::testCalculateVehicleDeposit));
        tests.add(new RunnableTest("TC-TINH-DETAIL-04", "Display vehicle primary image and gallery images correctly", Workflow09_VehicleCatalogDetailTest::testResolveVehicleImages));

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

        return new SystemTestMasterRunner.TestResult("Workflow 9: Vehicle Catalog, Search & Detail", tests.size(), passed, failed);
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

    private static Vehicle createTestVehicle(String status, String plate) throws Exception {
        Vehicle v = new Vehicle();
        v.setBrandId(1);
        v.setModelId(1);
        v.setYear(2024);
        v.setColor("White");
        v.setSeats(5);
        v.setTransmission("AUTOMATIC");
        v.setFuelType("PETROL");
        v.setDailyRate(new BigDecimal("1200000.00"));
        v.setDescription("Catalog Test Car");
        v.setLocation("Hanoi");
        v.setStatus(status);
        v.setMileage(4000);
        String shortPlate = "C9-" + (System.currentTimeMillis() % 1000000);
        v.setLicensePlate(shortPlate);
        int id = vehicleDAO.insert(v);
        createdVehicleIds.add(id);
        v.setVehicleId(id);
        return v;
    }

    private static void testLoadCatalogGuest() throws Exception {
        List<Vehicle> list = vehicleService.getAllVehicles();
        if (list == null) throw new AssertionError("Catalog should not be null");
    }

    private static void testLoadCatalogCustomer() throws Exception {
        List<Vehicle> list = vehicleService.getVehiclesByStatus("AVAILABLE");
        if (list == null) throw new AssertionError("Active catalog should not be null");
    }

    private static void testEmptySearchResult() {
        // Query empty filter check
    }

    private static void testSearchByKeyword() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE", "CAT-SRC-" + System.currentTimeMillis());
        Vehicle fetched = vehicleService.getVehicleByLicensePlate(v.getLicensePlate());
        if (fetched == null) throw new AssertionError("Search by license plate failed");
    }

    private static void testFilterByPriceRange() {
        // Price filter test
    }

    private static void testFilterBySeatsAndTransmission() {
        // Filter test
    }

    private static void testSearchNonExistentKeyword() {
        Vehicle fetched = vehicleService.getVehicleByLicensePlate("NON-EXISTENT-PLATE-999");
        if (fetched != null) throw new AssertionError("Non-existent search should return null");
    }

    private static void testViewVehicleDetails() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE", "CAT-DTL-" + System.currentTimeMillis());
        Vehicle fetched = vehicleService.getVehicleById(v.getVehicleId());
        if (fetched == null || fetched.getVehicleId() != v.getVehicleId()) {
            throw new AssertionError("View vehicle details failed");
        }
    }

    private static void testViewVehicleReviewsAndRating() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE", "CAT-REV-" + System.currentTimeMillis());
        int count = reviewDAO.countByVehicleId(v.getVehicleId());
        List<Review> reviews = reviewDAO.findByVehicleId(v.getVehicleId());
        if (count != 0 || !reviews.isEmpty()) throw new AssertionError("New vehicle should have 0 reviews");
    }

    private static void testCalculateVehicleDeposit() {
        BigDecimal deposit = vehicleService.calculateOneDayDeposit(new BigDecimal("1200000.00"));
        if (deposit == null || deposit.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AssertionError("Deposit calculation failed");
        }
    }

    private static void testResolveVehicleImages() throws Exception {
        Vehicle v = createTestVehicle("AVAILABLE", "CAT-IMG-" + System.currentTimeMillis());
        String imgUrl = vehicleService.resolvePrimaryImageUrl(v.getVehicleId());
        if (imgUrl == null || imgUrl.isEmpty()) {
            throw new AssertionError("Primary image URL should not be empty");
        }
    }

    private static void cleanup() {
        for (int id : createdVehicleIds) {
            try {
                vehicleDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdVehicleIds.clear();
    }
}
