<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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

    <c:if test="${empty cars}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">directions_car</span>
            <h3>Không có xe nào trong hệ thống</h3>
        </div>
    </c:if>

    <c:if test="${not empty cars}">
        <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:12px;">
            <c:forEach items="${cars}" var="car">
                <a href="${pageContext.request.contextPath}/vehicles/maintenance?action=list&carId=${car.carId}"
                   style="text-decoration:none; color:inherit; border:1px solid ${selectedCar.carId == car.carId ? 'var(--primary)' : 'var(--outline-variant)'}; border-radius:var(--radius-md); padding:14px; ${selectedCar.carId == car.carId ? 'background:var(--surface-container-low);' : 'background:var(--surface);'}">
                    <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
                        <div style="font-weight:600; color:var(--primary);">${car.brand} ${car.model}</div>
                        <c:if test="${car.status == 'MAINTENANCE'}"><span class="bk-badge bk-badge-pending" style="flex-shrink:0;"><span class="bk-badge-dot"></span> Đang bảo trì</span></c:if>
                        <c:if test="${car.status == 'AVAILABLE'}"><span class="bk-badge bk-badge-completed" style="flex-shrink:0;"><span class="bk-badge-dot"></span> Có sẵn</span></c:if>
                    </div>
                    <div style="font-size:13px; color:var(--on-surface-variant); margin-top:4px;">Biển số: ${car.licensePlate}</div>
                    <div style="font-size:13px; color:var(--on-surface-variant);">Năm: ${car.year}</div>
                </a>
            </c:forEach>
        </div>
    </c:if>
</div>

<c:if test="${not empty selectedCar}">
    <div class="bk-card" style="margin-bottom:24px;">
        <div class="bk-card-title">
            <span class="material-symbols-outlined">build</span> Ghi Nhận Bảo Trì — ${selectedCar.brand} ${selectedCar.model} (${selectedCar.licensePlate})
        </div>
        <form id="maintenanceForm" onsubmit="submitMaintenanceForm(event)">
            <input type="hidden" name="action" value="recordMaintenance">
            <input type="hidden" name="carId" id="carId" value="${selectedCar.carId}">

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
            <div style="overflow-x:auto;">
                <table class="bk-table">
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
                            <tr>
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
        </c:if>
    </div>
</c:if>

<script>
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
