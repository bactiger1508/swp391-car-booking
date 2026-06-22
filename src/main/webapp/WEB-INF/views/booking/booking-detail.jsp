<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi Tiết Booking"/>
</jsp:include>

<%-- Page Header --%>
<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/bookings/my">Đơn thuê của tôi</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Chi tiết đơn #BK-${booking.bookingId}</span>
        </div>
        <h2>Chi tiết Đơn thuê</h2>
    </div>
    <div style="display:flex;align-items:center;gap:12px;background:var(--surface-container-lowest);padding:12px 20px;border-radius:12px;border:1px solid var(--outline-variant);">
        <span style="font-size:14px;color:var(--on-surface-variant);font-weight:500;">Trạng thái:</span>
        <c:choose>
            <c:when test="${booking.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ xử lý</span></c:when>
            <c:when test="${booking.status == 'CONFIRMED'}"><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đã xác nhận</span></c:when>
            <c:when test="${booking.status == 'IN_PROGRESS'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Đang thuê</span></c:when>
            <c:when test="${booking.status == 'COMPLETED'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hoàn tất</span></c:when>
            <c:when test="${booking.status == 'REJECTED'}"><span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Đã từ chối</span></c:when>
            <c:when test="${booking.status == 'CANCELLED'}"><span class="bk-badge bk-badge-cancelled"><span class="bk-badge-dot"></span> Đã hủy</span></c:when>
            <c:otherwise><span class="bk-badge">${booking.status}</span></c:otherwise>
        </c:choose>
    </div>
</div>

<c:if test="${not empty success}">
    <div class="bk-alert bk-alert-success"><span class="material-symbols-outlined">check_circle</span> ${success}</div>
</c:if>

<div class="bk-detail-grid">
    <%-- LEFT --%>
    <div style="display:flex;flex-direction:column;gap:24px;">
        <%-- Vehicle Card --%>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">directions_car</span> Thông tin xe thuê
            </div>
            <c:if test="${not empty car}">
                <div style="display:flex;gap:16px;">
                    <div style="width:96px;height:96px;border-radius:8px;background:var(--surface-container-high);flex-shrink:0;display:flex;align-items:center;justify-content:center;">
                        <span class="material-symbols-outlined" style="font-size:40px;color:var(--outline);">directions_car</span>
                    </div>
                    <div>
                        <div style="font-weight:700;font-size:16px;color:var(--primary);">${car.brand} ${car.model}</div>
                        <div style="font-size:14px;color:var(--on-surface-variant);margin-top:4px;">Biển số: ${car.licensePlate}</div>
                        <div style="font-size:14px;color:var(--primary);font-weight:600;margin-top:8px;">
                            <fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/>đ / ngày
                        </div>
                    </div>
                </div>
            </c:if>
        </div>

        <%-- Schedule --%>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">calendar_today</span> Lịch trình thuê xe
            </div>
            <div class="bk-form-grid">
                <div class="bk-form-group">
                    <label class="bk-form-label">Ngày nhận xe</label>
                    <div style="font-size:16px;font-weight:600;color:var(--primary);padding:8px 0;">
                        <fmt:formatNumber value="${booking.startDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${booking.startDate.monthValue}" pattern="00"/>/${booking.startDate.year} <fmt:formatNumber value="${booking.startDate.hour}" pattern="00"/>:<fmt:formatNumber value="${booking.startDate.minute}" pattern="00"/>
                    </div>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Ngày trả xe</label>
                    <div style="font-size:16px;font-weight:600;color:var(--primary);padding:8px 0;">
                        <fmt:formatNumber value="${booking.endDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${booking.endDate.monthValue}" pattern="00"/>/${booking.endDate.year} <fmt:formatNumber value="${booking.endDate.hour}" pattern="00"/>:<fmt:formatNumber value="${booking.endDate.minute}" pattern="00"/>
                    </div>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Điểm nhận xe</label>
                    <div style="font-size:14px;padding:8px 0;">${not empty booking.pickupLocation ? booking.pickupLocation : 'Văn phòng chính'}</div>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Điểm trả xe</label>
                    <div style="font-size:14px;padding:8px 0;">${not empty booking.returnLocation ? booking.returnLocation : 'Văn phòng chính'}</div>
                </div>
            </div>
        </div>

        <%-- Rejection reason --%>
        <c:if test="${booking.status == 'REJECTED' && not empty booking.cancelReason}">
            <div class="bk-card" style="border-color:var(--error);border-left:4px solid var(--error);">
                <div class="bk-card-title" style="color:var(--error);">
                    <span class="material-symbols-outlined">block</span> Lý do từ chối
                </div>
                <p style="font-size:14px;color:var(--on-surface-variant);">${booking.cancelReason}</p>
            </div>
        </c:if>
        <c:if test="${booking.status == 'CANCELLED' && not empty booking.cancelReason}">
            <div class="bk-card" style="border-color:var(--error);border-left:4px solid var(--error);">
                <div class="bk-card-title" style="color:var(--error);">
                    <span class="material-symbols-outlined">cancel</span> Lý do hủy
                </div>
                <p style="font-size:14px;color:var(--on-surface-variant);">${booking.cancelReason}</p>
            </div>
        </c:if>
    </div>

    <%-- RIGHT: Payment Summary --%>
    <div>
        <div class="bk-cost-card" style="position:sticky;top:96px;">
            <h3><span class="material-symbols-outlined">receipt_long</span> Tóm tắt thanh toán</h3>
            <c:if test="${not empty rentalDays && not empty car}">
                <div class="bk-detail-rows">
                    <div class="bk-detail-row">
                        <span class="label">Giá thuê (${rentalDays} ngày)</span>
                        <span class="value"><fmt:formatNumber value="${car.dailyRate * rentalDays}" type="number" groupingUsed="true"/>đ</span>
                    </div>
                    <div class="bk-detail-row">
                        <span class="label">Thuế & Phí (10%)</span>
                        <span class="value"><fmt:formatNumber value="${car.dailyRate * rentalDays * 0.1}" type="number" groupingUsed="true"/>đ</span>
                    </div>
                </div>
                <div class="bk-summary-total">
                    <span class="label">Tổng cộng</span>
                    <span class="value"><fmt:formatNumber value="${car.dailyRate * rentalDays * 1.1}" type="number" groupingUsed="true"/>đ</span>
                </div>
                <div class="bk-summary-highlight">
                    <div>
                        <div class="label">Tiền cọc</div>
                        <div style="font-size:12px;color:var(--on-surface-variant);">Tạm giữ</div>
                    </div>
                    <span class="value"><fmt:formatNumber value="${booking.depositAmount}" type="number" groupingUsed="true"/>đ</span>
                </div>
            </c:if>

            <%-- Actions --%>
            <div style="margin-top:24px;display:flex;flex-direction:column;gap:12px;">
                <a href="${pageContext.request.contextPath}/bookings/my" class="bk-btn bk-btn-outline" style="justify-content:center;">
                    <span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách
                </a>

                <a href="${pageContext.request.contextPath}/handover/view?bookingId=${booking.bookingId}&carId=${booking.carId}" class="bk-btn bk-btn-outline" style="justify-content:center;">
                    <span class="material-symbols-outlined"></span> Xem biên bản bàn giao
                </a>



                <c:if test="${booking.status == 'PENDING' || booking.status == 'CONFIRMED'}">
                    <form method="post" action="${pageContext.request.contextPath}/bookings/cancel" style="width:100%;">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                        <input type="hidden" name="reason" value="Khách hàng tự hủy"/>
                        <button type="submit" class="bk-btn bk-btn-danger" style="width:100%;justify-content:center;" onclick="return confirm('Bạn có chắc chắn muốn hủy đơn thuê này?')">
                            <span class="material-symbols-outlined">cancel</span> Hủy đơn thuê
                        </button>
                    </form>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
