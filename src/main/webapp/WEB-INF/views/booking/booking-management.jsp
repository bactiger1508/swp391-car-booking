<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Đặt Xe"/>
</jsp:include>

<c:if test="${not empty success}">
    <div class="bk-alert bk-alert-success" data-auto-dismiss>
        <span class="material-symbols-outlined">check_circle</span> ${success}
    </div>
</c:if>

<%-- Page Header --%>
<div class="bk-page-header">
    <div>
        <h2>Quản lý Đặt xe</h2>
        <p>Quản lý tất cả các đặt chỗ mới và đang hoạt động.</p>
    </div>
    <div style="display:flex;gap:12px;">
        <c:if test="${not empty currentFilter}">
            <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-btn bk-btn-outline bk-btn-sm">
                <span class="material-symbols-outlined">filter_list_off</span> Xóa bộ lọc
            </a>
        </c:if>
        <a href="${pageContext.request.contextPath}/bookings/create" class="bk-btn bk-btn-primary">
            <span class="material-symbols-outlined">add</span> Đặt xe mới
        </a>
    </div>
</div>

<%-- Stats Grid --%>
<div class="bk-stats-grid">
    <div id="card-stat-PENDING" class="bk-stat-card" onclick="filterByStatus('PENDING')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Chờ Duyệt</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${pendingCount != null ? pendingCount : 0}</span>
        </div>
    </div>
    <div id="card-stat-CONFIRMED" class="bk-stat-card" onclick="filterByStatus('CONFIRMED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đã Xác Nhận</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${confirmedCount != null ? confirmedCount : 0}</span>
        </div>
    </div>
    <div id="card-stat-IN_PROGRESS" class="bk-stat-card" onclick="filterByStatus('IN_PROGRESS')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đang Cho Thuê</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${inProgressCount != null ? inProgressCount : 0}</span>
        </div>
    </div>
    <div id="card-stat-COMPLETED" class="bk-stat-card" onclick="filterByStatus('COMPLETED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Hoàn Tất</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${completedCount != null ? completedCount : 0}</span>
        </div>
    </div>
</div>

<%-- Data Table --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar" style="display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom: 20px;">
        <div class="bk-table-search" style="flex: 1; min-width: 250px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm theo Mã, Khách hàng, hoặc Xe..." oninput="filterTable()">
        </div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; background: var(--surface-variant); padding: 4px; border-radius: 8px; border: 1px solid var(--outline-variant);">
            <button onclick="filterByStatus('ALL')" id="btn-filter-ALL" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Tất cả
            </button>
            <button onclick="filterByStatus('PENDING')" id="btn-filter-PENDING" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Chờ duyệt
            </button>
            <button onclick="filterByStatus('CONFIRMED')" id="btn-filter-CONFIRMED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đã xác nhận
            </button>
            <button onclick="filterByStatus('IN_PROGRESS')" id="btn-filter-IN_PROGRESS" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đang thuê
            </button>
            <button onclick="filterByStatus('COMPLETED')" id="btn-filter-COMPLETED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Hoàn tất
            </button>
            <button onclick="filterByStatus('REJECTED')" id="btn-filter-REJECTED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Từ chối
            </button>
            <button onclick="filterByStatus('CANCELLED')" id="btn-filter-CANCELLED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đã hủy
            </button>
        </div>
    </div>

    <c:if test="${not empty bookings}">
        <div style="overflow-x:auto;" id="bookingTableContainer">
            <table class="bk-table" id="bookingTable">
                <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Khách hàng</th>
                        <th>Xe</th>
                        <th>Ngày</th>
                        <th>Trạng thái</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr data-status="${b.status}">
                            <td class="code">BK-${b.bookingId}</td>
                            <td>
                                <c:if test="${not empty userMap[b.customerId]}">
                                    <div style="font-weight:600;">${userMap[b.customerId].fullName}</div>
                                    <div class="sub" style="font-size:11px; color:var(--on-surface-variant);">${userMap[b.customerId].email}</div>
                                </c:if>
                                <c:if test="${empty userMap[b.customerId]}">User #${b.customerId}</c:if>
                            </td>
                            <td>
                                <c:if test="${not empty carMap[b.carId]}">
                                    <div style="font-weight:600;">${carMap[b.carId].brand} ${carMap[b.carId].model}</div>
                                    <div class="sub" style="font-size:11px; color:var(--on-surface-variant);">${carMap[b.carId].licensePlate}</div>
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
                                    <c:when test="${b.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ duyệt</span></c:when>
                                    <c:when test="${b.status == 'CONFIRMED'}"><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đã xác nhận</span></c:when>
                                    <c:when test="${b.status == 'IN_PROGRESS'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang thuê</span></c:when>
                                    <c:when test="${b.status == 'COMPLETED'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span></c:when>
                                    <c:when test="${b.status == 'REJECTED'}"><span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Đã từ chối</span></c:when>
                                    <c:when test="${b.status == 'CANCELLED'}"><span class="bk-badge bk-badge-cancelled"><span class="bk-badge-dot"></span> Đã hủy</span></c:when>
                                    <c:otherwise><span class="bk-badge">${b.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-right">
                                <div style="display:flex;justify-content:flex-end;gap:6px;">
                                    <c:if test="${b.status == 'CONFIRMED'}">
                                        <a href="${pageContext.request.contextPath}/handovers/create?bookingId=${b.bookingId}&carId=${b.carId}" class="bk-btn bk-btn-sm bk-btn-primary" style="background:#2E7D32; border-color:#2E7D32; color:#fff;">Giao xe</a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" class="bk-btn bk-btn-outline bk-btn-sm">Xem</a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>

    <div class="bk-empty" id="emptyStateMessage" style="display:none; padding: 40px 20px; text-align: center;">
        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--on-surface-variant); margin-bottom: 12px;">inbox</span>
        <h3 style="font-size: 18px; font-weight:700; color: var(--on-surface);">Không tìm thấy đơn đặt xe</h3>
        <p style="color: var(--on-surface-variant); margin-top: 4px; font-size: 13px;">Không có dữ liệu đặt xe nào khớp với trạng thái hoặc từ khóa tìm kiếm được chọn.</p>
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
    
    // Highlight the selected Stat Card with a premium glowing border
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

// Automatically apply filters on load if deep-linked via status parameter
window.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const statusParam = urlParams.get('status');
    if (statusParam && ['PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','REJECTED','CANCELLED'].includes(statusParam)) {
        filterByStatus(statusParam);
    } else {
        filterByStatus('ALL');
    }
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
