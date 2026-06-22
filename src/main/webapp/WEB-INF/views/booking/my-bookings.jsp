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

            <!-- Phân trang -->
            <div class="bk-pagination-container" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                <div style="font-size:13px; color:var(--on-surface-variant);">
                    Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> bản ghi
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <label style="font-size:13px; color:var(--on-surface-variant);">Số hàng:</label>
                    <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                        <option value="5">5</option>
                        <option value="10" selected="selected">10</option>
                        <option value="20">20</option>
                        <option value="50">50</option>
                    </select>
                    <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;">
                        <!-- nút chuyển trang -->
                    </div>
                </div>
            </div>
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
let currentPage = 1;
let pageSize = 10;
let filteredRows = [];

function changePageSize() {
    pageSize = parseInt(document.getElementById('pageSizeSelect').value);
    currentPage = 1;
    applyPagination();
}

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
    filteredRows = [];
    
    rows.forEach(row => {
        const rowStatus = row.getAttribute('data-status');
        const text = row.textContent.toLowerCase();
        
        const matchesStatus = (currentStatusFilter === 'ALL' || rowStatus === currentStatusFilter);
        const matchesSearch = text.includes(input);
        
        if (matchesStatus && matchesSearch) {
            filteredRows.push(row);
        } else {
            row.style.display = 'none';
        }
    });
    
    currentPage = 1;
    applyPagination();
}

function applyPagination() {
    const totalRows = filteredRows.length;
    const totalPages = Math.ceil(totalRows / pageSize) || 1;
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    // Hide all rows first, then show only the active page's rows
    const allRows = document.querySelectorAll('#bookingTable tbody tr');
    allRows.forEach(row => row.style.display = 'none');
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalRows);
    
    for (let i = startIdx; i < endIdx; i++) {
        filteredRows[i].style.display = '';
    }
    
    // Update labels
    const startDisplay = document.getElementById('pag-start');
    const endDisplay = document.getElementById('pag-end');
    const totalDisplay = document.getElementById('pag-total');
    if (startDisplay) startDisplay.innerText = totalRows > 0 ? (startIdx + 1) : 0;
    if (endDisplay) endDisplay.innerText = endIdx;
    if (totalDisplay) totalDisplay.innerText = totalRows;
    
    // Render pagination buttons
    const btnContainer = document.getElementById('paginationButtons');
    if (btnContainer) {
        btnContainer.innerHTML = '';
        
        // Prev button
        const prevBtn = document.createElement('button');
        prevBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        prevBtn.style.padding = '4px 8px';
        prevBtn.style.border = '1px solid var(--outline-variant)';
        prevBtn.style.borderRadius = '6px';
        prevBtn.style.cursor = 'pointer';
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_left</span>';
        prevBtn.onclick = () => { currentPage--; applyPagination(); };
        btnContainer.appendChild(prevBtn);
        
        // Page numbers
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }
        
        for (let p = startPage; p <= endPage; p++) {
            const pageBtn = document.createElement('button');
            pageBtn.className = p === currentPage ? 'bk-btn bk-btn-sm bk-btn-primary' : 'bk-btn bk-btn-sm bk-btn-outline';
            pageBtn.style.padding = '4px 10px';
            pageBtn.style.minWidth = '28px';
            pageBtn.style.borderRadius = '6px';
            pageBtn.style.cursor = 'pointer';
            pageBtn.style.fontWeight = '600';
            pageBtn.style.fontSize = '12px';
            if (p === currentPage) {
                pageBtn.style.background = 'var(--primary)';
                pageBtn.style.color = 'var(--on-primary)';
                pageBtn.style.border = 'none';
            } else {
                pageBtn.style.border = '1px solid var(--outline-variant)';
            }
            pageBtn.innerText = p;
            pageBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pageBtn);
        }
        
        // Next button
        const nextBtn = document.createElement('button');
        nextBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        nextBtn.style.padding = '4px 8px';
        nextBtn.style.border = '1px solid var(--outline-variant)';
        nextBtn.style.borderRadius = '6px';
        nextBtn.style.cursor = 'pointer';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_right</span>';
        nextBtn.onclick = () => { currentPage++; applyPagination(); };
        btnContainer.appendChild(nextBtn);
    }
    
    const tableContainer = document.getElementById('bookingTableContainer');
    const emptyState = document.getElementById('emptyStateMessage');
    
    if (totalRows === 0) {
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
    const statPending = document.getElementById('statPending');
    const statConfirmed = document.getElementById('statConfirmed');
    const statCompleted = document.getElementById('statCompleted');
    if (statPending) statPending.textContent = p;
    if (statConfirmed) statConfirmed.textContent = c;
    if (statCompleted) statCompleted.textContent = d;
    
    filterByStatus('ALL');
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
