<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Kiểm tra lịch xe trống"/>
</jsp:include>

<div class="bk-page-header">
    <div class="bk-page-header-text">
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Kiểm tra xe trống</span>
        </div>
        <h2>Kiểm tra xe khả dụng</h2>
        <p>Chọn khoảng thời gian thuê để tìm các dòng xe đang sẵn sàng hoạt động.</p>
    </div>
</div>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error" style="margin-bottom:20px;">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<%-- Form Check --%>
<div class="bk-card" style="margin-bottom:24px;padding:24px;">
    <form method="get" action="${pageContext.request.contextPath}/vehicles/availability">
        <div class="bk-form-grid" style="grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; align-items: flex-end;">
            <div class="bk-form-group">
                <label class="bk-form-label" for="startDate">Ngày nhận xe *</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <input type="date" id="startDate" name="startDate" class="bk-form-input" style="padding-left:40px;" value="${startDate}" required>
                </div>
            </div>
            
            <div class="bk-form-group">
                <label class="bk-form-label" for="endDate">Ngày trả xe *</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">calendar_today</span>
                    <input type="date" id="endDate" name="endDate" class="bk-form-input" style="padding-left:40px;" value="${endDate}" required>
                </div>
            </div>
            
            <div>
                <button type="submit" class="bk-btn bk-btn-primary" style="height:46px;width:100%;justify-content:center;">
                    <span class="material-symbols-outlined">search</span> Kiểm tra lịch trống
                </button>
            </div>
        </div>
    </form>
</div>

<%-- Results list --%>
<c:if test="${searched}">
    <div class="bk-card">
        <div class="bk-card-title" style="margin-bottom:20px;display:flex;justify-content:between;align-items:center;">
            <span>Danh sách xe trống khả dụng</span>
            <span class="bk-badge bk-badge-confirmed" style="font-size:12px;">${availableCars.size()} xe trống</span>
        </div>

        <c:choose>
            <c:when test="${empty availableCars}">
                <div style="text-align:center;padding:48px 24px;color:var(--on-surface-variant);">
                    <span class="material-symbols-outlined" style="font-size:48px;margin-bottom:12px;display:block;">no_cars</span>
                    Rất tiếc! Hiện không có xe nào trống trong khoảng thời gian được chọn. Vui lòng chọn lịch trình khác.
                </div>
            </c:when>
            <c:otherwise>
                <div class="bk-form-grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap:20px;">
                    <c:forEach var="car" items="${availableCars}">
                        <div class="bk-card" style="padding:16px;border:1px solid var(--outline-variant);display:flex;flex-direction:column;justify-content:between;height:100%;">
                            <div style="width:100%;height:160px;border-radius:8px;background:var(--surface-container-high);overflow:hidden;margin-bottom:16px;display:flex;align-items:center;justify-content:center;">
                                <img src="${pageContext.request.contextPath}${primaryImages[car.carId]}" alt="${car.brand} ${car.model}" style="width:100%;height:100%;object-fit:cover;border:none;" onerror="this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg'">
                            </div>
                            <div>
                                <div style="font-weight:700;font-size:18px;color:var(--primary);">${car.brand} ${car.model}</div>
                                <div style="font-size:12px;color:var(--outline);margin-top:2px;">Biển số: ${car.licensePlate}</div>
                                
                                <div style="display:flex;gap:12px;margin:12px 0;font-size:13px;color:var(--on-surface-variant);">
                                    <span style="display:flex;align-items:center;gap:4px;"><span class="material-symbols-outlined" style="font-size:16px;">event_seat</span> ${car.seats} chỗ</span>
                                    <span style="display:flex;align-items:center;gap:4px;"><span class="material-symbols-outlined" style="font-size:16px;">settings</span> ${car.transmission == 'AUTOMATIC' ? 'Tự động' : 'Số sàn'}</span>
                                    <span style="display:flex;align-items:center;gap:4px;"><span class="material-symbols-outlined" style="font-size:16px;">local_gas_station</span> ${car.fuelType == 'GASOLINE' ? 'Xăng' : car.fuelType == 'ELECTRIC' ? 'Điện' : 'Dầu'}</span>
                                </div>
                                
                                <div style="font-size:13px;color:var(--outline);margin-bottom:16px;">
                                    <span class="material-symbols-outlined" style="font-size:14px;vertical-align:middle;margin-right:4px;">location_on</span>${car.location}
                                </div>
                            </div>
                            
                            <div style="display:flex;justify-content:space-between;align-items:center;margin-top:auto;padding-top:12px;border-top:1px solid var(--outline-variant);margin-bottom:12px;">
                                <div>
                                    <div style="font-size:11px;color:var(--outline);">Giá thuê ngày</div>
                                    <div style="font-size:16px;font-weight:700;color:var(--primary);"><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/>đ</div>
                                </div>
                            </div>
                            
                            <div style="display:flex;gap:8px;">
                                <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="bk-btn bk-btn-outline" style="flex:1;justify-content:center;font-size:13px;padding:8px 12px;">
                                    <span class="material-symbols-outlined" style="font-size:18px;">visibility</span> Chi tiết
                                </a>
                                <a href="${pageContext.request.contextPath}/bookings/create?carId=${car.carId}&startDate=${startDate}&endDate=${endDate}" class="bk-btn bk-btn-primary" style="flex:1;justify-content:center;font-size:13px;padding:8px 12px;">
                                    <span class="material-symbols-outlined" style="font-size:18px;">event</span> Đặt ngay
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</c:if>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
