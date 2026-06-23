<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Thành Viên"/>
</jsp:include>
<div class="page-content">
    
    <c:if test="${not empty success}">
        <div class="alert alert-success">
            <span class="material-symbols-outlined">check_circle</span>
            ${success}
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <span class="material-symbols-outlined">error</span>
            ${error}
        </div>
    </c:if>

    <div class="bk-booking-grid" id="mainGrid" style="display: grid; grid-template-columns: ${not empty formUser ? '3fr 1fr' : '1fr'}; gap: 24px; align-items: start; transition: grid-template-columns 0.3s ease;">
        
        <%-- LEFT COLUMN: USER LIST TABLE --%>
        <div class="card">
            <div class="card-header" style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <h3>Danh sách thành viên</h3>
                <button class="btn btn-primary" onclick="showAddForm()" style="padding: 10px 20px;">+ Thêm tài khoản</button>
            </div>
            
            <%-- Search & Filter Bar --%>
            <form method="get" action="${pageContext.request.contextPath}/users" style="display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; align-items: center;">
                <input type="text" name="search" class="form-control" placeholder="Tìm kiếm tên, email, sđt..." value="${searchParam}" style="max-width: 260px; padding: 10px 14px;">
                <select name="role" class="form-control" style="max-width: 140px; padding: 10px 14px; cursor: pointer;">
                    <option value="All roles" ${roleParam == 'All roles' ? 'selected' : ''}>Tất cả vai trò</option>
                    <option value="ADMIN" ${roleParam == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                    <option value="STAFF" ${roleParam == 'STAFF' ? 'selected' : ''}>STAFF</option>
                    <option value="CUSTOMER" ${roleParam == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                </select>
                <select name="status" class="form-control" style="max-width: 150px; padding: 10px 14px; cursor: pointer;">
                    <option value="All status" ${statusParam == 'All status' ? 'selected' : ''}>Tất cả trạng thái</option>
                    <option value="Active" ${statusParam == 'Active' ? 'selected' : ''}>Hoạt động</option>
                    <option value="Inactive" ${statusParam == 'Inactive' ? 'selected' : ''}>Bị khóa</option>
                </select>
                <button type="submit" class="btn btn-primary" style="padding: 10px 18px;">Tìm kiếm</button>
                <a href="${pageContext.request.contextPath}/users" class="btn btn-outline" style="padding: 10px 18px;">Reset</a>
            </form>

            <c:if test="${not empty userList}">
                <div class="table-responsive">
                    <table class="table" id="userTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Họ và Tên</th>
                                <th>Email</th>
                                <th>Vai trò</th>
                                <th>Trạng thái</th>
                                <th style="text-align: right;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${userList}">
                                <tr>
                                    <td>${u.userId}</td>
                                    <td><strong>${u.fullName}</strong></td>
                                    <td>${u.email}</td>
                                    <td>
                                        <span class="badge ${u.role == 'ADMIN' ? 'badge-confirmed' : (u.role == 'STAFF' ? 'badge-progress' : 'badge-rented')}">
                                            ${u.role}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${u.active ? 'badge-available' : 'badge-cancelled'}">
                                            ${u.active ? 'Hoạt động' : 'Bị khóa'}
                                        </span>
                                    </td>
                                    <td style="text-align: right;">
                                        <div style="display: flex; gap: 8px; justify-content: flex-end; align-items: center;">
                                            <a href="${pageContext.request.contextPath}/users?action=edit&userId=${u.userId}&search=${searchParam}&role=${roleParam}&status=${statusParam}" class="btn btn-outline" style="padding: 6px 12px; font-size: 13px;">Sửa</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    
                    <!-- Phân trang cho Danh sách thành viên -->
                    <div class="bk-pagination-container" id="userPagination" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                        <div style="font-size:13px; color:var(--text-secondary);">
                            Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> thành viên
                        </div>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <label style="font-size:13px; color:var(--text-secondary);">Số hàng:</label>
                            <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--bg-card); color:var(--text-main); font-size:13px; outline:none; cursor:pointer;">
                                <option value="5">5</option>
                                <option value="10" selected="selected">10</option>
                                <option value="20">20</option>
                                <option value="50">50</option>
                            </select>
                            <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;">
                                <!-- nút chuyển trang sinh bằng JS -->
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
            <c:if test="${empty userList}">
                <div class="placeholder-content">
                    <span class="material-symbols-outlined" style="font-size: 48px; opacity: 0.3; margin-bottom: 12px;">group_off</span>
                    <p>Không tìm thấy thành viên nào trùng khớp.</p>
                </div>
            </c:if>
        </div>

        <%-- RIGHT COLUMN: ADD / EDIT FORM CARD --%>
        <div class="card" id="formCard" style="display: ${not empty formUser ? 'block' : 'none'};">
            <div class="card-header" style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <h3 id="formTitle">${not empty formUser ? 'Cập nhật tài khoản' : 'Thêm tài khoản'}</h3>
                <button type="button" onclick="closeForm()" style="background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-secondary); line-height: 1;">&times;</button>
            </div>
            
            <form method="post" action="${pageContext.request.contextPath}/users">
                <input type="hidden" id="formAction" name="action" value="${not empty formUser ? 'edit' : 'create'}">
                <c:if test="${not empty formUser}">
                    <input type="hidden" id="userIdField" name="userId" value="${formUser.userId}">
                </c:if>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="fullName">Họ và Tên</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" placeholder="Nguyễn Văn A" value="${not empty formUser ? formUser.fullName : ''}" required>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="email">Địa chỉ Email</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="name@example.com" value="${not empty formUser ? formUser.email : ''}" required ${not empty formUser ? 'readonly style="background: var(--bg-body); cursor: not-allowed;"' : ''}>
                </div>

                <c:if test="${empty formUser}">
                    <div class="form-group" id="passwordField" style="margin-bottom: 16px;">
                        <label for="password">Mật khẩu</label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="Nhập mật khẩu ít nhất 6 ký tự" required minlength="6">
                    </div>
                </c:if>

                <div class="form-group" id="phoneField" style="margin-bottom: 16px;">
                    <label for="phone">Số điện thoại</label>
                    <input type="tel" id="phone" name="phone" class="form-control" placeholder="0901234567" value="${not empty formUser ? formUser.phone : ''}">
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="role">Vai trò</label>
                    <select id="role" name="role" class="form-control" style="cursor: pointer;">
                        <option value="CUSTOMER" ${(not empty formUser && formUser.role == 'CUSTOMER') ? 'selected' : ''}>CUSTOMER</option>
                        <option value="STAFF" ${(not empty formUser && formUser.role == 'STAFF') ? 'selected' : ''}>STAFF</option>
                        <option value="ADMIN" ${(not empty formUser && formUser.role == 'ADMIN') ? 'selected' : ''}>ADMIN</option>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom: 24px; display: flex; align-items: center; gap: 8px; cursor: pointer;">
                    <input type="checkbox" id="isActive" name="isActive" value="1" ${empty formUser || formUser.active ? 'checked' : ''} style="width: 18px; height: 18px; cursor: pointer;">
                    <label for="isActive" style="margin-bottom: 0; cursor: pointer; font-size: 14px; font-weight: 600;">Kích hoạt tài khoản</label>
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <button type="submit" id="submitBtn" class="btn btn-primary" style="width: 100%; padding: 12px;">
                        ${not empty formUser ? 'Lưu cập nhật' : 'Thêm tài khoản'}
                    </button>
                    <c:if test="${not empty formUser}">
                        <a href="${pageContext.request.contextPath}/users" id="cancelBtn" class="btn btn-outline" style="width: 100%; padding: 12px;">Hủy chỉnh sửa</a>
                    </c:if>
                </div>
            </form>
        </div>

    </div>
</div>

<script>
function showAddForm() {
    document.getElementById("mainGrid").style.gridTemplateColumns = "3fr 1fr";
    document.getElementById("formCard").style.display = "block";
    
    // Reset Form to Add/Create mode dynamically
    document.getElementById("formTitle").innerText = "Thêm tài khoản";
    document.getElementById("formAction").value = "create";
    
    var userIdEl = document.getElementById("userIdField");
    if (userIdEl) userIdEl.remove();
    
    document.getElementById("fullName").value = "";
    document.getElementById("email").value = "";
    document.getElementById("email").readOnly = false;
    document.getElementById("email").style.background = "";
    document.getElementById("email").style.cursor = "";
    
    if (!document.getElementById("passwordField")) {
        var passHtml = '<div class="form-group" id="passwordField" style="margin-bottom: 16px;"><label for="password">Mật khẩu</label><input type="password" id="password" name="password" class="form-control" placeholder="Nhập mật khẩu ít nhất 6 ký tự" required minlength="6"></div>';
        document.getElementById("phoneField").insertAdjacentHTML('beforebegin', passHtml);
    }
    
    document.getElementById("phone").value = "";
    document.getElementById("role").value = "CUSTOMER";
    document.getElementById("isActive").checked = true;
    document.getElementById("submitBtn").innerText = "Thêm tài khoản";
    
    var cancelBtnEl = document.getElementById("cancelBtn");
    if (cancelBtnEl) cancelBtnEl.remove();
}

function closeForm() {
    document.getElementById("mainGrid").style.gridTemplateColumns = "1fr";
    document.getElementById("formCard").style.display = "none";
    
    // If currently in Edit mode, reload without params to keep URL clean
    if (document.getElementById("formAction").value === "edit") {
        window.location.href = "${pageContext.request.contextPath}/users";
    }
}

let currentPage = 1;
let pageSize = 10;
let tableRows = [];

function changePageSize() {
    pageSize = parseInt(document.getElementById('pageSizeSelect').value);
    currentPage = 1;
    applyPagination();
}

function initPagination() {
    tableRows = Array.from(document.querySelectorAll('#userTable tbody tr'));
    applyPagination();
}

function applyPagination() {
    const totalRows = tableRows.length;
    const totalPages = Math.ceil(totalRows / pageSize) || 1;
    const pagContainer = document.getElementById('userPagination');
    
    if (!pagContainer) return;
    if (totalRows <= pageSize && currentPage === 1) {
        pagContainer.style.display = 'none';
        tableRows.forEach(row => row.style.display = '');
        return;
    } else {
        pagContainer.style.display = 'flex';
    }
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    tableRows.forEach(row => row.style.display = 'none');
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalRows);
    
    for (let i = startIdx; i < endIdx; i++) {
        tableRows[i].style.display = '';
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
        prevBtn.className = 'btn btn-outline';
        prevBtn.style.padding = '4px 8px';
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
            pageBtn.className = p === currentPage ? 'btn btn-primary' : 'btn btn-outline';
            pageBtn.style.padding = '4px 10px';
            pageBtn.style.minWidth = '28px';
            pageBtn.style.cursor = 'pointer';
            pageBtn.style.fontWeight = '600';
            pageBtn.style.fontSize = '12px';
            if (p === currentPage) {
                pageBtn.style.background = 'var(--primary)';
                pageBtn.style.color = '#fff';
                pageBtn.style.border = 'none';
            }
            pageBtn.innerText = p;
            pageBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pageBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.className = 'btn btn-outline';
        nextBtn.style.padding = '4px 8px';
        nextBtn.style.cursor = 'pointer';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_right</span>';
        nextBtn.onclick = () => { currentPage++; applyPagination(); };
        btnContainer.appendChild(nextBtn);
    }
}

document.addEventListener('DOMContentLoaded', () => {
    initPagination();
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
