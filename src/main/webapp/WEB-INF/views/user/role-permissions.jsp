<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <jsp:include page="/WEB-INF/views/layout/header.jsp">
            <jsp:param name="pageTitle" value="Phân quyền vai trò - CarPro" />
        </jsp:include>

        <div class="page-content" style="padding: 24px;">

            <!-- TOP HEADER/BREADCRUMB -->
            <div
                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h2
                        style="font-weight: 700; color: var(--primary); margin-bottom: 4px; display: flex; align-items: center; gap: 8px;">
                        <span class="material-symbols-outlined" style="font-size: 28px;">admin_panel_settings</span>
                        Phân Quyền Vai Trò
                    </h2>
                    <p style="color: var(--text-secondary); font-size: 14px; margin: 0;">
                        Quản lý các cấp truy cập trên các khu vực chức năng khác nhau từ database.
                    </p>
                </div>
                <div style="display: flex; gap: 12px;">
                    <a href="${pageContext.request.contextPath}/users" class="btn btn-outline"
                        style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px;">
                        <span class="material-symbols-outlined" style="font-size: 18px;">arrow_back</span>
                        Quản Lý Thành Viên
                    </a>
                    <button type="submit" form="permissionForm" class="btn btn-primary"
                        style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px;">
                        <span class="material-symbols-outlined" style="font-size: 18px;">save</span>
                        Lưu Thay Đổi
                    </button>
                </div>
            </div>

            <!-- Messages -->
            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success"
                    style="margin-bottom: 24px; padding: 16px; border-radius: var(--radius-sm); display: flex; align-items: center; gap: 12px; font-weight: 500; font-size: 14px; background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0;">
                    <span class="material-symbols-outlined" style="font-size: 20px;">check_circle</span>
                    <span>${sessionScope.success}</span>
                </div>
                <c:remove var="success" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger"
                    style="margin-bottom: 24px; padding: 16px; border-radius: var(--radius-sm); display: flex; align-items: center; gap: 12px; font-weight: 500; font-size: 14px; background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca;">
                    <span class="material-symbols-outlined" style="font-size: 20px;">error</span>
                    <span>${sessionScope.error}</span>
                </div>
                <c:remove var="error" scope="session" />
            </c:if>

            <!-- MAIN CARD & FORM -->
            <div class="card"
                style="background: var(--bg-white); border-radius: var(--radius-xl); box-shadow: var(--shadow); border: 1px solid var(--border-color); overflow: hidden; padding: 24px;">

                <form id="permissionForm" method="post" action="${pageContext.request.contextPath}/roles">
                    <div class="table-responsive">
                        <table class="table"
                            style="width: 100%; border-collapse: collapse; border: 1px solid var(--border-color); border-radius: var(--radius-lg); overflow: hidden;">
                            <thead>
                                <tr style="background: var(--primary-light);">
                                    <th
                                        style="padding: 16px; text-align: left; font-weight: 700; color: var(--primary); font-size: 14px; border-bottom: 2px solid var(--border-color);">
                                        KHU VỰC CHỨC NĂNG / QUYỀN HẠN
                                    </th>
                                    <c:forEach var="r" items="${roles}">
                                        <th
                                            style="padding: 16px; text-align: center; font-weight: 700; color: var(--primary); font-size: 14px; border-bottom: 2px solid var(--border-color); min-width: 150px;">
                                            <c:choose>
                                                <c:when test="${r.role == 'ADMIN'}">
                                                    <span
                                                        style="display: inline-flex; align-items: center; gap: 4px; color: var(--danger);">
                                                        <span class="material-symbols-outlined"
                                                            style="font-size: 16px;">shield_person</span>
                                                        QUẢN TRỊ VIÊN
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.role == 'STAFF'}">
                                                    <span
                                                        style="display: inline-flex; align-items: center; gap: 4px; color: var(--info);">
                                                        <span class="material-symbols-outlined"
                                                            style="font-size: 16px;">badge</span>
                                                        NHÂN VIÊN
                                                    </span>
                                                </c:when>
                                                <c:when test="${r.role == 'CUSTOMER'}">
                                                    <span
                                                        style="display: inline-flex; align-items: center; gap: 4px; color: var(--success);">
                                                        <span class="material-symbols-outlined"
                                                            style="font-size: 16px;">person</span>
                                                        KHÁCH HÀNG
                                                    </span>
                                                </c:when>
                                                <c:otherwise>${r.role}</c:otherwise>
                                            </c:choose>
                                        </th>
                                    </c:forEach>
                                </tr>
                            </thead>

                            <tbody>
                                <c:set var="currentArea" value="" />
                                <c:forEach var="p" items="${permissions}">

                                    <!-- Functional Area Header Row -->
                                    <c:if test="${p.functionalArea != currentArea}">
                                        <c:set var="currentArea" value="${p.functionalArea}" />
                                        <tr
                                            style="background: var(--primary-light); font-weight: 600; border-top: 1px solid var(--border-color); border-bottom: 1px solid var(--border-color);">
                                            <td colspan="${roles.size() + 1}"
                                                style="padding: 12px 16px; text-align: left; color: var(--primary); font-size: 14px; font-weight: 700;">
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <span class="material-symbols-outlined"
                                                        style="font-size: 18px; color: var(--primary);">folder_open</span>
                                                    ${p.functionalArea}
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>

                                    <!-- Individual Permission Row -->
                                    <tr style="border-bottom: 1px solid var(--border-color); transition: background 0.2s;"
                                        onmouseover="this.style.background='rgba(4, 22, 56, 0.02)'"
                                        onmouseout="this.style.background='transparent'">
                                        <td style="padding: 14px 16px; text-align: left; vertical-align: middle;">
                                            <div style="font-weight: 600; color: var(--text-primary); font-size: 14px;">
                                                ${p.permissionName}</div>
                                            <div
                                                style="font-size: 11px; color: var(--text-secondary); margin-top: 2px; font-family: monospace;">
                                                Key: ${p.permissionKey}</div>
                                        </td>
                                        <c:forEach var="r" items="${roles}">
                                            <td align="center" style="padding: 14px; vertical-align: middle;">
                                                <div
                                                    style="position: relative; display: inline-flex; align-items: center; justify-content: center;">
                                                    <input type="checkbox" name="role_perm_${r.role}_${p.permissionKey}"
                                                        value="true" ${rolePermissions[r.role].contains(p.permissionKey)
                                                        ? 'checked' : '' } ${r.role=='ADMIN' ? 'disabled' : '' }
                                                        style="width: 20px; height: 20px; cursor: ${r.role == 'ADMIN' ? 'not-allowed' : 'pointer'}; accent-color: var(--primary);" />
                                                    <c:if test="${r.role == 'ADMIN'}">
                                                        <input type="hidden"
                                                            name="role_perm_${r.role}_${p.permissionKey}"
                                                            value="true" />
                                                    </c:if>
                                                </div>
                                            </td>
                                        </c:forEach>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Footer Action Button Panel -->
                    <div
                        style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; flex-wrap: wrap; gap: 16px;">
                        <div
                            style="display: flex; align-items: center; gap: 8px; color: var(--text-secondary); font-size: 13px; max-width: 600px;">
                            <span class="material-symbols-outlined"
                                style="font-size: 20px; color: var(--info);">info</span>
                            <span>Các quyền của quản trị viên (ADMIN) được kế thừa đầy đủ từ hệ thống và không thể thay
                                đổi để tránh khóa tài khoản.</span>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <jsp:include page="/WEB-INF/views/layout/footer.jsp" />