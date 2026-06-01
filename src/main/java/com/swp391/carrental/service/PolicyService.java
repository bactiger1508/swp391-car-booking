/*
 * Name: PolicyService
 * @Author: TungNLHE186756
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Contains business logic for PolicyService.
 */
package com.swp391.carrental.service;

import com.swp391.carrental.dao.PolicySettingDAO;
import com.swp391.carrental.model.PolicySetting;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Service for managing policy settings.
 */
public class PolicyService {

    private final PolicySettingDAO policyDAO = new PolicySettingDAO();

    public PolicySetting getPolicyByKey(String key) {
        try {
            return policyDAO.findByKey(key);
        } catch (SQLException e) {
            throw new AppException("Failed to get policy setting.", e);
        }
    }

    public String getPolicyValue(String key, String defaultValue) {
        try {
            PolicySetting setting = policyDAO.findByKey(key);
            return setting != null ? setting.getPolicyValue() : defaultValue;
        } catch (SQLException e) {
            return defaultValue;
        }
    }

    public List<PolicySetting> getAllPolicies() {
        try {
            return policyDAO.findAll();
        } catch (SQLException e) {
            throw new AppException("Failed to get policies.", e);
        }
    }

    public List<PolicySetting> getPoliciesByCategory(String category) {
        try {
            return policyDAO.findByCategory(category);
        } catch (SQLException e) {
            throw new AppException("Failed to get policies by category.", e);
        }
    }

    public boolean updatePolicy(String key, String value, int updatedBy) {
        try {
            return policyDAO.updateValue(key, value, updatedBy);
        } catch (SQLException e) {
            throw new AppException("Failed to update policy.", e);
        }
    }

    /**
     * Atomically updates multiple policy key-value pairs in one DB transaction.
     */
    public int batchUpdatePolicies(Map<String, String> updates, int updatedBy) {
        try {
            return policyDAO.batchUpdateValues(updates, updatedBy);
        } catch (SQLException e) {
            throw new AppException("Failed to batch-update policies.", e);
        }
    }

    public boolean deletePolicy(int policyId) {
        try {
            return policyDAO.delete(policyId);
        } catch (SQLException e) {
            throw new AppException("Failed to delete policy.", e);
        }
    }
}
