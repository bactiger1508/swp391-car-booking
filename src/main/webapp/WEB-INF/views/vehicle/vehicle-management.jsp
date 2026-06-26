<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Quản Lý Xe"/>
</jsp:include>

<%-- Calculate dynamic stats --%>
<c:set var="totalCars" value="${cars.size()}"/>
<c:set var="availableCars" value="0"/>
<c:set var="maintenanceCars" value="0"/>
<c:set var="rentedCars" value="0"/>

<c:forEach var="car" items="${cars}">
    <c:choose>
        <c:when test="${car.status == 'AVAILABLE'}"><c:set var="availableCars" value="${availableCars + 1}"/></c:when>
        <c:when test="${car.status == 'MAINTENANCE'}"><c:set var="maintenanceCars" value="${maintenanceCars + 1}"/></c:when>
        <c:when test="${car.status == 'RENTED'}"><c:set var="rentedCars" value="${rentedCars + 1}"/></c:when>
    </c:choose>
</c:forEach>

<div class="bk-page-header">
    <div>
        <h2>Đội Xe</h2>
        <p>Quản lý và giám sát tất cả tài sản của đội xe.</p>
    </div>
    <div style="display: flex; gap: 8px;">
        <a href="${pageContext.request.contextPath}/vehicles/manage?status=MAINTENANCE" class="bk-btn bk-btn-outline">
            <span class="material-symbols-outlined" style="font-size: 18px;">build</span>
            Xe đang bảo trì
        </a>
        <button onclick="openCreateModal()" class="bk-btn bk-btn-primary">
            <span class="material-symbols-outlined" style="font-size: 18px;">add</span>
            Thêm xe mới
        </button>
    </div>
</div>

<c:if test="${not empty success}">
    <div style="background:#E8F5E9; border-left:4px solid #2E7D32; padding:12px; margin-bottom:20px; border-radius:4px; color:#1B5E20;">
        ✓ ${success}
    </div>
</c:if>
<c:if test="${not empty error}">
    <div style="background:#FFEBEE; border-left:4px solid #C62828; padding:12px; margin-bottom:20px; border-radius:4px; color:#B71C1C;">
        ✗ ${error}
    </div>
</c:if>

<%-- Stats/Summary Grid --%>
<div class="bk-stats-grid">
    <div id="card-stat-ALL" class="bk-stat-card" onclick="filterByStatus('ALL')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface);">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Tổng Số Xe</span>
        <span class="value" style="font-size:28px; font-weight:800; color:var(--primary);">${totalCars}</span>
    </div>
    <div id="card-stat-AVAILABLE" class="bk-stat-card" onclick="filterByStatus('AVAILABLE')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #2E7D32;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Có Sẵn</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#2E7D32;">${availableCars}</span>
    </div>
    <div id="card-stat-MAINTENANCE" class="bk-stat-card" onclick="filterByStatus('MAINTENANCE')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #F57C00;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đang Bảo Trì</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#F57C00;">${maintenanceCars}</span>
    </div>
    <div id="card-stat-RENTED" class="bk-stat-card" onclick="filterByStatus('RENTED')" style="cursor:pointer; transition: all 0.25s ease; border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 18px; background: var(--surface); border-left: 5px solid #C62828;">
        <span class="label" style="font-weight:600; color:var(--on-surface-variant);">Đã Thuê / Ra Ngoài</span>
        <span class="value" style="font-size:28px; font-weight:800; color:#C62828;">${rentedCars}</span>
    </div>
</div>

<%-- Data Table Card --%>
<div class="bk-table-container">
    <div class="bk-table-toolbar" style="display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; margin-bottom: 20px;">
        <div class="bk-table-search" style="flex: 1; min-width: 250px;">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="carSearchInput" placeholder="Tìm kiếm xe, biển số..." oninput="filterCarTable()">
        </div>
        <div style="display:flex; gap:6px; flex-wrap:wrap; background: var(--surface-variant); padding: 4px; border-radius: 8px; border: 1px solid var(--outline-variant);">
            <button onclick="filterByStatus('ALL')" id="btn-filter-ALL" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Tất cả
            </button>
            <button onclick="filterByStatus('AVAILABLE')" id="btn-filter-AVAILABLE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Có sẵn
            </button>
            <button onclick="filterByStatus('RENTED')" id="btn-filter-RENTED" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Đã thuê
            </button>
            <button onclick="filterByStatus('MAINTENANCE')" id="btn-filter-MAINTENANCE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Bảo trì
            </button>
            <button onclick="filterByStatus('INACTIVE')" id="btn-filter-INACTIVE" class="bk-btn bk-btn-sm filter-btn" style="font-size:12px; padding:6px 12px; border-radius: 6px; border: none; font-weight:600; cursor:pointer;">
                Ngưng hoạt động
            </button>
        </div>
    </div>

    <c:if test="${not empty cars}">
        <div style="overflow-x:auto;" id="vehicleTableContainer">
            <table class="bk-table" id="vehicleTable">
                <thead>
                    <tr>
                        <th style="width:100px;">Ảnh</th>
                        <th>Tên Xe</th>
                        <th>Biển Số</th>
                        <th>Giá hàng ngày</th>
                        <th>Tiền cọc (1 ngày)</th>
                        <th style="text-align: center;">Số ghế</th>
                        <th>Trạng Thái</th>
                        <th>Bảo Trì Tiếp Theo</th>
                        <th style="text-align: right;">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="car" items="${cars}">
                        <c:set var="maintenance" value="${nextMaintenance[car.carId]}"/>
                        <c:set var="carImage" value="${primaryImages[car.carId]}"/>
                        <tr data-status="${car.status}">
                            <td style="padding: 8px;">
                                <c:choose>
                                    <c:when test="${not empty carImage}">
                                        <img src="${pageContext.request.contextPath}${carImage}" alt="${car.brand} ${car.model}" style="width: 100%; height: 80px; object-fit: cover; border-radius: 4px; cursor: pointer;" onclick="window.open(this.src)" title="Nhấn để xem ảnh lớn">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width: 100%; height: 80px; background: #f0f0f0; border-radius: 4px; display: flex; align-items: center; justify-content: center; color: #999; font-size: 12px;">
                                            <span class="material-symbols-outlined" style="font-size: 24px;">image_not_supported</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="font-semibold" style="color: var(--primary);">${car.brand} ${car.model} (${car.year})</td>
                            <td class="font-mono" style="font-weight: 600;">${car.licensePlate}</td>
                            <td class="font-semibold"><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/> VND</td>
                            <td>
                                <fmt:formatNumber value="${depositAmounts[car.carId]}" type="number" groupingUsed="true"/> VND
                                <span style="font-size:11px;color:var(--text-secondary);">(${depositPercentage}%)</span>
                            </td>
                            <td style="text-align: center; font-weight: 600;">${car.seats}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${car.status == 'AVAILABLE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#E8F5E9] text-[#2E7D32]" style="font-size:12px; font-weight:700;">Có Sẵn</span></c:when>
                                    <c:when test="${car.status == 'MAINTENANCE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFF3E0] text-[#EF6C00]" style="font-size:12px; font-weight:700;">Bảo Trì</span></c:when>
                                    <c:when test="${car.status == 'RENTED'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFEBEE] text-[#C62828]" style="font-size:12px; font-weight:700;">Đã Thuê</span></c:when>
                                    <c:otherwise><span class="inline-block px-2.5 py-1 rounded bg-[#ECEFF1] text-[#37474F]" style="font-size:12px; font-weight:700;">Ngưng hoạt động</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty maintenance}">
                                        <span style="font-weight: 600; color: var(--primary);">${maintenance.maintenanceType}</span><br/>
                                        <span style="font-size:12px; color:var(--text-secondary);">
                                            ${maintenance.scheduledDate} &middot; ${maintenance.status}
                                        </span>
                                    </c:when>
                                    <c:when test="${car.status == 'MAINTENANCE'}">
                                        <span style="color:#EF6C00; font-weight: 600;">Đang bảo trì</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--text-secondary);">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 4px; justify-content: flex-end;">
                                    <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="text-primary hover:text-primary-container p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Xem chi tiết" style="display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">visibility</span>
                                    </a>
                                    <button onclick="openEditModal(${car.carId}, '${car.brand}', '${car.model}', ${car.year}, '${car.color}', ${car.seats}, '${car.transmission}', '${car.fuelType}', ${car.dailyRate}, '${car.description}', '${car.location}', '${car.features}', '${car.status}', ${car.mileage}, '${car.licensePlate}')" class="text-[#1976D2] hover:text-[#1565C0] p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Sửa" style="border:none; background:none; cursor:pointer; display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">edit</span>
                                    </button>
                                    <button onclick="if(confirm('Bạn chắc chắn muốn xóa xe này?')) { deleteVehicle(${car.carId}); }" class="text-[#D32F2F] hover:text-[#B71C1C] p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Xóa" style="border:none; background:none; cursor:pointer; display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">delete</span>
                                    </button>
                                    <a href="${pageContext.request.contextPath}/maintenance?carId=${car.carId}" class="text-[#F57C00] hover:text-[#E65100] p-1.5 rounded hover:bg-surface-container-low transition-colors" title="Lịch bảo trì" style="display:inline-flex; align-items:center;">
                                        <span class="material-symbols-outlined" style="font-size: 20px;">build</span>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <!-- Phân trang -->
        <div class="bk-pagination-container" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
            <div style="font-size:13px; color:var(--on-surface-variant);">
                Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> bản ghi
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <label style="font-size:13px; color:var(--on-surface-variant);">Số hàng:</label>
                <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                    <option value="5">5</option>
                    <option value="10" selected="selected">10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                </select>
                <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;">
                    <!-- nút chuyển trang -->
                </div>
            </div>
        </div>
    </c:if>

    <div class="bk-empty" id="emptyStateMessage" style="display:none; padding: 40px 20px; text-align: center;">
        <span class="material-symbols-outlined" style="font-size: 48px; color: var(--on-surface-variant); margin-bottom: 12px;">directions_car</span>
        <h3 style="font-size: 18px; font-weight:700; color: var(--on-surface);">Không tìm thấy xe phù hợp</h3>
        <p style="color: var(--on-surface-variant); margin-top: 4px; font-size: 13px;">Không có xe nào khớp với trạng thái hoặc từ khóa tìm kiếm được chọn.</p>
    </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';
let currentStatusFilter = 'ALL';
let currentPage = 1;
let pageSize = 10;
let filteredRows = [];

function changePageSize() {
    pageSize = parseInt(document.getElementById('pageSizeSelect').value);
    currentPage = 1;
    applyPagination();
}

function filterByStatus(status) {
    currentStatusFilter = status;
    
    // Update active class on segmented buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.style.background = 'transparent';
        btn.style.color = 'var(--on-surface-variant)';
        btn.style.boxShadow = 'none';
    });
    
    const activeBtn = document.getElementById('btn-filter-' + status);
    if (activeBtn) {
        activeBtn.style.background = 'var(--primary)';
        activeBtn.style.color = 'var(--on-primary)';
        activeBtn.style.boxShadow = '0 2px 8px rgba(10, 25, 47, 0.15)';
    }
    
    // Highlight selected Stat Card
    document.querySelectorAll('.bk-stat-card').forEach(card => {
        card.style.borderColor = 'var(--outline-variant)';
        card.style.boxShadow = 'none';
        card.style.background = 'var(--surface)';
    });
    
    const activeCard = document.getElementById('card-stat-' + status);
    if (activeCard) {
        activeCard.style.borderColor = 'var(--primary)';
        activeCard.style.boxShadow = '0 6px 20px rgba(10, 25, 47, 0.08)';
        activeCard.style.background = 'var(--surface-variant)';
    }
    
    filterCarTable();
}

function filterCarTable() {
    const input = document.getElementById('carSearchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#vehicleTable tbody tr');
    filteredRows = [];
    
    rows.forEach(row => {
        const rowStatus = row.getAttribute('data-status');
        const text = row.textContent.toLowerCase();
        
        const matchesStatus = (currentStatusFilter === 'ALL' || rowStatus === currentStatusFilter);
        const matchesSearch = text.includes(input);
        
        if (matchesStatus && matchesSearch) {
            filteredRows.push(row);
        } else {
            row.style.display = 'none';
        }
    });
    
    currentPage = 1;
    applyPagination();
}

function applyPagination() {
    const totalRows = filteredRows.length;
    const totalPages = Math.ceil(totalRows / pageSize) || 1;
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    const allRows = document.querySelectorAll('#vehicleTable tbody tr');
    allRows.forEach(row => row.style.display = 'none');
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalRows);
    
    for (let i = startIdx; i < endIdx; i++) {
        filteredRows[i].style.display = '';
    }
    
    const startDisplay = document.getElementById('pag-start');
    const endDisplay = document.getElementById('pag-end');
    const totalDisplay = document.getElementById('pag-total');
    if (startDisplay) startDisplay.innerText = totalRows > 0 ? (startIdx + 1) : 0;
    if (endDisplay) endDisplay.innerText = endIdx;
    if (totalDisplay) totalDisplay.innerText = totalRows;
    
    const tableContainer = document.getElementById('vehicleTableContainer');
    const emptyState = document.getElementById('emptyStateMessage');
    
    if (totalRows === 0) {
        if (tableContainer) tableContainer.style.display = 'none';
        if (emptyState) emptyState.style.display = 'block';
    } else {
        if (tableContainer) tableContainer.style.display = 'block';
        if (emptyState) emptyState.style.display = 'none';
    }
    
    const btnContainer = document.getElementById('paginationButtons');
    if (btnContainer) {
        btnContainer.innerHTML = '';
        
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
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
            if (p < 1) continue;
            const pBtn = document.createElement('button');
            pBtn.type = 'button';
            pBtn.className = p === currentPage ? 'bk-btn bk-btn-sm bk-btn-primary' : 'bk-btn bk-btn-sm bk-btn-outline';
            pBtn.style.padding = '4px 10px';
            pBtn.style.border = '1px solid ' + (p === currentPage ? 'var(--primary)' : 'var(--outline-variant)');
            pBtn.style.borderRadius = '6px';
            pBtn.style.cursor = 'pointer';
            if (p === currentPage) {
                pBtn.style.background = 'var(--primary)';
                pBtn.style.color = 'var(--on-primary)';
            }
            pBtn.innerText = p;
            pBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
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

// Check on load
window.addEventListener('DOMContentLoaded', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const statusParam = urlParams.get('status');
    if (statusParam && ['AVAILABLE','RENTED','MAINTENANCE','INACTIVE'].includes(statusParam)) {
        filterByStatus(statusParam);
    } else {
        filterByStatus('ALL');
    }
});

// === MODALS ===
function openCreateModal() {
    document.getElementById('createForm').reset();
    document.getElementById('createPrimaryImagePreview').innerHTML = '';
    document.getElementById('createSecondaryImagePreview').innerHTML = '';
    document.getElementById('createModal').style.display = 'block';
}

function closeCreateModal() {
    document.getElementById('createModal').style.display = 'none';
}

function openEditModal(carId, brand, model, year, color, seats, transmission, fuelType, dailyRate, description, location, features, status, mileage, licensePlate) {
    document.getElementById('editCarId').value = carId;
    document.getElementById('editLicensePlate').value = licensePlate;
    document.getElementById('editBrand').value = brand;
    document.getElementById('editModel').value = model;
    document.getElementById('editYear').value = year;
    document.getElementById('editColor').value = color;
    document.getElementById('editSeats').value = seats;
    document.getElementById('editTransmission').value = transmission;
    document.getElementById('editFuelType').value = fuelType;
    document.getElementById('editDailyRate').value = dailyRate;
    document.getElementById('editDescription').value = description;
    document.getElementById('editLocation').value = location;
    document.getElementById('editFeatures').value = features;
    document.getElementById('editStatus').value = status;
    document.getElementById('editMileage').value = mileage;

    // Clear preview from previous edits
    document.getElementById('editPrimaryImagePreview').innerHTML = '';
    document.getElementById('editSecondaryImagePreview').innerHTML = '';
    document.getElementById('editPrimaryImageInput').value = '';
    document.getElementById('editSecondaryImageInput').value = '';

    // Fetch current images
    fetchCarImages(carId);

    document.getElementById('editModal').style.display = 'block';
}

function previewImages(event, previewContainerId) {
    const files = event.target.files;
    const preview = document.getElementById(previewContainerId);
    preview.innerHTML = '';

    for (let file of files) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const wrapper = document.createElement('div');
            wrapper.style.cssText = 'position:relative; background-color:#f0f0f0; padding:4px; border-radius:4px;';

            const imgEl = document.createElement('img');
            imgEl.src = e.target.result;
            imgEl.style.cssText = 'width:100%; height:80px; object-fit:cover; border-radius:4px;';

            const caption = document.createElement('span');
            caption.style.cssText = 'font-size:11px; color:#666; display:block; margin-top:2px; text-align:center; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;';
            caption.textContent = file.name;

            wrapper.appendChild(imgEl);
            wrapper.appendChild(caption);
            preview.appendChild(wrapper);
        };
        reader.readAsDataURL(file);
    }
}

function buildImageCard(img, carId) {
    const card = document.createElement('div');
    card.style.cssText = 'position:relative; background:#F5F5F5; border-radius:4px; overflow:hidden; border:2px solid ' + (img.isPrimary ? '#FFC107' : '#E0E0E0') + ';';

    if (img.isPrimary) {
        const badge = document.createElement('div');
        badge.style.cssText = 'position:absolute; top:4px; right:4px; background:#FFC107; color:#333; padding:2px 6px; border-radius:3px; font-size:10px; font-weight:bold;';
        badge.textContent = '★ Chính';
        card.appendChild(badge);
    }

    const imgEl = document.createElement('img');
    imgEl.src = contextPath + img.imageUrl;
    imgEl.style.cssText = 'width:100%; height:100px; object-fit:cover;';
    card.appendChild(imgEl);

    const actions = document.createElement('div');
    actions.style.cssText = 'padding:6px; background:#fff; display:flex; gap:4px; justify-content:space-between;';

    const deleteBtn = document.createElement('button');
    deleteBtn.type = 'button';
    deleteBtn.className = 'bk-btn bk-btn-sm';
    deleteBtn.style.cssText = 'flex:1; font-size:11px; padding:4px;';
    deleteBtn.textContent = '🗑 Xóa';
    deleteBtn.onclick = function() { deleteCarImage(img.imageId, carId); };
    actions.appendChild(deleteBtn);

    if (img.isPrimary) {
        const lockedBtn = document.createElement('button');
        lockedBtn.type = 'button';
        lockedBtn.disabled = true;
        lockedBtn.style.cssText = 'flex:1; font-size:11px; padding:4px; opacity:0.5; cursor:default;';
        lockedBtn.textContent = '✓ Chính';
        actions.appendChild(lockedBtn);
    } else {
        const makePrimaryBtn = document.createElement('button');
        makePrimaryBtn.type = 'button';
        makePrimaryBtn.className = 'bk-btn bk-btn-sm';
        makePrimaryBtn.style.cssText = 'flex:1; font-size:11px; padding:4px;';
        makePrimaryBtn.textContent = '⭐ Làm Chính';
        makePrimaryBtn.onclick = function() { setPrimaryCarImage(img.imageId, carId); };
        actions.appendChild(makePrimaryBtn);
    }

    card.appendChild(actions);
    return card;
}

function fetchCarImages(carId) {
    const primaryContainer = document.getElementById('currentPrimaryImage');
    const secondaryContainer = document.getElementById('currentSecondaryImages');
    primaryContainer.innerHTML = '<div style="grid-column:1/-1; text-align:center; color:#999; font-size:12px;">Đang tải ảnh...</div>';
    secondaryContainer.innerHTML = '';

    fetch(contextPath + '/vehicles/manage?action=getCarImages&carId=' + carId)
        .then(response => response.json())
        .then(images => {
            primaryContainer.innerHTML = '';
            secondaryContainer.innerHTML = '';

            const primaryImages = images.filter(img => img.isPrimary);
            const secondaryImages = images.filter(img => !img.isPrimary);

            if (primaryImages.length === 0) {
                primaryContainer.innerHTML = '<div style="grid-column:1/-1; padding:12px; background:#F5F5F5; border-radius:4px; font-size:12px; color:#999;">Chưa có ảnh chính</div>';
            } else {
                primaryImages.forEach(img => primaryContainer.appendChild(buildImageCard(img, carId)));
            }

            if (secondaryImages.length === 0) {
                secondaryContainer.innerHTML = '<div style="grid-column:1/-1; padding:12px; background:#F5F5F5; border-radius:4px; font-size:12px; color:#999;">Chưa có ảnh phụ</div>';
            } else {
                secondaryImages.forEach(img => secondaryContainer.appendChild(buildImageCard(img, carId)));
            }
        })
        .catch(error => {
            console.error('Error fetching images:', error);
            primaryContainer.innerHTML = '<div style="grid-column:1/-1; color:red; font-size:12px;">Lỗi tải ảnh</div>';
        });
}

function deleteCarImage(imageId, carId) {
    if (!confirm('Bạn chắc chắn muốn xóa ảnh này?')) return;

    fetch(contextPath + '/vehicles/manage?action=deleteImage&imageId=' + imageId, {method: 'POST'})
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                fetchCarImages(carId);
            } else {
                alert('Xóa ảnh thất bại');
            }
        })
        .catch(error => console.error('Error deleting image:', error));
}

function setPrimaryCarImage(imageId, carId) {
    fetch(contextPath + '/vehicles/manage?action=setPrimaryImage&imageId=' + imageId + '&carId=' + carId, {method: 'POST'})
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                fetchCarImages(carId);
            } else {
                alert('Cập nhật ảnh chính thất bại');
            }
        })
        .catch(error => console.error('Error setting primary image:', error));
}

function closeEditModal() {
    document.getElementById('editModal').style.display = 'none';
}

function deleteVehicle(carId) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/vehicles/manage';
    form.innerHTML = '<input type="hidden" name="action" value="delete"><input type="hidden" name="carId" value="' + carId + '">';
    document.body.appendChild(form);
    form.submit();
}

// Close modal when clicking outside
window.onclick = function(event) {
    let createModal = document.getElementById('createModal');
    let editModal = document.getElementById('editModal');
    if (event.target == createModal) {
        createModal.style.display = 'none';
    }
    if (event.target == editModal) {
        editModal.style.display = 'none';
    }
};

// AJAX form submission for create and edit vehicle
document.addEventListener('DOMContentLoaded', function() {
    const createForm = document.getElementById('createForm');
    if (createForm) {
        createForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const formData = new FormData(this);
            formData.append('action', 'create');

    try {
        const response = await fetch('${pageContext.request.contextPath}/vehicles/manage', {
            method: 'POST',
            body: formData
        });

        const text = await response.text();
        let result;
        try {
            result = JSON.parse(text);
        } catch {
            // If not JSON, it's a redirect (success) - reload the page
            location.reload();
            return;
        }

        if (result.success) {
            showSuccessAlert(result.message || 'Tạo xe thành công!');
            setTimeout(() => {
                closeCreateModal();
                location.reload();
            }, 1500);
        } else {
            showErrorAlert(result.error || 'Có lỗi xảy ra');
        }
        } catch (err) {
            showErrorAlert('Lỗi kết nối: ' + err.message);
        }
        });
    }

    const editForm = document.getElementById('editForm');
    if (editForm) {
        editForm.addEventListener('submit', async function(e) {
            e.preventDefault();

            const formData = new FormData(this);
            formData.append('action', 'update');

            try {
                const response = await fetch('${pageContext.request.contextPath}/vehicles/manage', {
                    method: 'POST',
                    body: formData
                });

                const text = await response.text();
                let result;
                try {
                    result = JSON.parse(text);
                } catch {
                    // If not JSON, it's a redirect (success) - reload the page
                    location.reload();
                    return;
                }

                if (result.success) {
                    showSuccessAlert(result.message || 'Cập nhật xe thành công!');
                    setTimeout(() => {
                        closeEditModal();
                        location.reload();
                    }, 1500);
                } else {
                    showErrorAlert(result.error || 'Có lỗi xảy ra');
                }
            } catch (err) {
                showErrorAlert('Lỗi kết nối: ' + err.message);
            }
        });
    }
});

function showErrorAlert(message) {
    const alertDiv = document.createElement('div');
    alertDiv.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #f44336;
        color: white;
        padding: 16px 24px;
        border-radius: 4px;
        z-index: 2000;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    `;
    alertDiv.textContent = message;
    document.body.appendChild(alertDiv);
    setTimeout(() => alertDiv.remove(), 4000);
}

function showSuccessAlert(message) {
    const alertDiv = document.createElement('div');
    alertDiv.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #4caf50;
        color: white;
        padding: 16px 24px;
        border-radius: 4px;
        z-index: 2000;
        box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    `;
    alertDiv.textContent = message;
    document.body.appendChild(alertDiv);
}
</script>

<!-- CREATE VEHICLE MODAL -->
<div id="createModal" class="bk-modal" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background-color:rgba(0,0,0,0.4); overflow-y:auto;">
    <div class="bk-modal-content" style="background-color:#fefefe; margin:2% auto; padding:20px; border:1px solid #888; width:90%; max-width:700px; border-radius:8px; max-height:90vh; overflow-y:auto;">
        <span class="bk-close" onclick="closeCreateModal()" style="color:#aaa; float:right; font-size:28px; font-weight:bold; cursor:pointer; position:sticky; top:0;">&times;</span>
        <h2 style="margin-top:0; color:var(--primary);">Thêm Xe Mới</h2>
        <form id="createForm" method="POST" action="${pageContext.request.contextPath}/vehicles/manage" enctype="multipart/form-data">
            <input type="hidden" name="action" value="create">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px;">
                <div class="bk-form-group">
                    <label class="bk-form-label">Biển Số *</label>
                    <input type="text" name="licensePlate" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Hãng Xe *</label>
                    <input type="text" name="brand" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Model *</label>
                    <input type="text" name="model" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Năm SX *</label>
                    <input type="number" name="year" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Màu Sắc</label>
                    <input type="text" name="color" class="bk-form-input">
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Số Ghế *</label>
                    <input type="number" name="seats" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Hộp Số *</label>
                    <select name="transmission" class="bk-form-select" required>
                        <option value="AUTOMATIC">Tự Động</option>
                        <option value="MANUAL">Số Sàn</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Loại Nhiên Liệu *</label>
                    <select name="fuelType" class="bk-form-select" required>
                        <option value="GASOLINE">Xăng</option>
                        <option value="DIESEL">Dầu Diesel</option>
                        <option value="ELECTRIC">Điện</option>
                        <option value="HYBRID">Hybrid</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Giá Thuê (VND/ngày) *</label>
                    <input type="number" name="dailyRate" class="bk-form-input" min="1" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Trạng Thái *</label>
                    <select name="status" class="bk-form-select" required>
                        <option value="AVAILABLE">Có Sẵn</option>
                        <option value="MAINTENANCE">Bảo Trì</option>
                        <option value="INACTIVE">Ngưng Hoạt Động</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Địa Điểm</label>
                    <input type="text" name="location" class="bk-form-input">
                </div>
            </div>
            <div class="bk-form-group">
                <label class="bk-form-label">Mô Tả</label>
                <textarea name="description" class="bk-form-input" rows="3"></textarea>
            </div>
            <div class="bk-form-group">
                <label class="bk-form-label">Tính Năng (cách nhau bằng dấu phẩy)</label>
                <input type="text" name="features" class="bk-form-input" placeholder="GPS, Bluetooth, Dashcam...">
            </div>

            <div style="border-top: 1px solid #ddd; padding-top: 16px; margin-top: 16px;">
                <label class="bk-form-label" style="font-weight:600; margin-bottom:8px; display:block;">Ảnh Xe</label>

                <div class="bk-form-group">
                    <label class="bk-form-label" style="font-size:12px; color:#F57C00;">★ Ảnh chính (hiển thị ở danh sách) *</label>
                    <label style="display:block; padding:16px; border:2px dashed #FFC107; border-radius:8px; text-align:center; cursor:pointer; background:#FFFDE7; transition: all 0.2s;">
                        <input type="file" id="createPrimaryImageInput" name="primaryImage" accept="image/*" required style="display:none;" onchange="previewImages(event, 'createPrimaryImagePreview')">
                        <span class="material-symbols-outlined" style="font-size:28px; color:#F57C00;">star</span>
                        <div style="font-weight:600; color:#F57C00; margin-top:4px; font-size:13px;">Chọn ảnh chính</div>
                        <div style="font-size:11px; color:#666; margin-top:2px;">JPG, PNG (tối đa 10MB)</div>
                    </label>
                    <div id="createPrimaryImagePreview" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(80px, 1fr)); gap:8px; margin-top:8px;"></div>
                </div>

                <div class="bk-form-group" style="margin-top:12px;">
                    <label class="bk-form-label" style="font-size:12px;">Ảnh phụ (có thể chọn nhiều)</label>
                    <label style="display:block; padding:16px; border:2px dashed #ccc; border-radius:8px; text-align:center; cursor:pointer; transition: all 0.2s;">
                        <input type="file" id="createSecondaryImageInput" name="secondaryImages" multiple accept="image/*" style="display:none;" onchange="previewImages(event, 'createSecondaryImagePreview')">
                        <span class="material-symbols-outlined" style="font-size:28px; color:#1976D2;">add_photo_alternate</span>
                        <div style="font-weight:600; color:#1976D2; margin-top:4px; font-size:13px;">Chọn ảnh phụ</div>
                        <div style="font-size:11px; color:#666; margin-top:2px;">JPG, PNG (tối đa 10MB/ảnh)</div>
                    </label>
                    <div id="createSecondaryImagePreview" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(80px, 1fr)); gap:8px; margin-top:8px;"></div>
                </div>
            </div>

            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
                <button type="button" onclick="closeCreateModal()" class="bk-btn bk-btn-outline">Hủy</button>
                <button type="submit" class="bk-btn bk-btn-primary">Tạo Xe</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT VEHICLE MODAL -->
<div id="editModal" class="bk-modal" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background-color:rgba(0,0,0,0.4); overflow-y:auto;">
    <div class="bk-modal-content" style="background-color:#fefefe; margin:2% auto; padding:20px; border:1px solid #888; width:90%; max-width:700px; border-radius:8px; max-height:90vh; overflow-y:auto;">
        <span class="bk-close" onclick="closeEditModal()" style="color:#aaa; float:right; font-size:28px; font-weight:bold; cursor:pointer; position:sticky; top:0;">&times;</span>
        <h2 style="margin-top:0; color:var(--primary);">Sửa Thông Tin Xe</h2>
        <form id="editForm" method="POST" action="${pageContext.request.contextPath}/vehicles/manage" enctype="multipart/form-data">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="carId" id="editCarId">
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px;">
                <div class="bk-form-group">
                    <label class="bk-form-label">Biển Số *</label>
                    <input type="text" id="editLicensePlate" name="licensePlate" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Hãng Xe *</label>
                    <input type="text" id="editBrand" name="brand" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Model *</label>
                    <input type="text" id="editModel" name="model" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Năm SX *</label>
                    <input type="number" id="editYear" name="year" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Màu Sắc</label>
                    <input type="text" id="editColor" name="color" class="bk-form-input">
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Số Ghế *</label>
                    <input type="number" id="editSeats" name="seats" class="bk-form-input" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Hộp Số *</label>
                    <select id="editTransmission" name="transmission" class="bk-form-select" required>
                        <option value="AUTOMATIC">Tự Động</option>
                        <option value="MANUAL">Số Sàn</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Loại Nhiên Liệu *</label>
                    <select id="editFuelType" name="fuelType" class="bk-form-select" required>
                        <option value="GASOLINE">Xăng</option>
                        <option value="DIESEL">Dầu Diesel</option>
                        <option value="ELECTRIC">Điện</option>
                        <option value="HYBRID">Hybrid</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Giá Thuê (VND/ngày) *</label>
                    <input type="number" id="editDailyRate" name="dailyRate" class="bk-form-input" min="1" required>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Trạng Thái *</label>
                    <select id="editStatus" name="status" class="bk-form-select" required>
                        <option value="AVAILABLE">Có Sẵn</option>
                        <option value="RENTED">Đã Thuê</option>
                        <option value="MAINTENANCE">Bảo Trì</option>
                        <option value="INACTIVE">Ngưng Hoạt Động</option>
                    </select>
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Số KM Hiện Tại</label>
                    <input type="number" id="editMileage" name="mileage" class="bk-form-input">
                </div>
                <div class="bk-form-group">
                    <label class="bk-form-label">Địa Điểm</label>
                    <input type="text" id="editLocation" name="location" class="bk-form-input">
                </div>
            </div>
            <div class="bk-form-group">
                <label class="bk-form-label">Mô Tả</label>
                <textarea id="editDescription" name="description" class="bk-form-input" rows="3"></textarea>
            </div>
            <div class="bk-form-group">
                <label class="bk-form-label">Tính Năng (cách nhau bằng dấu phẩy)</label>
                <input type="text" id="editFeatures" name="features" class="bk-form-input" placeholder="GPS, Bluetooth, Dashcam...">
            </div>

            <div style="border-top: 1px solid #ddd; padding-top: 16px; margin-top: 16px;">
                <h3 style="font-size:14px; font-weight:600; margin-bottom:12px;">Quản Lý Ảnh Xe</h3>

                <!-- Ảnh chính hiện tại -->
                <p style="font-size:12px; color:#F57C00; font-weight:600; margin-bottom:4px;">★ Ảnh chính hiện tại</p>
                <div id="currentPrimaryImage" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(100px, 1fr)); gap:12px; margin-bottom:16px;">
                    <!-- Will be populated by JavaScript after fetching -->
                </div>

                <!-- Ảnh phụ hiện tại -->
                <p style="font-size:12px; color:#666; font-weight:600; margin-bottom:4px;">Ảnh phụ hiện tại</p>
                <div id="currentSecondaryImages" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(100px, 1fr)); gap:12px; margin-bottom:16px;">
                    <!-- Will be populated by JavaScript after fetching -->
                </div>

                <!-- Đổi ảnh chính -->
                <div class="bk-form-group" style="margin-top:8px;">
                    <label class="bk-form-label" style="font-size:12px; color:#F57C00;">Đổi ảnh chính (tùy chọn)</label>
                    <label style="display:block; padding:16px; border:2px dashed #FFC107; border-radius:8px; text-align:center; cursor:pointer; background:#FFFDE7; transition: all 0.2s;">
                        <input type="file" id="editPrimaryImageInput" name="newPrimaryImage" accept="image/*" style="display:none;" onchange="previewImages(event, 'editPrimaryImagePreview')">
                        <span class="material-symbols-outlined" style="font-size:28px; color:#F57C00;">star</span>
                        <div style="font-weight:600; color:#F57C00; margin-top:4px; font-size:13px;">Chọn ảnh chính mới</div>
                        <div style="font-size:11px; color:#666; margin-top:2px;">Ảnh chính cũ sẽ chuyển thành ảnh phụ</div>
                    </label>
                    <div id="editPrimaryImagePreview" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(80px, 1fr)); gap:8px; margin-top:8px;"></div>
                </div>

                <!-- Thêm ảnh phụ -->
                <div class="bk-form-group" style="margin-top:12px;">
                    <label class="bk-form-label" style="font-size:12px;">Thêm ảnh phụ</label>
                    <label style="display:block; padding:16px; border:2px dashed #ccc; border-radius:8px; text-align:center; cursor:pointer; transition: all 0.2s;">
                        <input type="file" id="editSecondaryImageInput" name="newSecondaryImages" multiple accept="image/*" style="display:none;" onchange="previewImages(event, 'editSecondaryImagePreview')">
                        <span class="material-symbols-outlined" style="font-size:28px; color:#1976D2;">add_photo_alternate</span>
                        <div style="font-weight:600; color:#1976D2; margin-top:4px; font-size:13px;">Chọn ảnh phụ mới</div>
                        <div style="font-size:11px; color:#666; margin-top:2px;">JPG, PNG (tối đa 10MB/ảnh)</div>
                    </label>
                    <div id="editSecondaryImagePreview" style="display:grid; grid-template-columns:repeat(auto-fill, minmax(80px, 1fr)); gap:8px; margin-top:8px;"></div>
                </div>
            </div>

            <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:20px;">
                <button type="button" onclick="closeEditModal()" class="bk-btn bk-btn-outline">Hủy</button>
                <button type="submit" class="bk-btn bk-btn-primary">Lưu Thay Đổi</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
