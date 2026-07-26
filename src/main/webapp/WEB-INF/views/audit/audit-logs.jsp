<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Sử Hoạt Động"/>
</jsp:include>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<div class="bk-page-header">
    <div>
        <h2>Lịch Sử Hoạt Động</h2>
        <p>Theo dõi và lọc các hành động quan trọng được thực hiện bởi người dùng trong hệ thống.</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar" style="flex-wrap:wrap;">
        <form method="GET" action="${pageContext.request.contextPath}/audit-logs" style="display:flex; gap:12px; flex-wrap:wrap; align-items:flex-end; width:100%;">
            <input type="hidden" name="action" value="filter">

            <div class="bk-form-group">
                <label class="bk-form-label">ID Người Dùng</label>
                <input type="text" name="userId" value="${userIdFilter}" placeholder="Nhập ID" class="bk-form-input" style="padding-left:12px; width:140px;">
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Hành Động</label>
                <select name="action_filter" class="bk-form-select" style="width:180px;">
                    <option value="">-- Tất cả --</option>
                    <option value="CREATE" ${actionFilter == 'CREATE' ? 'selected' : ''}>Tạo mới</option>
                    <option value="UPDATE" ${actionFilter == 'UPDATE' ? 'selected' : ''}>Cập nhật</option>
                    <option value="DELETE" ${actionFilter == 'DELETE' ? 'selected' : ''}>Xóa</option>
                    <option value="UPDATESTATUS" ${actionFilter == 'UPDATESTATUS' ? 'selected' : ''}>Cập nhật trạng thái</option>
                    <option value="RECORDMAINTENANCE" ${actionFilter == 'RECORDMAINTENANCE' ? 'selected' : ''}>Ghi nhận bảo trì</option>
                    <option value="SUBMIT" ${actionFilter == 'SUBMIT' ? 'selected' : ''}>Gửi yêu cầu</option>
                </select>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Loại Thực Thể</label>
                <select name="entityType" class="bk-form-select" style="width:180px;">
                    <option value="">-- Tất cả --</option>
                    <option value="USER" ${entityTypeFilter == 'USER' ? 'selected' : ''}>Người dùng</option>
                    <option value="VEHICLE" ${entityTypeFilter == 'VEHICLE' ? 'selected' : ''}>Xe</option>
                    <option value="MAINTENANCE" ${entityTypeFilter == 'MAINTENANCE' ? 'selected' : ''}>Bảo trì</option>
                    <option value="BRAND_MODEL" ${entityTypeFilter == 'BRAND_MODEL' ? 'selected' : ''}>Hãng xe/Model</option>
                    <option value="BOOKING" ${entityTypeFilter == 'BOOKING' ? 'selected' : ''}>Đặt xe</option>
                    <option value="PAYMENT" ${entityTypeFilter == 'PAYMENT' ? 'selected' : ''}>Thanh toán</option>
                    <option value="CONTRACT" ${entityTypeFilter == 'CONTRACT' ? 'selected' : ''}>Hợp đồng</option>
                    <option value="AUTH" ${entityTypeFilter == 'AUTH' ? 'selected' : ''}>Đăng nhập/Đăng xuất</option>
                </select>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Từ Ngày</label>
                <input type="date" name="startDate" value="${startDateFilter}" class="bk-form-input" style="padding-left:12px;">
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Đến Ngày</label>
                <input type="date" name="endDate" value="${endDateFilter}" class="bk-form-input" style="padding-left:12px;">
            </div>

            <div style="display:flex; gap:8px;">
                <button type="submit" class="bk-btn bk-btn-primary">
                    <span class="material-symbols-outlined" style="font-size:18px;">filter_alt</span> Lọc
                </button>
                <a href="${pageContext.request.contextPath}/audit-logs" class="bk-btn bk-btn-outline">Xoá Bộ Lọc</a>
            </div>
        </form>
    </div>

    <c:if test="${empty logs}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">history</span>
            <h3>Không có bản ghi nào</h3>
            <p>Không có hoạt động nào khớp với điều kiện lọc đã chọn.</p>
        </div>
    </c:if>

    <c:if test="${not empty logs}">
        <div style="overflow-x:auto;">
            <table class="bk-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Người dùng</th>
                        <th>Hành động</th>
                        <th>Loại thực thể</th>
                        <th>ID thực thể</th>
                        <th>Chi tiết</th>
                        <th>Thời gian</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${logs}" var="log">
                        <tr>
                            <td class="code">#${log.auditId}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty userMap[log.userId]}">
                                        <div style="font-weight:600;">${userMap[log.userId].fullName}</div>
                                        <div class="sub" style="font-size:11px;">
                                            <c:choose>
                                                <c:when test="${userMap[log.userId].role == 'ADMIN'}">Quản trị viên</c:when>
                                                <c:when test="${userMap[log.userId].role == 'STAFF'}">Nhân viên</c:when>
                                                <c:when test="${userMap[log.userId].role == 'CUSTOMER'}">Khách hàng</c:when>
                                                <c:otherwise>${userMap[log.userId].role}</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:when>
                                    <c:otherwise>Người dùng #${log.userId}</c:otherwise>
                                </c:choose>
                            </td>
                            <c:set var="actionLabel" value="${not empty actionLabels[log.action] ? actionLabels[log.action] : log.action}"/>
                            <td>
                                <c:choose>
                                    <c:when test="${log.action == 'CREATE' || log.action == 'ADDBRAND' || log.action == 'ADDMODEL' || log.action == 'RECORDMAINTENANCE'}">
                                        <span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> ${actionLabel}</span>
                                    </c:when>
                                    <c:when test="${log.action == 'DELETE' || log.action == 'DELETEIMAGE'}">
                                        <span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> ${actionLabel}</span>
                                    </c:when>
                                    <c:when test="${log.action == 'UPDATE' || log.action == 'UPDATESTATUS' || log.action == 'EDIT' || log.action == 'TOGGLEBRANDACTIVE' || log.action == 'TOGGLEMODELACTIVE' || log.action == 'TOGGLEACTIVE' || log.action == 'SETPRIMARYIMAGE'}">
                                        <span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> ${actionLabel}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> ${actionLabel}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${not empty entityLabels[log.entityType] ? entityLabels[log.entityType] : log.entityType}</td>
                            <td>${log.entityId}</td>
                            <td class="sub">${log.details}</td>
                            <td>${log.createdAt}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
