package com.swp391.carrental.user.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.swp391.carrental.core.util.DBContext;
import com.swp391.carrental.user.model.Permission;
import com.swp391.carrental.user.model.Role;

public class PermissionDAO {

    /**
     * Get all roles from the database.
     */
    public List<Role> getAllRoles() throws SQLException {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT role_id, role, description, created_at FROM roles ORDER BY role_id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role r = new Role();
                r.setRoleId(rs.getInt("role_id"));
                r.setRole(rs.getString("role"));
                r.setDescription(rs.getString("description"));
                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) {
                    r.setCreatedAt(ts.toLocalDateTime());
                }
                roles.add(r);
            }
        }
        return roles;
    }

    /**
     * Get all permissions from the database.
     */
    public List<Permission> getAllPermissions() throws SQLException {
        List<Permission> permissions = new ArrayList<>();
        String sql = "SELECT permission_id, permission_key, permission_name, functional_area FROM permission WHERE functional_area <> 'Notification Management' AND permission_key NOT IN ('LOCK_USER_ACCOUNT', 'UPDATE_PROFILE') ORDER BY functional_area, permission_key";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Permission p = new Permission();
                p.setPermissionId(rs.getInt("permission_id"));
                p.setPermissionKey(rs.getString("permission_key"));
                p.setPermissionName(rs.getString("permission_name"));
                p.setFunctionalArea(rs.getString("functional_area"));
                permissions.add(p);
            }
        }
        return permissions;
    }

    /**
     * Get permission keys assigned to a specific role.
     */
    public List<String> getPermissionsByRole(String roleName) throws SQLException {
        List<String> permissionKeys = new ArrayList<>();
        String sql = "SELECT p.permission_key FROM permission p " +
                     "JOIN role_permission rp ON p.permission_id = rp.permission_id " +
                     "JOIN roles r ON rp.role_id = r.role_id " +
                     "WHERE r.role = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    permissionKeys.add(rs.getString("permission_key"));
                }
            }
        }
        return permissionKeys;
    }

    /**
     * Update permissions for a role in a transaction.
     */
    public boolean updateRolePermissions(String roleName, List<String> permissionKeys) throws SQLException {
        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;
        PreparedStatement psRoleId = null;
        PreparedStatement psPermId = null;

        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            // 1. Get role_id
            int roleId = -1;
            String sqlRoleId = "SELECT role_id FROM roles WHERE role = ?";
            psRoleId = conn.prepareStatement(sqlRoleId);
            psRoleId.setString(1, roleName);
            try (ResultSet rs = psRoleId.executeQuery()) {
                if (rs.next()) {
                    roleId = rs.getInt("role_id");
                }
            }

            if (roleId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Delete all existing permissions for this role
            String sqlDelete = "DELETE FROM role_permission WHERE role_id = ?";
            psDelete = conn.prepareStatement(sqlDelete);
            psDelete.setInt(1, roleId);
            psDelete.executeUpdate();

            // 3. Insert new permissions
            if (permissionKeys != null && !permissionKeys.isEmpty()) {
                String sqlInsert = "INSERT INTO role_permission (role_id, permission_id) VALUES (?, ?)";
                psInsert = conn.prepareStatement(sqlInsert);

                // Helper to query permission_id from permission_key
                String sqlPermId = "SELECT permission_id FROM permission WHERE permission_key = ?";
                psPermId = conn.prepareStatement(sqlPermId);

                for (String key : permissionKeys) {
                    psPermId.setString(1, key);
                    try (ResultSet rs = psPermId.executeQuery()) {
                        if (rs.next()) {
                            int permId = rs.getInt("permission_id");
                            psInsert.setInt(1, roleId);
                            psInsert.setInt(2, permId);
                            psInsert.addBatch();
                        }
                    }
                }
                psInsert.executeBatch();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (psRoleId != null) psRoleId.close();
            if (psDelete != null) psDelete.close();
            if (psPermId != null) psPermId.close();
            if (psInsert != null) psInsert.close();
            if (conn != null) conn.close();
        }
    }
}
