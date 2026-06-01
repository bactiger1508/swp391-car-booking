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
                                    
                                    <%-- Nút Duyệt sử dụng Modal tùy chỉnh --%>
                                    <form method="post" action="${pageContext.request.contextPath}/bookings/approval" style="display:inline;" id="approveForm-${b.bookingId}">
                                        <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                                        <input type="hidden" name="action" value="approve"/>
                                        <button type="button" class="bk-btn bk-btn-success bk-btn-sm" onclick="openApproveModal(${b.bookingId})">Duyệt</button>
                                    </form>
                                    
                                    <%-- Nút Từ chối sử dụng Modal tùy chỉnh --%>
                                    <form method="post" action="${pageContext.request.contextPath}/bookings/approval" style="display:inline;" id="rejectForm-${b.bookingId}">
                                        <input type="hidden" name="bookingId" value="${b.bookingId}"/>
                                        <input type="hidden" name="action" value="reject"/>
                                        <input type="hidden" name="reason" value=""/>
                                        <button type="button" class="bk-btn bk-btn-danger bk-btn-sm" onclick="openRejectModal(${b.bookingId})">Từ chối</button>
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

<%-- BK CUSTOM MODAL POPUP (GIAO DIỆN HỘP THOẠI XÁC NHẬN TÙY CHỈNH) --%>
<div id="customConfirmModal" class="bk-modal">
    <div class="bk-modal-content">
        <div class="bk-modal-header">
            <h3 id="modalTitle">Tiêu đề hộp thoại</h3>
            <span class="modal-close-icon" onclick="closeModal()">&times;</span>
        </div>
        <div class="bk-modal-body">
            <p id="modalMessage">Nội dung xác nhận...</p>
            
            <%-- Khung nhập lý do từ chối (chỉ hiện khi nhấn Từ chối) --%>
            <div id="modalInputContainer" style="display:none;margin-top:16px;">
                <label class="bk-form-label" style="margin-bottom:8px;display:block;">Lý do từ chối đơn hàng</label>
                <textarea id="modalReasonInput" class="bk-form-textarea" rows="3" placeholder="Nhập lý do từ chối tại đây..." style="padding-left:12px;"></textarea>
                <div id="modalErrorMsg" style="color:var(--error);font-size:12px;font-weight:600;margin-top:4px;display:none;">Lý do từ chối không được để trống!</div>
            </div>
        </div>
        <div class="bk-modal-footer">
            <button type="button" class="bk-btn bk-btn-outline" onclick="closeModal()">Hủy bỏ</button>
            <button type="button" id="modalConfirmBtn" class="bk-btn bk-btn-primary">Xác nhận</button>
        </div>
    </div>
</div>

<%-- CSS DÀNH RIÊNG CHO CUSTOM MODAL POPUP --%>
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
var isRejectAction = false;

function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#bookingTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}

function openApproveModal(bookingId) {
    activeForm = document.getElementById('approveForm-' + bookingId);
    isRejectAction = false;
    
    document.getElementById('modalTitle').textContent = "Phê duyệt đơn đặt xe #" + bookingId;
    document.getElementById('modalMessage').textContent = "Bạn có chắc chắn muốn phê duyệt đơn đặt xe #BK-" + bookingId + " này không? Xe sẽ được chuyển trạng thái chuẩn bị bàn giao.";
    document.getElementById('modalInputContainer').style.display = 'none';
    
    var confirmBtn = document.getElementById('modalConfirmBtn');
    confirmBtn.className = "bk-btn bk-btn-primary"; // Xanh dương
    
    document.getElementById('customConfirmModal').classList.add('open');
}

function openRejectModal(bookingId) {
    activeForm = document.getElementById('rejectForm-' + bookingId);
    isRejectAction = true;
    
    document.getElementById('modalTitle').textContent = "Từ chối đơn đặt xe #" + bookingId;
    document.getElementById('modalMessage').textContent = "Vui lòng nhập lý do cụ thể để gửi thông báo từ chối đơn đặt xe #BK-" + bookingId + " cho khách hàng:";
    
    var reasonInput = document.getElementById('modalReasonInput');
    reasonInput.value = "Không đạt yêu cầu"; // mặc định gợi ý
    document.getElementById('modalInputContainer').style.display = 'block';
    document.getElementById('modalErrorMsg').style.display = 'none';
    
    var confirmBtn = document.getElementById('modalConfirmBtn');
    confirmBtn.className = "bk-btn bk-btn-danger"; // Đỏ
    
    document.getElementById('customConfirmModal').classList.add('open');
    reasonInput.focus();
}

function closeModal() {
    document.getElementById('customConfirmModal').classList.remove('open');
    activeForm = null;
}

// Xử lý nút Xác nhận trên Modal tùy chỉnh
document.getElementById('modalConfirmBtn').onclick = function() {
    if (!activeForm) return;
    
    if (isRejectAction) {
        var reasonVal = document.getElementById('modalReasonInput').value.trim();
        if (reasonVal === "") {
            document.getElementById('modalErrorMsg').style.display = 'block';
            return;
        }
        activeForm.querySelector('input[name="reason"]').value = reasonVal;
    }
    
    // Tắt modal và submit form thực tế
    document.getElementById('customConfirmModal').classList.remove('open');
    activeForm.submit();
};
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
