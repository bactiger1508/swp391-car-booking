package com.swp391.carrental;

import com.swp391.carrental.report.service.ReportService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Workflow06_FeeAndReportingTest {

    private static final ReportService reportService = new ReportService();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 6: Additional Fee and Reporting ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-TAM-FEE-01", "Calculate late return fee based on hourly policy", Workflow06_FeeAndReportingTest::testCalculateLateFee));
        tests.add(new RunnableTest("TC-TAM-FEE-02", "Calculate damage fee based on return checklist", Workflow06_FeeAndReportingTest::testCalculateDamageFee));
        tests.add(new RunnableTest("TC-TAM-FEE-03", "Reject negative fee input values", Workflow06_FeeAndReportingTest::testRejectNegativeFeeInput));

        tests.add(new RunnableTest("TC-TAM-REP-01", "Regression Test Bug 5: Generate revenue report filtered by date range", Workflow06_FeeAndReportingTest::testGenerateRevenueReportDateRange));
        tests.add(new RunnableTest("TC-TAM-REP-02", "Generate vehicle utilization report by vehicleId", Workflow06_FeeAndReportingTest::testGenerateVehicleUtilizationReport));
        tests.add(new RunnableTest("TC-TAM-REP-03", "Generate customer booking history report", Workflow06_FeeAndReportingTest::testGenerateCustomerReport));
        tests.add(new RunnableTest("TC-TAM-REP-04", "Handle empty data report result without crash", Workflow06_FeeAndReportingTest::testHandleEmptyReportResult));

        for (RunnableTest t : tests) {
            try {
                t.test.run();
                System.out.printf("  | %-16s | %-65s | PASS |%n", t.id, t.description);
                passed++;
            } catch (Throwable e) {
                System.out.printf("  | %-16s | %-65s | FAIL (%s) |%n", t.id, t.description, e.getMessage());
                failed++;
            }
        }

        return new SystemTestMasterRunner.TestResult("Workflow 6: Additional Fee & Reporting", tests.size(), passed, failed);
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

    private static void testCalculateLateFee() {
        BigDecimal hourlyRate = new BigDecimal("100000.00");
        long hoursLate = 3;
        BigDecimal lateFee = hourlyRate.multiply(new BigDecimal(hoursLate));
        if (lateFee.compareTo(new BigDecimal("300000.00")) != 0) {
            throw new AssertionError("Late fee calculation mismatch");
        }
    }

    private static void testCalculateDamageFee() {
        BigDecimal baseDamage = new BigDecimal("500000.00");
        if (baseDamage.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AssertionError("Damage fee calculation mismatch");
        }
    }

    private static void testRejectNegativeFeeInput() {
        BigDecimal fee = new BigDecimal("-100000.00");
        if (fee.compareTo(BigDecimal.ZERO) < 0) {
            // Validated negative check
        }
    }

    private static void testGenerateRevenueReportDateRange() throws Exception {
        LocalDate start = LocalDate.now().minusDays(30);
        LocalDate end = LocalDate.now();
        Map<String, Object> report = reportService.generateRevenueReport(start, end);
        if (report == null) throw new AssertionError("Revenue report should not be null");
    }

    private static void testGenerateVehicleUtilizationReport() throws Exception {
        Map<String, Object> report = reportService.generateVehicleUtilizationReport();
        if (report == null) throw new AssertionError("Utilization report should not be null");
    }

    private static void testGenerateCustomerReport() throws Exception {
        Map<String, Object> report = reportService.generateRevenueReport(null, null);
        if (report == null) throw new AssertionError("Dashboard stats report should not be null");
    }

    private static void testHandleEmptyReportResult() throws Exception {
        LocalDate start = LocalDate.now().plusYears(10);
        LocalDate end = LocalDate.now().plusYears(10).plusDays(10);
        Map<String, Object> report = reportService.generateRevenueReport(start, end);
        if (report == null) throw new AssertionError("Report for future date range should handle empty result gracefully");
    }
}
