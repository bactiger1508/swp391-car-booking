<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Duyệt Đặt Xe"/>
</jsp:include>

<c:if test="${not empty success}">
    <div class="bk-alert bk-alert-success" data-auto-dismiss>
        <span class="material-symbols-outlined">check_circle</span> ${success}
    </div>
</c:if>
<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<div class="bk-page-header">
    <div>
        <h2>Duyệt Đặt xe</h2>
        <p>Xem và phê duyệt các đơn đặt xe đang chờ xử lý.</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty pendingBookings}">
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
                    <c:forEach var="b" items="${pendingBookings}">
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
                                <span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ duyệt</span>
                            </td>
                            <td class="text-right">
                                <div style="display:flex;justify-content:flex-end;gap:6px;">
                                    <a href="${pageContext.request.contextPath}/bookings/detail?id=${b.bookingId}" class="bk-btn bk-btn-outline bk-btn-sm">Xem</a>
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
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    <c:if test="${empty pendingBookings}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">task_alt</span>
            <h3>Không có đơn nào cần duyệt</h3>
            <p>Tất cả các đơn đặt xe đã được xử lý.</p>
        </div>
    </c:if>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#bookingTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
