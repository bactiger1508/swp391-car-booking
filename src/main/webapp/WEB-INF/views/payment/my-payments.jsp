<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<%
    request.setAttribute("dateTimeFormatter",
        java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Sử Thanh Toán Của Tôi"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/bookings/my">Chuyến Đi Của Tôi</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Lịch Sử Thanh Toán</span>
        </div>
        <h2>Lịch Sử Thanh Toán Của Tôi</h2>
        <p>Xem tất cả giao dịch thanh toán liên quan đến các đơn thuê xe của bạn.</p>
    </div>
</div>

<div class="bk-container" style="max-width: 1200px;">

    <%-- Error message --%>
    <c:if test="${not empty errorMsg}">
        <div class="bk-alert bk-alert-error" style="margin-bottom: 24px;">
            <span class="material-symbols-outlined">warning</span> ${errorMsg}
        </div>
    </c:if>

    <%-- Stats summary cards --%>
    <c:set var="totalPaidSum"   value="0"/>
    <c:set var="totalRefunded" value="0"/>
    <c:set var="pendingCount"  value="0"/>
    <c:forEach var="p" items="${myPayments}">
        <c:if test="${p.status == 'COMPLETED'}">
            <c:if test="${p.paymentType != 'REFUND'}">
                <c:set var="totalPaidSum" value="${totalPaidSum + p.amount}"/>
            </c:if>
            <c:if test="${p.paymentType == 'REFUND'}">
                <c:set var="totalRefunded" value="${totalRefunded + p.amount}"/>
            </c:if>
        </c:if>
        <c:if test="${p.status == 'PENDING'}">
            <c:set var="pendingCount" value="${pendingCount + 1}"/>
        </c:if>
    </c:forEach>

    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 32px;">
        <div class="bk-card" style="padding: 20px; display:flex; align-items:center; gap:14px;">
            <div style="width:40px; height:40px; border-radius:10px; background:#EEF2FD; display:flex; align-items:center; justify-content:center;">
                <span class="material-symbols-outlined" style="color:#2F5ACD; font-size:22px;">receipt_long</span>
            </div>
            <div>
                <div style="font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.5px;">Tổng giao dịch</div>
                <div style="font-size:22px; font-weight:800; color:var(--on-surface);">${empty myPayments ? 0 : myPayments.size()}</div>
            </div>
        </div>
        <div class="bk-card" style="padding: 20px; display:flex; align-items:center; gap:14px;">
            <div style="width:40px; height:40px; border-radius:10px; background:#EAF9F5; display:flex; align-items:center; justify-content:center;">
                <span class="material-symbols-outlined" style="color:#039C74; font-size:22px;">payments</span>
            </div>
            <div>
                <div style="font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.5px;">Tổng đã thanh toán</div>
                <div style="font-size:18px; font-weight:800; color:#039C74;"><fmt:formatNumber value="${totalPaidSum}" pattern="#,##0"/> đ</div>
            </div>
        </div>
        <div class="bk-card" style="padding: 20px; display:flex; align-items:center; gap:14px;">
            <div style="width:40px; height:40px; border-radius:10px; background:#FFF4F2; display:flex; align-items:center; justify-content:center;">
                <span class="material-symbols-outlined" style="color:#C9392D; font-size:22px;">currency_exchange</span>
            </div>
            <div>
                <div style="font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.5px;">Đã hoàn tiền</div>
                <div style="font-size:18px; font-weight:800; color:#C9392D;"><fmt:formatNumber value="${totalRefunded}" pattern="#,##0"/> đ</div>
            </div>
        </div>
        <div class="bk-card" style="padding: 20px; display:flex; align-items:center; gap:14px;">
            <div style="width:40px; height:40px; border-radius:10px; background:#FFFBEB; display:flex; align-items:center; justify-content:center;">
                <span class="material-symbols-outlined" style="color:#D97706; font-size:22px;">pending</span>
            </div>
            <div>
                <div style="font-size:11px; color:var(--text-secondary); font-weight:600; text-transform:uppercase; letter-spacing:0.5px;">Đang chờ xử lý</div>
                <div style="font-size:22px; font-weight:800; color:#D97706;">${pendingCount}</div>
            </div>
        </div>
    </div>

    <%-- Filters --%>
    <div class="bk-card" style="padding: 20px; margin-bottom: 24px;">
        <div style="display:flex; flex-wrap:wrap; gap:12px; align-items:center;">
            <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Tìm kiếm theo mã đơn, loại, phương thức..."
                   class="bk-form-input" style="flex:1; min-width:200px; max-width:340px; height:40px; padding:0 14px; font-size:14px;"/>
            <select id="filterType" onchange="filterTable()" class="bk-form-select" style="height:40px; font-size:14px; padding:0 12px; border-radius:8px; border:1px solid var(--outline-variant); min-width:170px;">
                <option value="All">Tất cả loại thanh toán</option>
                <option value="DEPOSIT">💵 Đặt cọc (DEPOSIT)</option>
                <option value="RENTAL">🚗 Tiền thuê (RENTAL)</option>
                <option value="ADDITIONAL_FEE">⚠️ Phụ phí (ADDITIONAL_FEE)</option>
                <option value="REFUND">🔄 Hoàn tiền (REFUND)</option>
            </select>
            <select id="filterMethod" onchange="filterTable()" class="bk-form-select" style="height:40px; font-size:14px; padding:0 12px; border-radius:8px; border:1px solid var(--outline-variant); min-width:170px;">
                <option value="All">Tất cả phương thức</option>
                <option value="CASH">💵 Tiền mặt (CASH)</option>
                <option value="BANK_TRANSFER">🏦 Chuyển khoản QR</option>
            </select>
            <select id="filterStatus" onchange="filterTable()" class="bk-form-select" style="height:40px; font-size:14px; padding:0 12px; border-radius:8px; border:1px solid var(--outline-variant); min-width:150px;">
                <option value="All">Tất cả trạng thái</option>
                <option value="COMPLETED">Thành công</option>
                <option value="PENDING">Chờ xử lý</option>
                <option value="REFUNDED">Đã hoàn tiền</option>
                <option value="FAILED">Thất bại</option>
            </select>
        </div>
    </div>

    <%-- Payment table --%>
    <c:choose>
        <c:when test="${empty myPayments}">
            <div class="bk-card" style="padding: 60px 24px; text-align: center;">
                <span class="material-symbols-outlined" style="font-size: 56px; color: var(--outline); margin-bottom: 12px; display:block;">receipt_long</span>
                <h4 style="color: var(--on-surface); margin-bottom: 8px;">Chưa có giao dịch nào</h4>
                <p style="color: var(--text-secondary); font-size: 14px;">Bạn chưa có giao dịch thanh toán nào. Hãy đặt xe để bắt đầu!</p>
                <a href="${pageContext.request.contextPath}/bookings/create" class="bk-btn bk-btn-primary" style="margin-top: 16px;">
                    <span class="material-symbols-outlined">add</span> Đặt Xe Ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bk-card" style="padding: 0; overflow: hidden;">
                <div style="overflow-x: auto;">
                    <table id="myPaymentTable" style="width:100%; border-collapse:collapse; min-width: 860px;">
                        <thead>
                            <tr style="background: var(--surface-container-highest); border-bottom: 2px solid var(--outline-variant);">
                                <th style="padding:14px 16px; text-align:left; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Mã GD</th>
                                <th style="padding:14px 16px; text-align:left; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Đơn thuê</th>
                                <th style="padding:14px 16px; text-align:left; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Loại thanh toán</th>
                                <th style="padding:14px 16px; text-align:left; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Phương thức</th>
                                <th style="padding:14px 16px; text-align:right; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Số tiền yêu cầu</th>
                                <th style="padding:14px 16px; text-align:right; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Đã thanh toán</th>
                                <th style="padding:14px 16px; text-align:right; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Chênh lệch</th>
                                <th style="padding:14px 16px; text-align:center; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Trạng thái</th>
                                <th style="padding:14px 16px; text-align:left; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-secondary);">Ngày thanh toán</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${myPayments}" varStatus="status">
                                <c:set var="overpaid" value="0"/>
                                <c:if test="${p.amountPaid != null && p.amountPaid > p.amount}">
                                    <c:set var="overpaid" value="${p.amountPaid - p.amount}"/>
                                </c:if>
                                <tr class="payment-row" style="border-bottom: 1px solid var(--outline-variant); ${status.index % 2 == 1 ? 'background: var(--surface-container-low);' : ''}"
                                    data-type="${p.paymentType}"
                                    data-method="${p.paymentMethod}"
                                    data-status="${p.status}"
                                    data-search="${p.paymentId} ${p.bookingId} ${p.paymentType} ${p.paymentMethod} ${p.status}">

                                    <%-- Payment ID & Ref --%>
                                    <td style="padding:12px 16px; font-weight:700; color:var(--primary); font-size:13px;">
                                        #PM-${p.paymentId}
                                        <c:if test="${not empty p.transactionRef}">
                                            <div style="font-size:11px; font-weight:normal; color: var(--text-secondary);">Ref: ${p.transactionRef}</div>
                                        </c:if>
                                    </td>

                                    <%-- Booking --%>
                                    <td style="padding:12px 16px;">
                                        <a href="${pageContext.request.contextPath}/bookings/detail?id=${p.bookingId}"
                                           style="color:var(--primary); font-weight:600; font-size:13px; text-decoration:none;"
                                           title="Xem chi tiết đơn thuê">
                                            #BK-${p.bookingId}
                                        </a>
                                        <c:if test="${p.contractId != null}">
                                            <div style="font-size:11px; color:var(--text-secondary);">#CT-${p.contractId}</div>
                                        </c:if>
                                    </td>

                                    <%-- Payment Type --%>
                                    <td style="padding:12px 16px; font-size:13px; font-weight:500;">
                                        <c:choose>
                                            <c:when test="${p.paymentType == 'DEPOSIT'}">
                                                <span style="display:inline-flex; align-items:center; gap:4px; background:#EEF2FD; color:#2F5ACD; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600;">💵 Đặt cọc</span>
                                            </c:when>
                                            <c:when test="${p.paymentType == 'RENTAL'}">
                                                <span style="display:inline-flex; align-items:center; gap:4px; background:#EAF9F5; color:#039C74; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600;">🚗 Tiền thuê</span>
                                            </c:when>
                                            <c:when test="${p.paymentType == 'ADDITIONAL_FEE'}">
                                                <span style="display:inline-flex; align-items:center; gap:4px; background:#FFF5F5; color:#C53030; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600;">⚠️ Phụ phí</span>
                                            </c:when>
                                            <c:when test="${p.paymentType == 'REFUND'}">
                                                <span style="display:inline-flex; align-items:center; gap:4px; background:#FFFBEB; color:#D97706; padding:3px 10px; border-radius:20px; font-size:12px; font-weight:600;">🔄 Hoàn tiền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span>${p.paymentType}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Payment Method --%>
                                    <td style="padding:12px 16px; font-size:13px; font-weight:500;">
                                        <c:choose>
                                            <c:when test="${p.paymentMethod == 'CASH'}">💵 Tiền mặt</c:when>
                                            <c:when test="${p.paymentMethod == 'BANK_TRANSFER'}">🏦 Chuyển khoản QR</c:when>
                                            <c:otherwise>${p.paymentMethod}</c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Required amount --%>
                                    <td style="padding:12px 16px; text-align:right; font-weight:600; font-size:13px;">
                                        <fmt:formatNumber value="${p.amount}" pattern="#,##0"/> đ
                                    </td>

                                    <%-- Amount paid --%>
                                    <td style="padding:12px 16px; text-align:right; font-size:13px;">
                                        <c:choose>
                                            <c:when test="${p.amountPaid != null}">
                                                <span style="font-weight:700; color:#039C74;">
                                                    <fmt:formatNumber value="${p.amountPaid}" pattern="#,##0"/> đ
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--text-secondary);">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Overpayment / Underpayment --%>
                                    <td style="padding:12px 16px; text-align:right; font-size:13px;">
                                        <c:choose>
                                            <c:when test="${p.amountPaid != null && p.amountPaid > p.amount}">
                                                <span style="color:#C53030; font-weight:700;">
                                                    +<fmt:formatNumber value="${p.amountPaid - p.amount}" pattern="#,##0"/> đ
                                                </span>
                                                <div style="font-size:10px; color:#C53030; font-weight:600;">CẦN HOÀN</div>
                                            </c:when>
                                            <c:when test="${p.amountPaid != null && p.amountPaid < p.amount}">
                                                <span style="color:#D97706; font-weight:700;">
                                                    -<fmt:formatNumber value="${p.amount - p.amountPaid}" pattern="#,##0"/> đ
                                                </span>
                                                <div style="font-size:10px; color:#D97706; font-weight:600;">CÒN NỢ</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--text-secondary);">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Status badge --%>
                                    <td style="padding:12px 16px; text-align:center;">
                                        <c:choose>
                                            <c:when test="${p.status == 'COMPLETED'}">
                                                <span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Thành công</span>
                                            </c:when>
                                            <c:when test="${p.status == 'PENDING'}">
                                                <span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ xử lý</span>
                                            </c:when>
                                            <c:when test="${p.status == 'REFUNDED'}">
                                                <span class="bk-badge bk-badge-info"><span class="bk-badge-dot"></span> Đã hoàn tiền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Thất bại</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <%-- Date --%>
                                    <td style="padding:12px 16px; font-size:12px; color:var(--text-secondary);">
                                        ${p.paidAt != null ? p.paidAt.format(dateTimeFormatter) : '—'}
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <%-- Empty state for filtered results --%>
                <div id="noResultsRow" style="display:none; padding:40px; text-align:center; color:var(--text-secondary);">
                    <span class="material-symbols-outlined" style="font-size:40px; display:block; margin-bottom:8px;">search_off</span>
                    Không tìm thấy giao dịch phù hợp với bộ lọc
                </div>

                <%-- Pagination --%>
                <div style="display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                    <div style="font-size:13px; color:var(--text-secondary);">
                        Hiển thị <span id="pag-start" style="font-weight:600;">0</span>
                        đến <span id="pag-end" style="font-weight:600;">0</span>
                        trong số <span id="pag-total" style="font-weight:600;">0</span> giao dịch
                    </div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <label style="font-size:13px; color:var(--text-secondary);">Số hàng:</label>
                        <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); font-size:13px; outline:none; cursor:pointer;">
                            <option value="5">5</option>
                            <option value="10" selected>10</option>
                            <option value="20">20</option>
                            <option value="50">50</option>
                        </select>
                        <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:8px;"></div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<script>
let currentPage = 1;
let pageSize = 10;
let filteredRows = [];

function filterTable() {
    var search  = (document.getElementById('searchInput')  ? document.getElementById('searchInput').value.toLowerCase()  : '');
    var type    = (document.getElementById('filterType')   ? document.getElementById('filterType').value   : 'All');
    var method  = (document.getElementById('filterMethod') ? document.getElementById('filterMethod').value : 'All');
    var status  = (document.getElementById('filterStatus') ? document.getElementById('filterStatus').value : 'All');

    var rows = document.querySelectorAll('#myPaymentTable tbody tr.payment-row');
    filteredRows = [];

    rows.forEach(function(row) {
        var dataType   = row.getAttribute('data-type')   || '';
        var dataMethod = row.getAttribute('data-method') || '';
        var dataStatus = row.getAttribute('data-status') || '';
        var dataSearch = row.getAttribute('data-search') || '';

        var match = true;
        if (type   !== 'All' && dataType   !== type)   match = false;
        if (method !== 'All' && dataMethod !== method) match = false;
        if (status !== 'All' && dataStatus !== status) match = false;
        if (search && !dataSearch.toLowerCase().includes(search)) match = false;

        row.style.display = 'none';
        if (match) filteredRows.push(row);
    });

    currentPage = 1;
    applyPagination();
}

function changePageSize() {
    pageSize = parseInt(document.getElementById('pageSizeSelect').value);
    currentPage = 1;
    applyPagination();
}

function applyPagination() {
    var start = (currentPage - 1) * pageSize;
    var end   = start + pageSize;
    filteredRows.forEach(function(row, i) {
        row.style.display = (i >= start && i < end) ? '' : 'none';
    });

    var noResults = document.getElementById('noResultsRow');
    if (noResults) noResults.style.display = (filteredRows.length === 0) ? 'block' : 'none';

    document.getElementById('pag-start').textContent = filteredRows.length > 0 ? start + 1 : 0;
    document.getElementById('pag-end').textContent   = Math.min(end, filteredRows.length);
    document.getElementById('pag-total').textContent = filteredRows.length;

    renderPaginationButtons(Math.ceil(filteredRows.length / pageSize));
}

function renderPaginationButtons(totalPages) {
    var container = document.getElementById('paginationButtons');
    container.innerHTML = '';
    if (totalPages <= 1) return;

    function makeBtn(label, onclick, disabled, active) {
        var b = document.createElement('button');
        b.type = 'button';
        b.textContent = label;
        b.disabled = disabled;
        b.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid var(--outline-variant); cursor:pointer; font-size:13px; background:' + (active ? 'var(--primary)' : 'var(--surface)') + '; color:' + (active ? 'var(--on-primary)' : 'var(--on-surface)') + ';';
        if (onclick) b.onclick = onclick;
        return b;
    }

    container.appendChild(makeBtn('‹', function(){ currentPage--; applyPagination(); }, currentPage === 1, false));
    for (var p = 1; p <= totalPages; p++) {
        (function(page) {
            container.appendChild(makeBtn(page, function(){ currentPage = page; applyPagination(); }, false, page === currentPage));
        })(p);
    }
    container.appendChild(makeBtn('›', function(){ currentPage++; applyPagination(); }, currentPage === totalPages, false));
}

document.addEventListener('DOMContentLoaded', function() {
    filterTable();
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
