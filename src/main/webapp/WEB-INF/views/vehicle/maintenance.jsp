<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Bảo Trì Xe"/>
</jsp:include>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<div class="bk-page-header">
    <div>
        <h2>Quản Lý Bảo Trì Xe</h2>
        <p>Ghi nhận và theo dõi lịch sử bảo trì, kiểm định, bảo hiểm, sửa chữa cho từng xe.</p>
    </div>
</div>

<div class="bk-card" style="margin-bottom:24px;">
    <div class="bk-card-title">
        <span class="material-symbols-outlined">directions_car</span> Chọn Xe
    </div>

    <c:if test="${empty vehicles}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">directions_car</span>
            <h3>Không có xe nào trong hệ thống</h3>
        </div>
    </c:if>

    <c:if test="${not empty vehicles}">
        <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:12px;">
            <c:forEach items="${vehicles}" var="vehicle">
                <a href="${pageContext.request.contextPath}/vehicles/maintenance?action=list&vehicleId=${vehicle.vehicleId}"
                   style="text-decoration:none; color:inherit; border:1px solid ${selectedVehicle.vehicleId == vehicle.vehicleId ? 'var(--primary)' : 'var(--outline-variant)'}; border-radius:var(--radius-md); padding:14px; ${selectedVehicle.vehicleId == vehicle.vehicleId ? 'background:var(--surface-container-low);' : 'background:var(--surface);'}">
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
                        <div style="font-weight:600; color:var(--primary);">${vehicle.brand} ${vehicle.model}</div>
                        <c:if test="${vehicle.status == 'MAINTENANCE'}"><span class="bk-badge bk-badge-pending" style="flex-shrink:0;"><span class="bk-badge-dot"></span> Đang bảo trì</span></c:if>
                        <c:if test="${vehicle.status == 'AVAILABLE'}"><span class="bk-badge bk-badge-completed" style="flex-shrink:0;"><span class="bk-badge-dot"></span> Có sẵn</span></c:if>
                    </div>
                    <div style="font-size:13px; color:var(--on-surface-variant); margin-top:4px;">Biển số: ${vehicle.licensePlate}</div>
                    <div style="font-size:13px; color:var(--on-surface-variant);">Năm: ${vehicle.year}</div>
                </a>
            </c:forEach>
        </div>
    </c:if>
</div>

<c:if test="${not empty selectedVehicle}">
    <div class="bk-card" style="margin-bottom:24px;">
        <div class="bk-card-title">
            <span class="material-symbols-outlined">build</span> Ghi Nhận Bảo Trì — ${selectedVehicle.brand} ${selectedVehicle.model} (${selectedVehicle.licensePlate})
        </div>
        <form id="maintenanceForm" onsubmit="submitMaintenanceForm(event)">
            <input type="hidden" name="action" value="recordMaintenance">
            <input type="hidden" name="vehicleId" id="vehicleId" value="${selectedVehicle.vehicleId}">

            <div class="bk-form-grid">
                <div class="bk-form-group">
                    <label class="bk-form-label">Loại Bảo Trì *</label>
                    <select name="maintenanceType" class="bk-form-select" required>
                        <option value="">-- Chọn --</option>
                        <option value="OIL_CHANGE">Thay Dầu</option>
                        <option value="TIRE_CHANGE">Thay Lốp</option>
                        <option value="INSPECTION">Kiểm Tra</option>
                        <option value="REPAIR">Sửa Chữa</option>
                        <option value="INSURANCE">Bảo Hiểm</option>
                        <option value="OTHER">Khác</option>
                    </select>
                </div>

                <div class="bk-form-group">
                    <label class="bk-form-label">Ngày Bảo Trì *</label>
                    <input type="date" name="scheduledDate" class="bk-form-input" style="padding-left:12px;" required>
                </div>

                <div class="bk-form-group full">
                    <label class="bk-form-label">Mô Tả *</label>
                    <textarea name="description" class="bk-form-textarea" required placeholder="Nhập mô tả chi tiết..."></textarea>
                </div>

                <div class="bk-form-group">
                    <label class="bk-form-label">Chi Phí (VNĐ)</label>
                    <input type="number" name="cost" class="bk-form-input" style="padding-left:12px;" placeholder="0" min="0">
                </div>

                <div class="bk-form-group full">
                    <label class="bk-form-label">Ghi Chú</label>
                    <textarea name="notes" class="bk-form-textarea" placeholder="Nhập ghi chú thêm..."></textarea>
                </div>
            </div>

            <div class="bk-form-actions">
                <button type="submit" class="bk-btn bk-btn-primary">
                    <span class="material-symbols-outlined" style="font-size:18px;">save</span> Lưu Bản Ghi
                </button>
            </div>
        </form>
    </div>

    <div class="bk-table-container">
        <div class="bk-card-title" style="padding:16px 16px 0;">
            <span class="material-symbols-outlined">history</span> Lịch Sử Bảo Trì
        </div>

        <c:if test="${empty maintenanceList}">
            <div class="bk-empty">
                <span class="material-symbols-outlined">event_busy</span>
                <h3>Chưa có lịch sử bảo trì</h3>
                <p>Xe này chưa có bản ghi bảo trì nào.</p>
            </div>
        </c:if>

        <c:if test="${not empty maintenanceList}">
            <div style="padding:16px 16px 0; position:relative; max-width:320px;">
                <span class="material-symbols-outlined" style="position:absolute; left:26px; top:50%; transform:translateY(-50%); font-size:18px; color:var(--text-secondary);">search</span>
                <input type="text" id="maintHistorySearchInput" placeholder="Tìm theo loại, mô tả, trạng thái..." oninput="filterMaintHistoryTable()"
                       style="width:100%; padding:8px 12px 8px 36px; border-radius:8px; border:1px solid var(--outline-variant); font-size:13px; box-sizing:border-box;">
            </div>
            <div style="overflow-x:auto;" id="maintHistoryTableContainer">
                <table class="bk-table" id="maintHistoryTable">
                    <thead>
                        <tr>
                            <th>Loại Bảo Trì</th>
                            <th>Mô Tả</th>
                            <th>Ngày</th>
                            <th>Chi Phí</th>
                            <th>Trạng Thái</th>
                            <th>Tạo Lúc</th>
                            <th style="text-align:right;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${maintenanceList}" var="m">
                            <tr class="maint-history-row" data-search="${fn:toLowerCase(m.maintenanceType)} ${fn:toLowerCase(m.description)} ${fn:toLowerCase(m.status)}">
                                <td>
                                    <c:choose>
                                        <c:when test="${m.maintenanceType == 'OIL_CHANGE'}">Thay Dầu</c:when>
                                        <c:when test="${m.maintenanceType == 'TIRE_CHANGE'}">Thay Lốp</c:when>
                                        <c:when test="${m.maintenanceType == 'INSPECTION'}">Kiểm Tra</c:when>
                                        <c:when test="${m.maintenanceType == 'REPAIR'}">Sửa Chữa</c:when>
                                        <c:when test="${m.maintenanceType == 'INSURANCE'}">Bảo Hiểm</c:when>
                                        <c:otherwise>Khác</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="sub">${m.description}</td>
                                <td>${m.scheduledDate}</td>
                                <td>${m.cost > 0 ? m.cost : '-'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${m.status == 'SCHEDULED'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Đã lên lịch</span></c:when>
                                        <c:when test="${m.status == 'IN_PROGRESS'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang thực hiện</span></c:when>
                                        <c:when test="${m.status == 'COMPLETED'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span></c:when>
                                        <c:when test="${m.status == 'CANCELLED'}"><span class="bk-badge bk-badge-cancelled"><span class="bk-badge-dot"></span> Đã hủy</span></c:when>
                                        <c:otherwise><span class="bk-badge">${m.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${m.createdAt}</td>
                                <td style="text-align:right;">
                                    <div style="display:inline-flex; gap:6px;">
                                        <c:if test="${m.status == 'SCHEDULED'}">
                                            <button onclick="updateMaintenanceStatus(${m.maintenanceId}, 'IN_PROGRESS')" class="bk-btn bk-btn-sm bk-btn-outline">Bắt đầu sửa</button>
                                            <button onclick="updateMaintenanceStatus(${m.maintenanceId}, 'CANCELLED')" class="bk-btn bk-btn-sm bk-btn-danger">Hủy</button>
                                        </c:if>
                                        <c:if test="${m.status == 'IN_PROGRESS'}">
                                            <button onclick="updateMaintenanceStatus(${m.maintenanceId}, 'COMPLETED')" class="bk-btn bk-btn-sm bk-btn-success">Xác nhận hoàn tất</button>
                                            <button onclick="updateMaintenanceStatus(${m.maintenanceId}, 'CANCELLED')" class="bk-btn bk-btn-sm bk-btn-danger">Hủy</button>
                                        </c:if>
                                        <c:if test="${m.status == 'COMPLETED' || m.status == 'CANCELLED'}">
                                            <span style="font-size:12px; color:var(--on-surface-variant);">—</span>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            <div id="maintHistoryEmptyState" style="display:none; text-align:center; padding:24px; color:var(--text-secondary);">
                Không tìm thấy bản ghi bảo trì phù hợp.
            </div>
            <div style="display:flex; justify-content:space-between; align-items:center; padding:16px; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                <div style="font-size:13px; color:var(--text-secondary);">
                    Hiển thị <span id="maintHistPagStart" style="font-weight:600;">0</span> đến <span id="maintHistPagEnd" style="font-weight:600;">0</span> trong số <span id="maintHistPagTotal" style="font-weight:600;">0</span> bản ghi
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <label style="font-size:13px; color:var(--text-secondary);">Số dòng:</label>
                    <select id="maintHistPageSizeSelect" onchange="changeMaintHistPageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--text-primary); font-size:13px; outline:none; cursor:pointer;">
                        <option value="5" selected="selected">5</option>
                        <option value="10">10</option>
                        <option value="20">20</option>
                        <option value="9999">Tất cả</option>
                    </select>
                    <div id="maintHistPaginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;"></div>
                </div>
            </div>
        </c:if>
    </div>
</c:if>

<script>
let maintHistCurrentPage = 1;
let maintHistPageSize = 5;
let maintHistFilteredRows = [];

function filterMaintHistoryTable() {
    const keyword = document.getElementById('maintHistorySearchInput').value.trim().toLowerCase();
    const allRows = Array.from(document.querySelectorAll('#maintHistoryTable tbody tr'));
    maintHistFilteredRows = allRows.filter(row => (row.getAttribute('data-search') || '').indexOf(keyword) !== -1);
    maintHistCurrentPage = 1;
    applyMaintHistPagination();
}

function changeMaintHistPageSize() {
    maintHistPageSize = parseInt(document.getElementById('maintHistPageSizeSelect').value);
    maintHistCurrentPage = 1;
    applyMaintHistPagination();
}

function applyMaintHistPagination() {
    const allRows = Array.from(document.querySelectorAll('#maintHistoryTable tbody tr'));
    allRows.forEach(row => row.style.display = 'none');

    const totalItems = maintHistFilteredRows.length;
    const totalPages = Math.max(1, Math.ceil(totalItems / maintHistPageSize));
    if (maintHistCurrentPage > totalPages) maintHistCurrentPage = totalPages;

    const start = (maintHistCurrentPage - 1) * maintHistPageSize;
    const end = Math.min(start + maintHistPageSize, totalItems);
    maintHistFilteredRows.slice(start, end).forEach(row => row.style.display = '');

    document.getElementById('maintHistPagStart').textContent = totalItems === 0 ? 0 : start + 1;
    document.getElementById('maintHistPagEnd').textContent = end;
    document.getElementById('maintHistPagTotal').textContent = totalItems;

    document.getElementById('maintHistoryTableContainer').style.display = totalItems === 0 ? 'none' : '';
    document.getElementById('maintHistoryEmptyState').style.display = totalItems === 0 ? '' : 'none';

    renderMaintHistPaginationButtons(totalPages);
}

function renderMaintHistPaginationButtons(totalPages) {
    const container = document.getElementById('maintHistPaginationButtons');
    container.innerHTML = '';

    const makeBtn = (label, page, disabled, active) => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.textContent = label;
        btn.disabled = disabled;
        btn.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid var(--outline-variant); background:' + (active ? 'var(--primary)' : 'var(--surface)') + '; color:' + (active ? '#fff' : 'var(--text-primary)') + '; font-size:12px; cursor:' + (disabled ? 'not-allowed' : 'pointer') + '; opacity:' + (disabled ? '0.5' : '1') + ';';
        btn.onclick = () => { maintHistCurrentPage = page; applyMaintHistPagination(); };
        return btn;
    };

    container.appendChild(makeBtn('«', maintHistCurrentPage - 1, maintHistCurrentPage <= 1, false));
    for (let p = 1; p <= totalPages; p++) {
        container.appendChild(makeBtn(String(p), p, false, p === maintHistCurrentPage));
    }
    container.appendChild(makeBtn('»', maintHistCurrentPage + 1, maintHistCurrentPage >= totalPages, false));
}

document.addEventListener('DOMContentLoaded', function() {
    const table = document.getElementById('maintHistoryTable');
    if (table) {
        maintHistFilteredRows = Array.from(table.querySelectorAll('tbody tr'));
        applyMaintHistPagination();
    }
});

function submitMaintenanceForm(event) {
    event.preventDefault();
    const formData = new FormData(document.getElementById('maintenanceForm'));

    fetch('${pageContext.request.contextPath}/vehicles/maintenance', {
        method: 'POST',
        body: new URLSearchParams(formData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message);
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    })
    .catch(error => alert('Lỗi: ' + error));
}

function updateMaintenanceStatus(maintenanceId, newStatus) {
    const confirmMessages = {
        'IN_PROGRESS': 'Xác nhận xe đã được gửi đi sửa chữa / bắt đầu bảo trì?',
        'COMPLETED': 'Xác nhận đã kiểm tra xe, hóa đơn và các hạng mục sửa chữa đạt yêu cầu? Xe sẽ chuyển lại trạng thái Có sẵn.',
        'CANCELLED': 'Xác nhận hủy lịch bảo trì này?'
    };
    if (!confirm(confirmMessages[newStatus] || 'Xác nhận cập nhật trạng thái?')) {
        return;
    }

    fetch('${pageContext.request.contextPath}/vehicles/maintenance', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=updateStatus&maintenanceId=' + maintenanceId + '&status=' + newStatus
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message);
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    })
    .catch(error => alert('Lỗi: ' + error));
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
