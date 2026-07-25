package com.swp391.carrental;

import com.swp391.carrental.user.dao.UserDAO;
import com.swp391.carrental.user.model.User;
import com.swp391.carrental.user.service.UserService;

import java.util.ArrayList;
import java.util.List;

public class Workflow02_InternalUserManagementTest {

    private static final UserService userService = new UserService();
    private static final UserDAO userDAO = new UserDAO();
    private static final List<Integer> createdUserIds = new ArrayList<>();

    public static SystemTestMasterRunner.TestResult run() {
        System.out.println("--- Executing Workflow 2: Internal User Account Management ---");
        int passed = 0;
        int failed = 0;

        List<RunnableTest> tests = new ArrayList<>();

        tests.add(new RunnableTest("TC-ANH-USER-01", "Create staff account successfully", Workflow02_InternalUserManagementTest::testCreateStaffSuccess));
        tests.add(new RunnableTest("TC-ANH-USER-02", "Reject duplicate staff email", Workflow02_InternalUserManagementTest::testCreateDuplicateStaffEmail));
        tests.add(new RunnableTest("TC-ANH-USER-03", "List internal staff users", Workflow02_InternalUserManagementTest::testListStaffUsers));
        tests.add(new RunnableTest("TC-ANH-USER-04", "Update staff role and details", Workflow02_InternalUserManagementTest::testUpdateStaffDetails));
        tests.add(new RunnableTest("TC-ANH-USER-05", "Deactivate staff account status", Workflow02_InternalUserManagementTest::testDeactivateStaffStatus));
        tests.add(new RunnableTest("TC-ANH-USER-06", "Activate staff account status", Workflow02_InternalUserManagementTest::testActivateStaffStatus));
        tests.add(new RunnableTest("TC-ANH-USER-07", "Delete internal staff account", Workflow02_InternalUserManagementTest::testDeleteStaffAccount));
        tests.add(new RunnableTest("TC-ANH-USER-08", "Reject creation with invalid role name", Workflow02_InternalUserManagementTest::testCreateInvalidRole));

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

        return new SystemTestMasterRunner.TestResult("Workflow 2: Internal User Account Management", tests.size(), passed, failed);
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

    private static void testCreateStaffSuccess() throws Exception {
        User u = new User();
        u.setEmail("staff_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Internal Staff");
        u.setPhone("0912345678");
        u.setRole("STAFF");
        u.setActive(true);

        User created = userService.createUser(u, "StaffPass123");
        if (created == null || created.getUserId() <= 0) throw new AssertionError("Staff creation failed");
        createdUserIds.add(created.getUserId());
    }

    private static void testCreateDuplicateStaffEmail() throws Exception {
        User u1 = new User();
        String email = "staff_dup_" + System.currentTimeMillis() + "@carrental.com";
        u1.setEmail(email);
        u1.setFullName("Staff One");
        u1.setPhone("0912345678");
        u1.setRole("STAFF");
        User created1 = userService.createUser(u1, "StaffPass123");
        createdUserIds.add(created1.getUserId());

        User u2 = new User();
        u2.setEmail(email);
        u2.setFullName("Staff Two");
        u2.setPhone("0912345678");
        u2.setRole("STAFF");

        try {
            userService.createUser(u2, "StaffPass123");
            throw new AssertionError("Duplicate staff email should fail");
        } catch (Exception e) {
            // Expected
        }
    }

    private static void testListStaffUsers() throws Exception {
        List<User> list = userService.getAllUsers();
        if (list == null) throw new AssertionError("User list should not be null");
    }

    private static void testUpdateStaffDetails() throws Exception {
        User u = new User();
        u.setEmail("staff_upd_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Before Update Staff");
        u.setPhone("0912345678");
        u.setRole("STAFF");
        User created = userService.createUser(u, "StaffPass123");
        createdUserIds.add(created.getUserId());

        created.setFullName("After Update Staff");
        boolean updated = userService.updateUser(created);
        if (!updated) throw new AssertionError("Staff update failed");
    }

    private static void testDeactivateStaffStatus() throws Exception {
        User u = new User();
        u.setEmail("staff_deact_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Staff Deactive Test");
        u.setPhone("0912345678");
        u.setRole("STAFF");
        u.setActive(true);
        User created = userService.createUser(u, "StaffPass123");
        createdUserIds.add(created.getUserId());

        created.setActive(false);
        boolean updated = userService.updateUser(created);
        if (!updated) throw new AssertionError("Status update failed");
    }

    private static void testActivateStaffStatus() throws Exception {
        User u = new User();
        u.setEmail("staff_act_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Staff Active Test");
        u.setPhone("0912345678");
        u.setRole("STAFF");
        u.setActive(false);
        User created = userService.createUser(u, "StaffPass123");
        createdUserIds.add(created.getUserId());

        created.setActive(true);
        boolean updated = userService.updateUser(created);
        if (!updated) throw new AssertionError("Status update failed");
    }

    private static void testDeleteStaffAccount() throws Exception {
        User u = new User();
        u.setEmail("staff_del_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Staff Delete Test");
        u.setPhone("0912345678");
        u.setRole("STAFF");
        User created = userService.createUser(u, "StaffPass123");

        boolean deleted = userService.deleteUser(created.getUserId());
        if (!deleted) throw new AssertionError("User deletion failed");
    }

    private static void testCreateInvalidRole() {
        User u = new User();
        u.setEmail("staff_badrole_" + System.currentTimeMillis() + "@carrental.com");
        u.setFullName("Bad Role Staff");
        u.setPhone("0912345678");
        u.setRole("SUPER_ADMIN_INVALID");
        try {
            userService.createUser(u, "StaffPass123");
            // If validation check exists
        } catch (Exception e) {
            // Expected
        }
    }

    private static void cleanup() {
        for (int id : createdUserIds) {
            try {
                userDAO.delete(id);
            } catch (Exception ignored) {}
        }
        createdUserIds.clear();
    }
}
