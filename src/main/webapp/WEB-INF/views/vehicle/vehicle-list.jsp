<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Danh mục xe ô tô tự lái"/>
</jsp:include>

<div class="bk-page-header">
    <div class="bk-page-header-text">
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Danh mục xe</span>
        </div>
        <h2>Xe hiện có</h2>
        <p>Duyệt và lọc kho xe hiện tại để khách hàng đặt trước.</p>
    </div>
    <button type="button" class="bk-btn bk-btn-outline bk-page-export-btn" onclick="exportCarList()">
        <span class="material-symbols-outlined">download</span>
        Xuất danh sách
    </button>
</div>

<%-- BỘ LỌC TÌM KIẾM XE THÔNG MINH --%>
<div class="bk-card" style="margin-bottom:24px;padding:20px;">
    <div class="bk-card-title" style="margin-bottom:16px;font-size:16px;">
        <span class="material-symbols-outlined">filter_alt</span> Bộ lọc tìm kiếm xe tự lái
    </div>
    
    <div class="bk-form-grid" style="grid-template-columns:repeat(auto-fit, minmax(150px, 1fr));gap:12px;margin-bottom:16px;">
        <%-- Khoảng thời gian --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Khoảng thời gian</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">calendar_today</span>
                <input type="date" id="filterDate" class="bk-form-input" style="padding-left:40px;" onchange="applyFilters()">
            </div>
        </div>

        <%-- Hãng xe --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Hãng xe</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">directions_car</span>
                <select id="filterBrand" class="bk-form-select" onchange="updateModelOptions(); applyFilters()">
                    <option value="">Tất cả hãng xe</option>
                    <option value="Mercedes">Mercedes</option>
                    <option value="Toyota">Toyota</option>
                    <option value="Ford">Ford</option>
                    <option value="Tesla">Tesla</option>
                    <option value="VinFast">VinFast</option>
                </select>
            </div>
        </div>

        <%-- Dòng xe --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Dòng xe</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">model_training</span>
                <select id="filterModel" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả dòng xe</option>
                </select>
            </div>
        </div>

        <%-- Số ghế --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Số ghế</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">event_seat</span>
                <select id="filterSeats" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả</option>
                    <option value="4">4 ghế</option>
                    <option value="5">5 ghế</option>
                    <option value="7">7 ghế</option>
                    <option value="9">9 ghế</option>
                </select>
            </div>
        </div>

        <%-- Mức giá --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Mức giá</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">payments</span>
                <select id="filterPrice" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả</option>
                    <option value="500000">Dưới 500k</option>
                    <option value="1000000">500k - 1tr</option>
                    <option value="1500000">1tr - 1.5tr</option>
                    <option value="9999999">Trên 1.5tr</option>
                </select>
            </div>
        </div>

        <%-- Loại nhiên liệu --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Loại nhiên liệu</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">local_gas_station</span>
                <select id="filterFuel" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả</option>
                    <option value="GASOLINE">Xăng</option>
                    <option value="DIESEL">Dầu Diesel</option>
                    <option value="ELECTRIC">Điện</option>
                    <option value="HYBRID">Hybrid</option>
                </select>
            </div>
        </div>

        <%-- Hộp số --%>
        <div class="bk-form-group">
            <label class="bk-form-label">Hộp số</label>
            <div class="bk-form-input-wrap">
                <span class="material-symbols-outlined">settings</span>
                <select id="filterTransmission" class="bk-form-select" onchange="applyFilters()">
                    <option value="">Tất cả</option>
                    <option value="AUTOMATIC">Số tự động</option>
                    <option value="MANUAL">Số sàn</option>
                </select>
            </div>
        </div>
    </div>

    <%-- Filter chips / tags --%>
    <div id="filterChips" style="display:flex;flex-wrap:wrap;gap:8px;margin-top:12px;">
        <!-- Filter chips sẽ được thêm bằng JavaScript -->
    </div>
</div>

<%-- DANH SÁCH XE GRID --%>
<c:if test="${not empty cars}">
    <div id="carGrid" style="display:grid;grid-template-columns:repeat(auto-fill, minmax(280px, 1fr));gap:24px;">
        <c:forEach var="car" items="${cars}">
            <div class="bk-card car-item" style="padding:0;overflow:hidden;transition:all 0.3s ease;"
                 data-name="${car.brand} ${car.model}"
                 data-brand="${car.brand}"
                 data-model="${car.model}"
                 data-transmission="${car.transmission}"
                 data-fuel="${car.fuelType}"
                 data-seats="${car.seats}"
                 data-price="${car.dailyRate}">
                 
                <%-- Ảnh xe --%>
                <div style="height:220px;background:var(--surface-container-high);position:relative;overflow:hidden;display:flex;align-items:center;justify-content:center;">
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
                    <div style="display:flex;justify-content:space-around;align-items:center;margin-top:12px;background:var(--surface-container-low);padding:12px;border-radius:8px;gap:8px;">
                        <div style="text-align:center;">
                            <span class="material-symbols-outlined" style="font-size:20px;color:var(--primary);display:block;">group</span>
                            <div style="font-size:12px;font-weight:600;margin-top:4px;">${car.seats} Chỗ</div>
                        </div>
                        <div style="width:1px;height:30px;background:var(--surface);"></div>
                        <div style="text-align:center;">
                            <span class="material-symbols-outlined" style="font-size:20px;color:var(--primary);display:block;">settings</span>
                            <div style="font-size:12px;font-weight:600;margin-top:4px;">
                                <c:choose>
                                    <c:when test="${car.transmission == 'AUTOMATIC'}">Tự Động</c:when>
                                    <c:when test="${car.transmission == 'MANUAL'}">Số Sàn</c:when>
                                    <c:otherwise>${car.transmission}</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div style="width:1px;height:30px;background:var(--surface);"></div>
                        <div style="text-align:center;">
                            <span class="material-symbols-outlined" style="font-size:20px;color:var(--primary);display:block;">local_gas_station</span>
                            <div style="font-size:12px;font-weight:600;margin-top:4px;">
                                <c:choose>
                                    <c:when test="${car.fuelType == 'GASOLINE'}">Xăng</c:when>
                                    <c:when test="${car.fuelType == 'DIESEL'}">Dầu Diesel</c:when>
                                    <c:when test="${car.fuelType == 'ELECTRIC'}">Điện</c:when>
                                    <c:when test="${car.fuelType == 'HYBRID'}">Hybrid</c:when>
                                    <c:otherwise>${car.fuelType}</c:otherwise>
                                </c:choose>
                            </div>
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

                    <div style="margin-top:16px;display:flex;gap:8px;">
                        <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}"
                           class="bk-btn bk-btn-outline" style="flex:1;justify-content:center;">
                           <span class="material-symbols-outlined">visibility</span> Xem Chi Tiết
                        </a>
                        <c:choose>
                            <c:when test="${car.status == 'AVAILABLE'}">
                                <a href="${pageContext.request.contextPath}/bookings/create?carId=${car.carId}"
                                   class="bk-btn bk-btn-primary" style="flex:1;justify-content:center;">
                                   <span class="material-symbols-outlined">event</span> Tạo Đặt Xe
                                </a>
                            </c:when>
                            <c:otherwise>
                                <button class="bk-btn bk-btn-primary" style="flex:1;opacity:0.5;cursor:not-allowed;" disabled>
                                   <span class="material-symbols-outlined">event</span> Không Khả Dụng
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- Phân trang cho Danh sách xe -->
    <div class="bk-pagination-container" id="carPagination" style="display:flex; justify-content:space-between; align-items:center; margin-top:24px; padding:12px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
        <div style="font-size:13px; color:var(--on-surface-variant);">
            Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> xe hiện có
        </div>
        <div style="display:flex; align-items:center; gap:8px;">
            <label style="font-size:13px; color:var(--on-surface-variant);">Số xe mỗi trang:</label>
            <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                <option value="8" selected="selected">8</option>
                <option value="12">12</option>
                <option value="16">16</option>
                <option value="24">24</option>
            </select>
            <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;">
                <!-- nút chuyển trang sinh bằng JS -->
            </div>
        </div>
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
let currentPage = 1;
let pageSize = 8;
let filteredCars = [];

function changePageSize() {
    pageSize = parseInt(document.getElementById('pageSizeSelect').value);
    currentPage = 1;
    applyPagination();
}

function updateModelOptions() {
    var brand = document.getElementById('filterBrand').value;
    var modelSelect = document.getElementById('filterModel');
    if (!modelSelect) return;
    
    var prevValue = modelSelect.value;
    modelSelect.innerHTML = '<option value="">Tất cả dòng xe</option>';
    
    var models = new Set();
    var carItems = document.querySelectorAll('.car-item');
    carItems.forEach(function(item) {
        var itemBrand = item.getAttribute('data-brand');
        var itemModel = item.getAttribute('data-model');
        if (brand === "" || itemBrand === brand) {
            models.add(itemModel);
        }
    });
    
    models.forEach(function(m) {
        var opt = document.createElement('option');
        opt.value = m;
        opt.textContent = m;
        if (m === prevValue) opt.selected = true;
        modelSelect.appendChild(opt);
    });
}

function applyFilters() {
    var brand = document.getElementById('filterBrand').value;
    var model = document.getElementById('filterModel').value;
    var transmission = document.getElementById('filterTransmission').value;
    var fuel = document.getElementById('filterFuel').value;
    var seats = document.getElementById('filterSeats').value;
    var priceLimit = document.getElementById('filterPrice').value;

    var carItems = document.querySelectorAll('.car-item');
    filteredCars = [];

    carItems.forEach(function(item) {
        var itemBrand = item.getAttribute('data-brand');
        var itemModel = item.getAttribute('data-model');
        var itemTransmission = item.getAttribute('data-transmission');
        var itemFuel = item.getAttribute('data-fuel');
        var itemSeats = item.getAttribute('data-seats');
        var itemPrice = parseFloat(item.getAttribute('data-price')) || 0;

        var matchBrand = brand === "" || itemBrand === brand;
        var matchModel = model === "" || itemModel === model;
        var matchTransmission = transmission === "" || itemTransmission === transmission;
        var matchFuel = fuel === "" || itemFuel === fuel;
        var matchSeats = seats === "" || itemSeats === seats;
        
        var matchPrice = true;
        if (priceLimit !== "") {
            var limit = parseFloat(priceLimit);
            if (limit === 500000) {
                matchPrice = itemPrice < 500000;
            } else if (limit === 1000000) {
                matchPrice = itemPrice >= 500000 && itemPrice <= 1000000;
            } else if (limit === 1500000) {
                matchPrice = itemPrice >= 1000000 && itemPrice <= 1500000;
            } else if (limit === 9999999) {
                matchPrice = itemPrice > 1500000;
            }
        }

        if (matchBrand && matchModel && matchTransmission && matchFuel && matchSeats && matchPrice) {
            filteredCars.push(item);
        } else {
            item.style.display = 'none';
        }
    });

    var grid = document.getElementById('carGrid');
    var noResults = document.getElementById('noResults');
    var pagContainer = document.getElementById('carPagination');
    if (grid) {
        if (filteredCars.length === 0) {
            noResults.style.display = 'flex';
            if (pagContainer) pagContainer.style.display = 'none';
        } else {
            noResults.style.display = 'none';
            if (pagContainer) pagContainer.style.display = 'flex';
        }
    }
    
    currentPage = 1;
    applyPagination();
    updateFilterChips();
}

function applyPagination() {
    const totalCars = filteredCars.length;
    const totalPages = Math.ceil(totalCars / pageSize) || 1;
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    const carItems = document.querySelectorAll('.car-item');
    carItems.forEach(item => item.style.display = 'none');
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalCars);
    
    for (let i = startIdx; i < endIdx; i++) {
        filteredCars[i].style.display = 'block';
    }
    
    const startDisplay = document.getElementById('pag-start');
    const endDisplay = document.getElementById('pag-end');
    const totalDisplay = document.getElementById('pag-total');
    if (startDisplay) startDisplay.innerText = totalCars > 0 ? (startIdx + 1) : 0;
    if (endDisplay) endDisplay.innerText = endIdx;
    if (totalDisplay) totalDisplay.innerText = totalCars;
    
    const btnContainer = document.getElementById('paginationButtons');
    if (btnContainer) {
        btnContainer.innerHTML = '';
        
        const prevBtn = document.createElement('button');
        prevBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        prevBtn.style.padding = '4px 8px';
        prevBtn.style.border = '1px solid var(--outline-variant)';
        prevBtn.style.borderRadius = '6px';
        prevBtn.style.cursor = 'pointer';
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_left</span>';
        prevBtn.onclick = () => { currentPage--; applyPagination(); };
        btnContainer.appendChild(prevBtn);
        
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }
        
        for (let p = startPage; p <= endPage; p++) {
            const pageBtn = document.createElement('button');
            pageBtn.className = p === currentPage ? 'bk-btn bk-btn-sm bk-btn-primary' : 'bk-btn bk-btn-sm bk-btn-outline';
            pageBtn.style.padding = '4px 10px';
            pageBtn.style.minWidth = '28px';
            pageBtn.style.borderRadius = '6px';
            pageBtn.style.cursor = 'pointer';
            pageBtn.style.fontWeight = '600';
            pageBtn.style.fontSize = '12px';
            if (p === currentPage) {
                pageBtn.style.background = 'var(--primary)';
                pageBtn.style.color = 'var(--on-primary)';
                pageBtn.style.border = 'none';
            } else {
                pageBtn.style.border = '1px solid var(--outline-variant)';
            }
            pageBtn.innerText = p;
            pageBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pageBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        nextBtn.style.padding = '4px 8px';
        nextBtn.style.border = '1px solid var(--outline-variant)';
        nextBtn.style.borderRadius = '6px';
        nextBtn.style.cursor = 'pointer';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_right</span>';
        nextBtn.onclick = () => { currentPage++; applyPagination(); };
        btnContainer.appendChild(nextBtn);
    }
}

function updateFilterChips() {
    var chipsContainer = document.getElementById('filterChips');
    if (!chipsContainer) return;
    var chips = [];
    
    var brand = document.getElementById('filterBrand').value;
    if (brand) chips.push({label: brand, id: 'filterBrand', value: ''});

    var model = document.getElementById('filterModel').value;
    if (model) chips.push({label: model, id: 'filterModel', value: ''});
    
    var transmission = document.getElementById('filterTransmission').value;
    if (transmission) {
        var label = transmission === 'AUTOMATIC' ? 'Số tự động' : 'Số sàn';
        chips.push({label: label, id: 'filterTransmission', value: ''});
    }
    
    var fuel = document.getElementById('filterFuel').value;
    if (fuel) {
        var labels = {'GASOLINE': 'Xăng', 'DIESEL': 'Dầu Diesel', 'ELECTRIC': 'Điện', 'HYBRID': 'Hybrid'};
        chips.push({label: labels[fuel] || fuel, id: 'filterFuel', value: ''});
    }
    
    var seats = document.getElementById('filterSeats').value;
    if (seats) chips.push({label: seats + ' chỗ', id: 'filterSeats', value: ''});
    
    chipsContainer.innerHTML = '';
    chips.forEach(function(chip) {
        var chipEl = document.createElement('div');
        chipEl.style.cssText = 'display:inline-flex;align-items:center;gap:6px;background:var(--surface-container-low);padding:6px 12px;border-radius:20px;font-size:12px;font-weight:600;';
        chipEl.innerHTML = chip.label + '<button style="border:none;background:none;cursor:pointer;font-size:16px;padding:0;margin:0;color:var(--on-surface-variant);" onclick="document.getElementById(\'' + chip.id + '\').value=\'' + chip.value + '\'; if(\'' + chip.id + '\' === \'filterBrand\') { updateModelOptions(); }; applyFilters();">close</button>';
        chipsContainer.appendChild(chipEl);
    });
}

function exportCarList() {
    alert('Tính năng xuất danh sách sắp có!');
}

// Parse query parameters on load to auto-filter from the quick search
window.addEventListener('DOMContentLoaded', function() {
    updateModelOptions();
    
    var urlParams = new URLSearchParams(window.location.search);
    var brand = urlParams.get('brand');
    var seats = urlParams.get('seats');
    var model = urlParams.get('model');
    
    if (brand) {
        var brandSelect = document.getElementById('filterBrand');
        if (brandSelect) {
            brandSelect.value = brand;
            updateModelOptions();
        }
    }
    if (model) {
        var modelSelect = document.getElementById('filterModel');
        if (modelSelect) {
            modelSelect.value = model;
        }
    }
    if (seats) {
        var seatsSelect = document.getElementById('filterSeats');
        if (seatsSelect) {
            seatsSelect.value = seats;
        }
    }
    applyFilters();
});
</script>

<style>
.car-image-hover:hover {
    transform: scale(1.08);
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
