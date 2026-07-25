package com.swp391.carrental;

import java.util.ArrayList;
import java.util.List;

public class SystemTestMasterRunner {

    public static class TestResult {
        public String workflowName;
        public int total;
        public int passed;
        public int failed;

        public TestResult(String workflowName, int total, int passed, int failed) {
            this.workflowName = workflowName;
            this.total = total;
            this.passed = passed;
            this.failed = failed;
        }
    }

    public static void main(String[] args) {
        System.out.println("=========================================================================================");
        System.out.println("        SWP391 CAR RENTAL MANAGEMENT - SYSTEM TEST REPORT EXECUTION SUITE (110 CASES)     ");
        System.out.println("=========================================================================================\n");

        List<TestResult> results = new ArrayList<>();

        // Execute 10 Workflows
        results.add(runWorkflow01());
        results.add(runWorkflow02());
        results.add(runWorkflow03());
        results.add(runWorkflow04());
        results.add(runWorkflow05());
        results.add(runWorkflow06());
        results.add(runWorkflow07());
        results.add(runWorkflow08());
        results.add(runWorkflow09());
        results.add(runWorkflow10());

        // Render Summary Report Table (Format matching Test Statistics sheet)
        System.out.println("\n=========================================================================================");
        System.out.println("                                SYSTEM TEST STATISTICS SUMMARY                            ");
        System.out.println("=========================================================================================");
        System.out.printf("| %-3s | %-52s | %-7s | %-6s | %-6s | %-8s |%n", "No", "Workflow Name", "Total", "Pass", "Fail", "Pass %");
        System.out.println("-----------------------------------------------------------------------------------------");

        int grandTotal = 0;
        int grandPassed = 0;
        int grandFailed = 0;
        int index = 1;

        for (TestResult r : results) {
            grandTotal += r.total;
            grandPassed += r.passed;
            grandFailed += r.failed;
            double passRate = (r.total > 0) ? ((double) r.passed / r.total) * 100 : 0.0;
            System.out.printf("| %-3d | %-52s | %-7d | %-6d | %-6d | %-7.2f%% |%n",
                    index++, r.workflowName, r.total, r.passed, r.failed, passRate);
        }

        System.out.println("-----------------------------------------------------------------------------------------");
        double overallPassRate = (grandTotal > 0) ? ((double) grandPassed / grandTotal) * 100 : 0.0;
        System.out.printf("| %-3s | %-52s | %-7d | %-6d | %-6d | %-7.2f%% |%n",
                "ALL", "GRAND TOTAL SYSTEM TEST SUITE", grandTotal, grandPassed, grandFailed, overallPassRate);
        System.out.println("=========================================================================================\n");

        if (grandFailed > 0) {
            System.err.println("❌ SYSTEM TEST SUITE FINISHED WITH FAILS!");
            System.exit(1);
        } else {
            System.out.println("✅ ALL 110 SYSTEM TEST CASES PASSED SUCCESSFULLY!");
        }
    }

    private static TestResult runWorkflow01() {
        return Workflow01_CustomerAuthProfileTest.run();
    }
    private static TestResult runWorkflow02() {
        return Workflow02_InternalUserManagementTest.run();
    }
    private static TestResult runWorkflow03() {
        return Workflow03_CustomerBookingTest.run();
    }
    private static TestResult runWorkflow04() {
        return Workflow04_StaffBookingReviewTest.run();
    }
    private static TestResult runWorkflow05() {
        return Workflow05_VehicleHandoverReturnTest.run();
    }
    private static TestResult runWorkflow06() {
        return Workflow06_FeeAndReportingTest.run();
    }
    private static TestResult runWorkflow07() {
        return Workflow07_ContractAndPaymentTest.run();
    }
    private static TestResult runWorkflow08() {
        return Workflow08_PolicyConfigurationTest.run();
    }
    private static TestResult runWorkflow09() {
        return Workflow09_VehicleCatalogDetailTest.run();
    }
    private static TestResult runWorkflow10() {
        return Workflow10_VehicleManagementMaintenanceTest.run();
    }
}
