<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết xe"/>
</jsp:include>

<c:if test="${not empty car}">
    <!-- Breadcrumb & Actions Header -->
    <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 24px;">
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/vehicles">Đội xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">${car.brand} ${car.model}</span>
        </div>
        
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <h2 style="margin: 0; font-size: 28px; font-weight: 700; color: var(--primary);">${car.brand} ${car.model}</h2>
                <c:choose>
                    <c:when test="${car.status == 'AVAILABLE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#E8F5E9] text-[#2E7D32]" style="font-size: 12px; font-weight: 700;">Có Sẵn</span></c:when>
                    <c:when test="${car.status == 'MAINTENANCE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFF3E0] text-[#EF6C00]" style="font-size: 12px; font-weight: 700;">Bảo Trì</span></c:when>
                    <c:when test="${car.status == 'RENTED'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFEBEE] text-[#C62828]" style="font-size: 12px; font-weight: 700;">Đã Thuê</span></c:when>
                    <c:otherwise><span class="inline-block px-2.5 py-1 rounded bg-[#ECEFF1] text-[#37474F]" style="font-size: 12px; font-weight: 700;">Ngưng hoạt động</span></c:otherwise>
                </c:choose>
            </div>
            
            <div style="display: flex; gap: 12px;">
                <a href="${pageContext.request.contextPath}/vehicles" class="bk-btn bk-btn-outline">
                    <span class="material-symbols-outlined">arrow_back</span>
                    Quay lại danh sách
                </a>
            </div>
        </div>
    </div>

    <!-- Bento Grid Layout -->
    <div class="bento-grid">
        <!-- Main Gallery Card (Spans 8 columns) -->
        <div class="bento-card bento-col-8">
            <div style="position: relative; width: 100%; height: 380px; background: var(--surface-container-high);">
                <c:choose>
                    <c:when test="${not empty images}">
                        <img src="${pageContext.request.contextPath}${images[0].imageUrl}"
                             alt="${car.brand} ${car.model}"
                             id="mainCarImage"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg';"
                             style="width: 100%; height: 100%; object-fit: cover;">
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg"
                             alt="${car.brand} ${car.model}"
                             id="mainCarImage"
                             style="width: 100%; height: 100%; object-fit: cover;">
                    </c:otherwise>
                </c:choose>
                <div style="position: absolute; top: 16px; right: 16px; background: rgba(255,255,255,0.9); backdrop-filter: blur(4px); px: 12px; padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; color: var(--primary); box-shadow: var(--shadow);">
                    Biển số: ${car.licensePlate}
                </div>
            </div>
            
            <!-- Thumbnails List (if multiple images present) -->
            <c:if test="${not empty images && images.size() > 1}">
                <div style="display: flex; gap: 8px; padding: 16px; overflow-x: auto; background: var(--bg-white); border-top: 1px solid var(--outline-variant);">
                    <c:forEach var="img" items="${images}" varStatus="status">
                        <img src="${pageContext.request.contextPath}${img.imageUrl}"
                             alt="Thumbnail ${status.index + 1}"
                             class="car-thumb ${status.first ? 'active' : ''}"
                             onclick="changeMainImage('${pageContext.request.contextPath}${img.imageUrl}', this)"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg';"
                             style="width: 96px; height: 64px; object-fit: cover; border-radius: 4px; cursor: pointer; border: 2px solid ${status.first ? 'var(--primary)' : 'transparent'}; opacity: ${status.first ? '1' : '0.7'}; transition: all 0.2s;">
                    </c:forEach>
                </div>
            </c:if>
        </div>

        <!-- Pricing & Action Card (Spans 4 columns) -->
        <div class="bento-card bento-col-4" style="background: var(--bg-white);">
            <div class="bento-card-body" style="display: flex; flex-direction: column; justify-content: space-between; height: 100%;">
                <div>
                    <h3 style="font-size: 16px; font-weight: 700; color: var(--on-surface-variant); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 12px;">Giá Thuê</h3>
                    
                    <div style="display: flex; align-items: baseline; gap: 4px; margin-bottom: 24px;">
                        <span style="font-size: 32px; font-weight: 700; color: var(--primary);"><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/> VND</span>
                        <span style="font-size: 14px; color: var(--on-surface-variant);">/ ngày</span>
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 24px;">
                        <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--outline-variant); font-size: 14px;">
                            <span style="color: var(--on-surface-variant);">Tiền đặt cọc</span>
                            <span style="font-weight: 600; color: var(--primary);"><fmt:formatNumber value="${depositAmount}" type="number" groupingUsed="true"/> VND (${depositPercentage}%)</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid var(--outline-variant); font-size: 14px;">
                            <span style="color: var(--on-surface-variant);">Địa điểm nhận xe</span>
                            <span style="font-weight: 600; color: var(--primary);">${car.location}</span>
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 14px;">
                            <span style="color: var(--on-surface-variant);">Giới hạn dặm/ngày</span>
                            <span style="font-weight: 600; color: var(--primary);">Không giới hạn</span>
                        </div>
                    </div>
                </div>

                <div style="display: flex; flex-direction: column; gap: 12px; margin-top: auto; padding-top: 16px;">
                    <c:choose>
                        <c:when test="${car.status == 'AVAILABLE'}">
                            <a href="${pageContext.request.contextPath}/bookings/create?carId=${car.carId}" class="bk-btn bk-btn-primary" style="text-align: center; justify-content: center; height: 48px; width: 100%;">
                                Đặt xe ngay
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="bk-btn bk-btn-outline" style="height: 48px; width: 100%; cursor: not-allowed; opacity: 0.6;" disabled>
                                Xe hiện tại không sẵn sàng
                            </button>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/bookings/calendar" class="bk-btn bk-btn-outline" style="text-align: center; justify-content: center; height: 48px; width: 100%;">
                        Xem lịch đặt xe
                    </a>
                </div>
            </div>
        </div>

        <!-- Specifications (4 columns) -->
        <div class="bento-card bento-col-4 bento-card-body">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--primary); border-bottom: 1px solid var(--outline-variant); padding-bottom: 8px; margin-bottom: 16px;">Thông Số Xe</h3>
            <div style="display: flex; flex-direction: column; gap: 12px; font-size: 14px;">
                <div style="display: flex; justify-content: space-between;">
                    <span style="color: var(--on-surface-variant);">Hãng &amp; Mẫu</span>
                    <span style="font-weight: 600;">${car.brand} ${car.model}</span>
                </div>
                <div style="display: flex; justify-content: space-between;">
                    <span style="color: var(--on-surface-variant);">Năm sản xuất</span>
                    <span style="font-weight: 600;">${car.year}</span>
                </div>
                <div style="display: flex; justify-content: space-between;">
                    <span style="color: var(--on-surface-variant);">Màu sắc</span>
                    <span style="font-weight: 600;">${car.color}</span>
                </div>
                <div style="display: flex; justify-content: space-between;">
                    <span style="color: var(--on-surface-variant);">Số km đã đi</span>
                    <span style="font-weight: 600;"><fmt:formatNumber value="${car.mileage}" type="number" groupingUsed="true"/> km</span>
                </div>
            </div>
        </div>

        <!-- Features (4 columns) -->
        <div class="bento-card bento-col-4 bento-card-body">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--primary); border-bottom: 1px solid var(--outline-variant); padding-bottom: 8px; margin-bottom: 16px;">Tiện Nghi &amp; Tính Năng</h3>
            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; font-size: 14px; color: var(--on-surface);">
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 20px;">airline_seat_recline_normal</span>
                    ${car.seats} Ghế ngồi
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 20px;">settings</span>
                    ${car.transmission}
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 20px;">local_gas_station</span>
                    ${car.fuelType}
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 20px;">ac_unit</span>
                    Điều hòa
                </div>
            </div>
            <c:if test="${not empty car.features}">
                <div style="margin-top: 16px; padding-top: 12px; border-top: 1px dashed var(--outline-variant); font-size: 13px; color: var(--on-surface-variant);">
                    <strong>Tính năng khác:</strong> ${car.features}
                </div>
            </c:if>
        </div>

        <!-- Description & Notes (4 columns) -->
        <div class="bento-card bento-col-4 bento-card-body">
            <h3 style="font-size: 16px; font-weight: 700; color: var(--primary); border-bottom: 1px solid var(--outline-variant); padding-bottom: 8px; margin-bottom: 16px;">Mô Tả &amp; Ghi Chú</h3>
            <p style="font-size: 14px; line-height: 1.6; color: var(--on-surface-variant); margin: 0;">
                ${not empty car.description ? car.description : 'Không có mô tả chi tiết cho xe này.'}
            </p>
            
            <div style="margin-top: 16px; padding: 12px; background: var(--surface-container-low); border-radius: 8px; border: 1px solid var(--outline-variant);">
                <span style="font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--secondary); display: block; margin-bottom: 4px;">Ghi chú của nhân viên</span>
                <span style="font-size: 13px; color: var(--on-surface);">Vết xước nhẹ ở cản xe. Tất cả hệ thống vận hành hoàn hảo.</span>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${empty car}">
    <div class="bk-empty">
        <span class="material-symbols-outlined">error</span>
        <h3>Không tìm thấy thông tin xe</h3>
        <p>${not empty error ? error : 'Xe bạn yêu cầu không tồn tại hoặc đã bị xóa.'}</p>
        <a href="${pageContext.request.contextPath}/vehicles" class="bk-btn bk-btn-primary">Quay lại danh sách</a>
    </div>
</c:if>

<script>
function changeMainImage(url, thumb) {
    document.getElementById('mainCarImage').src = url;
    
    // Toggle active thumb
    document.querySelectorAll('.car-thumb').forEach(el => {
        el.style.borderColor = 'transparent';
        el.style.opacity = '0.7';
    });
    thumb.style.borderColor = 'var(--primary)';
    thumb.style.opacity = '1';
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
