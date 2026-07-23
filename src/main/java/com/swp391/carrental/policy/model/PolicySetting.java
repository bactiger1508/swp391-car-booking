package com.swp391.carrental.policy.model;

import java.time.LocalDateTime;

/*
 * Name: PolicySetting
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Model representing a configurable system policy setting (key-value pair) in the database.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.3 (23/07/2026): Added Javadoc and method comments.
 */


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
