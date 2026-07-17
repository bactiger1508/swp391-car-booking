package com.swp391.carrental.user.model;

import java.time.LocalDateTime;

public class Role {
    private int roleId;
    private String role;
    private String description;
    private LocalDateTime createdAt;

    public Role() {
    }

    public Role(int roleId, String role, String description, LocalDateTime createdAt) {
        this.roleId = roleId;
        this.role = role;
        this.description = description;
        this.createdAt = createdAt;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
