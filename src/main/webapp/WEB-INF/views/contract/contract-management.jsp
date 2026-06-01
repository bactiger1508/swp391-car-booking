<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý Hợp đồng"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Quản lý hợp đồng</span>
        </div>
        <h2>Danh sách Hợp đồng thuê xe</h2>
        <p>Theo dõi và quản lý các hợp đồng thuê xe pháp lý giữa nhà xe và khách hàng.</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar" style="display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom: 20px;">
        <div class="bk-table-search" style="flex: 1; min-width: 250px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm hợp đồng..." oninput="filterTable()">
        </div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; background: var(--surface-variant); padding: 4px; border-radius: 8px; border: 1px solid var(--outline-variant);">
            <button onclick="filterByStatus('ALL')" id="btn-filter-ALL" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Tất cả
            </button>
            <button onclick="filterByStatus('DRAFT')" id="btn-filter-DRAFT" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Bản nháp
            </button>
            <button onclick="filterByStatus('ACTIVE')" id="btn-filter-ACTIVE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đang hiệu lực
            </button>
            <button onclick="filterByStatus('COMPLETED')" id="btn-filter-COMPLETED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Hoàn tất
            </button>
        </div>
    </div>

    <c:if test="${not empty contracts}">
        <div style="overflow-x:auto;" id="contractTableContainer">
            <table class="bk-table" id="contractTable">
                <thead>
                    <tr>
                        <th>Số Hợp đồng</th>
                        <th>Mã đơn</th>
                        <th>Khách hàng</th>
                        <th>Xe</th>
                        <th>Thời hạn</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${contracts}">
                        <tr data-status="${c.status}">
                            <td class="code">${c.contractNumber}</td>
                            <td><a href="${pageContext.request.contextPath}/bookings/detail?id=${c.bookingId}" style="font-weight:600;color:var(--primary);">#BK-${c.bookingId}</a></td>
                            <td>
                                <c:if test="${not empty userMap[c.customerId]}">
                                    <div>${userMap[c.customerId].fullName}</div>
                                    <div class="sub" style="font-size:11px;color:var(--on-surface-variant);">${userMap[c.customerId].email}</div>
                                </c:if>
                                <c:if test="${empty userMap[c.customerId]}">Khách hàng #${c.customerId}</c:if>
                            </td>
                            <td>
                                <c:if test="${not empty carMap[c.carId]}">
                                    <div>${carMap[c.carId].brand} ${carMap[c.carId].model}</div>
                                    <div class="sub" style="font-size:11px;color:var(--on-surface-variant);">${carMap[c.carId].licensePlate}</div>
                                </c:if>
                                <c:if test="${empty carMap[c.carId]}">Xe #${c.carId}</c:if>
                            </td>
                            <td>
                                <div style="font-size:13px;color:var(--on-surface-variant);">
                                    ${c.startDate.dayOfMonth}/${c.startDate.monthValue}/${c.startDate.year} - ${c.endDate.dayOfMonth}/${c.endDate.monthValue}/${c.endDate.year}
                                </div>
                            </td>
                            <td>
                                <div style="font-weight:600;color:var(--primary);">
                                    <fmt:formatNumber value="${c.totalAmount}" type="number" groupingUsed="true"/>đ
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.status == 'ACTIVE'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang hiệu lực</span></c:when>
                                    <c:when test="${c.status == 'COMPLETED'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span></c:when>
                                    <c:when test="${c.status == 'DRAFT'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Bản nháp</span></c:when>
                                    <c:otherwise><span class="bk-badge">${c.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-right">
                                <a href="${pageContext.request.contextPath}/contracts/detail?id=${c.contractId}" class="bk-btn bk-btn-outline bk-btn-sm">Xem chi tiết</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    
    <div class="bk-empty" id="emptyStateMessage" style="display:none; padding: 40px 20px; text-align: center;">
        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--on-surface-variant); margin-bottom: 12px;">description</span>
        <h3 style="font-size: 18px; font-weight:700; color: var(--on-surface);">Không tìm thấy hợp đồng</h3>
        <p style="color: var(--on-surface-variant); margin-top: 4px; font-size: 13px;">Không có tài liệu hợp đồng nào thỏa mãn bộ lọc hoặc từ khóa tìm kiếm được chọn.</p>
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
    
    filterTable();
}

function filterTable() {
    const input = document.getElementById('searchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#contractTable tbody tr');
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
    
    const tableContainer = document.getElementById('contractTableContainer');
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
    filterByStatus('ALL');
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
