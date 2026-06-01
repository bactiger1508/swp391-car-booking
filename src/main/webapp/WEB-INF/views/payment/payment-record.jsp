<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý Giao dịch Thanh toán"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Lịch sử thanh toán</span>
        </div>
        <h2>Nhật ký Giao dịch Thanh toán</h2>
        <p>Theo dõi các khoản thanh toán đặt cọc, thanh toán hóa đơn thuê và phụ phí từ khách hàng.</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm giao dịch theo mã, phương thức..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty payments}">
        <div style="overflow-x:auto;">
            <table class="bk-table" id="paymentTable">
                <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Mã đơn hàng</th>
                        <th>Số tiền</th>
                        <th>Loại giao dịch</th>
                        <th>Phương thức</th>
                        <th>Trạng thái</th>
                        <th>Ngày thanh toán</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${payments}">
                        <tr>
                            <td class="code">PAY-${p.paymentId}</td>
                            <td><a href="${pageContext.request.contextPath}/bookings/detail?id=${p.bookingId}" style="font-weight:600;color:var(--primary);">#BK-${p.bookingId}</a></td>
                            <td>
                                <div style="font-weight:700;color:var(--primary);">
                                    <fmt:formatNumber value="${p.amount}" type="number" groupingUsed="true"/>đ
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.paymentType == 'DEPOSIT'}"><span style="font-weight:600;color:var(--secondary);">Tiền đặt cọc</span></c:when>
                                    <c:when test="${p.paymentType == 'RENTAL'}"><span style="font-weight:600;color:var(--primary);">Thanh toán thuê xe</span></c:when>
                                    <c:when test="${p.paymentType == 'ADDITIONAL_FEE'}"><span style="font-weight:600;color:var(--error);">Phụ phí phát sinh</span></c:when>
                                    <c:when test="${p.paymentType == 'REFUND'}"><span style="font-weight:600;color:var(--info);">Hoàn tiền cọc</span></c:when>
                                    <c:otherwise>${p.paymentType}</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="font-weight:500;">
                                    <c:choose>
                                        <c:when test="${p.paymentMethod == 'CASH'}">Tiền mặt</c:when>
                                        <c:when test="${p.paymentMethod == 'BANK_TRANSFER'}">Chuyển khoản</c:when>
                                        <c:when test="${p.paymentMethod == 'CARD'}">Thẻ tín dụng</c:when>
                                        <c:otherwise>${p.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.status == 'COMPLETED'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Thành công</span></c:when>
                                    <c:when test="${p.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ xử lý</span></c:when>
                                    <c:when test="${p.status == 'FAILED'}"><span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Thất bại</span></c:when>
                                    <c:otherwise><span class="bk-badge">${p.status}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="font-size:13px;color:var(--on-surface-variant);">
                                    ${p.paidAt != null ? p.paidAt.dayOfMonth : ''}/${p.paidAt != null ? p.paidAt.monthValue : ''}/${p.paidAt != null ? p.paidAt.year : ''}
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    <c:if test="${empty payments}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">payments</span>
            <h3>Chưa ghi nhận giao dịch nào</h3>
            <p>Hệ thống hiện tại chưa phát sinh giao dịch thanh toán nào được lưu trữ.</p>
        </div>
    </c:if>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#paymentTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
