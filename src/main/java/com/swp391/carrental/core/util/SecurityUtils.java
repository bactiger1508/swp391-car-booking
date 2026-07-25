package com.swp391.carrental.core.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.util.Set;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.model.User;

/*
 * Name: SecurityUtils
 * @Author: AnhNNHE160896
 * Date: 21/07/2026
 * Version: 1.0
 * Description: Utilities for checking user roles and session permissions.
 */

/**
 * Security utilities containing helper methods for authentication and authorization.
 */
public class SecurityUtils {

    /**
     * Checks if the logged-in user has the specified permission key.
     * Admins automatically have all permissions.
     *
     * @param request the HTTP request containing the session
     * @param permissionKey the unique key of the permission to check
     * @return true if the user is authorized, false otherwise
     */
    @SuppressWarnings("unchecked")
    public static boolean hasPermission(HttpServletRequest request, String permissionKey) {
        HttpSession session = request.getSession(false);
        User currentUser = null;
        Set<String> userPermissions = null;

        if (session == null) {
            return false;
        }

        currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return false;
        }

        // Admin has all permissions bypass
        if (Role.ADMIN.equals(currentUser.getRole())) {
            return true;
        }

        userPermissions = (Set<String>) session.getAttribute("userPermissions");
        return userPermissions != null && userPermissions.contains(permissionKey);
    }
}

