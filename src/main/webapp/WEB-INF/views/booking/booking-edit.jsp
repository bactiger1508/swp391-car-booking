<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chỉnh sửa Đặt Xe"/>
</jsp:include>

<c:if test="${not empty error}">
    <div class="bk-alert bk-alert-error">
        <span class="material-symbols-outlined">error</span> ${error}
    </div>
</c:if>

<%-- Page Header --%>
<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/bookings/my">Đặt xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/bookings/detail?id=${booking.bookingId}">Chi tiết đơn #BK-${booking.bookingId}</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Chỉnh sửa</span>
        </div>
        <h2>Chỉnh sửa đơn đặt xe #BK-${booking.bookingId}</h2>
    </div>
    <a href="${pageContext.request.contextPath}/bookings/detail?id=${booking.bookingId}" class="bk-btn bk-btn-outline">Quay lại</a>
</div>

<%-- Booking Grid: Form left, Summary right --%>
<div class="bk-booking-grid">
    <%-- LEFT: Form --%>
    <div>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">edit_calendar</span> Thông tin thay đổi
            </div>

            <form method="post" action="${pageContext.request.contextPath}/bookings/edit" id="bookingForm" novalidate>
                <input type="hidden" name="bookingId" value="${booking.bookingId}">

                <%-- Car Selection: Brand → Model → Car --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <h3>Chọn xe</h3>
                    <div class="bk-form-grid" style="grid-template-columns: 1fr 1fr 1fr; gap: 16px;">
                        <%-- Brand Filter --%>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Hãng xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">business</span>
                                <select id="brandFilter" class="bk-form-select" onchange="onBrandChange()">
                                    <option value="">-- Chọn hãng xe --</option>
                                </select>
                            </div>
                        </div>
                        <%-- Model Filter --%>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Dòng xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">category</span>
                                <select id="modelFilter" class="bk-form-select" onchange="onModelChange()" disabled>
                                    <option value="">-- Chọn dòng xe --</option>
                                </select>
                            </div>
                        </div>
                        <%-- Car Selection --%>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Xe cụ thể <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">directions_car</span>
                                <select name="carId" id="carSelect" class="bk-form-select" onchange="updateCarInfo()" disabled>
                                    <option value="">-- Chọn xe --</option>
                                    <c:forEach var="car" items="${cars}">
                                        <option value="${car.carId}"
                                                data-brand="${car.brand}"
                                                data-model="${car.model}"
                                                data-plate="${car.licensePlate}"
                                                data-price="${car.dailyRate}"
                                                data-location="${car.location}"
                                                data-image="${primaryImages[car.carId]}"
                                                ${booking.carId == car.carId ? 'selected' : ''}>
                                            ${car.brand} ${car.model} — ${car.licensePlate}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-carId"></span>
                        </div>
                    </div>
                </div>

                <%-- Rental Mode & Packages --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <h3>Hình thức thuê xe</h3>
                    <div class="bk-form-grid" style="grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Gói thuê <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">deployed_code</span>
                                <c:set var="currentCombo" value="${booking.rentalMode == 'DAILY' ? 'DAILY_STANDARD' : booking.rentalMode == 'TRIP' ? 'TRIP_STANDARD' : booking.pricingPackage}"/>
                                <select name="rentalModeCombo" id="rentalModeCombo" class="bk-form-select" onchange="onRentalModeChange()">
                                    <option value="DAILY_STANDARD" ${currentCombo == 'DAILY_STANDARD' ? 'selected' : ''}>Thuê theo ngày (Tiêu chuẩn)</option>
                                    <option value="TRIP_STANDARD" ${currentCombo == 'TRIP_STANDARD' ? 'selected' : ''}>Thuê theo chuyến (Trọn gói ${not empty tripKmLimit ? tripKmLimit : 150}km)</option>
                                    <option value="COMBO_7_DAYS" ${currentCombo == 'COMBO_7_DAYS' ? 'selected' : ''}>Gói Combo 7 ngày (Tuần)</option>
                                    <option value="COMBO_10_DAYS" ${currentCombo == 'COMBO_10_DAYS' ? 'selected' : ''}>Gói Combo 10 ngày</option>
                                    <option value="COMBO_30_DAYS" ${currentCombo == 'COMBO_30_DAYS' ? 'selected' : ''}>Gói Combo 30 ngày (Tháng)</option>
                                </select>
                            </div>
                            <input type="hidden" name="rentalMode" id="rentalMode" value="${booking.rentalMode}">
                            <input type="hidden" name="pricingPackage" id="pricingPackage" value="${booking.pricingPackage}">
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Số KM di chuyển dự kiến <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">speed</span>
                                <input type="number" name="estimatedKm" id="estimatedKm" class="bk-form-input" placeholder="Nhập số km dự kiến" min="1" value="${booking.estimatedKm}" onchange="calculateBookingCost()" onkeyup="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-estimatedKm"></span>
                        </div>
                    </div>
                    <div id="modeDescription" style="margin-top: 8px; font-size: 13px; color: var(--on-surface-variant); background: var(--surface-container-low); padding: 12px; border-radius: 6px; border-left: 3px solid var(--primary); font-weight: 500;">
                    </div>
                </div>

                <hr style="border:none;border-top:1px solid var(--outline-variant);margin:24px 0;">

                <%-- Schedule --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <h3>Lịch trình</h3>
                    <div class="bk-form-grid">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Ngày bắt đầu <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">calendar_month</span>
                                <fmt:parseDate value="${booking.startDate}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedStartDate" type="both" />
                                <input type="date" name="startDate" id="startDate" class="bk-form-input" value="<fmt:formatDate value="${parsedStartDate}" pattern="yyyy-MM-dd"/>" onchange="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-startDate"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Giờ bắt đầu <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">schedule</span>
                                <input type="time" name="startTime" id="startTime" class="bk-form-input" value="<fmt:formatDate value="${parsedStartDate}" pattern="HH:mm"/>">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-startTime"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Ngày kết thúc <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">event</span>
                                <fmt:parseDate value="${booking.endDate}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedEndDate" type="both" />
                                <input type="date" name="endDate" id="endDate" class="bk-form-input" value="<fmt:formatDate value="${parsedEndDate}" pattern="yyyy-MM-dd"/>" onchange="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-endDate"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Giờ kết thúc <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">schedule</span>
                                <input type="time" name="endTime" id="endTime" class="bk-form-input" value="<fmt:formatDate value="${parsedEndDate}" pattern="HH:mm"/>">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-endTime"></span>
                        </div>
                    </div>
                </div>

                <%-- Delivery Method & Locations --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <h3>Nhận xe và Địa điểm</h3>
                    <div class="bk-form-grid" style="grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Phương thức nhận xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">local_shipping</span>
                                <select name="deliveryMethod" id="deliveryMethod" class="bk-form-select" onchange="onDeliveryMethodChange()">
                                    <option value="SHOWROOM" ${booking.deliveryMethod == 'SHOWROOM' ? 'selected' : ''}>Lấy tại showroom (Miễn phí)</option>
                                    <option value="DELIVERY" ${booking.deliveryMethod == 'DELIVERY' ? 'selected' : ''}>Giao xe tận nơi (<fmt:formatNumber value="${not empty deliveryFeePerKm ? deliveryFeePerKm : 15000}" type="number" groupingUsed="true"/>đ/km)</option>
                                </select>
                            </div>
                        </div>
                        <div class="bk-form-group" id="distanceGroup" style="display:${booking.deliveryMethod == 'DELIVERY' ? 'block' : 'none'};">
                            <label class="bk-form-label">Khoảng cách giao xe (km) <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">map</span>
                                <input type="number" name="deliveryDistance" id="deliveryDistance" class="bk-form-input" value="${booking.deliveryDistance}" min="0" onchange="calculateBookingCost()" onkeyup="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-deliveryDistance"></span>
                        </div>
                    </div>
                    
                    <div class="bk-form-grid" id="locationsGroup">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Điểm nhận xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">location_on</span>
                                <input type="text" name="pickupLocation" id="pickupLocation" class="bk-form-input" value="${booking.pickupLocation}" placeholder="Nhập địa điểm nhận xe" readonly>
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-pickupLocation"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Điểm trả xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">pin_drop</span>
                                <input type="text" name="returnLocation" id="returnLocation" class="bk-form-input" value="${booking.returnLocation}" placeholder="Nhập địa điểm trả xe">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-returnLocation"></span>
                        </div>
                    </div>
                    
                    <%-- Address Input for Delivery --%>
                    <div class="bk-form-group" id="deliveryAddressGroup" style="display:${booking.deliveryMethod == 'DELIVERY' ? 'block' : 'none'}; margin-top: 16px;">
                        <label class="bk-form-label">Địa chỉ giao xe tận nơi <span style="color:var(--error);">*</span></label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">home</span>
                            <input type="text" name="deliveryAddress" id="deliveryAddress" class="bk-form-input" value="${booking.deliveryAddress}" placeholder="Nhập địa chỉ nhà của bạn">
                        </div>
                        <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-deliveryAddress"></span>
                    </div>
                </div>

                <%-- Notes --%>
                <div class="bk-form-group" style="margin-bottom:24px;">
                    <label class="bk-form-label">Ghi chú (Tùy chọn)</label>
                    <textarea name="notes" id="notes" class="bk-form-textarea" rows="3" placeholder="Thêm bất kỳ yêu cầu đặc biệt hoặc ghi chú liên quan...">${booking.notes}</textarea>
                </div>

                <%-- Actions --%>
                <div class="bk-form-actions">
                    <button type="submit" class="bk-btn bk-btn-primary" style="padding:12px 32px;">
                        <span class="material-symbols-outlined">save</span> Lưu Thay Đổi
                    </button>
                </div>
            </form>
        </div>
    </div>

    <%-- RIGHT: Vehicle + Cost Summary --%>
    <div>
        <%-- Selected Vehicle --%>
        <div class="bk-cost-card bk-vehicle-card" style="margin-bottom:24px;">
            <div class="header">
                <h3><span class="material-symbols-outlined">directions_car</span> Xe đã chọn</h3>
            </div>
            <div id="vehicleInfo" style="color:var(--on-surface-variant);font-size:14px;">
                <p>Vui lòng chọn xe từ danh sách bên trái.</p>
            </div>
        </div>

        <%-- Financial Summary --%>
        <div class="bk-cost-card">
            <h3><span class="material-symbols-outlined">receipt_long</span> Tóm tắt Tài chính</h3>
            <div class="bk-detail-rows">
                <div class="bk-detail-row">
                    <span class="label">Giá thuê cơ bản (<span id="daysCount">0</span> ngày)</span>
                    <span class="value" id="baseCost">0 ₫</span>
                </div>
                <div class="bk-detail-row" id="rowDiscount" style="display:none;">
                    <span class="label" style="color: var(--success); font-weight: 600;">Chiết khấu & Ưu đãi</span>
                    <span class="value" id="discountCost" style="color: var(--success); font-weight: 600;">-0 ₫</span>
                </div>
                <div class="bk-detail-row" id="rowDelivery" style="display:none;">
                    <span class="label">Phí giao xe tận nơi</span>
                    <span class="value" id="deliveryCost">0 ₫</span>
                </div>
                <div class="bk-detail-row" id="rowSurcharge" style="display:none;">
                    <span class="label" style="color: var(--warning); font-weight: 600;">Dự kiến phụ trội KM</span>
                    <span class="value" id="surchargeCost" style="color: var(--warning); font-weight: 600;">0 ₫</span>
                </div>
                <div class="bk-detail-row" id="rowTetSurcharge" style="display:none;">
                    <span class="label" style="color: var(--error); font-weight: 600;">Phụ thu dịp lễ Tết</span>
                    <span class="value" id="tetSurchargeCost" style="color: var(--error); font-weight: 600;">0 ₫</span>
                </div>
                <div class="bk-detail-row">
                    <span class="label">Thuế suất VAT (${not empty taxRate ? taxRate : 10}%)</span>
                    <span class="value" id="taxCost">0 ₫</span>
                </div>
            </div>
            <div class="bk-summary-total">
                <span class="label">Tổng tiền ước tính</span>
                <span class="value" id="totalCost">0 ₫</span>
            </div>
            <div class="bk-summary-highlight">
                <div>
                    <div class="label">Tiền cọc yêu cầu (${not empty depositPercentage ? depositPercentage : 30}%)</div>
                    <div style="font-size:12px;color:var(--on-surface-variant);">Tạm giữ</div>
                </div>
                <span class="value" id="depositCost">0 ₫</span>
            </div>
        </div>
    </div>
</div>

<script>
var carPrices = {};
var carModels = {};
var carBrands = {};

var depositPct = parseFloat('${depositPercentage}') || 30;
var taxRateVal = parseFloat('${taxRate}') || 10;
var deliveryFeePerKm = parseFloat('${deliveryFeePerKm}') || 15000;
var tripKmLimit = parseInt('${tripKmLimit}') || 150;
var combo7KmLimit = parseInt('${combo7KmLimit}') || 1500;
var combo10KmLimit = parseInt('${combo10KmLimit}') || 2000;
var combo30KmLimit = parseInt('${combo30KmLimit}') || 5000;
var kmLimitPerDay = parseInt('${kmLimitPerDay}') || 250;
var discountLongTier = parseFloat('${discountLongTier}') || 20;
var discountMediumTier = parseFloat('${discountMediumTier}') || 10;
var discountShortTier = parseFloat('${discountShortTier}') || 5;
var lowMileagePct = parseFloat('${lowMileageDiscountPercent}') || 5;
var extraKmFee = parseFloat('${extraKmFee}') || 4000;
var tripMultiplier = parseFloat('${tripRateMultiplierPercent}') || 20;
var combo7DiscountPercent = parseFloat('${combo7DiscountPercent}') || 15;
var combo10DiscountPercent = parseFloat('${combo10DiscountPercent}') || 20;
var combo30DiscountPercent = parseFloat('${combo30DiscountPercent}') || 30;

var tetStartDateStr = '${tetStartDate}';
var tetEndDateStr = '${tetEndDate}';
var tetSurchargePercent = parseFloat('${tetSurchargePercent}') || 20;

var carsList = [];
<c:forEach var="car" items="${cars}">
    carsList.push({
        id: ${car.carId},
        brand: '${car.brand}',
        model: '${car.model}',
        plate: '${car.licensePlate}',
        price: parseFloat('${car.dailyRate}'),
        location: '${car.location}',
        image: '${primaryImages[car.carId]}'
    });
    carPrices[${car.carId}] = parseFloat('${car.dailyRate}');
    carModels[${car.carId}] = '${car.model}'.toLowerCase();
    carBrands[${car.carId}] = '${car.brand}'.toLowerCase();
</c:forEach>

function initFilters() {
    var brandFilter = document.getElementById('brandFilter');
    var selectedCarId = "${booking.carId}";
    
    var brands = new Set();
    carsList.forEach(function(c) {
        brands.add(c.brand);
    });
    
    brands.forEach(function(b) {
        var opt = document.createElement('option');
        opt.value = b;
        opt.textContent = b;
        brandFilter.appendChild(opt);
    });
    
    if (selectedCarId) {
        var carId = parseInt(selectedCarId);
        var foundCar = carsList.find(function(c) { return c.id === carId; });
        if (foundCar) {
            brandFilter.value = foundCar.brand;
            onBrandChange();
            
            var modelFilter = document.getElementById('modelFilter');
            modelFilter.value = foundCar.model;
            onModelChange();
            
            var carSelect = document.getElementById('carSelect');
            carSelect.value = selectedCarId;
            updateCarInfo();
        }
    }
}

function onBrandChange() {
    var brand = document.getElementById('brandFilter').value;
    var modelFilter = document.getElementById('modelFilter');
    var carSelect = document.getElementById('carSelect');
    
    modelFilter.innerHTML = '<option value="">-- Chọn dòng xe --</option>';
    carSelect.innerHTML = '<option value="">-- Chọn xe --</option>';
    carSelect.disabled = true;
    
    if (!brand) {
        modelFilter.disabled = true;
        updateCarInfo();
        return;
    }
    
    modelFilter.disabled = false;
    var models = new Set();
    carsList.forEach(function(c) {
        if (c.brand === brand) {
            models.add(c.model);
        }
    });
    
    models.forEach(function(m) {
        var opt = document.createElement('option');
        opt.value = m;
        opt.textContent = m;
        modelFilter.appendChild(opt);
    });
    updateCarInfo();
}

function onModelChange() {
    var brand = document.getElementById('brandFilter').value;
    var model = document.getElementById('modelFilter').value;
    var carSelect = document.getElementById('carSelect');
    
    carSelect.innerHTML = '<option value="">-- Chọn xe --</option>';
    
    if (!model) {
        carSelect.disabled = true;
        updateCarInfo();
        return;
    }
    
    carSelect.disabled = false;
    carsList.forEach(function(c) {
        if (c.brand === brand && c.model === model) {
            var opt = document.createElement('option');
            opt.value = c.id;
            opt.textContent = c.brand + ' ' + c.model + ' — ' + c.plate;
            carSelect.appendChild(opt);
        }
    });
    updateCarInfo();
}

function updateCarInfo() {
    var carId = document.getElementById('carSelect').value;
    var infoDiv = document.getElementById('vehicleInfo');
    
    if (!carId) {
        infoDiv.innerHTML = '<p>Vui lòng chọn xe từ danh sách bên trái.</p>';
        document.getElementById('pickupLocation').value = '';
        calculateBookingCost();
        return;
    }
    
    var car = carsList.find(function(c) { return c.id === parseInt(carId); });
    if (car) {
        infoDiv.innerHTML = '<div style="display:flex;gap:12px;align-items:center;">' +
            '<div style="width:64px;height:64px;border-radius:6px;background:var(--surface-container-high);overflow:hidden;flex-shrink:0;display:flex;align-items:center;justify-content:center;">' +
            '<img src="${pageContext.request.contextPath}' + car.image + '" style="width:100%;height:100%;object-fit:cover;" onerror="this.src=\'${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg\'">' +
            '</div>' +
            '<div>' +
            '<div style="font-weight:700;color:var(--primary);">' + car.brand + ' ' + car.model + '</div>' +
            '<div style="font-size:12px;color:var(--outline);margin-top:2px;">Biển số: ' + car.plate + '</div>' +
            '<div style="font-size:13px;font-weight:600;color:var(--primary);margin-top:4px;">' + formatNumber(car.price) + 'đ/ngày</div>' +
            '</div>' +
            '</div>';
        
        var deliveryMethod = document.getElementById('deliveryMethod').value;
        if (deliveryMethod === 'SHOWROOM') {
            document.getElementById('pickupLocation').value = "Showroom: " + car.location;
        }
    }
    calculateBookingCost();
}

function formatNumber(num) {
    return new Intl.NumberFormat('vi-VN').format(Math.round(num));
}

function parseLocalDate(dateStr) {
    if (!dateStr) return null;
    var parts = dateStr.split('-');
    return new Date(parts[0], parts[1] - 1, parts[2]);
}

function onRentalModeChange() {
    var modeCombo = document.getElementById('rentalModeCombo').value;
    var modeInput = document.getElementById('rentalMode');
    var pkgInput = document.getElementById('pricingPackage');
    var desc = document.getElementById('modeDescription');
    
    var edInput = document.getElementById('endDate');
    var sd = document.getElementById('startDate').value;
    
    edInput.readOnly = false;
    
    var descText = "";
    if (modeCombo === "DAILY_STANDARD") {
        modeInput.value = "DAILY";
        pkgInput.value = "";
        descText = "<strong>Thuê theo ngày tiêu chuẩn:</strong> Giá cơ bản được tính theo số ngày thuê. Khách đi vượt quá hạn mức số km hàng ngày (" + kmLimitPerDay + "km/ngày) sẽ chịu phí phụ trội " + formatNumber(extraKmFee) + "đ/km.";
    } else if (modeCombo === "TRIP_STANDARD") {
        modeInput.value = "TRIP";
        pkgInput.value = "";
        descText = "<strong>Thuê theo chuyến trọn gói:</strong> Phù hợp cho lộ trình xác định. Trọn gói tối đa " + tripKmLimit + "km. Giá thuê chuyến tính bằng 120% đơn giá ngày tiêu chuẩn.";
    } else if (modeCombo === "COMBO_7_DAYS") {
        modeInput.value = "COMBO";
        pkgInput.value = "COMBO_7_DAYS";
        descText = "<strong>Combo 7 ngày (Tuần):</strong> Gói thuê tuần tiết kiệm, giảm giá tới " + combo7DiscountPercent + "% so với ngày thường. Giới hạn tổng số km đi là " + formatNumber(combo7KmLimit) + "km.";
        edInput.readOnly = true;
        if (sd) {
            var start = new Date(sd);
            var end = new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
            edInput.value = end.toISOString().split('T')[0];
        }
    } else if (modeCombo === "COMBO_10_DAYS") {
        modeInput.value = "COMBO";
        pkgInput.value = "COMBO_10_DAYS";
        descText = "<strong>Combo 10 ngày đặc biệt:</strong> Áp dụng giảm giá " + combo10DiscountPercent + "% so với thuê ngày lẻ. Hạn mức tổng số km đi là " + formatNumber(combo10KmLimit) + "km.";
        edInput.readOnly = true;
        if (sd) {
            var start = new Date(sd);
            var end = new Date(start.getTime() + 10 * 24 * 60 * 60 * 1000);
            edInput.value = end.toISOString().split('T')[0];
        }
    } else if (modeCombo === "COMBO_30_DAYS") {
        modeInput.value = "COMBO";
        pkgInput.value = "COMBO_30_DAYS";
        descText = "<strong>Combo 30 ngày (Tháng):</strong> Gói thuê tháng siêu tiết kiệm, giảm giá lên tới " + combo30DiscountPercent + "% so với thuê ngày lẻ. Giới hạn " + formatNumber(combo30KmLimit) + "km cho cả tháng thuê.";
        edInput.readOnly = true;
        if (sd) {
            var start = new Date(sd);
            var end = new Date(start.getTime() + 30 * 24 * 60 * 60 * 1000);
            edInput.value = end.toISOString().split('T')[0];
        }
    }
    desc.innerHTML = descText;
    calculateBookingCost();
}

function onDeliveryMethodChange() {
    var deliveryMethod = document.getElementById('deliveryMethod').value;
    var distGroup = document.getElementById('distanceGroup');
    var addrGroup = document.getElementById('deliveryAddressGroup');
    var pickupInput = document.getElementById('pickupLocation');
    var pickupGroup = pickupInput.closest('.bk-form-group');
    
    if (deliveryMethod === "DELIVERY") {
        distGroup.style.display = 'block';
        addrGroup.style.display = 'block';
        if (pickupGroup) {
            pickupGroup.style.display = 'none';
        }
        pickupInput.value = "Giao xe tận nơi";
    } else {
        distGroup.style.display = 'none';
        addrGroup.style.display = 'none';
        if (pickupGroup) {
            pickupGroup.style.display = 'block';
        }
        pickupInput.readOnly = true;
        
        var carId = document.getElementById('carSelect').value;
        if (carId) {
            var car = carsList.find(function(c) { return c.id === parseInt(carId); });
            if (car) {
                pickupInput.value = "Showroom: " + car.location;
            }
        } else {
            pickupInput.value = "";
        }
    }
    calculateBookingCost();
}

function calculateBookingCost() {
    var carId = document.getElementById('carSelect').value;
    if (!carId) {
        resetSummary();
        return;
    }

    var dailyRate = carPrices[parseInt(carId)] || 0;
    var modeCombo = document.getElementById('rentalModeCombo').value;
    var estKm = parseInt(document.getElementById('estimatedKm').value) || 0;
    
    var sdVal = document.getElementById('startDate').value;
    var edVal = document.getElementById('endDate').value;
    
    if (!sdVal || !edVal) {
        resetSummary();
        return;
    }

    var start = new Date(sdVal);
    var end = new Date(edVal);
    var rentalDays = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    if (rentalDays < 1) rentalDays = 1;

    document.getElementById('daysCount').textContent = rentalDays;

    var baseAmount = 0;
    var kmLimit = 0;
    var discountPercent = 0;

    if (modeCombo === "DAILY_STANDARD") {
        baseAmount = dailyRate * rentalDays;
        kmLimit = kmLimitPerDay * rentalDays;
        if (rentalDays >= 14) {
            discountPercent = discountLongTier;
        } else if (rentalDays >= 7) {
            discountPercent = discountMediumTier;
        } else if (rentalDays >= 3) {
            discountPercent = discountShortTier;
        }
    } else if (modeCombo === "TRIP_STANDARD") {
        baseAmount = (dailyRate * 1.2) * rentalDays;
        kmLimit = tripKmLimit;
    } else if (modeCombo === "COMBO_7_DAYS") {
        baseAmount = dailyRate * 7;
        kmLimit = combo7KmLimit;
        discountPercent = combo7DiscountPercent;
    } else if (modeCombo === "COMBO_10_DAYS") {
        baseAmount = dailyRate * 10;
        kmLimit = combo10KmLimit;
        discountPercent = combo10DiscountPercent;
    } else if (modeCombo === "COMBO_30_DAYS") {
        baseAmount = dailyRate * 30;
        kmLimit = combo30KmLimit;
        discountPercent = combo30DiscountPercent;
    }

    var baseDiscount = baseAmount * (discountPercent / 100);
    var lowMileageDiscount = 0;
    if (estKm > 0 && estKm < (kmLimit * 0.7)) {
        lowMileageDiscount = baseAmount * (lowMileagePct / 100);
    }
    var totalDiscount = baseDiscount + lowMileageDiscount;

    var estimatedSurcharge = 0;
    if (estKm > kmLimit) {
        estimatedSurcharge = (estKm - kmLimit) * extraKmFee;
    }

    var deliveryMethod = document.getElementById('deliveryMethod').value;
    var deliveryDistance = parseFloat(document.getElementById('deliveryDistance').value) || 0;
    var deliveryFee = 0;
    if (deliveryMethod === "DELIVERY" && deliveryDistance > 0) {
        deliveryFee = deliveryDistance * deliveryFeePerKm;
    }

    var tetSurcharge = 0;
    if (tetStartDateStr && tetEndDateStr) {
        var tetStart = parseLocalDate(tetStartDateStr);
        var tetEnd = parseLocalDate(tetEndDateStr);
        var overlapDays = 0;
        
        for (var d = new Date(start); d < end; d.setDate(d.getDate() + 1)) {
            var curr = new Date(d);
            curr.setHours(0,0,0,0);
            if (curr >= tetStart && curr <= tetEnd) {
                overlapDays++;
            }
        }
        if (overlapDays > 0) {
            tetSurcharge = dailyRate * overlapDays * (tetSurchargePercent / 100);
        }
    }

    var subTotal = baseAmount - totalDiscount + estimatedSurcharge + deliveryFee + tetSurcharge;
    if (subTotal < 0) subTotal = 0;

    var taxAmount = subTotal * (taxRateVal / 100);
    var totalAmount = subTotal + taxAmount;
    var depositAmount = totalAmount * (depositPct / 100);

    document.getElementById('baseCost').textContent = formatNumber(baseAmount) + " ₫";
    
    var rowDiscount = document.getElementById('rowDiscount');
    if (totalDiscount > 0) {
        rowDiscount.style.display = 'flex';
        document.getElementById('discountCost').textContent = "-" + formatNumber(totalDiscount) + " ₫";
    } else {
        rowDiscount.style.display = 'none';
    }

    var rowDelivery = document.getElementById('rowDelivery');
    if (deliveryFee > 0) {
        rowDelivery.style.display = 'flex';
        document.getElementById('deliveryCost').textContent = formatNumber(deliveryFee) + " ₫";
    } else {
        rowDelivery.style.display = 'none';
    }

    var rowSurcharge = document.getElementById('rowSurcharge');
    if (estimatedSurcharge > 0) {
        rowSurcharge.style.display = 'flex';
        document.getElementById('surchargeCost').textContent = formatNumber(estimatedSurcharge) + " ₫";
    } else {
        rowSurcharge.style.display = 'none';
    }

    var rowTetSurcharge = document.getElementById('rowTetSurcharge');
    if (tetSurcharge > 0) {
        rowTetSurcharge.style.display = 'flex';
        document.getElementById('tetSurchargeCost').textContent = formatNumber(tetSurcharge) + " ₫";
    } else {
        rowTetSurcharge.style.display = 'none';
    }

    document.getElementById('taxCost').textContent = formatNumber(taxAmount) + " ₫";
    document.getElementById('totalCost').textContent = formatNumber(totalAmount) + " ₫";
    document.getElementById('depositCost').textContent = formatNumber(depositAmount) + " ₫";
}

function resetSummary() {
    document.getElementById('baseCost').textContent = "0 ₫";
    document.getElementById('rowDiscount').style.display = 'none';
    document.getElementById('rowDelivery').style.display = 'none';
    document.getElementById('rowSurcharge').style.display = 'none';
    document.getElementById('rowTetSurcharge').style.display = 'none';
    document.getElementById('taxCost').textContent = "0 ₫";
    document.getElementById('totalCost').textContent = "0 ₫";
    document.getElementById('depositCost').textContent = "0 ₫";
}

// Auto bind start date to set end date for combo
document.getElementById('startDate').addEventListener('change', function() {
    var sd = this.value;
    if (!sd) return;
    
    var modeCombo = document.getElementById('rentalModeCombo').value;
    var edInput = document.getElementById('endDate');
    
    if (modeCombo === "COMBO_7_DAYS") {
        var start = new Date(sd);
        var end = new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
        edInput.value = end.toISOString().split('T')[0];
    } else if (modeCombo === "COMBO_10_DAYS") {
        var start = new Date(sd);
        var end = new Date(start.getTime() + 10 * 24 * 60 * 60 * 1000);
        edInput.value = end.toISOString().split('T')[0];
    } else if (modeCombo === "COMBO_30_DAYS") {
        var start = new Date(sd);
        var end = new Date(start.getTime() + 30 * 24 * 60 * 60 * 1000);
        edInput.value = end.toISOString().split('T')[0];
    }
    calculateBookingCost();
});

// Setup form validation
window.addEventListener('DOMContentLoaded', function() {
    initFilters();
    onRentalModeChange();
    
    var form = document.getElementById('bookingForm');
    if (form) {
        form.addEventListener('submit', function(event) {
            var hasErrors = false;
            
            function showError(id, msg) {
                var el = document.getElementById('err-' + id);
                if (el) {
                    el.textContent = msg;
                    el.style.display = 'block';
                }
                hasErrors = true;
            }
            
            var errElements = document.querySelectorAll('.error-msg');
            errElements.forEach(function(el) {
                el.textContent = '';
                el.style.display = 'none';
            });
            
            var carVal = document.getElementById('carSelect').value;
            if (!carVal) {
                showError('carId', 'Vui lòng chọn xe.');
            }
            
            var sdVal = document.getElementById('startDate').value;
            if (!sdVal) {
                showError('startDate', 'Vui lòng chọn ngày bắt đầu.');
            }
            
            var stVal = document.getElementById('startTime').value;
            if (!stVal) {
                showError('startTime', 'Vui lòng chọn giờ bắt đầu.');
            }
            
            var edVal = document.getElementById('endDate').value;
            if (!edVal) {
                showError('endDate', 'Vui lòng chọn ngày kết thúc.');
            }
            
            var etVal = document.getElementById('endTime').value;
            if (!etVal) {
                showError('endTime', 'Vui lòng chọn giờ kết thúc.');
            }

            var estKmVal = parseInt(document.getElementById('estimatedKm').value);
            if (isNaN(estKmVal) || estKmVal <= 0) {
                showError('estimatedKm', 'Vui lòng nhập số km di chuyển dự kiến hợp lệ (lớn hơn 0).');
            }
            
            var deliveryMethod = document.getElementById('deliveryMethod').value;
            if (deliveryMethod === "DELIVERY") {
                var addrVal = document.getElementById('deliveryAddress').value.trim();
                if (!addrVal) {
                    showError('deliveryAddress', 'Vui lòng nhập địa chỉ giao xe tận nơi.');
                }
                var distVal = parseFloat(document.getElementById('deliveryDistance').value);
                if (isNaN(distVal) || distVal <= 0) {
                    showError('deliveryDistance', 'Vui lòng nhập khoảng cách giao xe lớn hơn 0.');
                }
            }

            var plVal = document.getElementById('pickupLocation').value.trim();
            if (!plVal) {
                showError('pickupLocation', 'Vui lòng nhập điểm nhận xe.');
            }
            
            var rlVal = document.getElementById('returnLocation').value.trim();
            if (!rlVal) {
                showError('returnLocation', 'Vui lòng nhập điểm trả xe.');
            }
            
            if (sdVal && edVal) {
                var todayDateStr = new Date().toISOString().split('T')[0];
                if (sdVal < todayDateStr) {
                    showError('startDate', 'Ngày bắt đầu không được ở quá khứ.');
                }
                
                var start = new Date(sdVal);
                var end = new Date(edVal);
                var days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
                if (days < 1) {
                    days = 1;
                }

                var modeCombo = document.getElementById('rentalModeCombo').value;
                if (modeCombo === "COMBO_10_DAYS" && days !== 10) {
                    showError('endDate', 'Gói combo 10 ngày yêu cầu thời gian thuê chính xác là 10 ngày.');
                } else if (modeCombo === "COMBO_7_DAYS" && days !== 7) {
                    showError('endDate', 'Gói combo tuần yêu cầu thời gian thuê chính xác là 7 ngày.');
                } else if (modeCombo === "COMBO_30_DAYS" && days !== 30) {
                    showError('endDate', 'Gói combo tháng yêu cầu thời gian thuê chính xác là 30 ngày.');
                }
                
                if (edVal < sdVal) {
                    showError('endDate', 'Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.');
                } else if (edVal === sdVal && stVal && etVal) {
                    if (etVal <= stVal) {
                        showError('endTime', 'Giờ kết thúc phải lớn hơn giờ bắt đầu khi chọn cùng ngày.');
                    }
                }
            }
            
            if (hasErrors) {
                event.preventDefault();
                var firstError = document.querySelector('.error-msg[style*="display: block"]');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        });
    }
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
