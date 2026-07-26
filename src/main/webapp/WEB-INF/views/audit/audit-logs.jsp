<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
        <div style="margin-bottom: 16px; position: relative; max-width: 360px;">
            <span class="material-symbols-outlined" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 18px; color: var(--on-surface-variant, #666);">search</span>
            <input type="text" id="auditLogSearchInput" placeholder="Tìm kiếm theo người dùng, hành động, chi tiết..." oninput="filterAuditLogTable()"
                   style="width: 100%; padding: 8px 12px 8px 36px; border-radius: 8px; border: 1px solid var(--outline-variant, #ccc); font-size: 13px; box-sizing: border-box;">
        </div>
        <div style="overflow-x:auto;" id="auditLogTableContainer">
            <table class="bk-table" id="auditLogTable">
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
                        <c:choose>
                            <c:when test="${not empty userMap[log.userId]}">
                                <c:set var="logUserName" value="${userMap[log.userId].fullName}"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="logUserName" value="Người dùng ${log.userId}"/>
                            </c:otherwise>
                        </c:choose>
                        <tr data-search="${fn:toLowerCase(logUserName)} ${fn:toLowerCase(not empty actionLabels[log.action] ? actionLabels[log.action] : log.action)} ${fn:toLowerCase(not empty log.details ? log.details : '')}">
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
                            <td class="code">
                                <c:choose>
                                    <c:when test="${not empty log.entityId}">#${log.entityId}</c:when>
                                    <c:otherwise>—</c:otherwise>
                                </c:choose>
                            </td>
                            <td class="sub">${not empty log.details ? log.details : 'Không có mô tả chi tiết'}</td>
                            <td>${log.createdAt}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <div id="auditLogEmptyState" style="display:none; text-align:center; padding:24px; color:var(--on-surface-variant, #666);">
            Không tìm thấy hoạt động phù hợp.
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; padding-top:12px; border-top:1px solid var(--outline-variant, #ddd); flex-wrap:wrap; gap:12px;">
            <div style="font-size:13px; color:var(--on-surface-variant, #666);">
                Hiển thị <span id="auditLogPagStart" style="font-weight:600;">0</span> đến <span id="auditLogPagEnd" style="font-weight:600;">0</span> trong số <span id="auditLogPagTotal" style="font-weight:600;">0</span> bản ghi
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <label style="font-size:13px; color:var(--on-surface-variant, #666);">Số hàng:</label>
                <select id="auditLogPageSizeSelect" onchange="changeAuditLogPageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant, #ccc); font-size:13px; outline:none; cursor:pointer;">
                    <option value="10">10</option>
                    <option value="20" selected="selected">20</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
                <div id="auditLogPaginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;"></div>
            </div>
        </div>
    </c:if>
</div>

<script>
    let auditLogCurrentPage = 1;
    let auditLogPageSize = 20;
    let auditLogFilteredRows = [];

    function filterAuditLogTable() {
        const keyword = document.getElementById('auditLogSearchInput').value.trim().toLowerCase();
        const allRows = Array.from(document.querySelectorAll('#auditLogTable tbody tr'));
        auditLogFilteredRows = allRows.filter(row => {
            const searchText = row.getAttribute('data-search') || '';
            return searchText.indexOf(keyword) !== -1;
        });
        auditLogCurrentPage = 1;
        applyAuditLogPagination();
    }

    function changeAuditLogPageSize() {
        auditLogPageSize = parseInt(document.getElementById('auditLogPageSizeSelect').value);
        auditLogCurrentPage = 1;
        applyAuditLogPagination();
    }

    function applyAuditLogPagination() {
        const allRows = Array.from(document.querySelectorAll('#auditLogTable tbody tr'));
        allRows.forEach(row => row.style.display = 'none');

        const totalItems = auditLogFilteredRows.length;
        const totalPages = Math.max(1, Math.ceil(totalItems / auditLogPageSize));
        if (auditLogCurrentPage > totalPages) auditLogCurrentPage = totalPages;

        const start = (auditLogCurrentPage - 1) * auditLogPageSize;
        const end = Math.min(start + auditLogPageSize, totalItems);
        const pageRows = auditLogFilteredRows.slice(start, end);
        pageRows.forEach(row => row.style.display = '');

        document.getElementById('auditLogPagStart').textContent = totalItems === 0 ? 0 : start + 1;
        document.getElementById('auditLogPagEnd').textContent = end;
        document.getElementById('auditLogPagTotal').textContent = totalItems;

        document.getElementById('auditLogTableContainer').style.display = totalItems === 0 ? 'none' : '';
        document.getElementById('auditLogEmptyState').style.display = totalItems === 0 ? '' : 'none';

        renderAuditLogPaginationButtons(totalPages);
    }

    function renderAuditLogPaginationButtons(totalPages) {
        const container = document.getElementById('auditLogPaginationButtons');
        container.innerHTML = '';

        const makeBtn = (label, page, disabled, active) => {
            const btn = document.createElement('button');
            btn.textContent = label;
            btn.disabled = disabled;
            btn.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid #ccc; background:' + (active ? '#2F5ACD' : '#fff') + '; color:' + (active ? '#fff' : '#333') + '; font-size:12px; cursor:' + (disabled ? 'not-allowed' : 'pointer') + '; opacity:' + (disabled ? '0.5' : '1') + ';';
            btn.onclick = () => { auditLogCurrentPage = page; applyAuditLogPagination(); };
            return btn;
        };

        container.appendChild(makeBtn('«', auditLogCurrentPage - 1, auditLogCurrentPage <= 1, false));
        const maxButtons = 7;
        let startPage = Math.max(1, auditLogCurrentPage - Math.floor(maxButtons / 2));
        let endPage = Math.min(totalPages, startPage + maxButtons - 1);
        startPage = Math.max(1, endPage - maxButtons + 1);
        for (let p = startPage; p <= endPage; p++) {
            container.appendChild(makeBtn(String(p), p, false, p === auditLogCurrentPage));
        }
        container.appendChild(makeBtn('»', auditLogCurrentPage + 1, auditLogCurrentPage >= totalPages, false));
    }

    document.addEventListener('DOMContentLoaded', function() {
        const table = document.getElementById('auditLogTable');
        if (table) {
            auditLogFilteredRows = Array.from(table.querySelectorAll('tbody tr'));
            applyAuditLogPagination();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
