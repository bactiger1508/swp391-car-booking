package com.swp391.carrental.core.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.util.Set;
import com.swp391.carrental.user.constant.Role;
import com.swp391.carrental.user.model.User;

public class SecurityUtils {

    /**
     * Checks if the logged-in user has the specified permission key.
     * Admins automatically have all permissions.
     */
    @SuppressWarnings("unchecked")
    public static boolean hasPermission(HttpServletRequest request, String permissionKey) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return false;
        }

        // Admin has all permissions bypass
        if (Role.ADMIN.equals(currentUser.getRole())) {
            return true;
        }

        Set<String> userPermissions = (Set<String>) session.getAttribute("userPermissions");
        return userPermissions != null && userPermissions.contains(permissionKey);
    }
}
