package com.swp391.carrental.service;

import com.swp391.carrental.dao.PolicySettingDAO;
import com.swp391.carrental.model.PolicySetting;
import com.swp391.carrental.exception.AppException;

import java.sql.SQLException;
import java.util.List;

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
}
