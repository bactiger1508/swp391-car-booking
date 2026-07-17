<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Thông Báo"/>
</jsp:include>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<div class="bk-page-header">
    <div>
        <h2>Thông Báo</h2>
        <p>Các thông báo liên quan đến đặt xe, hợp đồng, thanh toán và hoạt động tài khoản của bạn.</p>
    </div>
    <c:if test="${unreadCount > 0}">
        <button onclick="markAllAsRead()" class="bk-btn bk-btn-outline">
            <span class="material-symbols-outlined" style="font-size: 18px;">done_all</span>
            Đánh dấu tất cả đã đọc
        </button>
    </c:if>
</div>

<div class="bk-table-container">
    <c:if test="${empty notifications}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">notifications_off</span>
            <h3>Không có thông báo nào</h3>
            <p>Bạn sẽ nhận được thông báo khi có hoạt động mới liên quan đến tài khoản.</p>
        </div>
    </c:if>

    <c:if test="${not empty notifications}">
        <div style="display:flex; flex-direction:column;">
            <c:forEach items="${notifications}" var="notif">
                <div id="notif-${notif.notificationId}" style="display:flex; align-items:flex-start; justify-content:space-between; gap:16px; padding:16px; border-bottom:1px solid var(--outline-variant); ${notif.read ? '' : 'background:var(--surface-container-lowest);'}">
                    <div style="flex:1; min-width:0;">
                        <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
                            <c:choose>
                                <c:when test="${notif.notificationType == 'BOOKING'}"><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đặt xe</span></c:when>
                                <c:when test="${notif.notificationType == 'PAYMENT'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Thanh toán</span></c:when>
                                <c:when test="${notif.notificationType == 'CONTRACT'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Hợp đồng</span></c:when>
                                <c:when test="${notif.notificationType == 'HANDOVER'}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Giao/Nhận xe</span></c:when>
                                <c:otherwise><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Hệ thống</span></c:otherwise>
                            </c:choose>
                            <span style="font-weight:${notif.read ? '500' : '700'}; color:var(--on-background);">${notif.title}</span>
                        </div>
                        <div style="font-size:14px; color:var(--on-surface-variant);">${notif.message}</div>
                        <div style="font-size:12px; color:var(--on-surface-variant); margin-top:6px;">${notif.createdAt}</div>
                    </div>
                    <c:if test="${!notif.read}">
                        <button onclick="markAsRead(${notif.notificationId})" class="bk-btn bk-btn-sm bk-btn-outline" style="flex-shrink:0;">Đánh dấu đã đọc</button>
                    </c:if>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<script>
function markAsRead(notificationId) {
    fetch('${pageContext.request.contextPath}/notifications', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=markAsRead&notificationId=' + notificationId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}

function markAllAsRead() {
    fetch('${pageContext.request.contextPath}/notifications', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=markAllAsRead'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
