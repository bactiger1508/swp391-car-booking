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
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px;">
                <c:forEach items="${schedules}" var="s">
                    <div style="border: 1px solid var(--outline-variant); border-radius: var(--radius-md); padding: 16px; background: var(--surface); display: flex; flex-direction: column; gap: 12px; transition: var(--transition);">
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
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
