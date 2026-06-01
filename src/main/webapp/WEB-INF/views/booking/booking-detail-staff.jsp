<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi Tiết Booking (Staff)"/>
</jsp:include>

<%-- Page Header --%>
<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/bookings/manage">Quản lý đặt xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Chi tiết đơn #BK-${booking.bookingId}</span>
        </div>
        <h2>Chi tiết & Xử lý Đơn thuê</h2>
    </div>
    <div style="display:flex;align-items:center;gap:12px;background:var(--surface-container-lowest);padding:12px 20px;border-radius:12px;border:1px solid var(--outline-variant);">
        <span style="font-size:14px;color:var(--on-surface-variant);font-weight:500;">Trạng thái:</span>
        <c:choose>
            <c:when test="${booking.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ duyệt</span></c:when>
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

        <%-- Customer + Vehicle cards --%>
        <div class="bk-detail-2col">
            <%-- Customer --%>
            <div class="bk-card">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">account_circle</span> Thông tin khách hàng
                </div>
                <c:if test="${not empty customer}">
                    <div class="bk-detail-rows">
                        <div class="bk-detail-row"><span class="label">Họ và tên</span><span class="value">${customer.fullName}</span></div>
                        <div class="bk-detail-row"><span class="label">Email</span><span class="value">${customer.email}</span></div>
                        <div class="bk-detail-row"><span class="label">Số điện thoại</span><span class="value">${not empty customer.phone ? customer.phone : 'N/A'}</span></div>
                    </div>
                </c:if>
            </div>

            <%-- Vehicle --%>
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
        </div>

        <%-- Schedule --%>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">edit_calendar</span> Lịch trình thuê xe
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

            <c:if test="${not empty booking.notes}">
                <div class="bk-info-note" style="margin-top:16px;">
                    <span class="material-symbols-outlined">info</span>
                    <p><strong>Ghi chú:</strong> ${booking.notes}</p>
                </div>
            </c:if>
        </div>

        <%-- Rejection / Cancellation reason --%>
        <c:if test="${booking.status == 'REJECTED' && not empty booking.cancelReason}">
            <div class="bk-card" style="border-left:4px solid var(--error);">
                <div class="bk-card-title" style="color:var(--error);"><span class="material-symbols-outlined">block</span> Lý do từ chối</div>
                <p style="font-size:14px;color:var(--on-surface-variant);">${booking.cancelReason}</p>
            </div>
        </c:if>
        <c:if test="${booking.status == 'CANCELLED' && not empty booking.cancelReason}">
            <div class="bk-card" style="border-left:4px solid var(--error);">
                <div class="bk-card-title" style="color:var(--error);"><span class="material-symbols-outlined">cancel</span> Lý do hủy</div>
                <p style="font-size:14px;color:var(--on-surface-variant);">${booking.cancelReason}</p>
            </div>
        </c:if>
    </div>

    <%-- RIGHT: Summary + Actions --%>
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
                    <div><div class="label">Tiền cọc</div></div>
                    <span class="value"><fmt:formatNumber value="${booking.depositAmount}" type="number" groupingUsed="true"/>đ</span>
                </div>
            </c:if>

            <%-- Staff Actions --%>
            <c:if test="${booking.status == 'PENDING'}">
                <div style="margin-top:24px;display:flex;flex-direction:column;gap:12px;">
                    <form method="post" action="${pageContext.request.contextPath}/bookings/approval" style="width:100%;" id="approveForm">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                        <input type="hidden" name="action" value="approve"/>
                        <button type="button" class="bk-btn bk-btn-primary" style="width:100%;justify-content:center;padding:14px;" onclick="handleApproveClick()">
                            <span class="material-symbols-outlined">check_circle</span> Duyệt đơn
                        </button>
                    </form>

                    <button type="button" class="bk-btn bk-btn-danger" style="width:100%;justify-content:center;padding:14px;" onclick="toggleReject()">
                        <span class="material-symbols-outlined">cancel</span> Từ chối đơn
                    </button>

                    <div class="bk-reject-form" id="rejectForm">
                        <form method="post" action="${pageContext.request.contextPath}/bookings/approval" id="rejectFormAction">
                            <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                            <input type="hidden" name="action" value="reject"/>
                            <div class="bk-form-group" style="margin-bottom:12px;">
                                <label class="bk-form-label">Lý do từ chối</label>
                                <textarea name="reason" id="rejectReasonTextarea" class="bk-form-textarea" rows="3" required placeholder="Nhập lý do từ chối..."></textarea>
                                <div id="rejectErrorMsg" style="color:var(--error);font-size:12px;font-weight:600;margin-top:4px;display:none;">Lý do từ chối không được để trống!</div>
                            </div>
                            <button type="button" class="bk-btn bk-btn-danger" style="width:100%;justify-content:center;" onclick="handleRejectClick()">
                                Xác nhận từ chối
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>

            <div style="margin-top:16px;">
                <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-btn bk-btn-outline" style="width:100%;justify-content:center;">
                    <span class="material-symbols-outlined">arrow_back</span> Quay lại
                </a>
            </div>
        </div>
    </div>
</div>

<%-- BK CUSTOM MODAL POPUP --%>
<div id="customConfirmModal" class="bk-modal">
    <div class="bk-modal-content">
        <div class="bk-modal-header">
            <h3 id="modalTitle">Tiêu đề</h3>
            <span class="modal-close-icon" onclick="closeModal()">&times;</span>
        </div>
        <div class="bk-modal-body">
            <p id="modalMessage">Nội dung...</p>
        </div>
        <div class="bk-modal-footer">
            <button type="button" class="bk-btn bk-btn-outline" onclick="closeModal()">Hủy bỏ</button>
            <button type="button" id="modalConfirmBtn" class="bk-btn bk-btn-primary">Xác nhận</button>
        </div>
    </div>
</div>

<style>
.bk-modal {
    position: fixed;
    top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(4, 22, 56, 0.4);
    backdrop-filter: blur(4px);
    display: flex; align-items: center; justify-content: center;
    z-index: 1000;
    opacity: 0; pointer-events: none;
    transition: opacity 0.2s ease-in-out;
}
.bk-modal.open {
    opacity: 1; pointer-events: auto;
}
.bk-modal-content {
    background: var(--surface-container-lowest);
    border: 1px solid var(--outline-variant);
    border-radius: var(--radius-xl);
    width: 90%; max-width: 480px;
    box-shadow: var(--shadow-lg);
    padding: 24px;
    transform: scale(0.9);
    transition: transform 0.2s ease-in-out;
}
.bk-modal.open .bk-modal-content {
    transform: scale(1);
}
.bk-modal-header {
    display: flex; justify-content: space-between; align-items: center;
    border-bottom: 1px solid var(--outline-variant);
    padding-bottom: 12px;
    margin-bottom: 16px;
}
.bk-modal-header h3 {
    font-size: 18px; font-weight: 700; color: var(--primary);
    margin: 0;
}
.modal-close-icon {
    font-size: 24px; font-weight: 700; color: var(--on-surface-variant);
    cursor: pointer; line-height: 1;
}
.modal-close-icon:hover { color: var(--primary); }
.bk-modal-body {
    font-size: 14px; color: var(--on-surface-variant);
    line-height: 1.6; margin-bottom: 24px;
}
.bk-modal-footer {
    display: flex; justify-content: flex-end; gap: 12px;
    border-top: 1px solid var(--outline-variant);
    padding-top: 16px;
}
</style>

<script>
var activeForm = null;

function toggleReject() {
    var form = document.getElementById('rejectForm');
    form.classList.toggle('open');
}

function handleApproveClick() {
    activeForm = document.getElementById('approveForm');
    
    document.getElementById('modalTitle').textContent = "Duyệt Đơn Đặt Xe";
    document.getElementById('modalMessage').textContent = "Bạn có chắc chắn muốn duyệt và phê duyệt đơn đặt xe #BK-${booking.bookingId} này không? Hệ thống sẽ tự động lập hợp đồng tương ứng cho đơn hàng này.";
    
    var confirmBtn = document.getElementById('modalConfirmBtn');
    confirmBtn.className = "bk-btn bk-btn-primary";
    
    document.getElementById('customConfirmModal').classList.add('open');
}

function handleRejectClick() {
    var reasonText = document.getElementById('rejectReasonTextarea').value.trim();
    if (reasonText === "") {
        document.getElementById('rejectErrorMsg').style.display = 'block';
        return;
    }
    document.getElementById('rejectErrorMsg').style.display = 'none';
    
    activeForm = document.getElementById('rejectFormAction');
    
    document.getElementById('modalTitle').textContent = "Từ Chối Đơn Đặt Xe";
    document.getElementById('modalMessage').textContent = "Xác nhận từ chối đơn đặt xe #BK-${booking.bookingId} với lý do: \"" + reasonText + "\"?";
    
    var confirmBtn = document.getElementById('modalConfirmBtn');
    confirmBtn.className = "bk-btn bk-btn-danger";
    
    document.getElementById('customConfirmModal').classList.add('open');
}

function closeModal() {
    document.getElementById('customConfirmModal').classList.remove('open');
    activeForm = null;
}

document.getElementById('modalConfirmBtn').onclick = function() {
    if (!activeForm) return;
    document.getElementById('customConfirmModal').classList.remove('open');
    activeForm.submit();
};
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
