<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Tạo Đặt Xe"/>
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
            <span class="current">Tạo đặt xe</span>
        </div>
        <h2>Tạo đơn đặt xe mới</h2>
    </div>
    <a href="${pageContext.request.contextPath}/bookings/my" class="bk-btn bk-btn-outline">Hủy</a>
</div>

<%-- Booking Grid: Form left, Summary right --%>
<div class="bk-booking-grid">
    <%-- LEFT: Form --%>
    <div>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">assignment</span> Chi tiết Đặt xe
            </div>

            <form method="post" action="${pageContext.request.contextPath}/bookings/create" id="bookingForm" novalidate>

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
                                                ${selectedCarId == car.carId ? 'selected' : ''}>
                                            ${car.brand} ${car.model} — ${car.licensePlate}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-carId"></span>
                        </div>
                    </div>
                    <%-- Available count hint --%>
                    <div id="carCountHint" style="margin-top: 8px; font-size: 13px; color: var(--on-surface-variant); display: none;">
                        <span class="material-symbols-outlined" style="font-size:16px;vertical-align:middle;">info</span>
                        <span id="carCountText"></span>
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
                                <select name="rentalModeCombo" id="rentalModeCombo" class="bk-form-select" onchange="onRentalModeChange()">
                                    <option value="DAILY_STANDARD">Thuê theo ngày (Tiêu chuẩn)</option>
                                    <option value="TRIP_STANDARD">Thuê theo chuyến (Trọn gói ${not empty tripKmLimit ? tripKmLimit : 150}km)</option>
                                    <option value="COMBO_7_DAYS">Gói Combo 7 ngày (Tuần)</option>
                                    <option value="COMBO_10_DAYS">Gói Combo 10 ngày</option>
                                    <option value="COMBO_30_DAYS">Gói Combo 30 ngày (Tháng)</option>
                                </select>
                            </div>
                            <!-- Hidden inputs to submit separate values -->
                            <input type="hidden" name="rentalMode" id="rentalMode" value="DAILY">
                            <input type="hidden" name="pricingPackage" id="pricingPackage" value="">
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Số KM di chuyển dự kiến <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">speed</span>
                                <input type="number" name="estimatedKm" id="estimatedKm" class="bk-form-input" placeholder="Nhập số km dự kiến" min="1" value="100" onchange="calculateBookingCost()" onkeyup="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-estimatedKm"></span>
                        </div>
                    </div>
                    <div id="modeDescription" style="margin-top: 8px; font-size: 13px; color: var(--on-surface-variant); background: var(--surface-container-low); padding: 12px; border-radius: 6px; border-left: 3px solid var(--primary); font-weight: 500;">
                        <!-- Sẽ thay đổi theo lựa chọn gói thuê -->
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
                                <input type="date" name="startDate" id="startDate" class="bk-form-input" onchange="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-startDate"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Giờ bắt đầu <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">schedule</span>
                                <input type="time" name="startTime" id="startTime" class="bk-form-input" value="08:00">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-startTime"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Ngày kết thúc <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">event</span>
                                <input type="date" name="endDate" id="endDate" class="bk-form-input" onchange="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-endDate"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Giờ kết thúc <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">schedule</span>
                                <input type="time" name="endTime" id="endTime" class="bk-form-input" value="08:00">
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
                                    <option value="SHOWROOM">Lấy tại showroom (Miễn phí)</option>
                                    <option value="DELIVERY">Giao xe tận nơi (<fmt:formatNumber value="${not empty deliveryFeePerKm ? deliveryFeePerKm : 15000}" type="number" groupingUsed="true"/>đ/km)</option>
                                </select>
                            </div>
                        </div>
                        <div class="bk-form-group" id="distanceGroup" style="display:none;">
                            <label class="bk-form-label">Khoảng cách giao xe (km) <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">map</span>
                                <input type="number" name="deliveryDistance" id="deliveryDistance" class="bk-form-input" value="0" min="0" onchange="calculateBookingCost()" onkeyup="calculateBookingCost()">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-deliveryDistance"></span>
                        </div>
                    </div>
                    
                    <div class="bk-form-grid" id="locationsGroup">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Điểm nhận xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">location_on</span>
                                <input type="text" name="pickupLocation" id="pickupLocation" class="bk-form-input" placeholder="Nhập địa điểm nhận xe" readonly>
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-pickupLocation"></span>
                        </div>
                        <div class="bk-form-group">
                            <label class="bk-form-label">Điểm trả xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">pin_drop</span>
                                <input type="text" name="returnLocation" id="returnLocation" class="bk-form-input" placeholder="Nhập địa điểm trả xe">
                            </div>
                            <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-returnLocation"></span>
                        </div>
                    </div>
                    
                    <%-- Address Input for Delivery --%>
                    <div class="bk-form-group" id="deliveryAddressGroup" style="display:none; margin-top: 16px;">
                        <label class="bk-form-label">Địa chỉ giao xe tận nơi <span style="color:var(--error);">*</span></label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">home</span>
                            <input type="text" name="deliveryAddress" id="deliveryAddress" class="bk-form-input" placeholder="Nhập địa chỉ nhà của bạn">
                        </div>
                        <span class="error-msg" style="color:var(--error);font-size:12px;margin-top:4px;display:none;" id="err-deliveryAddress"></span>
                    </div>
                </div>

                <%-- Notes --%>
                <div class="bk-form-group" style="margin-bottom:24px;">
                    <label class="bk-form-label">Ghi chú (Tùy chọn)</label>
                    <textarea name="notes" class="bk-form-textarea" rows="3" placeholder="Thêm bất kỳ yêu cầu đặc biệt hoặc ghi chú liên quan..."></textarea>
                </div>

                <%-- Actions --%>
                <div class="bk-form-actions">
                    <button type="submit" class="bk-btn bk-btn-primary" style="padding:12px 32px;">
                        <span class="material-symbols-outlined">check_circle</span> Gửi Đơn Đặt xe
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

// Configurations loaded dynamically from policy settings in servlet
var depositPct = parseFloat('${depositPercentage}') || 30;
var taxRate = parseFloat('${taxRate}') || 10;
var deliveryFeePerKm = parseFloat('${deliveryFeePerKm}') || 15000;
var tripKmLimit = parseInt('${tripKmLimit}') || 150;
var combo7KmLimit = parseInt('${combo7KmLimit}') || 1500;
var combo10KmLimit = parseInt('${combo10KmLimit}') || 2000;
var combo30KmLimit = parseInt('${combo30KmLimit}') || 5000;
var kmLimitPerDay = parseInt('${kmLimitPerDay}') || 250;
var discountLongTier = parseFloat('${discountLongTier}') || 20;
var discountMediumTier = parseFloat('${discountMediumTier}') || 10;
var discountShortTier = parseFloat('${discountShortTier}') || 5;
var lowMileageDiscountPercent = parseFloat('${lowMileageDiscountPercent}') || 5;
var extraKmFee = parseFloat('${extraKmFee}') || 4000;
var tripRateMultiplierPercent = parseFloat('${tripRateMultiplierPercent}') || 20;
var combo7DiscountPercent = parseFloat('${combo7DiscountPercent}') || 15;
var combo10DiscountPercent = parseFloat('${combo10DiscountPercent}') || 20;
var combo30DiscountPercent = parseFloat('${combo30DiscountPercent}') || 30;

var tetStartDateStr = '${tetStartDate}' || '2026-02-12';
var tetEndDateStr = '${tetEndDate}' || '2026-02-22';
var tetSurchargePct = parseFloat('${tetSurchargePercent}') || 20;

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
    var selectedCarId = "${selectedCarId}";
    
    // Get unique brands
    var brands = [];
    carsList.forEach(function(car) {
        if (brands.indexOf(car.brand) === -1) {
            brands.push(car.brand);
        }
    });
    
    // Populate brand filter
    brands.sort().forEach(function(b) {
        var opt = document.createElement('option');
        opt.value = b;
        opt.textContent = b;
        brandFilter.appendChild(opt);
    });

    // If pre-selected car is passed
    if (selectedCarId) {
        var preSelectedCar = carsList.find(function(c) { return c.id == selectedCarId; });
        if (preSelectedCar) {
            brandFilter.value = preSelectedCar.brand;
            onBrandChange(preSelectedCar.model, preSelectedCar.id);
        }
    }
}

function onBrandChange(preSelectedModel, preSelectedCarId) {
    var brand = document.getElementById('brandFilter').value;
    var modelFilter = document.getElementById('modelFilter');
    var carSelect = document.getElementById('carSelect');
    
    modelFilter.innerHTML = '<option value="">-- Chọn dòng xe --</option>';
    modelFilter.disabled = !brand;
    carSelect.innerHTML = '<option value="">-- Chọn xe --</option>';
    carSelect.disabled = true;
    
    document.getElementById('carCountHint').style.display = 'none';
    document.getElementById('vehicleInfo').innerHTML = '<p>Vui lòng chọn xe từ danh sách bên trái.</p>';
    
    if (!brand) {
        calculateBookingCost();
        return;
    }
    
    // Get unique models
    var models = [];
    carsList.forEach(function(car) {
        if (car.brand === brand && models.indexOf(car.model) === -1) {
            models.push(car.model);
        }
    });
    
    models.sort().forEach(function(m) {
        var opt = document.createElement('option');
        opt.value = m;
        opt.textContent = m;
        modelFilter.appendChild(opt);
    });
    
    if (preSelectedModel) {
        modelFilter.value = preSelectedModel;
        onModelChange(preSelectedCarId);
    }
}

function onModelChange(preSelectedCarId) {
    var brand = document.getElementById('brandFilter').value;
    var model = document.getElementById('modelFilter').value;
    var carSelect = document.getElementById('carSelect');
    
    carSelect.innerHTML = '<option value="">-- Chọn xe --</option>';
    carSelect.disabled = !model;
    
    document.getElementById('carCountHint').style.display = 'none';
    document.getElementById('vehicleInfo').innerHTML = '<p>Vui lòng chọn xe từ danh sách bên trái.</p>';
    
    if (!model) {
        calculateBookingCost();
        return;
    }
    
    var matchingCars = carsList.filter(function(car) {
        return car.brand === brand && car.model === model;
    });
    
    matchingCars.forEach(function(car) {
        var opt = document.createElement('option');
        opt.value = car.id;
        opt.textContent = car.brand + ' ' + car.model + ' — ' + car.plate;
        opt.setAttribute('data-brand', car.brand);
        opt.setAttribute('data-model', car.model);
        opt.setAttribute('data-plate', car.plate);
        opt.setAttribute('data-price', car.price);
        opt.setAttribute('data-location', car.location);
        opt.setAttribute('data-image', car.image);
        carSelect.appendChild(opt);
    });
    
    var hintDiv = document.getElementById('carCountHint');
    var hintText = document.getElementById('carCountText');
    hintText.textContent = 'Có ' + matchingCars.length + ' xe sẵn sàng cho dòng ' + brand + ' ' + model;
    hintDiv.style.display = 'block';
    
    if (preSelectedCarId) {
        carSelect.value = preSelectedCarId;
        updateCarInfo();
    }
}

function formatVND(num) {
    return new Intl.NumberFormat('vi-VN').format(num) + ' ₫';
}

function formatNumber(num) {
    return new Intl.NumberFormat('vi-VN').format(num);
}

function updateCarInfo() {
    var sel = document.getElementById('carSelect');
    var opt = sel.options[sel.selectedIndex];
    var info = document.getElementById('vehicleInfo');
    if (!opt.value) {
        info.innerHTML = '<p>Vui lòng chọn xe từ danh sách bên trái.</p>';
        return;
    }
    var brand = opt.getAttribute('data-brand');
    var model = opt.getAttribute('data-model');
    var plate = opt.getAttribute('data-plate');
    var price = parseFloat(opt.getAttribute('data-price')) || 0;
    var location = opt.getAttribute('data-location') || 'Văn phòng chính';
    var imgUrl = opt.getAttribute('data-image') || '/assets/images/cars/placeholder.jpg';
    var contextPath = '${pageContext.request.contextPath}';
    
    // Auto-fill pickup location for showroom
    var deliveryMethod = document.getElementById('deliveryMethod').value;
    if (deliveryMethod === "SHOWROOM") {
        document.getElementById('pickupLocation').value = "Showroom: " + location;
    }
    document.getElementById('returnLocation').value = location;
    
    info.innerHTML =
        '<div style="width:100%;height:140px;background:var(--surface-container-high);border-radius:8px;overflow:hidden;margin-bottom:12px;display:flex;align-items:center;justify-content:center;box-shadow: 0 4px 16px 0 rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.05);">' +
            '<img src="' + contextPath + imgUrl + '" alt="' + brand + '" style="width:100%;height:100%;object-fit:cover;" onerror="this.onerror=null; this.src=\'' + contextPath + '/assets/images/cars/placeholder.jpg\';"/>' +
        '</div>' +
        '<div style="font-size:24px;font-weight:600;color:var(--on-surface);letter-spacing:-0.01em;">' + brand + ' ' + model + '</div>' +
        '<div class="bk-vehicle-specs" style="margin-top:12px;">' +
            '<div><span class="spec-label">Biển số xe</span><div class="spec-value">' + plate + '</div></div>' +
            '<div><span class="spec-label">Giá theo ngày</span><div class="spec-value">' + formatVND(price) + '</div></div>' +
        '</div>';
    calculateBookingCost();
}

function onRentalModeChange() {
    var modeCombo = document.getElementById('rentalModeCombo').value;
    var desc = document.getElementById('modeDescription');
    var sd = document.getElementById('startDate').value;
    var edInput = document.getElementById('endDate');
    
    var descText = "";
    if (modeCombo === "DAILY_STANDARD") {
        descText = "<strong>Thuê theo ngày:</strong> Phù hợp cho nhu cầu di chuyển linh hoạt. Giới hạn " + kmLimitPerDay + "km/ngày. Ưu đãi chiết khấu: " + discountShortTier + "% cho 5-9 ngày, " + discountMediumTier + "% cho 10-29 ngày, " + discountLongTier + "% từ 30 ngày trở lên. Tặng thêm chiết khấu " + lowMileageDiscountPercent + "% khi di chuyển ít (khấu hao thấp, dưới " + Math.round(kmLimitPerDay / 2) + "km/ngày).";
        edInput.readOnly = false;
    } else if (modeCombo === "TRIP_STANDARD") {
        descText = "<strong>Thuê theo chuyến:</strong> Trọn gói di chuyển ngắn hạn trong ngày hoặc chuyến nhanh. Giới hạn " + tripKmLimit + "km trọn gói. Đơn giá km phụ trội " + formatVND(extraKmFee) + "/km. Giảm " + lowMileageDiscountPercent + "% nếu di chuyển ít hơn " + Math.round(tripKmLimit / 2) + "km.";
        edInput.readOnly = false;
    } else if (modeCombo === "COMBO_7_DAYS") {
        descText = "<strong>Combo 7 ngày:</strong> Gói thuê tuần cực kỳ ưu đãi, tiết kiệm " + combo7DiscountPercent + "% so với giá thuê ngày thường. Giới hạn " + formatNumber(combo7KmLimit) + "km cho cả tuần thuê. Thích hợp đi công tác hoặc du lịch gia đình.";
        edInput.readOnly = true;
        if (sd) {
            var start = new Date(sd);
            var end = new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
            edInput.value = end.toISOString().split('T')[0];
        }
    } else if (modeCombo === "COMBO_10_DAYS") {
        descText = "<strong>Combo 10 ngày:</strong> Gói thuê dài hạn cực tốt, tiết kiệm " + combo10DiscountPercent + "% so với giá ngày thường. Giới hạn " + formatNumber(combo10KmLimit) + "km toàn bộ chuyến đi.";
        edInput.readOnly = true;
        if (sd) {
            var start = new Date(sd);
            var end = new Date(start.getTime() + 10 * 24 * 60 * 60 * 1000);
            edInput.value = end.toISOString().split('T')[0];
        }
    } else if (modeCombo === "COMBO_30_DAYS") {
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
        // When delivery is active, backend uses deliveryAddress so we can fill pickupLocation with placeholder to satisfy validation
        pickupInput.value = "Giao xe tận nơi";
    } else {
        distGroup.style.display = 'none';
        addrGroup.style.display = 'none';
        if (pickupGroup) {
            pickupGroup.style.display = 'block';
        }
        pickupInput.readOnly = true;
        
        var sel = document.getElementById('carSelect');
        var opt = sel.options[sel.selectedIndex];
        if (opt && opt.value) {
            var location = opt.getAttribute('data-location') || 'Văn phòng chính';
            pickupInput.value = "Showroom: " + location;
        } else {
            pickupInput.value = "Showroom chính: 123 Đường Láng, Hà Nội";
        }
    }
    calculateBookingCost();
}

function calculateBookingCost() {
    var carId = document.getElementById('carSelect').value;
    var sd = document.getElementById('startDate').value;
    var ed = document.getElementById('endDate').value;
    var modeCombo = document.getElementById('rentalModeCombo').value;
    var estimatedKm = parseInt(document.getElementById('estimatedKm').value) || 0;
    var deliveryMethod = document.getElementById('deliveryMethod').value;
    var deliveryDistance = parseFloat(document.getElementById('deliveryDistance').value) || 0;

    if (!carId || !sd || !ed) {
        return;
    }

    var start = new Date(sd);
    var end = new Date(ed);
    var days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    if (days < 1) {
        days = 1;
    }

    var dailyRate = carPrices[carId] || 0;
    var model = carModels[carId] || "";
    var brand = carBrands[carId] || "";

    var rentalMode = "DAILY";
    var pricingPackage = "";
    var baseAmount = 0;
    var kmLimit = kmLimitPerDay * days;
    var extraKmRate = extraKmFee;

    if (modeCombo === "DAILY_STANDARD") {
        rentalMode = "DAILY";
        pricingPackage = "";
        baseAmount = dailyRate * days;
        kmLimit = kmLimitPerDay * days;
        extraKmRate = extraKmFee;
    } else if (modeCombo === "TRIP_STANDARD") {
        rentalMode = "TRIP";
        pricingPackage = "";
        baseAmount = dailyRate * (1.0 + (tripRateMultiplierPercent / 100.0));
        kmLimit = tripKmLimit;
        extraKmRate = extraKmFee;
    } else if (modeCombo === "COMBO_7_DAYS") {
        rentalMode = "COMBO";
        pricingPackage = "COMBO_7_DAYS";
        baseAmount = dailyRate * 7 * (1.0 - (combo7DiscountPercent / 100.0));
        kmLimit = combo7KmLimit;
        extraKmRate = extraKmFee;
    } else if (modeCombo === "COMBO_10_DAYS") {
        rentalMode = "COMBO";
        pricingPackage = "COMBO_10_DAYS";
        baseAmount = dailyRate * 10 * (1.0 - (combo10DiscountPercent / 100.0));
        kmLimit = combo10KmLimit;
        extraKmRate = extraKmFee;
    } else if (modeCombo === "COMBO_30_DAYS") {
        rentalMode = "COMBO";
        pricingPackage = "COMBO_30_DAYS";
        baseAmount = dailyRate * 30 * (1.0 - (combo30DiscountPercent / 100.0));
        kmLimit = combo30KmLimit;
        extraKmRate = extraKmFee;
    }

    // Set hidden inputs
    document.getElementById('rentalMode').value = rentalMode;
    document.getElementById('pricingPackage').value = pricingPackage;

    // 1. Tiered discount
    var tierDiscount = 0;
    if (rentalMode === "DAILY") {
        if (days >= 30) {
            tierDiscount = baseAmount * (discountLongTier / 100.0);
        } else if (days >= 10) {
            tierDiscount = baseAmount * (discountMediumTier / 100.0);
        } else if (days >= 5) {
            tierDiscount = baseAmount * (discountShortTier / 100.0);
        }
    }

    // 2. Low-mileage rebate
    var lowMileageDiscount = 0;
    if (kmLimit > 0 && estimatedKm > 0 && estimatedKm < (kmLimit / 2.0)) {
        lowMileageDiscount = baseAmount * (lowMileageDiscountPercent / 100.0);
    }
    
    var discountAmount = tierDiscount + lowMileageDiscount;

    // 3. Excess KM surcharge
    var estimatedSurcharge = 0;
    if (estimatedKm > kmLimit) {
        estimatedSurcharge = (estimatedKm - kmLimit) * extraKmRate;
    }

    // 4. Delivery fee
    var deliveryFee = 0;
    if (deliveryMethod === "DELIVERY" && deliveryDistance > 0) {
        deliveryFee = deliveryDistance * deliveryFeePerKm;
    }

    // 5. Lunar New Year surcharge (Tet Surcharge)
    var tetSurcharge = 0;
    if (sd && ed) {
        function parseLocalDate(dateStr) {
            var parts = dateStr.split('-');
            return new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]), 0, 0, 0, 0);
        }
        
        var tetStart = parseLocalDate(tetStartDateStr);
        var tetEnd = parseLocalDate(tetEndDateStr);
        var rentStart = parseLocalDate(sd);
        
        var overlapDays = 0;
        for (var i = 0; i < days; i++) {
            var current = new Date(rentStart.getTime());
            current.setDate(rentStart.getDate() + i);
            if (current >= tetStart && current <= tetEnd) {
                overlapDays++;
            }
        }
        
        if (overlapDays > 0) {
            tetSurcharge = dailyRate * overlapDays * (tetSurchargePct / 100.0);
        }
    }

    var subtotal = baseAmount - discountAmount + estimatedSurcharge + deliveryFee + tetSurcharge;
    if (subtotal < 0) {
        subtotal = 0;
    }

    var tax = Math.round(subtotal * (taxRate / 100.0));
    var total = subtotal + tax;
    var deposit = Math.round(total * (depositPct / 100.0));

    // Update financial panel
    document.getElementById('daysCount').textContent = days;
    document.getElementById('baseCost').textContent = formatVND(baseAmount);
    
    var rowDiscount = document.getElementById('rowDiscount');
    if (discountAmount > 0) {
        document.getElementById('discountCost').textContent = "-" + formatVND(discountAmount);
        rowDiscount.style.display = 'flex';
    } else {
        rowDiscount.style.display = 'none';
    }

    var rowDelivery = document.getElementById('rowDelivery');
    if (deliveryFee > 0) {
        document.getElementById('deliveryCost').textContent = formatVND(deliveryFee);
        rowDelivery.style.display = 'flex';
    } else {
        rowDelivery.style.display = 'none';
    }

    var rowSurcharge = document.getElementById('rowSurcharge');
    if (estimatedSurcharge > 0) {
        document.getElementById('surchargeCost').textContent = formatVND(estimatedSurcharge);
        var labelEl = rowSurcharge.querySelector('.label');
        if (labelEl) {
            labelEl.textContent = "Dự kiến phụ trội KM (" + formatVND(extraKmRate) + "/km)";
        }
        rowSurcharge.style.display = 'flex';
    } else {
        rowSurcharge.style.display = 'none';
    }

    var rowTetSurcharge = document.getElementById('rowTetSurcharge');
    if (tetSurcharge > 0) {
        document.getElementById('tetSurchargeCost').textContent = formatVND(tetSurcharge);
        rowTetSurcharge.style.display = 'flex';
    } else {
        rowTetSurcharge.style.display = 'none';
    }

    document.getElementById('taxCost').textContent = formatVND(tax);
    document.getElementById('totalCost').textContent = formatVND(total);
    document.getElementById('depositCost').textContent = formatVND(deposit);
}

// Init and attach listeners robustly
document.addEventListener('DOMContentLoaded', function() {
    var sel = document.getElementById('carSelect');
    var sd = document.getElementById('startDate');
    var ed = document.getElementById('endDate');

    if (sel) {
        sel.addEventListener('change', function() {
            updateCarInfo();
        });
    }

    // Initialize the cascading dropdowns
    initFilters();

    [sd, ed].forEach(function(el) {
        if (el) {
            ['change', 'input', 'blur', 'keyup'].forEach(function(evt) {
                el.addEventListener(evt, function() {
                    if (el.id === 'startDate') {
                        // If combo package, auto update end date
                        var modeCombo = document.getElementById('rentalModeCombo').value;
                        if (modeCombo === "COMBO_7_DAYS" && sd.value) {
                            var start = new Date(sd.value);
                            var end = new Date(start.getTime() + 7 * 24 * 60 * 60 * 1000);
                            document.getElementById('endDate').value = end.toISOString().split('T')[0];
                        } else if (modeCombo === "COMBO_10_DAYS" && sd.value) {
                            var start = new Date(sd.value);
                            var end = new Date(start.getTime() + 10 * 24 * 60 * 60 * 1000);
                            document.getElementById('endDate').value = end.toISOString().split('T')[0];
                        } else if (modeCombo === "COMBO_30_DAYS" && sd.value) {
                            var start = new Date(sd.value);
                            var end = new Date(start.getTime() + 30 * 24 * 60 * 60 * 1000);
                            document.getElementById('endDate').value = end.toISOString().split('T')[0];
                        }
                    }
                    calculateBookingCost();
                });
            });
        }
    });

    onRentalModeChange();
    onDeliveryMethodChange();

    if (sel && sel.value) { 
        updateCarInfo(); 
    }
    
    // Set min date to today
    var today = new Date().toISOString().split('T')[0];
    if (sd) sd.setAttribute('min', today);
    if (ed) ed.setAttribute('min', today);
    
    // Custom form validation
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
