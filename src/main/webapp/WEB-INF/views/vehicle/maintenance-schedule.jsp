<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Trình Bảo Dưỡng Xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Lịch Trình Bảo Dưỡng Xe</h2>
        <p>Theo dõi lịch trình và lên kế hoạch bảo dưỡng định kỳ cho toàn bộ đội xe.</p>
    </div>
</div>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 24px;">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<div class="bk-detail-grid" style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px; align-items: start;">
    <!-- Cột trái: Form lên lịch -->
    <div class="bk-card" style="padding: 24px;">
        <div class="bk-card-title" style="margin-bottom: 20px;">
            <span class="material-symbols-outlined">event_note</span> Lên Lịch Bảo Trì
        </div>
        <form action="${pageContext.request.contextPath}/maintenance" method="post">
            <div class="bk-form-group" style="margin-bottom: 16px;">
                <label class="bk-form-label">Chọn xe <span style="color:var(--error);">*</span></label>
                <select name="vehicleId" class="bk-form-select" required>
                    <option value="">-- Chọn xe --</option>
                    <c:forEach items="${allVehicles}" var="car">
                        <option value="${car.vehicleId}">${car.brand} ${car.model} (${car.licensePlate})</option>
                    </c:forEach>
                </select>
            </div>
            <div class="bk-form-group" style="margin-bottom: 16px;">
                <label class="bk-form-label">Ngày bắt đầu <span style="color:var(--error);">*</span></label>
                <input type="date" name="startDate" class="bk-form-input" style="padding-left: 12px;" required>
            </div>
            <div class="bk-form-group" style="margin-bottom: 16px;">
                <label class="bk-form-label">Ngày kết thúc dự kiến <span style="color:var(--error);">*</span></label>
                <input type="date" name="endDate" class="bk-form-input" style="padding-left: 12px;" required>
            </div>
            <div class="bk-form-group" style="margin-bottom: 20px;">
                <label class="bk-form-label">Ghi chú</label>
                <textarea name="notes" class="bk-form-textarea" placeholder="Nhập ghi chú hoặc mô tả bảo trì..." style="min-height: 80px;"></textarea>
            </div>
            <button type="submit" class="bk-btn bk-btn-primary" style="width: 100%; justify-content: center;">
                <span class="material-symbols-outlined" style="font-size: 18px; margin-right: 6px;">save</span> Lưu Lịch Bảo Trì
            </button>
        </form>
    </div>

    <!-- Cột phải: Grid danh sách lịch trình -->
    <div class="bk-card" style="padding: 24px;">
        <div class="bk-card-title" style="margin-bottom: 20px;">
            <span class="material-symbols-outlined">calendar_today</span> Danh Sách Kế Hoạch Bảo Trì
        </div>
        <c:if test="${empty schedules}">
            <div class="bk-empty" style="padding: 60px 20px; text-align: center; color: var(--text-secondary); background: var(--surface); border-radius: var(--radius-md); border: 1px dashed var(--outline-variant);">
                <span class="material-symbols-outlined" style="font-size: 48px; color: var(--outline);">event_busy</span>
                <h3 style="margin-top: 16px; font-weight: 600; color: var(--primary);">Chưa có lịch trình bảo trì nào</h3>
                <p style="margin-top: 4px; font-size: 14px;">Mọi xe hiện đang hoạt động bình thường trên hệ thống.</p>
            </div>
        </c:if>
        <c:if test="${not empty schedules}">
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px;" id="scheduleGrid">
                <c:forEach items="${schedules}" var="s">
                    <div class="schedule-card" style="border: 1px solid var(--outline-variant); border-radius: var(--radius-md); padding: 16px; background: var(--surface); display: flex; flex-direction: column; gap: 12px; transition: var(--transition);">
                        <div style="display: flex; justify-content: space-between; align-items: start; gap: 8px;">
                            <div style="font-weight: 700; color: var(--primary); font-size: 15px;">
                                <c:forEach items="${allVehicles}" var="car">
                                    <c:if test="${car.vehicleId == s.vehicleId}">
                                        ${car.brand} ${car.model}
                                    </c:if>
                                </c:forEach>
                            </div>
                            <c:choose>
                                <c:when test="${s.status == 'SCHEDULED'}">
                                    <span class="bk-badge bk-badge-pending" style="font-size: 11px; flex-shrink: 0;"><span class="bk-badge-dot"></span> Đã lên lịch</span>
                                </c:when>
                                <c:when test="${s.status == 'IN_PROGRESS'}">
                                    <span class="bk-badge bk-badge-progress" style="font-size: 11px; flex-shrink: 0;"><span class="bk-badge-dot"></span> Đang sửa</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="bk-badge bk-badge-completed" style="font-size: 11px; flex-shrink: 0;"><span class="bk-badge-dot"></span> ${s.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div style="font-size: 13px; color: var(--text-secondary);">
                            <c:forEach items="${allVehicles}" var="car">
                                <c:if test="${car.vehicleId == s.vehicleId}">
                                    Biển số: <span style="font-weight:600; color:var(--text-primary);">${car.licensePlate}</span>
                                </c:if>
                            </c:forEach>
                        </div>
                        <div style="font-size: 13px; color: var(--text-secondary); display: flex; flex-direction: column; gap: 4px; padding: 10px; background: var(--surface-container-low); border-radius: 4px; border: 1px solid var(--border-color);">
                            <div><strong>Bắt đầu:</strong> ${s.scheduledDate}</div>
                            <div><strong>Kết thúc dự kiến:</strong> ${s.completedDate}</div>
                        </div>
                        <c:if test="${not empty s.notes}">
                            <div style="font-size: 12px; color: var(--text-secondary); border-top: 1px dashed var(--outline-variant); padding-top: 8px; font-style: italic;">
                                "${s.notes}"
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding-top:16px; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                <div style="font-size:13px; color:var(--text-secondary);">
                    Hiển thị <span id="schedPagStart" style="font-weight:600;">0</span> đến <span id="schedPagEnd" style="font-weight:600;">0</span> trong số <span id="schedPagTotal" style="font-weight:600;">0</span> lịch bảo trì
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <label style="font-size:13px; color:var(--text-secondary);">Số thẻ/trang:</label>
                    <select id="schedPageSizeSelect" onchange="changeSchedPageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--text-primary); font-size:13px; outline:none; cursor:pointer;">
                        <option value="6" selected="selected">6</option>
                        <option value="12">12</option>
                        <option value="24">24</option>
                        <option value="9999">Tất cả</option>
                    </select>
                    <div id="schedPaginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;"></div>
                </div>
            </div>
        </c:if>
    </div>
</div>

<script>
    let schedCurrentPage = 1;
    let schedPageSize = 6;
    let schedAllCards = [];

    // Reads the selected page size and re-renders the schedule grid from page 1.
    function changeSchedPageSize() {
        schedPageSize = parseInt(document.getElementById('schedPageSizeSelect').value);
        schedCurrentPage = 1;
        applySchedPagination();
    }

    // Shows only the schedule cards for the current page and updates the pagination summary/buttons.
    function applySchedPagination() {
        schedAllCards.forEach(card => card.style.display = 'none');

        const totalItems = schedAllCards.length;
        const totalPages = Math.max(1, Math.ceil(totalItems / schedPageSize));
        if (schedCurrentPage > totalPages) schedCurrentPage = totalPages;

        const start = (schedCurrentPage - 1) * schedPageSize;
        const end = Math.min(start + schedPageSize, totalItems);
        for (let i = start; i < end; i++) {
            schedAllCards[i].style.display = '';
        }

        document.getElementById('schedPagStart').textContent = totalItems === 0 ? 0 : start + 1;
        document.getElementById('schedPagEnd').textContent = end;
        document.getElementById('schedPagTotal').textContent = totalItems;

        renderSchedPaginationButtons(totalPages);
    }

    // Builds the prev/page-number/next pagination buttons for the schedule grid.
    function renderSchedPaginationButtons(totalPages) {
        const container = document.getElementById('schedPaginationButtons');
        container.innerHTML = '';

        const makeBtn = (label, page, disabled, active) => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.textContent = label;
            btn.disabled = disabled;
            btn.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid var(--outline-variant); background:' + (active ? 'var(--primary)' : 'var(--surface)') + '; color:' + (active ? '#fff' : 'var(--text-primary)') + '; font-size:12px; cursor:' + (disabled ? 'not-allowed' : 'pointer') + '; opacity:' + (disabled ? '0.5' : '1') + ';';
            btn.onclick = () => { schedCurrentPage = page; applySchedPagination(); };
            return btn;
        };

        container.appendChild(makeBtn('«', schedCurrentPage - 1, schedCurrentPage <= 1, false));
        for (let p = 1; p <= totalPages; p++) {
            container.appendChild(makeBtn(String(p), p, false, p === schedCurrentPage));
        }
        container.appendChild(makeBtn('»', schedCurrentPage + 1, schedCurrentPage >= totalPages, false));
    }

    document.addEventListener('DOMContentLoaded', function() {
        const grid = document.getElementById('scheduleGrid');
        if (grid) {
            schedAllCards = Array.from(grid.querySelectorAll('.schedule-card'));
            applySchedPagination();
        }
    });
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
