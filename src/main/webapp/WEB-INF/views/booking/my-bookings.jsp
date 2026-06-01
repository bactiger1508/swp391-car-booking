<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Đơn Thuê Của Tôi"/>
</jsp:include>

<c:if test="${not empty success}">
    <div class="bk-alert bk-alert-success" data-auto-dismiss>
        <span class="material-symbols-outlined">check_circle</span> ${success}
    </div>
</c:if>

<%-- Page Header --%>
<div class="bk-page-header">
    <div>
        <h2>Đơn thuê của tôi</h2>
        <p>Theo dõi và quản lý lịch sử thuê xe của bạn</p>
    </div>
    <a href="${pageContext.request.contextPath}/bookings/create" class="bk-btn bk-btn-primary">
        <span class="material-symbols-outlined">add</span> Thuê xe mới
    </a>
</div>

<%-- Stats --%>
<div class="bk-stats-grid">
    <div id="card-stat-ALL" class="bk-stat-card" onclick="filterByStatus('ALL')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Tổng số đơn</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${bookings != null ? bookings.size() : 0}</span>
        </div>
    </div>
    <div id="card-stat-PENDING" class="bk-stat-card" onclick="filterByStatus('PENDING')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đang xử lý</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statPending" style="font-size:28px; font-weight:800; color:var(--primary);">0</span>
        </div>
    </div>
    <div id="card-stat-CONFIRMED" class="bk-stat-card" onclick="filterByStatus('CONFIRMED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đã xác nhận</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statConfirmed" style="font-size:28px; font-weight:800; color:var(--primary);">0</span>
        </div>
    </div>
    <div id="card-stat-COMPLETED" class="bk-stat-card" onclick="filterByStatus('COMPLETED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Hoàn tất</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statCompleted" style="font-size:28px; font-weight:800; color:var(--primary);">0</span>
        </div>
    </div>
</div>

<%-- Table --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search" style="flex: 1; min-width: 250px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm mã đơn, tên xe..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty bookings}">
        <div style="overflow-x:auto;" id="bookingTableContainer">
            <table class="bk-table" id="bookingTable">
                <thead>
                    <tr>
                        <th>Mã đặt xe</th>
                        <th>Thông tin xe</th>
                        <th>Thời gian thuê</th>
                        <th>Trạng thái</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr data-status="${b.status}" onclick="window.location='${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}'" style="cursor:pointer;">
                            <td class="code">BK-${b.bookingId}</td>
                            <td>
                                <c:if test="${not empty carMap[b.carId]}">
                                    <div style="font-weight:700;color:var(--on-surface);">${carMap[b.carId].brand} ${carMap[b.carId].model}</div>
                                    <div class="sub">BKS: ${carMap[b.carId].licensePlate}</div>
                                </c:if>
                                <c:if test="${empty carMap[b.carId]}">Xe #${b.carId}</c:if>
                            </td>
                            <td>
                                <div>
                                    <fmt:formatNumber value="${b.startDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${b.startDate.monthValue}" pattern="00"/>
                                    -
                                    <fmt:formatNumber value="${b.endDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${b.endDate.monthValue}" pattern="00"/>/${b.endDate.year}
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${b.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ xử lý</span></c:when>
                                    <c:when test="${b.status == 'CONFIRMED'}"><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đã xác nhận</span></c:when>
                                    <c:when test="${b.status == 'IN_PROGRESS'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang thuê</span></c:when>
                                    <c:when test="${b.status == 'COMPLETED'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span></c:when>
                                    <c:when test="${b.status == 'REJECTED'}"><span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Đã từ chối</span></c:when>
                                    <c:when test="${b.status == 'CANCELLED'}"><span class="bk-badge bk-badge-cancelled"><span class="bk-badge-dot"></span> Đã hủy</span></c:when>
                                    <c:otherwise><span class="bk-badge">${b.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-right">
                                <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" class="bk-btn bk-btn-outline bk-btn-sm" onclick="event.stopPropagation();">
                                    Xem chi tiết <span class="material-symbols-outlined" style="font-size:16px;">chevron_right</span>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>

    <div class="bk-empty" id="emptyStateMessage" style="display:none; padding: 40px 20px; text-align: center;">
        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--on-surface-variant); margin-bottom: 12px;">inbox</span>
        <h3 style="font-size: 18px; font-weight:700; color: var(--on-surface);">Không tìm thấy đơn thuê nào</h3>
        <p style="color: var(--on-surface-variant); margin-top: 4px; font-size: 13px;">Bạn không có đơn đặt xe nào thuộc trạng thái này hoặc khớp với từ khóa tìm kiếm.</p>
    </div>
</div>

<script>
let currentStatusFilter = 'ALL';

function filterByStatus(status) {
    currentStatusFilter = status;
    
    // Highlight the selected Stat Card
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
    
    filterTable();
}

function filterTable() {
    const input = document.getElementById('searchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#bookingTable tbody tr');
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
    
    const tableContainer = document.getElementById('bookingTableContainer');
    const emptyState = document.getElementById('emptyStateMessage');
    
    if (visibleCount === 0) {
        if (tableContainer) tableContainer.style.display = 'none';
        if (emptyState) emptyState.style.display = 'block';
    } else {
        if (tableContainer) tableContainer.style.display = 'block';
        if (emptyState) emptyState.style.display = 'none';
    }
}

// Count stats & check load on DOM load
document.addEventListener('DOMContentLoaded', function() {
    var rows = document.querySelectorAll('#bookingTable tbody tr');
    var p = 0, c = 0, d = 0;
    rows.forEach(function(r) {
        var s = r.getAttribute('data-status');
        if (s === 'PENDING') p++;
        if (s === 'CONFIRMED') c++;
        if (s === 'COMPLETED') d++;
    });
    document.getElementById('statPending').textContent = p;
    document.getElementById('statConfirmed').textContent = c;
    document.getElementById('statCompleted').textContent = d;
    
    filterByStatus('ALL');
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
