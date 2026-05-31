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
    <a href="${pageContext.request.contextPath}/bookings/manage?status=PENDING" class="bk-stat-card" style="text-decoration:none;">
        <span class="label">Chờ Duyệt</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value">${pendingCount != null ? pendingCount : 0}</span>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/bookings/manage?status=CONFIRMED" class="bk-stat-card" style="text-decoration:none;">
        <span class="label">Đã Xác Nhận</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value">${confirmedCount != null ? confirmedCount : 0}</span>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/bookings/manage?status=IN_PROGRESS" class="bk-stat-card" style="text-decoration:none;">
        <span class="label">Đang Cho Thuê</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value">${inProgressCount != null ? inProgressCount : 0}</span>
        </div>
    </a>
    <a href="${pageContext.request.contextPath}/bookings/manage?status=COMPLETED" class="bk-stat-card" style="text-decoration:none;">
        <span class="label">Hoàn Tất</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value">${completedCount != null ? completedCount : 0}</span>
        </div>
    </a>
</div>

<%-- Data Table --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm theo Mã, Khách hàng, hoặc Xe..." oninput="filterTable()">
        </div>
        <div style="display:flex;gap:8px;">
            <c:forEach var="st" items="${['PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','REJECTED','CANCELLED']}">
                <a href="${pageContext.request.contextPath}/bookings/manage?status=${st}"
                   class="bk-btn bk-btn-sm ${currentFilter == st ? 'bk-btn-primary' : 'bk-btn-outline'}"
                   style="font-size:11px;padding:4px 10px;">
                    <c:choose>
                        <c:when test="${st == 'PENDING'}">Chờ duyệt</c:when>
                        <c:when test="${st == 'CONFIRMED'}">Đã xác nhận</c:when>
                        <c:when test="${st == 'IN_PROGRESS'}">Đang thuê</c:when>
                        <c:when test="${st == 'COMPLETED'}">Hoàn tất</c:when>
                        <c:when test="${st == 'REJECTED'}">Từ chối</c:when>
                        <c:when test="${st == 'CANCELLED'}">Đã hủy</c:when>
                    </c:choose>
                </a>
            </c:forEach>
        </div>
    </div>

    <c:if test="${not empty bookings}">
        <div style="overflow-x:auto;">
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
                        <tr>
                            <td class="code">BK-${b.bookingId}</td>
                            <td>
                                <c:if test="${not empty userMap[b.customerId]}">
                                    <div>${userMap[b.customerId].fullName}</div>
                                    <div class="sub">${userMap[b.customerId].email}</div>
                                </c:if>
                                <c:if test="${empty userMap[b.customerId]}">User #${b.customerId}</c:if>
                            </td>
                            <td>
                                <c:if test="${not empty carMap[b.carId]}">
                                    ${carMap[b.carId].brand} ${carMap[b.carId].model}
                                    <div class="sub">${carMap[b.carId].licensePlate}</div>
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
                                    <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" class="bk-btn bk-btn-outline bk-btn-sm">Xem</a>
                                    <c:if test="${b.status == 'PENDING'}">
                                        <form method="post" action="${pageContext.request.contextPath}/bookings/approval" style="display:inline;">
                                            <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                                            <input type="hidden" name="action" value="approve"/>
                                            <button type="submit" class="bk-btn bk-btn-success bk-btn-sm" onclick="return confirm('Duyệt booking #${b.bookingId}?')">Duyệt</button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/bookings/approval" style="display:inline;">
                                            <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                                            <input type="hidden" name="action" value="reject"/>
                                            <input type="hidden" name="reason" value="Không đạt yêu cầu"/>
                                            <button type="submit" class="bk-btn bk-btn-danger bk-btn-sm" onclick="return confirm('Từ chối booking #${b.bookingId}?')">Từ chối</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    <c:if test="${empty bookings}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">inbox</span>
            <h3>Không có booking nào</h3>
            <p>${not empty currentFilter ? 'Không có booking ở trạng thái đã chọn.' : 'Chưa có dữ liệu đặt xe.'}</p>
        </div>
    </c:if>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#bookingTable tbody tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(input) ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
