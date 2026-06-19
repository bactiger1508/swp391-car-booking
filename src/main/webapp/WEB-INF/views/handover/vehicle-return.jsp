<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản lý Nhận lại xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Nhận lại xe</span>
        </div>
        <h2>Nhật ký Biên bản Nhận lại xe</h2>
        <p>Kiểm tra kỹ lưỡng quãng đường thực tế, mức nhiên liệu, hư hỏng và tính toán các phụ phí phát sinh khi khách hàng trả xe. (BR-07, BR-08)</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm biên bản nhận xe..." oninput="filterTable()" />
        </div>
    </div>

    <%--<c:if test="${not empty returns}">--%>
    <div style="overflow-x:auto;">
        <table class="bk-table" id="returnTable">
            <thead>
                <tr>
                    <th>Mã BB</th>
                    <th>Đơn thuê xe</th>
                    <th>Mã Xe</th>
                    <th>Ngày nhận xe</th>
                    <th>Quãng đường đi</th>
                    <th>Phụ thu phát sinh</th>
                    <th>Nhân viên nhận xe</th>
                    <th>Thao tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="r" items="${returns}">
                    <tr>
                        <td class="code">RT-${r.returnId}</td>
                        <td><a href="${pageContext.request.contextPath}/bookings/detail?id=${r.bookingId}" style="font-weight:600;color:var(--primary);">#BK-${r.bookingId}</a></td>
                        <td style="font-weight:500;">Xe #${r.carId}</td>
                        <td>
                            <div style="font-size:13px;">
                                ${r.returnDate.dayOfMonth}/${r.returnDate.monthValue}/${r.returnDate.year} ${r.returnDate.hour}:${r.returnDate.minute}
                            </div>
                        </td>
                        <td><div style="font-weight:600;color:var(--primary);">${r.mileageAtReturn} km</div></td>
                        <td>
                            <div style="font-weight:700;color:var(--error);">
                                <fmt:formatNumber value="${r.totalAdditionalFee}" type="number" groupingUsed="true"/>đ
                            </div>
                        </td>
                        <td>Nhân viên #${r.receivedBy}</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/returns/detail?bookingId=${r.bookingId}&carId=${r.carId}" class="bk-btn bk-btn-sm bk-btn-primary">Xem</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    <%--</c:if>--%>
    <%--<c:if test="${empty returns}">--%>
    <!-- Fallback data to show gorgeous table representation when database is clean -->
    <!--        <div style="overflow-x:auto;">
                <table class="bk-table" id="returnTable">
                    <thead>
                        <tr>
                            <th>Mã BB</th>
                            <th>Đơn thuê xe</th>
                            <th>Mã Xe</th>
                            <th>Ngày nhận xe</th>
                            <th>Quãng đường đi</th>
                            <th>Phụ thu phát sinh</th>
                            <th>Nhân viên nhận xe</th>
                        </tr>
                    </thead>
                </table>
            </div>-->
    <%--</c:if>--%>
</div>

<script>
    function filterTable() {
        var input = document.getElementById('searchInput').value.toLowerCase();
        var rows = document.querySelectorAll('#returnTable tbody tr');
        rows.forEach(function (row) {
            row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
        });
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
