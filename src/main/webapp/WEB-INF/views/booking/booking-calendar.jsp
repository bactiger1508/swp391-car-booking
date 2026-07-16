<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Lịch Đặt Xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Lịch Đặt Xe</h2>
        <p>Quản lý và theo dõi lịch thuê xe theo dạng timeline.</p>
    </div>
</div>

<%-- Error Message Banner --%>
<c:if test="${not empty errorMessage}">
    <div style="background: var(--error-container, #fde8e8); color: var(--on-error-container, #c62828); padding: 16px 20px; border-radius: 12px; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; font-weight: 500;">
        <span class="material-symbols-outlined">error</span>
        ${errorMessage}
    </div>
</c:if>

<%-- Stats Cards --%>
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 24px;">
    <c:set var="pendingCount" value="0"/>
    <c:set var="confirmedCount" value="0"/>
    <c:set var="progressCount" value="0"/>
    <c:set var="totalCount" value="0"/>
    <c:forEach var="b" items="${bookings}">
        <c:set var="totalCount" value="${totalCount + 1}"/>
        <c:if test="${b.status == 'PENDING'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:if>
        <c:if test="${b.status == 'CONFIRMED'}"><c:set var="confirmedCount" value="${confirmedCount + 1}"/></c:if>
        <c:if test="${b.status == 'IN_PROGRESS'}"><c:set var="progressCount" value="${progressCount + 1}"/></c:if>
    </c:forEach>

    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: var(--primary); font-size: 28px;">event_note</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Tổng đơn tháng</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: var(--on-surface);">${totalCount}</div>
    </div>
    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: #b45309; font-size: 28px;">hourglass_top</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Chờ duyệt</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: #b45309;">${pendingCount}</div>
    </div>
    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 28px;">check_circle</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Đã xác nhận</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: var(--secondary);">${confirmedCount}</div>
    </div>
    <div style="background: var(--surface-container-lowest); border: 1px solid var(--outline-variant); border-radius: 16px; padding: 20px;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="material-symbols-outlined" style="color: #059669; font-size: 28px;">directions_car</span>
            <span style="font-size: 13px; color: var(--on-surface-variant); font-weight: 500;">Đang thuê</span>
        </div>
        <div style="font-size: 28px; font-weight: 700; color: #059669;">${progressCount}</div>
    </div>
</div>

<%-- Month Navigation & Filters --%>
<div class="bk-table-container" style="padding: 0;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid var(--outline-variant); flex-wrap: wrap; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <button id="prevMonth" onclick="navigateMonth(-1)" style="background: var(--surface-container-high); border: 1px solid var(--outline-variant); border-radius: 10px; padding: 8px 12px; cursor: pointer; color: var(--on-surface); display: flex; align-items: center;">
                <span class="material-symbols-outlined" style="font-size: 20px;">chevron_left</span>
            </button>
            <h3 id="monthLabel" style="font-size: 18px; font-weight: 700; color: var(--on-surface); min-width: 200px; text-align: center;">
                Tháng ${calMonth} / ${calYear}
            </h3>
            <button id="nextMonth" onclick="navigateMonth(1)" style="background: var(--surface-container-high); border: 1px solid var(--outline-variant); border-radius: 10px; padding: 8px 12px; cursor: pointer; color: var(--on-surface); display: flex; align-items: center;">
                <span class="material-symbols-outlined" style="font-size: 20px;">chevron_right</span>
            </button>
            <button onclick="goToToday()" style="background: var(--primary); color: var(--on-primary); border: none; border-radius: 10px; padding: 8px 16px; cursor: pointer; font-weight: 600; font-size: 13px;">
                Hôm nay
            </button>
        </div>
        <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
            <select id="statusFilter" onchange="applyFilter()" style="padding: 8px 12px; border-radius: 8px; border: 1px solid var(--outline-variant); background: var(--surface-container-lowest); color: var(--on-surface); font-size: 13px; cursor: pointer;">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING">Chờ duyệt</option>
                <option value="CONFIRMED">Đã xác nhận</option>
                <option value="IN_PROGRESS">Đang thuê</option>
                <option value="COMPLETED">Hoàn tất</option>
            </select>
            <div style="position: relative;">
                <span class="material-symbols-outlined" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 18px; color: var(--on-surface-variant);">search</span>
                <input type="text" id="searchInput" placeholder="Tìm xe..." oninput="applyFilter()" style="padding: 8px 12px 8px 34px; border-radius: 8px; border: 1px solid var(--outline-variant); background: var(--surface-container-lowest); color: var(--on-surface); font-size: 13px; width: 160px;">
            </div>
        </div>
    </div>

    <%-- Legend --%>
    <div style="display: flex; gap: 16px; padding: 12px 20px; border-bottom: 1px solid var(--outline-variant); flex-wrap: wrap;">
        <div style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--on-surface-variant);">
            <span style="width: 14px; height: 14px; border-radius: 4px; background: linear-gradient(135deg, #f59e0b, #d97706);"></span> Chờ duyệt
        </div>
        <div style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--on-surface-variant);">
            <span style="width: 14px; height: 14px; border-radius: 4px; background: linear-gradient(135deg, #3b82f6, #2563eb);"></span> Đã xác nhận
        </div>
        <div style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--on-surface-variant);">
            <span style="width: 14px; height: 14px; border-radius: 4px; background: linear-gradient(135deg, #10b981, #059669);"></span> Đang thuê
        </div>
        <div style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--on-surface-variant);">
            <span style="width: 14px; height: 14px; border-radius: 4px; background: linear-gradient(135deg, #6b7280, #4b5563);"></span> Hoàn tất
        </div>
        <div style="display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--on-surface-variant);">
            <span style="width: 2px; height: 14px; background: #ef4444;"></span> Hôm nay
        </div>
    </div>

    <%-- Gantt Timeline Container --%>
    <div id="ganttContainer" style="overflow-x: auto; position: relative;">
        <div id="ganttTimeline" style="min-width: 100%;"></div>
    </div>

    <%-- Empty State --%>
    <div id="emptyState" style="display: none; text-align: center; padding: 60px 20px;">
        <span class="material-symbols-outlined" style="font-size: 64px; color: var(--on-surface-variant); opacity: 0.4;">event_busy</span>
        <h3 style="margin: 16px 0 8px; color: var(--on-surface);">Không có lịch đặt xe</h3>
        <p style="color: var(--on-surface-variant);">Không tìm thấy booking nào trong tháng này.</p>
    </div>
</div>

<%-- Tooltip --%>
<div id="bookingTooltip" style="display: none; position: fixed; z-index: 9999; background: var(--surface-container-highest, #2a2a2a); border: 1px solid var(--outline-variant); border-radius: 12px; padding: 16px; min-width: 260px; max-width: 340px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); pointer-events: none;">
</div>

<%-- Inline CSS for Gantt --%>
<style>
.gantt-grid {
    display: grid;
    border-collapse: collapse;
}
.gantt-header-cell {
    padding: 8px 0;
    text-align: center;
    font-size: 11px;
    font-weight: 600;
    color: var(--on-surface-variant);
    border-right: 1px solid var(--outline-variant);
    border-bottom: 2px solid var(--outline-variant);
    position: sticky;
    top: 0;
    background: var(--surface-container-low, #1e1e1e);
    z-index: 2;
}
.gantt-header-cell.today {
    background: rgba(239, 68, 68, 0.15);
    color: #ef4444;
    font-weight: 700;
}
.gantt-header-cell.weekend {
    color: var(--outline);
}
.gantt-car-label {
    padding: 10px 12px;
    font-size: 13px;
    font-weight: 600;
    color: var(--on-surface);
    border-right: 2px solid var(--outline-variant);
    border-bottom: 1px solid var(--outline-variant);
    background: var(--surface-container-low, #1e1e1e);
    position: sticky;
    left: 0;
    z-index: 3;
    display: flex;
    flex-direction: column;
    justify-content: center;
    min-height: 48px;
    white-space: nowrap;
}
.gantt-car-label .sub {
    font-size: 11px;
    font-weight: 400;
    color: var(--on-surface-variant);
    margin-top: 2px;
}
.gantt-cell {
    border-right: 1px solid var(--outline-variant);
    border-bottom: 1px solid var(--outline-variant);
    position: relative;
    min-height: 48px;
}
.gantt-cell.today-col {
    background: rgba(239, 68, 68, 0.06);
}
.gantt-cell.weekend-col {
    background: rgba(255, 255, 255, 0.015);
}
.gantt-bar {
    position: absolute;
    top: 8px;
    height: calc(100% - 16px);
    min-height: 32px;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    align-items: center;
    padding: 0 8px;
    font-size: 11px;
    font-weight: 600;
    color: #fff;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    z-index: 1;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
    text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.gantt-bar:hover {
    transform: scaleY(1.15);
    box-shadow: 0 4px 16px rgba(0,0,0,0.4);
    z-index: 5;
}
.gantt-bar.PENDING { background: linear-gradient(135deg, #f59e0b, #d97706); }
.gantt-bar.CONFIRMED { background: linear-gradient(135deg, #3b82f6, #2563eb); }
.gantt-bar.IN_PROGRESS { background: linear-gradient(135deg, #10b981, #059669); }
.gantt-bar.COMPLETED { background: linear-gradient(135deg, #6b7280, #4b5563); }
.gantt-today-line {
    position: absolute;
    top: 0;
    bottom: 0;
    width: 2px;
    background: #ef4444;
    z-index: 4;
    pointer-events: none;
}
.gantt-loading {
    text-align: center;
    padding: 40px;
    color: var(--on-surface-variant);
}
</style>

<script>
// ===== Calendar State =====
var calState = {
    month: ${calMonth},
    year: ${calYear},
    daysInMonth: ${daysInMonth},
    cars: [],
    bookings: [],
    userMap: {}
};

// Initialize from server-side data
(function() {
    // Build cars array from server data
    <c:forEach var="car" items="${cars}">
    calState.cars.push({
        carId: ${car.carId},
        brand: "${car.brand}",
        model: "${car.model}",
        licensePlate: "${car.licensePlate}",
        status: "${car.status}"
    });
    </c:forEach>

    // Build bookings array from server data
    <c:forEach var="b" items="${bookings}">
    calState.bookings.push({
        bookingId: ${b.bookingId},
        carId: ${b.carId},
        customerId: ${b.customerId},
        status: "${b.status}",
        startDate: "${b.startDate}",
        endDate: "${b.endDate}",
        totalAmount: <c:choose><c:when test="${b.totalAmount != null}">${b.totalAmount}</c:when><c:otherwise>null</c:otherwise></c:choose>
    });
    </c:forEach>

    // Build user map
    <c:forEach var="entry" items="${userMap}">
    calState.userMap[${entry.key}] = {
        fullName: "${entry.value.fullName}",
        email: "${entry.value.email}"
    };
    </c:forEach>

    renderGantt();
})();

// ===== Render the Gantt timeline =====
function renderGantt() {
    var container = document.getElementById('ganttTimeline');
    var emptyState = document.getElementById('emptyState');
    var statusFilter = document.getElementById('statusFilter').value;
    var searchInput = document.getElementById('searchInput').value.toLowerCase();

    // Filter cars that have bookings (matching filters)
    var filteredBookings = calState.bookings.filter(function(b) {
        if (statusFilter && b.status !== statusFilter) return false;
        return true;
    });

    // Filter cars by search
    var filteredCars = calState.cars.filter(function(car) {
        if (searchInput) {
            var label = (car.brand + ' ' + car.model + ' ' + car.licensePlate).toLowerCase();
            if (label.indexOf(searchInput) === -1) return false;
        }
        // Only show cars that have at least one booking this month (after status filter)
        var hasBooking = filteredBookings.some(function(b) { return b.carId === car.carId; });
        // If no filters, show all cars with bookings; if search matches, show even if no bookings
        return hasBooking || searchInput;
    });

    // If search is active, keep cars matching search even without bookings
    if (!searchInput && filteredCars.length === 0 && filteredBookings.length === 0) {
        container.innerHTML = '';
        emptyState.style.display = 'block';
        return;
    }

    // If cars are empty but we have search, show nothing
    if (filteredCars.length === 0) {
        container.innerHTML = '';
        emptyState.style.display = 'block';
        return;
    }

    emptyState.style.display = 'none';

    var days = calState.daysInMonth;
    var today = new Date();
    var todayDay = (today.getFullYear() === calState.year && (today.getMonth() + 1) === calState.month) ? today.getDate() : -1;
    var cellWidth = 44; // px per day column
    var labelWidth = 180; // px for car label column

    var gridCols = labelWidth + 'px ' + ('repeat(' + days + ', ' + cellWidth + 'px)');
    var html = '<div class="gantt-grid" style="grid-template-columns: ' + gridCols + '; width: ' + (labelWidth + days * cellWidth) + 'px;">';

    // Header row
    html += '<div class="gantt-header-cell" style="position: sticky; left: 0; z-index: 5; background: var(--surface-container-low, #1e1e1e); border-right: 2px solid var(--outline-variant);">Xe</div>';
    for (var d = 1; d <= days; d++) {
        var dateObj = new Date(calState.year, calState.month - 1, d);
        var dayOfWeek = dateObj.getDay(); // 0=Sun, 6=Sat
        var isToday = (d === todayDay);
        var isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
        var cls = 'gantt-header-cell';
        if (isToday) cls += ' today';
        else if (isWeekend) cls += ' weekend';
        html += '<div class="' + cls + '">' + d + '</div>';
    }

    // Car rows with booking bars
    filteredCars.forEach(function(car) {
        // Car label
        html += '<div class="gantt-car-label">';
        html += '<div>' + car.brand + ' ' + car.model + '</div>';
        html += '<div class="sub">' + car.licensePlate + '</div>';
        html += '</div>';

        // Day cells (relative container for bars)
        html += '<div style="grid-column: 2 / -1; position: relative; min-height: 48px; display: grid; grid-template-columns: repeat(' + days + ', ' + cellWidth + 'px); border-bottom: 1px solid var(--outline-variant);">';

        // Background day cells
        for (var d = 1; d <= days; d++) {
            var dateObj = new Date(calState.year, calState.month - 1, d);
            var dayOfWeek = dateObj.getDay();
            var isToday = (d === todayDay);
            var isWeekend = (dayOfWeek === 0 || dayOfWeek === 6);
            var cls = 'gantt-cell';
            if (isToday) cls += ' today-col';
            else if (isWeekend) cls += ' weekend-col';
            html += '<div class="' + cls + '"></div>';
        }

        // Booking bars for this car
        var carBookings = filteredBookings.filter(function(b) { return b.carId === car.carId; });
        carBookings.forEach(function(b) {
            var start = parseDate(b.startDate);
            var end = parseDate(b.endDate);
            var monthStart = new Date(calState.year, calState.month - 1, 1);
            var monthEnd = new Date(calState.year, calState.month - 1, days, 23, 59, 59);

            // Clamp to month boundaries
            var barStart = Math.max(start.getTime(), monthStart.getTime());
            var barEnd = Math.min(end.getTime(), monthEnd.getTime());

            // Calculate position in fractional days (1-indexed)
            var startFrac = (barStart - monthStart.getTime()) / (1000 * 60 * 60 * 24);
            var endFrac = (barEnd - monthStart.getTime()) / (1000 * 60 * 60 * 24);
            var leftPx = startFrac * cellWidth;
            var widthPx = Math.max((endFrac - startFrac) * cellWidth, 16); // min 16px

            // Status label
            var statusLabels = {PENDING: 'Chờ duyệt', CONFIRMED: 'Xác nhận', IN_PROGRESS: 'Đang thuê', COMPLETED: 'Hoàn tất'};

            html += '<div class="gantt-bar ' + b.status + '" ';
            html += 'style="left:' + leftPx + 'px; width:' + widthPx + 'px;" ';
            html += 'data-booking-id="' + b.bookingId + '" ';
            html += 'data-car-brand="' + car.brand + '" data-car-model="' + car.model + '" data-car-plate="' + car.licensePlate + '" ';
            html += 'data-status="' + b.status + '" data-status-label="' + (statusLabels[b.status] || b.status) + '" ';
            html += 'data-start="' + formatDateVN(start) + '" data-end="' + formatDateVN(end) + '" ';
            html += 'data-customer="' + (calState.userMap[b.customerId] ? calState.userMap[b.customerId].fullName : 'KH #' + b.customerId) + '" ';
            html += 'data-amount="' + (b.totalAmount != null ? formatMoney(b.totalAmount) : '—') + '" ';
            html += 'onmouseenter="showTooltip(event, this)" onmouseleave="hideTooltip()" ';
            html += 'onclick="window.location.href=\'' + contextPath + '/bookings/detail?id=' + b.bookingId + '\'">';
            html += 'BK-' + b.bookingId;
            html += '</div>';
        });

        // Today line
        if (todayDay > 0) {
            var todayX = (todayDay - 1) * cellWidth + (cellWidth / 2);
            html += '<div class="gantt-today-line" style="left:' + todayX + 'px;"></div>';
        }

        html += '</div>'; // end day cells container
    });

    html += '</div>'; // end gantt-grid
    container.innerHTML = html;

    // Auto-scroll to today
    if (todayDay > 0) {
        var scrollTarget = (todayDay - 1) * cellWidth - 200;
        if (scrollTarget > 0) {
            document.getElementById('ganttContainer').scrollLeft = scrollTarget;
        }
    }
}

// ===== Helper functions =====
var contextPath = '${pageContext.request.contextPath}';

function parseDate(str) {
    if (!str) return new Date();
    // Handle "2026-07-10T08:00" format
    var parts = str.split('T');
    var dateParts = parts[0].split('-');
    var timeParts = parts[1] ? parts[1].split(':') : [0, 0];
    return new Date(parseInt(dateParts[0]), parseInt(dateParts[1]) - 1, parseInt(dateParts[2]),
                    parseInt(timeParts[0]), parseInt(timeParts[1]));
}

function formatDateVN(d) {
    var dd = String(d.getDate()).padStart(2, '0');
    var mm = String(d.getMonth() + 1).padStart(2, '0');
    var hh = String(d.getHours()).padStart(2, '0');
    var mi = String(d.getMinutes()).padStart(2, '0');
    return dd + '/' + mm + '/' + d.getFullYear() + ' ' + hh + ':' + mi;
}

function formatMoney(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' ₫';
}

// ===== Tooltip =====
function showTooltip(event, el) {
    var tooltip = document.getElementById('bookingTooltip');
    var statusColors = {PENDING: '#f59e0b', CONFIRMED: '#3b82f6', IN_PROGRESS: '#10b981', COMPLETED: '#6b7280'};
    var color = statusColors[el.dataset.status] || '#666';

    tooltip.innerHTML =
        '<div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;">' +
            '<span style="width:10px;height:10px;border-radius:50%;background:' + color + ';"></span>' +
            '<strong style="font-size:15px;color:var(--on-surface);">BK-' + el.dataset.bookingId + '</strong>' +
            '<span style="font-size:12px;padding:2px 8px;border-radius:6px;background:' + color + '20;color:' + color + ';font-weight:600;">' + el.dataset.statusLabel + '</span>' +
        '</div>' +
        '<div style="display:grid;grid-template-columns:auto 1fr;gap:6px 12px;font-size:13px;">' +
            '<span style="color:var(--on-surface-variant);">Xe:</span>' +
            '<span style="color:var(--on-surface);font-weight:500;">' + el.dataset.carBrand + ' ' + el.dataset.carModel + ' (' + el.dataset.carPlate + ')</span>' +
            '<span style="color:var(--on-surface-variant);">Khách:</span>' +
            '<span style="color:var(--on-surface);font-weight:500;">' + el.dataset.customer + '</span>' +
            '<span style="color:var(--on-surface-variant);">Nhận xe:</span>' +
            '<span style="color:var(--on-surface);font-weight:500;">' + el.dataset.start + '</span>' +
            '<span style="color:var(--on-surface-variant);">Trả xe:</span>' +
            '<span style="color:var(--on-surface);font-weight:500;">' + el.dataset.end + '</span>' +
            '<span style="color:var(--on-surface-variant);">Tổng tiền:</span>' +
            '<span style="color:var(--primary);font-weight:700;">' + el.dataset.amount + '</span>' +
        '</div>' +
        '<div style="margin-top:10px;font-size:11px;color:var(--on-surface-variant);text-align:center;">Click để xem chi tiết →</div>';

    tooltip.style.display = 'block';

    // Position near cursor
    var x = event.clientX + 16;
    var y = event.clientY + 16;
    if (x + 340 > window.innerWidth) x = event.clientX - 350;
    if (y + 200 > window.innerHeight) y = event.clientY - 210;
    tooltip.style.left = x + 'px';
    tooltip.style.top = y + 'px';
}

function hideTooltip() {
    document.getElementById('bookingTooltip').style.display = 'none';
}

// ===== Month Navigation =====
function navigateMonth(delta) {
    var newMonth = calState.month + delta;
    var newYear = calState.year;
    if (newMonth < 1) { newMonth = 12; newYear--; }
    if (newMonth > 12) { newMonth = 1; newYear++; }
    loadMonth(newMonth, newYear);
}

function goToToday() {
    var now = new Date();
    loadMonth(now.getMonth() + 1, now.getFullYear());
}

function loadMonth(month, year) {
    var container = document.getElementById('ganttTimeline');
    container.innerHTML = '<div class="gantt-loading"><span class="material-symbols-outlined" style="font-size: 32px; animation: spin 1s linear infinite;">progress_activity</span><p>Đang tải...</p></div>';
    document.getElementById('emptyState').style.display = 'none';

    var url = contextPath + '/bookings/calendar?ajax=true&month=' + month + '&year=' + year;
    fetch(url)
        .then(function(resp) { return resp.json(); })
        .then(function(data) {
            if (data.error) {
                container.innerHTML = '<div class="gantt-loading" style="color:#c62828;"><span class="material-symbols-outlined">error</span><p>' + data.error + '</p></div>';
                return;
            }
            calState.month = data.month;
            calState.year = data.year;
            calState.daysInMonth = data.daysInMonth;
            calState.cars = data.cars || [];
            calState.bookings = data.bookings || [];
            // Note: userMap stays from initial load for now
            document.getElementById('monthLabel').textContent = 'Tháng ' + calState.month + ' / ' + calState.year;
            renderGantt();
        })
        .catch(function(err) {
            container.innerHTML = '<div class="gantt-loading" style="color:#c62828;"><span class="material-symbols-outlined">error</span><p>Lỗi kết nối: ' + err.message + '</p></div>';
        });
}

// ===== Filter =====
function applyFilter() {
    renderGantt();
}
</script>

<style>
@keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
