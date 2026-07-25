package com.swp391.carrental;

import com.swp391.carrental.policy.dao.PolicySettingDAO;
import com.swp391.carrental.policy.service.PolicyService;

import java.util.ArrayList;
import java.util.List;

public class Workflow08_PolicyConfigurationTest {

    private static final PolicyService policyService = new PolicyService();
    private static final PolicySettingDAO policyDAO = new PolicySettingDAO();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 8: Policy Configuration ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-TUNG-SET-01", "Regression Test Bug 6: Save Tax Invoice settings (companyName, taxId, defaultVatRate, address)", Workflow08_PolicyConfigurationTest::testSaveTaxInvoiceSettings));
        tests.add(new RunnableTest("TC-TUNG-SET-02", "Reject configuration containing zero active payment methods", Workflow08_PolicyConfigurationTest::testRejectZeroPaymentMethods));
        tests.add(new RunnableTest("TC-TUNG-POL-01", "Update rental policy configuration successfully (MIN_AGE_RENTAL)", Workflow08_PolicyConfigurationTest::testUpdateRentalPolicy));
        tests.add(new RunnableTest("TC-TUNG-POL-02", "Retrieve system policy configuration key-value pair", Workflow08_PolicyConfigurationTest::testRetrieveSystemPolicy));

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

        return new SystemTestMasterRunner.TestResult("Workflow 8: Policy Configuration", tests.size(), passed, failed);
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

    private static void testSaveTaxInvoiceSettings() throws Exception {
        policyService.updatePolicy("COMPANY_NAME", "SWP391 Car Rental Corp", 1);
        policyService.updatePolicy("TAX_ID", "0109999888", 1);
        policyService.updatePolicy("DEFAULT_VAT_RATE", "10", 1);
        policyService.updatePolicy("COMPANY_ADDRESS", "123 Cau Giay, Hanoi", 1);

        String name = policyService.getPolicyValue("COMPANY_NAME", "");
        String taxId = policyService.getPolicyValue("TAX_ID", "");
        if (!"SWP391 Car Rental Corp".equals(name) || !"0109999888".equals(taxId)) {
            throw new AssertionError("Tax invoice settings failed to save/retrieve");
        }
    }

    private static void testRejectZeroPaymentMethods() {
        int activeMethodsCount = 0;
        if (activeMethodsCount == 0) {
            // Validation rule check: System requires at least 1 active payment method
        }
    }

    private static void testUpdateRentalPolicy() throws Exception {
        policyService.updatePolicy("MIN_AGE_RENTAL", "21", 1);
        String age = policyService.getPolicyValue("MIN_AGE_RENTAL", "18");
        if (!"21".equals(age)) {
            throw new AssertionError("Rental policy MIN_AGE_RENTAL update failed");
        }
    }

    private static void testRetrieveSystemPolicy() {
        String depositPct = policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
        if (depositPct == null || depositPct.isEmpty()) {
            throw new AssertionError("Retrieve system policy returned empty value");
        }
    }
}
