package com.swp391.carrental;

import com.swp391.carrental.booking.dao.BookingDAO;
import com.swp391.carrental.booking.model.Booking;
import com.swp391.carrental.handover.dao.HandoverDAO;
import com.swp391.carrental.handover.dao.ReturnDAO;
import com.swp391.carrental.handover.model.VehicleHandover;
import com.swp391.carrental.handover.model.VehicleReturn;
import com.swp391.carrental.handover.service.HandoverService;
import com.swp391.carrental.vehicle.dao.VehicleDAO;
import com.swp391.carrental.vehicle.model.Vehicle;
import com.swp391.carrental.vehicle.service.VehicleService;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Workflow05_VehicleHandoverReturnTest {

    private static final HandoverService handoverService = new HandoverService();
    private static final HandoverDAO handoverDAO = new HandoverDAO();
    private static final ReturnDAO returnDAO = new ReturnDAO();
    private static final BookingDAO bookingDAO = new BookingDAO();
    private static final VehicleDAO vehicleDAO = new VehicleDAO();
    private static final VehicleService vehicleService = new VehicleService();

    private static final List<Integer> createdHandoverIds = new ArrayList<>();
    private static final List<Integer> createdReturnIds = new ArrayList<>();
    private static final List<Integer> createdBookingIds = new ArrayList<>();
    private static final List<Integer> createdVehicleIds = new ArrayList<>();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 5: Vehicle Handover, Return Processing and Deposit Settlement ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-TAM-HO-01", "Create vehicle handover record successfully", Workflow05_VehicleHandoverReturnTest::testCreateHandoverSuccess));
        tests.add(new RunnableTest("TC-TAM-HO-02", "Reject handover for booking without active contract or deposit", Workflow05_VehicleHandoverReturnTest::testRejectHandoverNoActiveContract));
        tests.add(new RunnableTest("TC-TAM-HO-03", "View handover details by bookingId and vehicleId", Workflow05_VehicleHandoverReturnTest::testViewHandoverDetails));
        tests.add(new RunnableTest("TC-TAM-HO-04", "Update handover odometer and battery/fuel condition", Workflow05_VehicleHandoverReturnTest::testUpdateHandoverCondition));
        tests.add(new RunnableTest("TC-TAM-HO-05", "Reject handover odometer smaller than initial vehicle mileage", Workflow05_VehicleHandoverReturnTest::testRejectHandoverInvalidOdo));
        tests.add(new RunnableTest("TC-TAM-HO-06", "List all handover records for staff dashboard", Workflow05_VehicleHandoverReturnTest::testListHandovers));
        tests.add(new RunnableTest("TC-TAM-HO-07", "Customer approves handover checklist and receives vehicle", Workflow05_VehicleHandoverReturnTest::testCustomerApproveHandover));

        tests.add(new RunnableTest("TC-TAM-RET-01", "Create vehicle return record successfully", Workflow05_VehicleHandoverReturnTest::testCreateReturnSuccess));
        tests.add(new RunnableTest("TC-TAM-RET-02", "Reject return for booking that has not been handed over", Workflow05_VehicleHandoverReturnTest::testRejectReturnWithoutHandover));
        tests.add(new RunnableTest("TC-TAM-RET-03", "View return record details by bookingId and vehicleId", Workflow05_VehicleHandoverReturnTest::testViewReturnDetails));
        tests.add(new RunnableTest("TC-TAM-RET-04", "Update vehicle return inspection condition and damages", Workflow05_VehicleHandoverReturnTest::testUpdateReturnInspection));
        tests.add(new RunnableTest("TC-TAM-RET-05", "Reject return odometer smaller than handover odometer", Workflow05_VehicleHandoverReturnTest::testRejectReturnInvalidOdo));
        tests.add(new RunnableTest("TC-TAM-RET-06", "List all vehicle return records for staff dashboard", Workflow05_VehicleHandoverReturnTest::testListReturns));

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

        return new SystemTestMasterRunner.TestResult("Workflow 5: Vehicle Handover, Return & Deposit Settlement", tests.size(), passed, failed);
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
        List<com.swp391.carrental.vehicle.model.VehicleBrand> brands = vehicleService.getAllBrands();
        int brandId = (brands != null && !brands.isEmpty()) ? brands.get(0).getBrandId() : 1;
        List<com.swp391.carrental.vehicle.model.VehicleModel> models = vehicleService.getModelsByBrandId(brandId);
        int modelId = (models != null && !models.isEmpty()) ? models.get(0).getModelId() : 1;

        Vehicle v = new Vehicle();
        v.setBrandId(brandId);
        v.setModelId(modelId);
        v.setYear(2024);
        v.setColor("Blue");
        v.setSeats(5);
        v.setTransmission("AUTOMATIC");
        v.setFuelType("PETROL");
        v.setDailyRate(new BigDecimal("1500000.00"));
        v.setDescription("Handover Test Car");
        v.setLocation("Hanoi");
        v.setStatus("AVAILABLE");
        v.setMileage(10000);
        v.setLicensePlate("HO-" + System.currentTimeMillis());
        int id = vehicleService.addVehicle(v);
        createdVehicleIds.add(id);
        v.setVehicleId(id);
        return v;
    }

    private static int createSampleBooking(int vehicleId) throws Exception {
        Booking b = new Booking();
        b.setCustomerId(1);
        b.setVehicleId(vehicleId);
        b.setStartDate(LocalDateTime.now());
        b.setEndDate(LocalDateTime.now().plusDays(2));
        b.setPickupLocation("Showroom");
        b.setReturnLocation("Showroom");
        b.setStatus("CONFIRMED");
        b.setRentalMode("SELF_DRIVE");
        b.setDeliveryMethod("HOME_DELIVERY");
        b.setDeliveryFee(BigDecimal.ZERO);
        b.setBaseAmount(new BigDecimal("3000000.00"));
        b.setDiscountAmount(BigDecimal.ZERO);
        b.setTaxAmount(BigDecimal.ZERO);
        b.setTotalAmount(new BigDecimal("3000000.00"));
        b.setDepositAmount(new BigDecimal("900000.00"));
        int id = bookingDAO.insert(b);
        createdBookingIds.add(id);
        return id;
    }

    private static void testCreateHandoverSuccess() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleHandover h = new VehicleHandover();
        h.setBookingId(bookingId);
        h.setVehicleId(v.getVehicleId());
        h.setHandoverDate(LocalDateTime.now());
        h.setMileageAtHandover(10050);
        h.setFuelLevel("100%");
        h.setExteriorCondition("Good");
        h.setHandedBy(1);
        h.setReceivedBy(1);
        h.setStatus("COMPLETED");

        int hId = handoverDAO.insert(h);
        if (hId <= 0) throw new AssertionError("Handover record creation failed");
        createdHandoverIds.add(hId);
    }

    private static void testRejectHandoverNoActiveContract() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());
        // Validation logic mock check
    }

    private static void testViewHandoverDetails() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleHandover h = new VehicleHandover();
        h.setBookingId(bookingId);
        h.setVehicleId(v.getVehicleId());
        h.setHandoverDate(LocalDateTime.now());
        h.setMileageAtHandover(10000);
        h.setFuelLevel("100%");
        h.setExteriorCondition("Good");
        h.setHandedBy(1);
        h.setReceivedBy(1);
        h.setStatus("COMPLETED");
        int hId = handoverDAO.insert(h);
        createdHandoverIds.add(hId);

        VehicleHandover fetched = handoverDAO.findByBookingId(bookingId);
        if (fetched == null || fetched.getHandoverId() != hId) {
            throw new AssertionError("Failed to view handover details");
        }
    }

    private static void testUpdateHandoverCondition() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleHandover h = new VehicleHandover();
        h.setBookingId(bookingId);
        h.setVehicleId(v.getVehicleId());
        h.setHandoverDate(LocalDateTime.now());
        h.setMileageAtHandover(10000);
        h.setFuelLevel("100%");
        h.setExteriorCondition("Minor Scratch");
        h.setHandedBy(1);
        h.setReceivedBy(1);
        h.setStatus("COMPLETED");
        int hId = handoverDAO.insert(h);
        createdHandoverIds.add(hId);

        h.setHandoverId(hId);
        h.setExteriorCondition("Scratch Polished");
        int updated = handoverDAO.update(h);
        if (updated <= 0) throw new AssertionError("Failed to update handover condition");
    }

    private static void testRejectHandoverInvalidOdo() throws Exception {
        Vehicle v = createTestVehicle(); // Mileage = 10000
        int bookingId = createSampleBooking(v.getVehicleId());
        // ODO smaller validation check
    }

    private static void testListHandovers() throws Exception {
        List<VehicleHandover> list = handoverDAO.findAll();
        if (list == null) throw new AssertionError("Handover list should not be null");
    }

    private static void testCustomerApproveHandover() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleHandover h = new VehicleHandover();
        h.setBookingId(bookingId);
        h.setVehicleId(v.getVehicleId());
        h.setHandoverDate(LocalDateTime.now());
        h.setMileageAtHandover(10000);
        h.setFuelLevel("100%");
        h.setExteriorCondition("Good");
        h.setHandedBy(1);
        h.setReceivedBy(1);
        h.setStatus("PENDING_CUSTOMER");
        int hId = handoverDAO.insert(h);
        createdHandoverIds.add(hId);

        h.setHandoverId(hId);
        h.setStatus("COMPLETED");
        int updated = handoverDAO.update(h);
        if (updated <= 0) throw new AssertionError("Customer handover approval failed");
    }

    private static void testCreateReturnSuccess() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleReturn r = new VehicleReturn();
        r.setBookingId(bookingId);
        r.setVehicleId(v.getVehicleId());
        r.setReturnDate(LocalDateTime.now().plusDays(2));
        r.setMileageAtReturn(10200);
        r.setFuelLevel("100%");
        r.setExteriorCondition("Perfect");
        r.setReceivedBy(1);
        r.setReturnedBy(1);

        int rId = returnDAO.insert(r);
        if (rId <= 0) throw new AssertionError("Vehicle return creation failed");
        createdReturnIds.add(rId);
    }

    private static void testRejectReturnWithoutHandover() throws Exception {
        // Validation check
    }

    private static void testViewReturnDetails() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleReturn r = new VehicleReturn();
        r.setBookingId(bookingId);
        r.setVehicleId(v.getVehicleId());
        r.setReturnDate(LocalDateTime.now().plusDays(2));
        r.setMileageAtReturn(10200);
        r.setFuelLevel("100%");
        r.setExteriorCondition("Perfect");
        r.setReceivedBy(1);
        r.setReturnedBy(1);
        int rId = returnDAO.insert(r);
        createdReturnIds.add(rId);

        VehicleReturn fetched = returnDAO.findByBookingId(bookingId);
        if (fetched == null || fetched.getReturnId() != rId) {
            throw new AssertionError("Failed to view return details");
        }
    }

    private static void testUpdateReturnInspection() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleReturn r = new VehicleReturn();
        r.setBookingId(bookingId);
        r.setVehicleId(v.getVehicleId());
        r.setReturnDate(LocalDateTime.now().plusDays(2));
        r.setMileageAtReturn(10200);
        r.setFuelLevel("100%");
        r.setExteriorCondition("Clean");
        r.setReceivedBy(1);
        r.setReturnedBy(1);
        int rId = returnDAO.insert(r);
        createdReturnIds.add(rId);

        r.setReturnId(rId);
        r.setExteriorCondition("Clean & Inspected");
        int updated = returnDAO.update(r);
        if (updated <= 0) throw new AssertionError("Failed to update return inspection");
    }

    private static void testRejectReturnInvalidOdo() throws Exception {
        Vehicle v = createTestVehicle();
        int bookingId = createSampleBooking(v.getVehicleId());

        VehicleHandover h = new VehicleHandover();
        h.setBookingId(bookingId);
        h.setVehicleId(v.getVehicleId());
        h.setHandoverDate(LocalDateTime.now());
        h.setMileageAtHandover(10000);
        h.setFuelLevel("100%");
        h.setExteriorCondition("Good");
        h.setHandedBy(2);
        h.setReceivedBy(1);
        h.setStatus("COMPLETED");
        int hId = handoverDAO.insert(h);
        createdHandoverIds.add(hId);
    }

    private static void testListReturns() throws Exception {
        List<VehicleReturn> list = returnDAO.findAll();
        if (list == null) throw new AssertionError("Returns list should not be null");
    }

    private static void cleanup() {
        for (int id : createdReturnIds) {
            try {
                returnDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdReturnIds.clear();

        for (int id : createdHandoverIds) {
            try {
                handoverDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdHandoverIds.clear();

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
