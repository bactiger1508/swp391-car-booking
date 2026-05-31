<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Đặt Xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Lịch Đặt Xe</h2>
        <p>Quản lý và theo dõi tất cả lịch đặt xe trong hệ thống.</p>
    </div>
</div>

<%-- Error Message Banner --%>
<c:if test="${not empty errorMessage}">
    <div style="background: var(--error-container, #fde8e8); color: var(--on-error-container, #c62828); padding: 16px 20px; border-radius: 12px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; font-weight: 500;">
        <span class="material-symbols-outlined">error</span>
        ${errorMessage}
    </div>
</c:if>

<%-- Stats Cards --%>
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
    <%-- Count active bookings --%>
    <c:set var="pendingCount" value="0"/>
    <c:set var="confirmedCount" value="0"/>
    <c:set var="progressCount" value="0"/>
    <c:set var="totalCount" value="0"/>
    <c:forEach var="b" items="${bookings}">
        <c:set var="totalCount" value="${totalCount + 1}"/>
        <c:if test="${b.status == 'PENDING'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:if>
        <c:if test="${b.status == 'CONFIRMED'}"><c:set var="confirmedCount" value="${confirmedCount + 1}"/></c:if>
        <c:if test="${b.status == 'IN_PROGRESS'}"><c:set var="progressCount" value="${progressCount + 1}"/></c:if>
    </c:forEach>

    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: var(--primary); font-size: 28px;">event_note</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Tổng đơn</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: var(--on-surface);">${totalCount}</div>
    </div>

    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: #b45309; font-size: 28px;">hourglass_top</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Chờ duyệt</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: #b45309;">${pendingCount}</div>
    </div>

    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 28px;">check_circle</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Đã xác nhận</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: var(--secondary);">${confirmedCount}</div>
    </div>

    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: #059669; font-size: 28px;">directions_car</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Đang thuê</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: #059669;">${progressCount}</div>
    </div>
</div>

<%-- Search and Filter Toolbar --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm theo tên xe, biển số, khách hàng..." oninput="filterTable()">
        </div>
        <div style="display: flex; gap: 8px; align-items: center;">
            <select id="statusFilter" onchange="filterTable()" style="padding: 8px 12px; border-radius: 8px; border: 1px solid var(--outline-variant); background: var(--surface-container-lowest); color: var(--on-surface); font-size: 13px; cursor: pointer;">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING">Chờ duyệt</option>
                <option value="CONFIRMED">Đã xác nhận</option>
                <option value="IN_PROGRESS">Đang thuê</option>
                <option value="COMPLETED">Hoàn tất</option>
                <option value="CANCELLED">Đã hủy</option>
                <option value="REJECTED">Từ chối</option>
            </select>
        </div>
    </div>

    <%-- Bookings Table --%>
    <c:if test="${not empty bookings}">
        <div style="overflow-x: auto;">
            <table class="bk-table" id="bookingsTable">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Xe</th>
                        <th>Khách hàng</th>
                        <th>Ngày bắt đầu</th>
                        <th>Ngày kết thúc</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th style="text-align: center;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr data-status="${b.status}">
                            <td class="code">
                                <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" style="color: var(--primary); text-decoration: none; font-weight: 600;">
                                    BK-${b.bookingId}
                                </a>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty carMap[b.carId]}">
                                        <div style="font-weight: 600;">${carMap[b.carId].brand} ${carMap[b.carId].model}</div>
                                        <div class="sub">${carMap[b.carId].licensePlate}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: var(--on-surface-variant);">Xe #${b.carId}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty userMap[b.customerId]}">
                                        <div style="font-weight: 500;">${userMap[b.customerId].fullName}</div>
                                        <div class="sub">${userMap[b.customerId].email}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: var(--on-surface-variant);">User #${b.customerId}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${b.startDate != null}">
                                    <div style="white-space: nowrap;">
                                        <fmt:formatNumber value="${b.startDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${b.startDate.monthValue}" pattern="00"/>/${b.startDate.year}
                                    </div>
                                    <div class="sub">
                                        <fmt:formatNumber value="${b.startDate.hour}" pattern="00"/>:<fmt:formatNumber value="${b.startDate.minute}" pattern="00"/>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${b.endDate != null}">
                                    <div style="white-space: nowrap;">
                                        <fmt:formatNumber value="${b.endDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${b.endDate.monthValue}" pattern="00"/>/${b.endDate.year}
                                    </div>
                                    <div class="sub">
                                        <fmt:formatNumber value="${b.endDate.hour}" pattern="00"/>:<fmt:formatNumber value="${b.endDate.minute}" pattern="00"/>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${b.totalAmount != null}">
                                    <div style="font-weight: 600; color: var(--primary); white-space: nowrap;">
                                        <fmt:formatNumber value="${b.totalAmount}" type="number" groupingUsed="true"/> ₫
                                    </div>
                                </c:if>
                                <c:if test="${b.totalAmount == null}">
                                    <span style="color: var(--on-surface-variant);">—</span>
                                </c:if>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${b.status == 'PENDING'}">
                                        <span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ duyệt</span>
                                    </c:when>
                                    <c:when test="${b.status == 'CONFIRMED'}">
                                        <span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đã xác nhận</span>
                                    </c:when>
                                    <c:when test="${b.status == 'IN_PROGRESS'}">
                                        <span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang thuê</span>
                                    </c:when>
                                    <c:when test="${b.status == 'COMPLETED'}">
                                        <span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span>
                                    </c:when>
                                    <c:when test="${b.status == 'CANCELLED'}">
                                        <span class="bk-badge" style="background: var(--surface-container-high); color: var(--on-surface-variant);"><span class="bk-badge-dot" style="background: var(--outline);"></span> Đã hủy</span>
                                    </c:when>
                                    <c:when test="${b.status == 'REJECTED'}">
                                        <span class="bk-badge" style="background: #fde8e8; color: #c62828;"><span class="bk-badge-dot" style="background: #c62828;"></span> Từ chối</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="bk-badge">${b.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: center;">
                                <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" class="bk-btn bk-btn-outline bk-btn-sm" title="Xem chi tiết">
                                    <span class="material-symbols-outlined" style="font-size: 16px;">visibility</span> Xem
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
            <span class="material-symbols-outlined">event_busy</span>
            <h3>Chưa có lịch đặt xe</h3>
            <p>Hệ thống chưa ghi nhận đơn đặt xe nào.</p>
        </div>
    </c:if>
</div>

<%-- Minimal JS for search/filter only --%>
<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var statusFilter = document.getElementById('statusFilter').value;
    var rows = document.querySelectorAll('#bookingsTable tbody tr');

    rows.forEach(function(row) {
        var textMatch = !input || row.textContent.toLowerCase().indexOf(input) !== -1;
        var statusMatch = !statusFilter || row.getAttribute('data-status') === statusFilter;
        row.style.display = (textMatch && statusMatch) ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
