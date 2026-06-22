<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý Giao xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Biên bản bàn giao</span>
        </div>
        <h2>Nhật ký Biên bản Bàn giao xe</h2>
        <p>Kiểm soát tình trạng xe (số km, mức nhiên liệu, hư hại ngoại thất/nội thất) trước khi bàn giao chìa khóa cho khách thuê. (BR-06)</p>
    </div>
    <div>
        <a href="${pageContext.request.contextPath}/bookings/manage?status=CONFIRMED" class="bk-btn bk-btn-primary">
            <span class="material-symbols-outlined">add</span> Bàn giao xe mới
        </a>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm biên bản giao xe..." oninput="filterTable()" />
        </div>
    </div>

    <c:if test="${not empty handovers}">
        <div style="overflow-x:auto;">
            <table class="bk-table" id="handoverTable">
                <thead>
                    <tr>
                        <th>Mã BB</th>
                        <th>Đơn thuê xe</th>
                        <th>Mã Xe</th>
                        <th>Ngày bàn giao</th>
                        <th>Số km</th>
                        <th>Mức xăng</th>
                        <th>Tình trạng ngoại thất</th>
                        <th>Nhân viên bàn giao</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="h" items="${handovers}">
                        <tr>
                            <td class="code">HD-${h.handoverId}</td>
                            <td><a href="${pageContext.request.contextPath}/bookings/detail?id=${h.bookingId}" style="font-weight:600;color:var(--primary);">#BK-${h.bookingId}</a></td>
                            <td style="font-weight:500;">Xe #${h.carId}</td>
                            <td>
                                <div style="font-size:13px;">
                                    ${h.handoverDate.dayOfMonth}/${h.handoverDate.monthValue}/${h.handoverDate.year} ${h.handoverDate.hour}:${h.handoverDate.minute}
                                </div>
                            </td>
                            <td><div style="font-weight:600;color:var(--primary);">${h.mileageAtHandover} km</div></td>
                            <td>
                                <span class="bk-badge bk-badge-confirmed" style="background:var(--success-container);color:var(--on-success-container);">
                                    ${h.fuelLevel}
                                </span>
                            </td>
                            <td>
                                <div style="font-size:12px;color:var(--on-surface-variant);max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;" title="${h.exteriorCondition}">
                                    ${not empty h.exteriorCondition ? h.exteriorCondition : 'NULL'}
                                </div>
                            </td>
                            <td>Nhân viên #${h.handedBy}</td>
                            <td>
                                <span class="bk-badge bk-badge-confirmed" style="background:var(--success-container);color:var(--on-success-container);">
                                    ${h.status}
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/handovers/detail?bookingId=${h.bookingId}&carId=${h.carId}" class="bk-btn bk-btn-sm bk-btn-primary">Xem</a>
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
    <c:if test="${empty handovers}">
        <!-- Fallback data to show gorgeous table representation when database is clean -->
        <div style="overflow-x:auto;">
            <table class="bk-table" id="handoverTable">
                <thead>
                    <tr>
                        <th>Mã BB</th>
                        <th>Đơn thuê xe</th>
                        <th>Mã Xe</th>
                        <th>Ngày bàn giao</th>
                        <th>Số km</th>
                        <th>Mức xăng</th>
                        <th>Tình trạng ngoại thất</th>
                        <th>Nhân viên bàn giao</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
            </table>
        </div>
    </c:if>
</div>

<script>
    let currentPage = 1;
    let pageSize = 10;
    let filteredRows = [];

    function changePageSize() {
        pageSize = parseInt(document.getElementById('pageSizeSelect').value);
        currentPage = 1;
        applyPagination();
    }

    function filterTable() {
        const input = document.getElementById('searchInput').value.toLowerCase();
        const rows = document.querySelectorAll('#handoverTable tbody tr');
        filteredRows = [];
        
        rows.forEach(row => {
            if (row.textContent.toLowerCase().includes(input)) {
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
        
        const allRows = document.querySelectorAll('#handoverTable tbody tr');
        allRows.forEach(row => row.style.display = 'none');
        
        const startIdx = (currentPage - 1) * pageSize;
        const endIdx = Math.min(startIdx + pageSize, totalRows);
        
        for (let i = startIdx; i < endIdx; i++) {
            filteredRows[i].style.display = '';
        }
        
        const startDisplay = document.getElementById('pag-start');
        const endDisplay = document.getElementById('pag-end');
        const totalDisplay = document.getElementById('pag-total');
        if (startDisplay) startDisplay.innerText = totalRows > 0 ? (startIdx + 1) : 0;
        if (endDisplay) endDisplay.innerText = endIdx;
        if (totalDisplay) totalDisplay.innerText = totalRows;
        
        const btnContainer = document.getElementById('paginationButtons');
        if (btnContainer) {
            btnContainer.innerHTML = '';
            
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
    }

    document.addEventListener('DOMContentLoaded', () => {
        filterTable();
    });
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
