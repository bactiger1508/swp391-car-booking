<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Phân quyền vai trò - CarPro</title>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

            <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">

            <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet">
        </head>

        <body class="auth-body">

            <div class="auth-container">

                <div class="auth-card" style="max-width:1100px;width:95%;">

                    <div class="auth-accent"></div>

                    <div class="auth-card-body">

                        <!-- HEADER -->
                        <div class="auth-header">
                            <div class="auth-icon-wrapper">
                                <span class="material-symbols-outlined">
                                    admin_panel_settings
                                </span>
                            </div>

                            <h1>Phân quyền vai trò</h1>

                            <p class="subtitle">
                                Quản lý các cấp truy cập trên các khu vực chức năng khác nhau từ database.
                            </p>
                        </div>

                        <!-- Messages -->
                        <c:if test="${not empty sessionScope.success}">
                            <div class="alert alert-success"
                                style="margin-bottom: 20px; background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 12px; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
                                <span class="material-symbols-outlined">check_circle</span>
                                <span>${sessionScope.success}</span>
                            </div>
                            <c:remove var="success" scope="session" />
                        </c:if>
                        <c:if test="${not empty sessionScope.error}">
                            <div class="alert alert-danger"
                                style="margin-bottom: 20px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; padding: 12px; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
                                <span class="material-symbols-outlined">error</span>
                                <span>${sessionScope.error}</span>
                            </div>
                            <c:remove var="error" scope="session" />
                        </c:if>

                        <!-- ACTION BUTTONS -->
                        <div style="
                display:flex;
                justify-content:space-between;
                margin-bottom:24px;
                flex-wrap:wrap;
                gap:12px;
            ">

                            <a href="${pageContext.request.contextPath}/users" class="btn btn-secondary"
                                style="text-decoration:none;">
                                ← Quay lại Quản Lý Người Dùng
                            </a>

                            <div style="display:flex;gap:12px;">
                                <button type="submit" form="permissionForm" class="btn btn-primary">
                                    Lưu quyền
                                </button>
                            </div>

                        </div>

                        <!-- FORM -->
                        <form id="permissionForm" method="post" action="${pageContext.request.contextPath}/roles">

                            <table style="
                    width:100%;
                    border-collapse:collapse;
                    border:1px solid #e5e7eb;
                    border-radius:12px;
                    overflow:hidden;
                ">

                                <thead style="background:#f8fafc;">
                                    <tr>
                                        <th style="padding:16px;text-align:left;">
                                            KHU VỰC CHỨC NĂNG / QUYỀN HẠN
                                        </th>
                                        <c:forEach var="r" items="${roles}">
                                            <th style="padding:16px; text-align: center;">
                                                <c:choose>
                                                    <c:when test="${r.role == 'ADMIN'}">QUẢN TRỊ VIÊN</c:when>
                                                    <c:when test="${r.role == 'STAFF'}">NHÂN VIÊN</c:when>
                                                    <c:when test="${r.role == 'CUSTOMER'}">KHÁCH HÀNG</c:when>
                                                    <c:otherwise>${r.role}</c:otherwise>
                                                </c:choose>
                                            </th>
                                        </c:forEach>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:set var="currentArea" value="" />
                                    <c:forEach var="p" items="${permissions}">
                                        <c:if test="${p.functionalArea != currentArea}">
                                            <c:set var="currentArea" value="${p.functionalArea}" />
                                            <tr
                                                style="background:#f1f5f9;font-weight:600; border-top: 2px solid #e2e8f0; border-bottom: 1px solid #e2e8f0;">
                                                <td colspan="${roles.size() + 1}"
                                                    style="padding:12px 16px; text-align: left; color: #334155; font-size: 14px;">
                                                    📁 ${p.functionalArea}
                                                </td>
                                            </tr>
                                        </c:if>
                                        <tr style="border-bottom: 1px solid #f1f5f9;">
                                            <td style="padding:14px 16px; text-align: left; vertical-align: middle;">
                                                <div style="font-weight: 500; color: #1e293b;">${p.permissionName}</div>
                                                <div style="font-size: 11px; color: #94a3b8; margin-top: 2px;">Key:
                                                    ${p.permissionKey}</div>
                                            </td>
                                            <c:forEach var="r" items="${roles}">
                                                <td align="center" style="padding: 14px; vertical-align: middle;">
                                                    <input type="checkbox" name="role_perm_${r.role}_${p.permissionKey}"
                                                        value="true" ${rolePermissions[r.role].contains(p.permissionKey)
                                                        ? 'checked' : '' } ${r.role=='ADMIN' ? 'disabled' : '' }
                                                        style="width: 18px; height: 18px; cursor: ${r.role == 'ADMIN' ? 'not-allowed' : 'pointer'};" />
                                                    <c:if test="${r.role == 'ADMIN'}">
                                                        <input type="hidden"
                                                            name="role_perm_${r.role}_${p.permissionKey}"
                                                            value="true" />
                                                    </c:if>
                                                </td>
                                            </c:forEach>
                                        </tr>
                                    </c:forEach>
                                </tbody>

                            </table>

                        </form>

                        <!-- FOOTER NOTE -->
                        <div class="alert alert-info" style="margin-top:20px;">
                            <span class="material-symbols-outlined" style="margin-right:8px;">
                                info
                            </span>
                            Các quyền của quản trị viên (ADMIN) được kế thừa đầy đủ từ hệ thống và không thể thay đổi.
                        </div>

                    </div>

                </div>

            </div>

        </body>

        </html>