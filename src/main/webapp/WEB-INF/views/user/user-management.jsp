<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Thành Viên" />
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

    <div class="bk-booking-grid" id="mainGrid"
         style="display: grid; grid-template-columns: ${not empty formUser|| formMode eq 'create' ? '3fr 1fr' : '1fr'}; gap: 24px; align-items: start; transition: grid-template-columns 0.3s ease;">

        <%-- LEFT COLUMN: USER LIST TABLE --%>
        <div class="card">
            <div class="card-header"
                 style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <h3>Danh sách thành viên</h3>
                <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                    <button class="btn btn-primary" onclick="showAddForm()" style="padding: 10px 20px;">+ Thêm
                        tài khoản</button>
                    </c:if>
            </div>

            <%-- Search & Filter Bar --%>
            <form method="get" action="${pageContext.request.contextPath}/users"
                  style="display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap; align-items: center;">
                <input type="text" name="search" class="form-control"
                       placeholder="Tìm kiếm tên, email, sđt..." value="${searchParam}"
                       style="max-width: 260px; padding: 10px 14px;">
                <select name="role" class="form-control"
                        style="max-width: 140px; padding: 10px 14px; cursor: pointer;">
                    <option value="All roles" ${roleParam=='All roles' ? 'selected' : '' }>Tất cả vai
                        trò</option>
                    <option value="ADMIN" ${roleParam=='ADMIN' ? 'selected' : '' }>Quản lý</option>
                    <option value="STAFF" ${roleParam=='STAFF' ? 'selected' : '' }>Nhân viên</option>
                    <option value="CUSTOMER" ${roleParam=='CUSTOMER' ? 'selected' : '' }>Khách hàng</option>
                </select>
                <select name="status" class="form-control"
                        style="max-width: 150px; padding: 10px 14px; cursor: pointer;">
                    <option value="All status" ${statusParam=='All status' ? 'selected' : '' }>Tất cả
                        trạng thái</option>
                    <option value="Active" ${statusParam=='Active' ? 'selected' : '' }>Hoạt động
                    </option>
                    <option value="Inactive" ${statusParam=='Inactive' ? 'selected' : '' }>Bị khóa
                    </option>
                </select>
                <button type="submit" class="btn btn-primary" style="padding: 10px 18px;">Tìm
                    kiếm</button>
                <a href="${pageContext.request.contextPath}/users" class="btn btn-outline"
                   style="padding: 10px 18px;">Reset</a>
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
                                    <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                                    <th style="text-align: right;">Hành động</th>
                                    </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${userList}">
                                <tr>
                                    <td>${u.userId}</td>
                                    <td><strong>${u.fullName}</strong></td>
                                    <td>${u.email}</td>
                                    <td>
                                        <span
                                            class="badge ${u.role == 'ADMIN' ? 'badge-confirmed' : (u.role == 'STAFF' ? 'badge-progress' : 'badge-rented')}">
                                            ${u.role == 'ADMIN' ? 'Quản lý' :(u.role == 'STAFF' ? 'Nhân viên' : 'Khách hàng')}
                                        </span>
                                    </td>
                                    <td>
                                        <span
                                            class="badge ${u.active ? 'badge-available' : 'badge-cancelled'}">
                                            ${u.active ? 'Hoạt động' : 'Bị khóa'}
                                        </span>
                                    </td>
                                    <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                                        <td style="text-align: right;">
                                            <div
                                                style="display: flex; gap: 8px; justify-content: flex-end; align-items: center;">
                                                <a href="${pageContext.request.contextPath}/users?action=edit&userId=${u.userId}&search=${searchParam}&role=${roleParam}&status=${statusParam}"
                                                   class="btn btn-outline"
                                                   style="padding: 6px 12px; font-size: 13px;">Sửa</a>
                                            </div>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- Phân trang cho Danh sách thành viên -->
                    <div class="bk-pagination-container"
                         style="display:flex;
                         justify-content:space-between;
                         align-items:center;
                         margin-top:20px;
                         padding:12px 0;
                         border-top:1px solid var(--outline-variant);">

                        <div>
                            Hiển thị
                            ${(currentPage-1)*10+1}
                            -
                            <c:choose>
                                <c:when test="${currentPage*10 > totalRecords}">
                                    ${totalRecords}
                                </c:when>
                                <c:otherwise>
                                    ${currentPage*10}
                                </c:otherwise>
                            </c:choose>
                            trong tổng số
                            ${totalRecords}
                            thành viên
                        </div>

                        <div style="display:flex;gap:5px;">

                            <c:if test="${currentPage>1}">
                                <a class="btn btn-outline"
                                   href="${pageContext.request.contextPath}/users?page=${currentPage-1}&search=${searchParam}&role=${roleParam}&status=${statusParam}">
                                    ‹
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="i">

                                <a class="${i==currentPage?'btn btn-primary':'btn btn-outline'}"
                                   href="${pageContext.request.contextPath}/users?page=${i}&search=${searchParam}&role=${roleParam}&status=${statusParam}">
                                    ${i}
                                </a>

                            </c:forEach>

                            <c:if test="${currentPage<totalPages}">
                                <a class="btn btn-outline"
                                   href="${pageContext.request.contextPath}/users?page=${currentPage+1}&search=${searchParam}&role=${roleParam}&status=${statusParam}">
                                    ›
                                </a>
                            </c:if>

                        </div>

                    </div>
                </div>
            </c:if>
            <c:if test="${empty userList}">
                <div class="placeholder-content">
                    <span class="material-symbols-outlined"
                          style="font-size: 48px; opacity: 0.3; margin-bottom: 12px;">group_off</span>
                    <p>Không tìm thấy thành viên nào trùng khớp.</p>
                </div>
            </c:if>
        </div>

        <%-- RIGHT COLUMN: ADD / EDIT FORM CARD --%>
        <div class="card" id="formCard" style="display: ${not empty formUser || formMode eq 'create' ? 'block' : 'none'};">
            <div class="card-header"
                 style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <h3 id="formTitle"> ${formMode eq 'edit' ? 'Cập nhật tài khoản' : 'Thêm tài khoản'}</h3>
                <button type="button" onclick="closeForm()"
                        style="background: none; border: none; font-size: 24px; cursor: pointer; color: var(--text-secondary); line-height: 1;">&times;</button>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/users">
                <input type="hidden" id="formAction" name="action"
                       value="${formMode eq 'edit' ? 'edit' : 'create'}">
                <c:if test="${formMode eq 'edit'}">
                    <input type="hidden" id="userIdField" name="userId" value="${formUser.userId}">
                </c:if>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="fullName">Họ và Tên</label>
                    <input type="text" id="fullName" name="fullName" class="form-control"
                           placeholder="Nguyễn Văn A"
                           value="${not empty formUser ? formUser.fullName : ''}" ${formMode eq 'edit'
                                    ? 'readonly style="background: var(--bg-body); cursor: not-allowed;"'
                                    : '' }>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="email">Địa chỉ Email</label>
                    <input type="text" id="email" name="email" class="form-control"
                           placeholder="name@example.com"
                           value="${not empty formUser ? formUser.email : ''}" ${formMode eq 'edit'
                                    ? 'readonly style="background: var(--bg-body); cursor: not-allowed;"'
                                    : '' }>
                </div>

                <c:if test="${formMode ne 'edit'}">
                    <div class="form-group" id="passwordField" style="margin-bottom: 16px;">
                        <label for="password">Mật khẩu</label>
                        <input type="password" id="password" name="password" class="form-control"
                               placeholder="Nhập mật khẩu ít nhất 6 ký tự"   minlength="6">
                    </div>
                </c:if>

                <div class="form-group" id="phoneField" style="margin-bottom: 16px;">
                    <label for="phone">Số điện thoại</label>
                    <input type="tel" id="phone" name="phone" class="form-control"
                           placeholder="0901234567" value="${not empty formUser ? formUser.phone : ''}" ${formMode eq 'edit'
                                                             ? 'readonly style="background: var(--bg-body); cursor: not-allowed;"'
                                                             : '' }>
                </div>

                <div class="form-group" style="margin-bottom: 16px;">
                    <label for="role">Vai trò</label>
                    <select id="role" name="role" class="form-control" style="cursor: pointer;">
                        <option value="CUSTOMER" ${(not empty formUser && formUser.role=='CUSTOMER' )
                                                   ? 'selected' : '' }>Khách hàng</option>
                        <option value="STAFF" ${(not empty formUser && formUser.role=='STAFF' )
                                                ? 'selected' : '' }>Nhân viên</option>
                        <option value="ADMIN" ${(not empty formUser && formUser.role=='ADMIN' )
                                                ? 'selected' : '' }>Quản lý</option>
                    </select>
                </div>

                <div class="form-group"
                     style="margin-bottom: 24px; display: flex; align-items: center; gap: 8px; cursor: pointer;">
                    <input type="checkbox" id="isActive" name="isActive" value="1" ${empty formUser ||
                                                                                     formUser.active ? 'checked' : '' }
                           style="width: 18px; height: 18px; cursor: pointer;">
                    <label for="isActive"
                           style="margin-bottom: 0; cursor: pointer; font-size: 14px; font-weight: 600;">Kích
                        hoạt tài khoản</label>
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <button type="submit" id="submitBtn" class="btn btn-primary"
                            style="width: 100%; padding: 12px;">
                        ${formMode == 'edit' ? 'Lưu cập nhật' : 'Thêm tài khoản'}
                    </button>
                    <c:if test="${formMode eq 'edit'}">
                        <a href="${pageContext.request.contextPath}/users" id="cancelBtn"
                           class="btn btn-outline" style="width: 100%; padding: 12px;">Hủy chỉnh
                            sửa</a>
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
        if (userIdEl)
            userIdEl.remove();

        document.getElementById("fullName").value = "";
        document.getElementById("fullName").readOnly = false;
        document.getElementById("fullName").style.background = "";
        document.getElementById("fullName").style.cursor = "";
        document.getElementById("email").value = "";
        document.getElementById("email").readOnly = false;
        document.getElementById("email").style.background = "";
        document.getElementById("email").style.cursor = "";

        if (!document.getElementById("passwordField")) {
            var passHtml = '<div class="form-group" id="passwordField" style="margin-bottom: 16px;"><label for="password">Mật khẩu</label><input type="password" id="password" name="password" class="form-control" placeholder="Nhập mật khẩu ít nhất 6 ký tự" required minlength="6"></div>';
            document.getElementById("phoneField").insertAdjacentHTML('beforebegin', passHtml);
        }

        document.getElementById("phone").value = "";
        document.getElementById("phone").readOnly = false;
        document.getElementById("phone").style.background = "";
        document.getElementById("phone").style.cursor = "";
        document.getElementById("role").value = "CUSTOMER";
        document.getElementById("isActive").checked = true;
        document.getElementById("submitBtn").innerText = "Thêm tài khoản";

        var cancelBtnEl = document.getElementById("cancelBtn");
        if (cancelBtnEl)
            cancelBtnEl.remove();
    }

    function closeForm() {
        document.getElementById("mainGrid").style.gridTemplateColumns = "1fr";
        document.getElementById("formCard").style.display = "none";

        // If currently in Edit mode, reload without params to keep URL clean
        if (document.getElementById("formAction").value === "edit") {
            window.location.href = "${pageContext.request.contextPath}/users";
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />