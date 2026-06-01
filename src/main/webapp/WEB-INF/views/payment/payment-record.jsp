<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Thanh Toán & Giao Dịch"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Thanh toán & Giao dịch</span>
        </div>
        <h2>Giao Dịch & Nhật Ký Thanh Toán</h2>
        <p>Ghi nhận các giao dịch thanh toán mới của khách hàng và theo dõi toàn bộ lịch sử thanh toán đặt cọc, thanh toán thuê xe, phụ phí.</p>
    </div>
</div>

<div class="page-content" style="max-width: 1200px; margin: 0 auto; padding-top: 0;">
    
    <%-- Toast container for screen notifications --%>
    <div class="toast-container" id="toast-container">
        <c:if test="${not empty sessionScope.paymentSuccess}">
            <div class="toast toast-success" id="toast-success">
                <div class="toast-content">
                    <span class="toast-icon">✨</span>
                    <span class="toast-message">${sessionScope.paymentSuccess}</span>
                </div>
                <button class="toast-close" onclick="closeToast('toast-success')">&times;</button>
            </div>
            <c:remove var="paymentSuccess" scope="session"/>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="toast toast-error" id="toast-error">
                <div class="toast-content">
                    <span class="toast-icon">⚠️</span>
                    <span class="toast-message">${errorMsg}</span>
                </div>
                <button class="toast-close" onclick="closeToast('toast-error')">&times;</button>
            </div>
        </c:if>
    </div>

    <%-- Record New Payment Form (Bento Style) --%>
    <div class="bk-card" style="margin-bottom: 28px;">
        <div class="bk-card-title">
            <span class="material-symbols-outlined">payments</span>
            <span>Ghi Nhận Thanh Toán Mới</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/payments/record" id="form-record-payment" style="margin-top: 16px;">
            <div class="bk-form-grid" style="grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;">

                <%-- Mã Đặt Xe --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="bookingId">Mã Đặt Xe *</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">directions_car</span>
                        <input type="number" id="bookingId" name="bookingId" class="bk-form-input" required placeholder="VD: 1">
                    </div>
                </div>

                <%-- Mã Hợp Đồng --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="contractId">Mã Hợp Đồng</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">description</span>
                        <input type="number" id="contractId" name="contractId" class="bk-form-input" placeholder="Để trống nếu không có">
                    </div>
                </div>

                <%-- Số Tiền --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="amount">Số Tiền (VND) *</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">attach_money</span>
                        <input type="number" id="amount" name="amount" class="bk-form-input" required min="1" placeholder="VD: 1800000">
                    </div>
                </div>

                <%-- Loại Thanh Toán --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="paymentType">Loại Thanh Toán *</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">category</span>
                        <select id="paymentType" name="paymentType" class="bk-form-select" required>
                            <option value="">-- Chọn loại --</option>
                            <option value="DEPOSIT">Đặt Cọc (DEPOSIT)</option>
                            <option value="RENTAL">Tiền Thuê (RENTAL)</option>
                            <option value="ADDITIONAL_FEE">Phí Phát Sinh</option>
                            <option value="REFUND">Hoàn Tiền (REFUND)</option>
                        </select>
                    </div>
                </div>

                <%-- Phương Thức --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="paymentMethod">Phương Thức *</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">credit_card</span>
                        <select id="paymentMethod" name="paymentMethod" class="bk-form-select" required>
                            <option value="">-- Chọn phương thức --</option>
                            <c:if test="${enabledMethods['CASH']}">
                                <option value="CASH">💵 Tiền Mặt</option>
                            </c:if>
                            <c:if test="${enabledMethods['BANK_TRANSFER']}">
                                <option value="BANK_TRANSFER">🏦 Chuyển Khoản</option>
                            </c:if>
                            <c:if test="${enabledMethods['CARD']}">
                                <option value="CARD">💳 Thẻ Tín Dụng/Ghi Nợ</option>
                            </c:if>
                            <c:if test="${enabledMethods['MOMO']}">
                                <option value="MOMO">📱 MoMo</option>
                            </c:if>
                            <c:if test="${enabledMethods['VNPAY']}">
                                <option value="VNPAY">🔵 VNPay</option>
                            </c:if>
                            <c:if test="${enabledMethods['ZALOPAY']}">
                                <option value="ZALOPAY">🟢 ZaloPay</option>
                            </c:if>
                        </select>
                    </div>
                    <span style="color:var(--text-secondary);font-size:11px;margin-top:2px;">
                        Chỉ hiện phương thức đang bật.
                        <a href="${pageContext.request.contextPath}/admin/payment-settings" style="color:var(--primary);font-weight:600;text-decoration:underline;">Cấu hình</a>
                    </span>
                </div>

                <%-- Mã Giao Dịch --%>
                <div class="bk-form-group">
                    <label class="bk-form-label" for="transactionRef">Mã Giao Dịch</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">receipt</span>
                        <input type="text" id="transactionRef" name="transactionRef" class="bk-form-input" placeholder="VD: TXN-20260530-001">
                    </div>
                </div>

                <%-- Ghi Chú --%>
                <div class="bk-form-group full" style="grid-column: span 3; margin-top: 8px;">
                    <label class="bk-form-label" for="notes">Ghi Chú</label>
                    <div class="bk-form-input-wrap">
                        <span class="material-symbols-outlined">notes</span>
                        <input type="text" id="notes" name="notes" class="bk-form-input" placeholder="Ghi chú thêm (nếu có)">
                    </div>
                </div>

            </div>
            <div style="display:flex; justify-content:flex-end; margin-top:20px;">
                <button type="submit" class="bk-btn bk-btn-primary" id="btn-record-payment">
                    <span class="material-symbols-outlined">save</span> Lưu Thanh Toán
                </button>
            </div>
        </form>
    </div>

    <%-- Payment History Table (Bento Style) --%>
    <div class="bk-card">
        <div class="bk-card-title">
            <span class="material-symbols-outlined">history</span>
            <span>Nhật Ký Giao Dịch Thanh Toán</span>
        </div>
        
        <div class="bk-table-toolbar" style="margin-bottom: 20px; margin-top: 16px;">
            <div class="bk-table-search" style="flex: 1; min-width: 250px;">
                <span class="material-symbols-outlined">search</span>
                <input type="text" id="searchInput" placeholder="Tìm kiếm giao dịch theo mã, phương thức..." oninput="filterTable()">
            </div>
        </div>

        <c:if test="${not empty payments}">
            <div class="bk-table-container">
                <table class="bk-table" id="paymentTable">
                    <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Đơn Hàng & Hợp Đồng</th>
                        <th>Số Tiền</th>
                        <th>Loại Giao Dịch</th>
                        <th>Phương Thức</th>
                        <th>Trạng Thái</th>
                        <th>Ghi Chú</th>
                        <th>Ngày Thanh Toán</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="p" items="${payments}">
                        <tr>
                            <td class="code">
                                PAY-${p.paymentId}
                                <c:if test="${not empty p.transactionRef}">
                                    <div class="sub" style="font-weight: normal; color: var(--text-secondary);">Ref: ${p.transactionRef}</div>
                                </c:if>
                            </td>
                            <td>
                                <div>
                                    <a href="${pageContext.request.contextPath}/bookings/detail?id=${p.bookingId}" style="font-weight:600;color:var(--primary);">
                                        #BK-${p.bookingId}
                                    </a>
                                </div>
                                <c:if test="${not empty p.contractId && p.contractId > 0}">
                                    <div class="sub">
                                        <a href="${pageContext.request.contextPath}/contracts/detail?id=${p.contractId}" style="color: var(--text-secondary);">
                                            Hợp đồng: #CT-${p.contractId}
                                        </a>
                                    </div>
                                </c:if>
                            </td>
                            <td>
                                <strong style="font-size: 15px; color: var(--primary);">
                                    <fmt:formatNumber value="${p.amount}" pattern="#,##0"/> VND
                                </strong>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.paymentType == 'DEPOSIT'}"><span style="font-weight:600;color:var(--secondary);">💵 Tiền đặt cọc</span></c:when>
                                    <c:when test="${p.paymentType == 'RENTAL'}"><span style="font-weight:600;color:var(--primary);">🚗 Thanh toán thuê xe</span></c:when>
                                    <c:when test="${p.paymentType == 'ADDITIONAL_FEE'}"><span style="font-weight:600;color:var(--error, #ba1a1a);"><span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;">warning</span> Phụ phí phát sinh</span></c:when>
                                    <c:when test="${p.paymentType == 'REFUND'}"><span style="font-weight:600;color:var(--info, #39B8FF);">🔄 Hoàn trả cọc</span></c:when>
                                    <c:otherwise>${p.paymentType}</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="font-weight:500;">
                                    <c:choose>
                                        <c:when test="${p.paymentMethod == 'CASH'}">Tiền mặt</c:when>
                                        <c:when test="${p.paymentMethod == 'BANK_TRANSFER'}">Chuyển khoản</c:when>
                                        <c:when test="${p.paymentMethod == 'CARD'}">Thẻ tín dụng</c:when>
                                        <c:when test="${p.paymentMethod == 'MOMO'}">Ví MoMo</c:when>
                                        <c:when test="${p.paymentMethod == 'VNPAY'}">Cổng VNPay</c:when>
                                        <c:when test="${p.paymentMethod == 'ZALOPAY'}">Ví ZaloPay</c:when>
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
                            <td style="font-size: 13px; color: var(--text-secondary); max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                ${not empty p.notes ? p.notes : '—'}
                            </td>
                            <td style="font-size:13px;color:var(--text-secondary);">
                                ${p.paidAt != null ? p.paidAt.format(dateTimeFormatter) : '—'}
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
                <h3>Chưa có giao dịch thanh toán nào</h3>
                <p>Hệ thống hiện tại chưa phát sinh giao dịch thanh toán nào được lưu trữ.</p>
            </div>
        </c:if>
    </div>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#paymentTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', () => {
    const successToast = document.getElementById('toast-success');
    const errorToast = document.getElementById('toast-error');
    
    if (successToast) {
        setTimeout(() => successToast.classList.add('show'), 100);
        setTimeout(() => fadeOutToast(successToast), 4000);
    }
    if (errorToast) {
        setTimeout(() => errorToast.classList.add('show'), 100);
        setTimeout(() => fadeOutToast(errorToast), 5000);
    }
});

function closeToast(id) {
    const toast = document.getElementById(id);
    if (toast) {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 400);
    }
}

function fadeOutToast(toast) {
    if (toast && toast.parentNode) {
        toast.classList.add('fade-out');
        setTimeout(() => toast.remove(), 300);
    }
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
