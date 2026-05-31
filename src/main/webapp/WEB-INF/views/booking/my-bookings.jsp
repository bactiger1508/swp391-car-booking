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
    <div class="bk-stat-card">
        <span class="label">Tổng số đơn</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value">${bookings != null ? bookings.size() : 0}</span>
        </div>
    </div>
    <div class="bk-stat-card">
        <span class="label">Đang xử lý</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statPending">0</span>
        </div>
    </div>
    <div class="bk-stat-card">
        <span class="label">Đã xác nhận</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statConfirmed">0</span>
        </div>
    </div>
    <div class="bk-stat-card">
        <span class="label">Hoàn tất</span>
        <div style="display:flex;align-items:baseline;margin-top:8px;">
            <span class="value" id="statCompleted">0</span>
        </div>
    </div>
</div>

<%-- Table --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm mã đơn, tên xe..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty bookings}">
        <div style="overflow-x:auto;">
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
    <c:if test="${empty bookings}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">directions_car</span>
            <h3>Chưa có đơn thuê nào</h3>
            <p>Hãy đặt xe đầu tiên của bạn ngay!</p>
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
// Count stats
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
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
