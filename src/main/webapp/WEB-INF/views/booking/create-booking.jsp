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

                <%-- Car Selection --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <div class="bk-form-group">
                        <label class="bk-form-label">Chọn xe <span style="color:var(--error);">*</span></label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">directions_car</span>
                            <select name="carId" id="carSelect" class="bk-form-select" onchange="updateCarInfo()">
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

                <%-- Locations --%>
                <div class="bk-form-section" style="margin-bottom:24px;">
                    <h3>Địa điểm</h3>
                    <div class="bk-form-grid">
                        <div class="bk-form-group">
                            <label class="bk-form-label">Điểm nhận xe <span style="color:var(--error);">*</span></label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined">location_on</span>
                                <input type="text" name="pickupLocation" id="pickupLocation" class="bk-form-input" placeholder="Nhập địa điểm nhận xe">
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
                    <span class="label">Giá cơ bản (<span id="daysCount">0</span> ngày)</span>
                    <span class="value" id="baseCost">0 ₫</span>
                </div>
                <div class="bk-detail-row">
                    <span class="label">Thuế & Phí (10%)</span>
                    <span class="value" id="taxCost">0 ₫</span>
                </div>
            </div>
            <div class="bk-summary-total">
                <span class="label">Số tiền ước tính</span>
                <span class="value" id="totalCost">0 ₫</span>
            </div>
            <div class="bk-summary-highlight">
                <div>
                    <div class="label">Tiền cọc Yêu cầu</div>
                    <div style="font-size:12px;color:var(--on-surface-variant);">Tạm giữ</div>
                </div>
                <span class="value" id="depositCost">0 ₫</span>
            </div>
        </div>
    </div>
</div>

<script>
var carPrices = {};
var depositPct = parseFloat('${depositPercentage}') || 30;
<c:forEach var="car" items="${cars}">
    carPrices[${car.carId}] = parseFloat('${car.dailyRate}');
</c:forEach>

function formatVND(num) {
    return new Intl.NumberFormat('vi-VN').format(num) + ' ₫';
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
    
    // Auto-fill and keep pickup and return location flexible
    document.getElementById('pickupLocation').value = location;
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

function calculateBookingCost() {
    var carId = document.getElementById('carSelect').value;
    var sd = document.getElementById('startDate').value;
    var ed = document.getElementById('endDate').value;
    console.log('calculateCost called with:', { carId: carId, startDate: sd, endDate: ed });
    if (!carId || !sd || !ed) {
        console.log('calculateCost returned early because inputs are missing');
        return;
    }

    var start = new Date(sd);
    var end = new Date(ed);
    var days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    console.log('Calculated date difference in days:', days);
    if (days < 1) {
        days = 1;
        console.log('Adjusted negative or zero days to minimum: 1 day');
    }

    var price = carPrices[carId] || 0;
    console.log('Daily price for car:', price);
    var base = price * days;
    var deposit = Math.ceil(base * depositPct / 100);
    var tax = base * 0.1;
    var total = base + tax;

    document.getElementById('daysCount').textContent = days;
    document.getElementById('baseCost').textContent = formatVND(base);
    document.getElementById('taxCost').textContent = formatVND(Math.round(tax));
    document.getElementById('totalCost').textContent = formatVND(Math.round(total));
    document.getElementById('depositCost').textContent = formatVND(deposit);
    console.log('Cost summary updated successfully on UI:', { base: base, deposit: deposit, tax: tax, total: total });
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

    [sd, ed].forEach(function(el) {
        if (el) {
            ['change', 'input', 'blur', 'keyup'].forEach(function(evt) {
                el.addEventListener(evt, function() {
                    console.log('Event triggered: ' + evt + ' on ' + el.id + ' with value: ' + el.value);
                    calculateBookingCost();
                });
            });
        }
    });

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
            
            // Helper function to show error
            function showError(id, msg) {
                var el = document.getElementById('err-' + id);
                if (el) {
                    el.textContent = msg;
                    el.style.display = 'block';
                }
                hasErrors = true;
            }
            
            // Clear previous errors
            var errElements = document.querySelectorAll('.error-msg');
            errElements.forEach(function(el) {
                el.textContent = '';
                el.style.display = 'none';
            });
            
            // Validate Car
            var carVal = document.getElementById('carSelect').value;
            if (!carVal) {
                showError('carId', 'Vui lòng chọn xe.');
            }
            
            // Validate Start Date
            var sdVal = document.getElementById('startDate').value;
            if (!sdVal) {
                showError('startDate', 'Vui lòng chọn ngày bắt đầu.');
            }
            
            // Validate Start Time
            var stVal = document.getElementById('startTime').value;
            if (!stVal) {
                showError('startTime', 'Vui lòng chọn giờ bắt đầu.');
            }
            
            // Validate End Date
            var edVal = document.getElementById('endDate').value;
            if (!edVal) {
                showError('endDate', 'Vui lòng chọn ngày kết thúc.');
            }
            
            // Validate End Time
            var etVal = document.getElementById('endTime').value;
            if (!etVal) {
                showError('endTime', 'Vui lòng chọn giờ kết thúc.');
            }
            
            // Validate Pickup Location
            var plVal = document.getElementById('pickupLocation').value.trim();
            if (!plVal) {
                showError('pickupLocation', 'Vui lòng nhập điểm nhận xe.');
            }
            
            // Validate Return Location
            var rlVal = document.getElementById('returnLocation').value.trim();
            if (!rlVal) {
                showError('returnLocation', 'Vui lòng nhập điểm trả xe.');
            }
            
            // Date validations if both dates are entered
            if (sdVal && edVal) {
                var todayDateStr = new Date().toISOString().split('T')[0];
                if (sdVal < todayDateStr) {
                    showError('startDate', 'Ngày bắt đầu không được ở quá khứ.');
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
                event.preventDefault(); // Prevent form submission
                
                // Scroll to the first error
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
