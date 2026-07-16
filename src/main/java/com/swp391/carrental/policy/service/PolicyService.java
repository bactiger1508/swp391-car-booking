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
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for PolicyService.
 */



/**
 * Service for managing policy settings.
 */
public class PolicyService {

    private final PolicySettingDAO policyDAO = new PolicySettingDAO();
    private static volatile Map<String, String> cache = null;

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

    private static synchronized void clearCache() {
        cache = null;
    }

    // Get policy by key
    public PolicySetting getPolicyByKey(String key) {
        try {
            return policyDAO.findByKey(key);
        } catch (SQLException e) {
            throw new AppException("Failed to get policy setting.", e);
        }
    }

    // Get policy value with fallback default value 
    public String getPolicyValue(String key, String defaultValue) {
        if (cache == null) {
            loadCache(policyDAO);
        }
        String val = cache.get(key);
        return val != null ? val : defaultValue;
    }

    // Get all policy settings
    public List<PolicySetting> getAllPolicies() {
        try {
            return policyDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get policies.", e);
        }
    }

    // Get policies by category
    public List<PolicySetting> getPoliciesByCategory(String category) {
        try {
            return policyDAO.findByCategory(category);
        } catch (SQLException e) {
            throw new AppException("Failed to get policies by category.", e);
        }
    }

    // Update a policy setting
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
     * Atomically updates multiple policy key-value pairs in one DB transaction.
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

    // Delete a policy setting 
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
