<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    request.setAttribute("monthFormatter", java.time.format.DateTimeFormatter.ofPattern("dd 'Thg' MM, yyyy"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="${sessionScope.currentUser.role == 'CUSTOMER' ? 'Hợp đồng của tôi' : 'Quản lý Hợp đồng'}"/>
</jsp:include>

<%-- Page Header --%>
<div class="bk-page-header">
    <div class="bk-page-header-text">
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">${sessionScope.currentUser.role == 'CUSTOMER' ? 'Hợp đồng của tôi' : 'Quản lý Hợp đồng'}</span>
        </div>
        <h2>${sessionScope.currentUser.role == 'CUSTOMER' ? 'Hợp đồng của tôi' : 'Quản lý Hợp đồng'}</h2>
        <p>Xem và quản lý tất cả các hợp đồng thuê xe đang hoạt động, chờ xử lý và đã hoàn thành.</p>
    </div>
    
    <div style="display: flex; gap: 12px; align-items: center;">
        <button type="button" class="bk-btn bk-btn-outline" onclick="window.print()" style="height: 40px;">
            <span class="material-symbols-outlined">download</span> Xuất PDF
        </button>
        <c:if test="${sessionScope.currentUser.role != 'CUSTOMER'}">
            <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-btn bk-btn-primary" style="height: 40px;">
                <span class="material-symbols-outlined">add</span> Tạo Hợp đồng
            </a>
        </c:if>
    </div>
</div>

<%-- Search and Filtering Container (Image 1 Format) --%>
<div class="bk-card" style="padding: 20px; margin-bottom: 24px;">
    <div class="bk-form-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)) 120px; gap: 16px; align-items: flex-end;">
        <%-- Trạng thái --%>
        <div class="bk-form-group">
            <label class="bk-form-label" style="font-weight:600; font-size:12px; margin-bottom:6px;">Trạng thái</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">filter_list</span>
                <select id="filterStatus" class="bk-form-select" onchange="applyFilters()" style="padding-left: 40px;">
                    <option value="">Tất cả trạng thái</option>
                    <option value="ACTIVE">Hoạt động</option>
                    <option value="DRAFT">Chờ ký</option>
                    <option value="COMPLETED">Đã hoàn thành</option>
                    <option value="CANCELLED">Đã hủy</option>
                </select>
            </div>
        </div>

        <%-- Khoảng thời gian --%>
        <div class="bk-form-group">
            <label class="bk-form-label" style="font-weight:600; font-size:12px; margin-bottom:6px;">Khoảng thời gian</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">calendar_today</span>
                <input type="date" id="filterDate" class="bk-form-input" onchange="applyFilters()" style="padding-left: 40px;">
            </div>
        </div>

        <%-- Hạng xe --%>
        <div class="bk-form-group">
            <label class="bk-form-label" style="font-weight:600; font-size:12px; margin-bottom:6px;">Hạng xe</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">directions_car</span>
                <select id="filterClass" class="bk-form-select" onchange="applyFilters()" style="padding-left: 40px;">
                    <option value="">Tất cả các hạng</option>
                    <option value="Sedan">Sedan</option>
                    <option value="SUV">SUV</option>
                    <option value="Hạng sang">Hạng sang</option>
                    <option value="Phổ thông">Phổ thông</option>
                </select>
            </div>
        </div>

        <%-- Clear Filter Button --%>
        <div class="bk-form-group" style="justify-content: flex-end;">
            <button type="button" class="bk-btn bk-btn-outline" onclick="clearFilters()" style="width:100%; height:40px; justify-content:center;">
                Xóa Bộ lọc
            </button>
        </div>
    </div>
</div>

<%-- Contracts Data Table (Image 1 Style) --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar" style="display:flex; justify-content:space-between; align-items:center; padding: 16px;">
        <div class="bk-table-search" style="width: 320px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm hợp đồng, khách hàng, xe..." oninput="applyFilters()">
        </div>
    </div>

    <c:if test="${not empty contracts}">
        <div style="overflow-x: auto;">
            <table class="bk-table" id="contractTable" style="width:100%; border-collapse: collapse;">
                <thead>
                    <tr style="background: var(--surface-container-low); border-bottom: 1px solid var(--outline-variant);">
                        <th style="padding: 16px 20px;">Mã Hợp đồng</th>
                        <th style="padding: 16px 20px;">Mã Đặt xe</th>
                        <th style="padding: 16px 20px;">Khách hàng</th>
                        <th style="padding: 16px 20px;">Xe</th>
                        <th style="padding: 16px 20px;">Ngày</th>
                        <th style="padding: 16px 20px;">Trạng thái</th>
                        <th style="padding: 16px 20px; text-align: right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${contracts}">
                        <c:set var="cust" value="${userMap[c.customerId]}"/>
                        <c:set var="carItem" value="${carMap[c.carId]}"/>
                        
                        <%-- Calculate rental days --%>
                        <c:set var="days" value="1"/>
                        <c:if test="${c.startDate != null && c.endDate != null}">
                            <c:set var="days" value="${java.time.temporal.ChronoUnit.DAYS.between(c.startDate.toLocalDate(), c.endDate.toLocalDate())}"/>
                            <c:if test="${days < 1}"><c:set var="days" value="1"/></c:if>
                        </c:if>

                        <tr data-status="${c.status}" 
                            data-carclass="${carItem != null ? (carItem.seats >= 7 ? 'SUV' : (carItem.dailyRate > 1500000 ? 'Hạng sang' : 'Sedan')) : 'Phổ thông'}"
                            data-startdate="${c.startDate != null ? c.startDate.toLocalDate().toString() : ''}"
                            data-enddate="${c.endDate != null ? c.endDate.toLocalDate().toString() : ''}"
                            style="border-bottom: 1px solid var(--outline-variant); height: 80px;">
                            
                            <%-- Contract Number --%>
                            <td class="code" style="padding: 16px 20px; font-weight: 700; color: var(--primary);">
                                <a href="${pageContext.request.contextPath}/contracts/detail?id=${c.contractId}" style="text-decoration:none; color:var(--primary); font-size:16px;">
                                    ${c.contractNumber}
                                </a>
                            </td>
                            
                            <%-- Booking Number --%>
                            <td style="padding: 16px 20px; font-weight: 500; color: var(--text-secondary);">
                                <a href="${pageContext.request.contextPath}/bookings/detail?id=${c.bookingId}" style="text-decoration:none; color:var(--text-secondary);">
                                    BKG-${c.bookingId}
                                </a>
                            </td>
                            
                            <%-- Customer Details with Avatar (Image 1 Style) --%>
                            <td style="padding: 16px 20px;">
                                <div style="display:flex; align-items:center; gap:12px;">
                                    <div style="width:36px; height:36px; border-radius:50%; background: #D0E1FB; color:#041638; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:13px;">
                                        ${fn:substring(cust != null ? cust.fullName : 'Hệ thống', 0, 2)}
                                    </div>
                                    <div style="text-align: left;">
                                        <div style="font-weight: 700; color: var(--text-primary); font-size: 14px;">
                                            ${cust != null ? cust.fullName : 'Hệ thống'}
                                        </div>
                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 2px;">
                                            <c:choose>
                                                <c:when test="${cust != null && cust.role == 'CUSTOMER'}">Bán lẻ</c:when>
                                                <c:when test="${cust != null && cust.role == 'ADMIN'}">Quản trị viên</c:when>
                                                <c:otherwise>TK Doanh nghiệp</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            
                            <%-- Car Details --%>
                            <td style="padding: 16px 20px; text-align: left;">
                                <div style="font-weight: 700; color: var(--text-primary); font-size: 14px;">
                                    ${carItem != null ? carItem.brand : 'Không rõ'} ${carItem != null ? carItem.model : 'phương tiện'}
                                </div>
                                <div style="font-size: 11px; color: var(--text-secondary); margin-top: 2px;">
                                    <c:choose>
                                        <c:when test="${carItem != null && carItem.seats >= 7}">SUV</c:when>
                                        <c:when test="${carItem != null && carItem.dailyRate > 1500000}">Hạng sang</c:when>
                                        <c:when test="${carItem != null}">Sedan</c:when>
                                        <c:otherwise>Phổ thông</c:otherwise>
                                    </c:choose>
                                    <c:if test="${carItem != null}"> • ${carItem.licensePlate}</c:if>
                                </div>
                            </td>
                            
                            <%-- Rental Period --%>
                            <td style="padding: 16px 20px; text-align: left;">
                                <div style="font-size: 13px; color: var(--text-primary); font-weight: 500;">
                                    ${c.startDate != null ? c.startDate.format(monthFormatter) : ''} - ${c.endDate != null ? c.endDate.format(monthFormatter) : ''}
                                </div>
                                <div style="font-size: 11px; color: var(--text-secondary); margin-top: 2px;">
                                    ${days} Ngày
                                </div>
                            </td>
                            
                            <%-- Contract Status --%>
                            <td style="padding: 16px 20px;">
                                <c:choose>
                                    <c:when test="${c.status == 'ACTIVE'}">
                                        <span class="bk-badge bk-badge-progress" style="background:#E2F9F3; color:#039C74;"><span class="bk-badge-dot" style="background:#039C74;"></span> Hoạt động</span>
                                    </c:when>
                                    <c:when test="${c.status == 'DRAFT'}">
                                        <span class="bk-badge bk-badge-pending" style="background:#FFF8E5; color:#D9A000;"><span class="bk-badge-dot" style="background:#D9A000;"></span> Chờ ký</span>
                                    </c:when>
                                    <c:when test="${c.status == 'COMPLETED'}">
                                        <span class="bk-badge bk-badge-completed" style="background:#F2F3F5; color:#505F76;"><span class="bk-badge-dot" style="background:#505F76;"></span> Đã hoàn thành</span>
                                    </c:when>
                                    <c:when test="${c.status == 'CANCELLED'}">
                                        <span class="bk-badge bk-badge-rejected" style="background:#FFEBEA; color:#C9392D;"><span class="bk-badge-dot" style="background:#C9392D;"></span> Đã hủy</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="bk-badge">${c.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            
                            <%-- Thao tác Actions --%>
                            <td style="padding: 16px 20px; text-align: right; vertical-align: middle;">
                                <div style="display:flex; justify-content:flex-end; gap:16px; align-items:center;">
                                    <a href="${pageContext.request.contextPath}/contracts/detail?id=${c.contractId}" 
                                       title="Xem hợp đồng" style="color: var(--text-secondary); display:flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size:20px;">visibility</span>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        
        <!-- Phân trang -->
        <div class="bk-pagination-container" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 20px; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
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
    </c:if>
    <c:if test="${empty contracts}">
        <div class="bk-empty" style="padding:80px 20px; text-align:center;">
            <span class="material-symbols-outlined" style="font-size: 48px; opacity: 0.3; margin-bottom: 16px;">description</span>
            <h3 style="font-size:18px; font-weight:700; color:var(--text-primary); margin-bottom:8px;">Chưa có hợp đồng nào</h3>
            <p style="color:var(--text-secondary); font-size:14px;">Không tìm thấy hợp đồng thuê xe nào khớp với tài khoản của bạn.</p>
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

function applyFilters() {
    var search = document.getElementById('searchInput').value.toLowerCase();
    var status = document.getElementById('filterStatus').value;
    var dateVal = document.getElementById('filterDate').value;
    var carClass = document.getElementById('filterClass').value;
    
    var rows = document.querySelectorAll('#contractTable tbody tr');
    filteredRows = [];
    
    rows.forEach(function(row) {
        var rowStatus = row.getAttribute('data-status');
        var rowClass = row.getAttribute('data-carclass');
        var rowStart = row.getAttribute('data-startdate');
        var rowEnd = row.getAttribute('data-enddate');
        var rowText = row.textContent.toLowerCase();
        
        var matchesSearch = rowText.includes(search);
        var matchesStatus = status === "" || rowStatus === status;
        var matchesClass = carClass === "" || rowClass === carClass;
        
        var matchesDate = true;
        if (dateVal !== "") {
            // Check if filter date is between contract start and end dates
            if (rowStart && rowEnd) {
                matchesDate = (dateVal >= rowStart && dateVal <= rowEnd);
            }
        }
        
        if (matchesSearch && matchesStatus && matchesClass && matchesDate) {
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
    
    const allRows = document.querySelectorAll('#contractTable tbody tr');
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
        prevBtn.type = 'button';
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
            if (p < 1) continue;
            const pBtn = document.createElement('button');
            pBtn.type = 'button';
            pBtn.className = p === currentPage ? 'bk-btn bk-btn-sm bk-btn-primary' : 'bk-btn bk-btn-sm bk-btn-outline';
            pBtn.style.padding = '4px 10px';
            pBtn.style.border = '1px solid ' + (p === currentPage ? 'var(--primary)' : 'var(--outline-variant)');
            pBtn.style.borderRadius = '6px';
            pBtn.style.cursor = 'pointer';
            if (p === currentPage) {
                pBtn.style.background = 'var(--primary)';
                pBtn.style.color = 'var(--on-primary)';
            }
            pBtn.innerText = p;
            pBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
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

function clearFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('filterStatus').value = '';
    document.getElementById('filterDate').value = '';
    document.getElementById('filterClass').value = '';
    applyFilters();
}

// Run initial filters and pagination
window.addEventListener('DOMContentLoaded', function() {
    applyFilters();
});
</script>
