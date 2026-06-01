<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Danh mục xe ô tô tự lái"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Danh mục xe</span>
        </div>
        <h2>Danh mục Xe tự lái CarPro</h2>
        <p>Tìm kiếm và lựa chọn dòng xe phù hợp với nhu cầu và ngân sách của bạn.</p>
    </div>
</div>

<%-- BỘ LỌC TÌM KIẾM XE THÔNG MINH --%>
<div class="bk-card" style="margin-bottom:24px;padding:20px;">
    <div class="bk-card-title" style="margin-bottom:16px;font-size:16px;">
        <span class="material-symbols-outlined">filter_alt</span> Bộ lọc tìm kiếm xe tự lái
    </div>
    
    <div class="bk-form-grid" style="grid-template-columns:repeat(auto-fit, minmax(180px, 1fr));gap:16px;">
        <%-- Tìm theo tên --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Tên xe / Hãng xe</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">search</span>
                <input type="text" id="filterKeyword" class="bk-form-input" placeholder="Ví dụ: VinFast..." style="padding-left:40px;" oninput="applyFilters()">
            </div>
        </div>

        <%-- Lọc theo Hộp số --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Hộp số (Truyền động)</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">settings_input_component</span>
                <select id="filterTransmission" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả hộp số</option>
                    <option value="AUTOMATIC">Số tự động</option>
                    <option value="MANUAL">Số sàn</option>
                </select>
            </div>
        </div>

        <%-- Lọc theo Nhiên liệu --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Loại nhiên liệu</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">local_gas_station</span>
                <select id="filterFuel" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả nhiên liệu</option>
                    <option value="GASOLINE">Xăng</option>
                    <option value="DIESEL">Dầu Diesel</option>
                    <option value="ELECTRIC">Điện</option>
                    <option value="HYBRID">Hybrid</option>
                </select>
            </div>
        </div>

        <%-- Lọc theo Số chỗ ngồi --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Số chỗ ngồi</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">group</span>
                <select id="filterSeats" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả số chỗ</option>
                    <option value="4">4 chỗ</option>
                    <option value="5">5 chỗ</option>
                    <option value="7">7 chỗ</option>
                </select>
            </div>
        </div>

        <%-- Lọc theo Mức giá --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Giá thuê (Ngày)</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">payments</span>
                <select id="filterPrice" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả mức giá</option>
                    <option value="1000000">Dưới 1,000,000đ</option>
                    <option value="1500000">Từ 1tr - 1.5tr</option>
                    <option value="9999999">Trên 1.5tr</option>
                </select>
            </div>
        </div>
    </div>
</div>

<%-- DANH SÁCH XE GRID --%>
<c:if test="${not empty cars}">
    <div id="carGrid" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(280px, 1fr));gap:24px;">
        <c:forEach var="car" items="${cars}">
            <%-- Mỗi xe có data- attributes phục vụ bộ lọc thời gian thực --%>
            <div class="bk-card car-item" style="padding:0;overflow:hidden;transition:all 0.3s ease;"
                 data-name="${car.brand} ${car.model}"
                 data-brand="${car.brand}"
                 data-transmission="${car.transmission}"
                 data-fuel="${car.fuelType}"
                 data-seats="${car.seats}"
                 data-price="${car.dailyRate}">
                 
                <%-- Ảnh xe --%>
                <div style="height:180px;background:var(--surface-container-high);position:relative;overflow:hidden;display:flex;align-items:center;justify-content:center;">
                    <c:set var="thumb" value="${primaryImages[car.carId]}"/>
                    <img src="${pageContext.request.contextPath}${thumb}"
                         alt="${car.brand} ${car.model}"
                         style="width:100%;height:100%;object-fit:cover;transition:transform 0.5s ease;"
                         class="car-image-hover"
                         onerror="this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg'"/>
                         
                    <div style="position:absolute;top:12px;left:12px;background:rgba(4,22,56,0.85);color:#fff;padding:4px 8px;border-radius:4px;font-size:11px;font-weight:700;letter-spacing:0.5px;">
                        ${car.licensePlate}
                    </div>
                </div>

                <%-- Chi tiết --%>
                <div style="padding:20px;">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                        <h4 style="font-size:18px;font-weight:700;color:var(--primary);margin:0;">${car.brand} ${car.model}</h4>
                    </div>
                    
                    <p style="margin-top:6px;font-size:13px;color:var(--on-surface-variant);display:flex;align-items:center;gap:6px;">
                        <span class="material-symbols-outlined" style="font-size:16px;">calendar_month</span> Năm sản xuất: ${car.year}
                    </p>

                    <%-- Bento specs chi tiết --%>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px;background:var(--surface-container-low);padding:8px 12px;border-radius:8px;font-size:12px;font-weight:600;color:var(--on-surface-variant);">
                        <div style="display:flex;align-items:center;gap:4px;">
                            <span class="material-symbols-outlined" style="font-size:16px;">group</span> ${car.seats} chỗ
                        </div>
                        <div style="display:flex;align-items:center;gap:4px;">
                            <span class="material-symbols-outlined" style="font-size:16px;">settings_input_component</span>
                            <c:choose>
                                <c:when test="${car.transmission == 'AUTOMATIC'}">Số tự động</c:when>
                                <c:when test="${car.transmission == 'MANUAL'}">Số sàn</c:when>
                                <c:otherwise>${car.transmission}</c:otherwise>
                            </c:choose>
                        </div>
                        <div style="display:flex;align-items:center;gap:4px;grid-column:span 2;">
                            <span class="material-symbols-outlined" style="font-size:16px;">local_gas_station</span>
                            Nhiên liệu: 
                            <c:choose>
                                <c:when test="${car.fuelType == 'GASOLINE'}">Xăng</c:when>
                                <c:when test="${car.fuelType == 'DIESEL'}">Dầu Diesel</c:when>
                                <c:when test="${car.fuelType == 'ELECTRIC'}">Điện</c:when>
                                <c:when test="${car.fuelType == 'HYBRID'}">Hybrid</c:when>
                                <c:otherwise>${car.fuelType}</c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Giá thuê --%>
                    <div style="margin-top:16px;display:flex;justify-content:space-between;align-items:center;">
                        <div>
                            <span style="font-size:11px;font-weight:700;text-transform:uppercase;color:var(--on-surface-variant);display:block;letter-spacing:0.5px;">Giá thuê 1 ngày</span>
                            <span style="font-size:20px;font-weight:800;color:var(--primary);"><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/>đ</span>
                        </div>
                        <c:choose>
                            <c:when test="${car.status == 'AVAILABLE'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Sẵn sàng</span></c:when>
                            <c:when test="${car.status == 'RENTED'}"><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> Đang thuê</span></c:when>
                            <c:when test="${car.status == 'MAINTENANCE'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Đang bảo trì</span></c:when>
                            <c:otherwise><span class="bk-badge">${car.status}</span></c:otherwise>
                        </c:choose>
                    </div>

                    <div style="margin-top:16px;">
                        <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}"
                           class="bk-btn bk-btn-primary" style="width:100%;justify-content:center;">
                           <span class="material-symbols-outlined">visibility</span> Xem Chi Tiết
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <%-- Thông báo không tìm thấy kết quả lọc --%>
    <div id="noResults" class="bk-empty" style="display:none;margin-top:24px;">
        <span class="material-symbols-outlined">search_off</span>
        <h3>Không tìm thấy xe phù hợp</h3>
        <p>Vui lòng thay đổi từ khóa hoặc điều kiện lọc tìm kiếm của bạn.</p>
    </div>
</c:if>

<c:if test="${empty cars}">
    <div class="bk-empty">
        <span class="material-symbols-outlined">directions_car</span>
        <h3>Không có xe nào sẵn sàng phục vụ</h3>
        <p>Hệ thống hiện tại chưa có xe ô tô nào khả dụng cho thuê. Vui lòng quay lại sau.</p>
    </div>
</c:if>

<script>
function applyFilters() {
    var keyword = document.getElementById('filterKeyword').value.toLowerCase().trim();
    var transmission = document.getElementById('filterTransmission').value;
    var fuel = document.getElementById('filterFuel').value;
    var seats = document.getElementById('filterSeats').value;
    var priceLimit = document.getElementById('filterPrice').value;

    var carItems = document.querySelectorAll('.car-item');
    var visibleCount = 0;

    carItems.forEach(function(item) {
        var name = item.getAttribute('data-name').toLowerCase();
        var itemTransmission = item.getAttribute('data-transmission');
        var itemFuel = item.getAttribute('data-fuel');
        var itemSeats = item.getAttribute('data-seats');
        var itemPrice = parseFloat(item.getAttribute('data-price')) || 0;

        var matchKeyword = keyword === "" || name.includes(keyword);
        var matchTransmission = transmission === "" || itemTransmission === transmission;
        var matchFuel = fuel === "" || itemFuel === fuel;
        var matchSeats = seats === "" || itemSeats === seats;
        
        var matchPrice = true;
        if (priceLimit !== "") {
            var limit = parseFloat(priceLimit);
            if (limit === 1000000) {
                matchPrice = itemPrice < 1000000;
            } else if (limit === 1500000) {
                matchPrice = itemPrice >= 1000000 && itemPrice <= 1500000;
            } else if (limit === 9999999) {
                matchPrice = itemPrice > 1500000;
            }
        }

        if (matchKeyword && matchTransmission && matchFuel && matchSeats && matchPrice) {
            item.style.display = 'block';
            visibleCount++;
        } else {
            item.style.display = 'none';
        }
    });

    var grid = document.getElementById('carGrid');
    var noResults = document.getElementById('noResults');
    if (grid) {
        if (visibleCount === 0) {
            noResults.style.display = 'flex';
        } else {
            noResults.style.display = 'none';
        }
    }
}
</script>

<style>
.car-image-hover:hover {
    transform: scale(1.08);
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
