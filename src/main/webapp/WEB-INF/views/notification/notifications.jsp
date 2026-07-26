<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
        <div style="margin-bottom: 16px; position: relative; max-width: 360px;">
            <span class="material-symbols-outlined" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 18px; color: var(--on-surface-variant);">search</span>
            <input type="text" id="notifSearchInput" placeholder="Tìm kiếm theo tiêu đề, nội dung..." oninput="filterNotifTable()"
                   style="width: 100%; padding: 8px 12px 8px 36px; border-radius: 8px; border: 1px solid var(--outline-variant); font-size: 13px; box-sizing: border-box;">
        </div>
        <div id="notifListContainer" style="display:flex; flex-direction:column;">
            <c:forEach items="${notifications}" var="notif">
                <div id="notif-${notif.notificationId}" class="notif-row" onclick="goToNotification(${notif.notificationId})"
                     data-search="${fn:toLowerCase(notif.title)} ${fn:toLowerCase(notif.message)}"
                     style="cursor:pointer; display:flex; align-items:flex-start; justify-content:space-between; gap:16px; padding:16px; border-bottom:1px solid var(--outline-variant); ${notif.read ? '' : 'background:var(--surface-container-lowest);'}">
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
                        <button onclick="event.stopPropagation(); markAsRead(${notif.notificationId})" class="bk-btn bk-btn-sm bk-btn-outline" style="flex-shrink:0;">Đánh dấu đã đọc</button>
                    </c:if>
                </div>
            </c:forEach>
        </div>
        <div id="notifEmptyState" style="display:none; text-align:center; padding:24px; color:var(--on-surface-variant);">
            Không tìm thấy thông báo phù hợp.
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; padding:12px 16px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
            <div style="font-size:13px; color:var(--on-surface-variant);">
                Hiển thị <span id="notifPagStart" style="font-weight:600;">0</span> đến <span id="notifPagEnd" style="font-weight:600;">0</span> trong số <span id="notifPagTotal" style="font-weight:600;">0</span> thông báo
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <label style="font-size:13px; color:var(--on-surface-variant);">Số dòng:</label>
                <select id="notifPageSizeSelect" onchange="changeNotifPageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                    <option value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                </select>
                <div id="notifPaginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;"></div>
            </div>
        </div>
    </c:if>
</div>

<script>
function goToNotification(notificationId) {
    window.location.href = '${pageContext.request.contextPath}/notifications?action=click&notificationId=' + notificationId;
}

let notifCurrentPage = 1;
let notifPageSize = 10;
let notifFilteredRows = [];

function filterNotifTable() {
    const keyword = document.getElementById('notifSearchInput').value.trim().toLowerCase();
    const allRows = Array.from(document.querySelectorAll('.notif-row'));
    notifFilteredRows = allRows.filter(row => {
        const searchText = row.getAttribute('data-search') || '';
        return searchText.indexOf(keyword) !== -1;
    });
    notifCurrentPage = 1;
    applyNotifPagination();
}

function changeNotifPageSize() {
    notifPageSize = parseInt(document.getElementById('notifPageSizeSelect').value);
    notifCurrentPage = 1;
    applyNotifPagination();
}

function applyNotifPagination() {
    const allRows = Array.from(document.querySelectorAll('.notif-row'));
    allRows.forEach(row => row.style.display = 'none');

    const totalItems = notifFilteredRows.length;
    const totalPages = Math.max(1, Math.ceil(totalItems / notifPageSize));
    if (notifCurrentPage > totalPages) notifCurrentPage = totalPages;

    const start = (notifCurrentPage - 1) * notifPageSize;
    const end = Math.min(start + notifPageSize, totalItems);
    const pageRows = notifFilteredRows.slice(start, end);
    pageRows.forEach(row => row.style.display = '');

    document.getElementById('notifPagStart').textContent = totalItems === 0 ? 0 : start + 1;
    document.getElementById('notifPagEnd').textContent = end;
    document.getElementById('notifPagTotal').textContent = totalItems;

    document.getElementById('notifListContainer').style.display = totalItems === 0 ? 'none' : '';
    document.getElementById('notifEmptyState').style.display = totalItems === 0 ? '' : 'none';

    renderNotifPaginationButtons(totalPages);
}

function renderNotifPaginationButtons(totalPages) {
    const container = document.getElementById('notifPaginationButtons');
    container.innerHTML = '';

    const makeBtn = (label, page, disabled, active) => {
        const btn = document.createElement('button');
        btn.textContent = label;
        btn.disabled = disabled;
        btn.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid var(--outline-variant); background:' + (active ? 'var(--primary)' : 'var(--surface)') + '; color:' + (active ? '#fff' : 'var(--on-surface)') + '; font-size:12px; cursor:' + (disabled ? 'not-allowed' : 'pointer') + '; opacity:' + (disabled ? '0.5' : '1') + ';';
        btn.onclick = () => { notifCurrentPage = page; applyNotifPagination(); };
        return btn;
    };

    container.appendChild(makeBtn('«', notifCurrentPage - 1, notifCurrentPage <= 1, false));
    for (let p = 1; p <= totalPages; p++) {
        container.appendChild(makeBtn(String(p), p, false, p === notifCurrentPage));
    }
    container.appendChild(makeBtn('»', notifCurrentPage + 1, notifCurrentPage >= totalPages, false));
}

document.addEventListener('DOMContentLoaded', function() {
    notifFilteredRows = Array.from(document.querySelectorAll('.notif-row'));
    if (notifFilteredRows.length > 0) {
        applyNotifPagination();
    }
});

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
