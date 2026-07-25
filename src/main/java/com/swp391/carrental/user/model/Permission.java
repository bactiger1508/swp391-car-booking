package com.swp391.carrental.user.model;
/*
 * Name: Permission
 * @Author: AnhNNHE160896
 * Date: 01/07/2026
 * Version: 1.0
 * Description: Handles business logic and operations for Permission.
 */

/**
 * Extended permission for admin.
 * Maps to the 'permission ' table.
 */
public class Permission {
    private int permissionId;
    private String permissionKey;
    private String permissionName;
    private String functionalArea;

    public Permission() {
    }

    public Permission(int permissionId, String permissionKey, String permissionName, String functionalArea) {
        this.permissionId = permissionId;
        this.permissionKey = permissionKey;
        this.permissionName = permissionName;
        this.functionalArea = functionalArea;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }

    public String getPermissionKey() {
        return permissionKey;
    }

    public void setPermissionKey(String permissionKey) {
        this.permissionKey = permissionKey;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }

    public String getFunctionalArea() {
        return functionalArea;
    }

    public void setFunctionalArea(String functionalArea) {
        this.functionalArea = functionalArea;
    }
}
