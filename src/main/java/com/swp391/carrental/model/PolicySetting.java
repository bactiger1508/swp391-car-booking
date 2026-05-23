package com.swp391.carrental.model;

import java.time.LocalDateTime;

/**
 * Configurable policy setting (key-value pair).
 * Maps to the 'policy_settings' table.
 */
public class PolicySetting {

    private int policyId;
    private String policyKey;
    private String policyValue;
    private String description;
    private String category;
    private Integer updatedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public PolicySetting() {
    }

    public int getPolicyId() { return policyId; }
    public void setPolicyId(int policyId) { this.policyId = policyId; }

    public String getPolicyKey() { return policyKey; }
    public void setPolicyKey(String policyKey) { this.policyKey = policyKey; }

    public String getPolicyValue() { return policyValue; }
    public void setPolicyValue(String policyValue) { this.policyValue = policyValue; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
