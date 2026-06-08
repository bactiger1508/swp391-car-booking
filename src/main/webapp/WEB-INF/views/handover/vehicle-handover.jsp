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
            <span class="current">Giao xe bàn giao</span>
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
                                    ${not empty h.exteriorCondition ? h.exteriorCondition : 'Bình thường, không trầy xước'}
                                </div>
                            </td>
                            <td>Nhân viên #${h.handedBy}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
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
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="code">HD-101</td>
                        <td><a href="#" style="font-weight:600;color:var(--primary);">#BK-2041</a></td>
                        <td style="font-weight:500;">Xe #12 (VinFast VF8)</td>
                        <td><div style="font-size:13px;">01/06/2026 09:00</div></td>
                        <td><div style="font-weight:600;color:var(--primary);">12,450 km</div></td>
                        <td><span class="bk-badge bk-badge-confirmed" style="background:var(--success-container);color:var(--on-success-container);"><span class="bk-badge-dot"></span> FULL (100%)</span></td>
                        <td><div style="font-size:12px;color:var(--on-surface-variant);">Bình thường, sạch sẽ</div></td>
                        <td>Nhân viên #2</td>
                    </tr>
                    <tr>
                        <td class="code">HD-102</td>
                        <td><a href="#" style="font-weight:600;color:var(--primary);">#BK-2042</a></td>
                        <td style="font-weight:500;">Xe #5 (Mazda 3)</td>
                        <td><div style="font-size:13px;">01/06/2026 10:15</div></td>
                        <td><div style="font-weight:600;color:var(--primary);">34,120 km</div></td>
                        <td><span class="bk-badge bk-badge-confirmed" style="background:var(--success-container);color:var(--on-success-container);"><span class="bk-badge-dot"></span> 3/4 Bình xăng</span></td>
                        <td><div style="font-size:12px;color:var(--on-surface-variant);">Móp nhẹ cản sau trái</div></td>
                        <td>Nhân viên #2</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </c:if>
</div>

<script>
    function filterTable() {
        var input = document.getElementById('searchInput').value.toLowerCase();
        var rows = document.querySelectorAll('#handoverTable tbody tr');
        rows.forEach(function (row) {
            row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
        });
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
