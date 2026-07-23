package com.swp391.carrental.policy.service;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import com.swp391.carrental.core.exception.AppException;
import com.swp391.carrental.policy.dao.PolicySettingDAO;
import com.swp391.carrental.policy.model.PolicySetting;

/*
 * Name: PolicyService
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Service containing business logic for policy settings management with a volatile static cache.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (31/05/2026): feat: implement payment processing system including recor...
 * - v1.3 (01/06/2026): last update for iter1
 * - v1.4 (04/06/2026): refactor: apply coding conventions and improve code docum...
 * - v1.5 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.6 (16/07/2026): perf(policy): cache policy settings in-memory to prevent ...
 * - v1.7 (17/07/2026): docs(convention): update header comments and versions for...
 * - v1.8 (23/07/2026): Added Javadoc and method comments.
 */
public class PolicyService {

    private final PolicySettingDAO policyDAO = new PolicySettingDAO();
    private static volatile Map<String, String> cache = null;

    /**
     * Helper function to initialize and load the static volatile policies cache map from database.
     */
    private static synchronized void loadCache(PolicySettingDAO dao) {
        if (cache == null) {
            Map<String, String> temp = new java.util.HashMap<>();
            try {
                for (PolicySetting setting : dao.findAll()) {
                    temp.put(setting.getPolicyKey(), setting.getPolicyValue());
                }
            } catch (SQLException e) {
                // Fallback will handle it
            }
            cache = temp;
        }
    }

    /**
     * Helper function to clear and evict cache, forcing next read to fetch fresh DB values.
     */
    private static synchronized void clearCache() {
        cache = null;
    }

    /**
     * Query a policy setting by key.
     */
    public PolicySetting getPolicyByKey(String key) {
        try {
            return policyDAO.findByKey(key);
        } catch (SQLException e) {
            throw new AppException("Failed to get policy setting.", e);
        }
    }

    /**
     * Query the value of a policy setting by key with a fallback default.
     */
    public String getPolicyValue(String key, String defaultValue) {
        if (cache == null) {
            loadCache(policyDAO);
        }
        String val = cache.get(key);
        return val != null ? val : defaultValue;
    }

    /**
     * Retrieve all policy settings in the system.
     */
    public List<PolicySetting> getAllPolicies() {
        try {
            return policyDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get policies.", e);
        }
    }

    /**
     * Retrieve policy settings belonging to a specific category.
     */
    public List<PolicySetting> getPoliciesByCategory(String category) {
        try {
            return policyDAO.findByCategory(category);
        } catch (SQLException e) {
            throw new AppException("Failed to get policies by category.", e);
        }
    }

    /**
     * Update a policy setting's value.
     */
    public boolean updatePolicy(String key, String value, int updatedBy) {
        try {
            boolean ok = policyDAO.updateValue(key, value, updatedBy);
            if (ok) {
                clearCache();
            }
            return ok;
        } catch (SQLException e) {
            throw new AppException("Failed to update policy.", e);
        }
    }

    /**
     * Perform bulk updates on multiple policy settings in a single transaction.
     */
    public int batchUpdatePolicies(Map<String, String> updates, int updatedBy) {
        try {
            int count = policyDAO.batchUpdateValues(updates, updatedBy);
            if (count > 0) {
                clearCache();
            }
            return count;
        } catch (SQLException e) {
            throw new AppException("Failed to batch-update policies.", e);
        }
    }

    /**
     * Delete a policy setting by ID.
     */
    public boolean deletePolicy(int policyId) {
        try {
            boolean ok = policyDAO.delete(policyId);
            if (ok) {
                clearCache();
            }
            return ok;
        } catch (SQLException e) {
            throw new AppException("Failed to delete policy.", e);
        }
    }
}
