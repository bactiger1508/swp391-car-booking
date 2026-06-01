<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Xe"/>
</jsp:include>

<%-- Calculate dynamic stats --%>
<c:set var="totalCars" value="${cars.size()}"/>
<c:set var="availableCars" value="0"/>
<c:set var="maintenanceCars" value="0"/>
<c:set var="rentedCars" value="0"/>

<c:forEach var="car" items="${cars}">
    <c:choose>
        <c:when test="${car.status == 'AVAILABLE'}"><c:set var="availableCars" value="${availableCars + 1}"/></c:when>
        <c:when test="${car.status == 'MAINTENANCE'}"><c:set var="maintenanceCars" value="${maintenanceCars + 1}"/></c:when>
        <c:when test="${car.status == 'RENTED'}"><c:set var="rentedCars" value="${rentedCars + 1}"/></c:when>
    </c:choose>
</c:forEach>

<div class="bk-page-header">
    <div>
        <h2>Đội Xe</h2>
        <p>Quản lý và giám sát tất cả tài sản của đội xe.</p>
    </div>
    <div style="display: flex; gap: 8px;">
        <a href="${pageContext.request.contextPath}/vehicles/manage?status=MAINTENANCE" class="bk-btn bk-btn-outline">
            <span class="material-symbols-outlined" style="font-size: 18px;">build</span>
            Xe đang bảo trì
        </a>
    </div>
</div>

<%-- Stats/Summary Grid --%>
<div class="bk-stats-grid">
    <div id="card-stat-ALL" class="bk-stat-card" onclick="filterByStatus('ALL')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Tổng Số Xe</span>
        <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${totalCars}</span>
    </div>
    <div id="card-stat-AVAILABLE" class="bk-stat-card" onclick="filterByStatus('AVAILABLE')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #2E7D32;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Có Sẵn</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#2E7D32;">${availableCars}</span>
    </div>
    <div id="card-stat-MAINTENANCE" class="bk-stat-card" onclick="filterByStatus('MAINTENANCE')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #F57C00;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đang Bảo Trì</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#F57C00;">${maintenanceCars}</span>
    </div>
    <div id="card-stat-RENTED" class="bk-stat-card" onclick="filterByStatus('RENTED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #C62828;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đã Thuê / Ra Ngoài</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#C62828;">${rentedCars}</span>
    </div>
</div>

<%-- Data Table Card --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar" style="display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom: 20px;">
        <div class="bk-table-search" style="flex: 1; min-width: 250px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="carSearchInput" placeholder="Tìm kiếm xe, biển số..." oninput="filterCarTable()">
        </div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; background: var(--surface-variant); padding: 4px; border-radius: 8px; border: 1px solid var(--outline-variant);">
            <button onclick="filterByStatus('ALL')" id="btn-filter-ALL" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Tất cả
            </button>
            <button onclick="filterByStatus('AVAILABLE')" id="btn-filter-AVAILABLE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Có sẵn
            </button>
            <button onclick="filterByStatus('RENTED')" id="btn-filter-RENTED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đã thuê
            </button>
            <button onclick="filterByStatus('MAINTENANCE')" id="btn-filter-MAINTENANCE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Bảo trì
            </button>
            <button onclick="filterByStatus('INACTIVE')" id="btn-filter-INACTIVE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Ngưng hoạt động
            </button>
        </div>
    </div>

    <c:if test="${not empty cars}">
        <div style="overflow-x:auto;" id="vehicleTableContainer">
            <table class="bk-table" id="vehicleTable">
                <thead>
                    <tr>
                        <th>Tên Xe</th>
                        <th>Biển Số</th>
                        <th>Giá hàng ngày</th>
                        <th>Tiền cọc (1 ngày)</th>
                        <th style="text-align: center;">Số ghế</th>
                        <th>Trạng Thái</th>
                        <th>Bảo Trì Tiếp Theo</th>
                        <th style="text-align: right;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="car" items="${cars}">
                        <c:set var="maintenance" value="${nextMaintenance[car.carId]}"/>
                        <tr data-status="${car.status}">
                            <td class="font-semibold" style="color: var(--primary);">${car.brand} ${car.model} (${car.year})</td>
                            <td class="font-mono" style="font-weight: 600;">${car.licensePlate}</td>
                            <td class="font-semibold"><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/> VND</td>
                            <td>
                                <fmt:formatNumber value="${depositAmounts[car.carId]}" type="number" groupingUsed="true"/> VND
                                <span style="font-size:11px;color:var(--text-secondary);">(${depositPercentage}%)</span>
                            </td>
                            <td style="text-align: center; font-weight: 600;">${car.seats}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${car.status == 'AVAILABLE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#E8F5E9] text-[#2E7D32]" style="font-size:12px; font-weight:700;">Có Sẵn</span></c:when>
                                    <c:when test="${car.status == 'MAINTENANCE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFF3E0] text-[#EF6C00]" style="font-size:12px; font-weight:700;">Bảo Trì</span></c:when>
                                    <c:when test="${car.status == 'RENTED'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFEBEE] text-[#C62828]" style="font-size:12px; font-weight:700;">Đã Thuê</span></c:when>
                                    <c:otherwise><span class="inline-block px-2.5 py-1 rounded bg-[#ECEFF1] text-[#37474F]" style="font-size:12px; font-weight:700;">Ngưng hoạt động</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty maintenance}">
                                        <span style="font-weight: 600; color: var(--primary);">${maintenance.maintenanceType}</span><br/>
                                        <span style="font-size:12px; color:var(--text-secondary);">
                                            ${maintenance.scheduledDate} &middot; ${maintenance.status}
                                        </span>
                                    </c:when>
                                    <c:when test="${car.status == 'MAINTENANCE'}">
                                        <span style="color:#EF6C00; font-weight: 600;">Đang bảo trì</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--text-secondary);">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 4px; justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="text-primary hover:text-primary-container p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Xem chi tiết" style="display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">visibility</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/maintenance?carId=${car.carId}" class="text-[#F57C00] hover:text-[#E65100] p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Lịch bảo trì" style="display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">build</span>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>

    <div class="bk-empty" id="emptyStateMessage" style="display:none; padding: 40px 20px; text-align: center;">
        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--on-surface-variant); margin-bottom: 12px;">directions_car</span>
        <h3 style="font-size: 18px; font-weight:700; color: var(--on-surface);">Không tìm thấy xe phù hợp</h3>
        <p style="color: var(--on-surface-variant); margin-top: 4px; font-size: 13px;">Không có xe nào khớp với trạng thái hoặc từ khóa tìm kiếm được chọn.</p>
    </div>
</div>

<script>
let currentStatusFilter = 'ALL';

function filterByStatus(status) {
    currentStatusFilter = status;
    
    // Update active class on segmented buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.style.background = 'transparent';
        btn.style.color = 'var(--on-surface-variant)';
        btn.style.boxShadow = 'none';
    });
    
    const activeBtn = document.getElementById('btn-filter-' + status);
    if (activeBtn) {
        activeBtn.style.background = 'var(--primary)';
        activeBtn.style.color = 'var(--on-primary)';
        activeBtn.style.boxShadow = '0 2px 8px rgba(10, 25, 47, 0.15)';
    }
    
    // Highlight selected Stat Card
    document.querySelectorAll('.bk-stat-card').forEach(card => {
        card.style.borderColor = 'var(--outline-variant)';
        card.style.boxShadow = 'none';
        card.style.background = 'var(--surface)';
    });
    
    const activeCard = document.getElementById('card-stat-' + status);
    if (activeCard) {
        activeCard.style.borderColor = 'var(--primary)';
        activeCard.style.boxShadow = '0 6px 20px rgba(10, 25, 47, 0.08)';
        activeCard.style.background = 'var(--surface-variant)';
    }
    
    filterCarTable();
}

function filterCarTable() {
    const input = document.getElementById('carSearchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#vehicleTable tbody tr');
    let visibleCount = 0;
    
    rows.forEach(row => {
        const rowStatus = row.getAttribute('data-status');
        const text = row.textContent.toLowerCase();
        
        const matchesStatus = (currentStatusFilter === 'ALL' || rowStatus === currentStatusFilter);
        const matchesSearch = text.includes(input);
        
        if (matchesStatus && matchesSearch) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    const tableContainer = document.getElementById('vehicleTableContainer');
    const emptyState = document.getElementById('emptyStateMessage');
    
    if (visibleCount === 0) {
        if (tableContainer) tableContainer.style.display = 'none';
        if (emptyState) emptyState.style.display = 'block';
    } else {
        if (tableContainer) tableContainer.style.display = 'block';
        if (emptyState) emptyState.style.display = 'none';
    }
}

// Check on load
window.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const statusParam = urlParams.get('status');
    if (statusParam && ['AVAILABLE','RENTED','MAINTENANCE','INACTIVE'].includes(statusParam)) {
        filterByStatus(statusParam);
    } else {
        filterByStatus('ALL');
    }
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
