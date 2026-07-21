<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@page import="com.swp391.carrental.user.dao.CustomerProfileDAO"%>
<%
    // Khởi tạo nhanh đối tượng DAO để dùng trong vòng lặp c:forEach
    CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    request.setAttribute("profileDAO", profileDAO);
%>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Customer Profile Verification"/>
</jsp:include>

<div class="page-content">
    <div class="card">
        <div class="card-header">
            <h2>Quản lý hồ sơ khách hàng</h2>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/user/customer-profiles" style="display:flex;gap:12px;margin-bottom:20px;">
            <input class="form-control" type="text" name="keyword" value="${param.keyword}" placeholder="Tìm kiếm...">
            <select class="form-control" name="status">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING" ${param.status=='PENDING'?'selected':''}>Chờ xác minh</option>
                <option value="VERIFIED" ${param.status=='VERIFIED'?'selected':''}>Đã xác minh</option>
                <option value="REJECTED" ${param.status=='REJECTED'?'selected':''}>Đã từ chối</option>
            </select>
            <button class="btn btn-primary">Tìm kiếm</button>
        </form>

        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.success=='verified'}">Xác minh hồ sơ thành công.</c:when>
                    <c:otherwise>Từ chối hồ sơ thành công.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên khách hàng</th> <th>Số CCCD / Hộ chiếu</th>
                    <th>Số Giấy phép lái xe</th>
                    <th>Trạng thái</th>
                    <th>Hoạt động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${profiles}" var="p">
                    <tr>
                        <td>${p.profileId}</td>
                        <td>
                            <strong>${profileDAO.getCustomerName(p.userId)}</strong><br>
                            <small class="text-muted">${profileDAO.getCustomerEmail(p.userId)}</small>
                        </td>
                        <td>${p.idCardNumber}</td>
                        <td>${p.driverLicenseNumber}</td>
                        <td>
                            <c:choose>
                                <c:when test="${p.verificationStatus=='PENDING'}">
                                    <span class="badge badge-warning">Chờ xác minh</span>
                                </c:when>
                                <c:when test="${p.verificationStatus=='VERIFIED'}">
                                    <span class="badge badge-success">Đã xác minh</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">Đã từ chối</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a class="btn btn-info" href="${pageContext.request.contextPath}/user/customer-profiles?action=view&id=${p.profileId}&searchStatus=${param.status}&searchKeyword=${param.keyword}">
                                Xem
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <!-- Phân trang -->
        <div class="bk-pagination-container" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 0; border-top:1px solid #ddd; flex-wrap:wrap; gap:12px;">
            <div style="font-size:13px; color:#555;">
                Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> bản ghi
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <label style="font-size:13px; color:#555;">Số hàng:</label>
                <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid #ddd; background:#fff; font-size:13px; outline:none; cursor:pointer;">
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

function applyPagination() {
    const totalRows = filteredRows.length;
    const totalPages = Math.ceil(totalRows / pageSize) || 1;
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    const allRows = document.querySelectorAll('.table tbody tr');
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
        prevBtn.className = 'btn btn-sm btn-outline-secondary';
        prevBtn.style.padding = '4px 8px';
        prevBtn.style.cursor = 'pointer';
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerText = '‹';
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
            pBtn.className = p === currentPage ? 'btn btn-sm btn-primary' : 'btn btn-sm btn-outline-secondary';
            pBtn.style.padding = '4px 10px';
            pBtn.style.cursor = 'pointer';
            pBtn.innerText = p;
            pBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'btn btn-sm btn-outline-secondary';
        nextBtn.style.padding = '4px 8px';
        nextBtn.style.cursor = 'pointer';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerText = '›';
        nextBtn.onclick = () => { currentPage++; applyPagination(); };
        btnContainer.appendChild(nextBtn);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const rows = document.querySelectorAll('.table tbody tr');
    filteredRows = Array.from(rows);
    applyPagination();
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>