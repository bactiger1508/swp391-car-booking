<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết xe - Admin"/>
</jsp:include>

<c:if test="${not empty vehicle}">
    <!-- Breadcrumb & Header -->
    <div style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 24px;">
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/vehicles/manage">Quản lý xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">${vehicle.brand} ${vehicle.model}</span>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <h2 style="margin: 0; font-size: 28px; font-weight: 700; color: var(--primary);">${vehicle.brand} ${vehicle.model}</h2>
                <c:choose>
                    <c:when test="${vehicle.status == 'AVAILABLE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#E8F5E9] text-[#2E7D32]" style="font-size: 12px; font-weight: 700;">Có Sẵn</span></c:when>
                    <c:when test="${vehicle.status == 'MAINTENANCE'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFF3E0] text-[#EF6C00]" style="font-size: 12px; font-weight: 700;">Bảo Trì</span></c:when>
                    <c:when test="${vehicle.status == 'RENTED'}"><span class="inline-block px-2.5 py-1 rounded bg-[#FFEBEE] text-[#C62828]" style="font-size: 12px; font-weight: 700;">Đã Thuê</span></c:when>
                    <c:otherwise><span class="inline-block px-2.5 py-1 rounded bg-[#ECEFF1] text-[#37474F]" style="font-size: 12px; font-weight: 700;">Ngưng hoạt động</span></c:otherwise>
                </c:choose>
            </div>

            <div style="display: flex; gap: 12px;">
                <a href="${pageContext.request.contextPath}/vehicles/manage" class="bk-btn bk-btn-outline">
                    <span class="material-symbols-outlined">arrow_back</span>
                    Quay lại
                </a>
            </div>
        </div>
    </div>

    <!-- Gallery Section -->
    <div class="bento-grid">
        <div class="bento-card bento-col-8">
            <div style="position: relative; width: 100%; height: 380px; background: var(--surface-container-high);">
                <c:choose>
                    <c:when test="${not empty images}">
                        <img src="${pageContext.request.contextPath}${images[0].imageUrl}"
                             alt="${vehicle.brand} ${vehicle.model}"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg';"
                             style="width: 100%; height: 100%; object-fit: cover;">
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg"
                             alt="${vehicle.brand} ${vehicle.model}"
                             style="width: 100%; height: 100%; object-fit: cover;">
                    </c:otherwise>
                </c:choose>
                <div style="position: absolute; top: 16px; right: 16px; background: rgba(255,255,255,0.9); padding: 6px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; color: var(--primary); box-shadow: var(--shadow);">
                    Biển số: ${vehicle.licensePlate}
                </div>
            </div>
        </div>

        <!-- Vehicle Info & Status Management -->
        <div class="bento-card bento-col-4" style="background: var(--bg-white);">
            <div class="bento-card-body">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--primary); border-bottom: 1px solid var(--outline-variant); padding-bottom: 8px; margin-bottom: 16px;">Thông Tin Xe</h3>

                <div style="display: flex; flex-direction: column; gap: 12px; font-size: 14px; margin-bottom: 20px;">
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--on-surface-variant);">ID Xe</span>
                        <span style="font-weight: 600;">#${vehicle.vehicleId}</span>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--on-surface-variant);">Năm sản xuất</span>
                        <span style="font-weight: 600;">${vehicle.year}</span>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--on-surface-variant);">Giá thuê/ngày</span>
                        <span style="font-weight: 600;"><fmt:formatNumber value="${vehicle.dailyRate}" type="number" groupingUsed="true"/> VND</span>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span style="color: var(--on-surface-variant);">Trạng thái</span>
                        <span style="font-weight: 600; color: var(--primary);">
                            <c:choose>
                                <c:when test="${vehicle.status == 'AVAILABLE'}">Có Sẵn</c:when>
                                <c:when test="${vehicle.status == 'RENTED'}">Đã Thuê</c:when>
                                <c:when test="${vehicle.status == 'MAINTENANCE'}">Bảo Trì</c:when>
                                <c:when test="${vehicle.status == 'INACTIVE'}">Ngưng Hoạt Động</c:when>
                                <c:otherwise>${vehicle.status}</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <c:if test="${userRole == 'ADMIN'}">
                    <div style="border-top: 1px solid var(--outline-variant); padding-top: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 700; margin-bottom: 8px;">Cập nhật trạng thái:</label>
                        <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                            <button type="button" class="bk-btn bk-btn-sm bk-btn-outline" onclick="updateVehicleStatus('AVAILABLE')" style="font-size: 12px; padding: 6px 10px;">Có Sẵn</button>
                            <button type="button" class="bk-btn bk-btn-sm bk-btn-outline" onclick="updateVehicleStatus('RENTED')" style="font-size: 12px; padding: 6px 10px;">Đã Thuê</button>
                            <button type="button" class="bk-btn bk-btn-sm bk-btn-outline" onclick="updateVehicleStatus('MAINTENANCE')" style="font-size: 12px; padding: 6px 10px;">Bảo Trì</button>
                            <button type="button" class="bk-btn bk-btn-sm bk-btn-outline" onclick="updateVehicleStatus('INACTIVE')" style="font-size: 12px; padding: 6px 10px;">Ngưng</button>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Audit Logs Section (Change History) -->
    <div class="bento-card" style="margin-top: 24px; padding: 24px;">
        <h3 style="margin: 0 0 16px 0; font-size: 18px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">history</span> Lịch Sử Thay Đổi
        </h3>

        <c:choose>
            <c:when test="${empty auditLogs}">
                <div style="text-align: center; padding: 24px; background: var(--surface-container-low); border-radius: 8px; color: var(--on-surface-variant);">
                    Chưa có thay đổi nào được ghi nhận cho xe này.
                </div>
            </c:when>
            <c:otherwise>
                <div style="margin-bottom: 16px; position: relative; max-width: 320px;">
                    <span class="material-symbols-outlined" style="position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 18px; color: var(--on-surface-variant);">search</span>
                    <input type="text" id="auditSearchInput" placeholder="Tìm kiếm theo người thực hiện, hành động, chi tiết..." oninput="filterAuditTable()"
                           style="width: 100%; padding: 8px 12px 8px 36px; border-radius: 8px; border: 1px solid var(--outline-variant); font-size: 13px; box-sizing: border-box;">
                </div>
                <div style="overflow-x: auto;" id="auditTableContainer">
                    <table style="width: 100%; border-collapse: collapse; font-size: 14px;" id="auditTable">
                        <thead>
                            <tr style="background: var(--surface-container-low); border-bottom: 2px solid var(--outline-variant);">
                                <th style="text-align: left; padding: 12px; font-weight: 700; color: var(--primary);">Thời gian</th>
                                <th style="text-align: left; padding: 12px; font-weight: 700; color: var(--primary);">Người thực hiện</th>
                                <th style="text-align: left; padding: 12px; font-weight: 700; color: var(--primary);">Hành động</th>
                                <th style="text-align: left; padding: 12px; font-weight: 700; color: var(--primary);">Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${auditLogs}">
                                <tr style="border-bottom: 1px solid var(--outline-variant);"
                                    data-search="${fn:toLowerCase(not empty log.userName ? log.userName : '')} ${fn:toLowerCase(log.action)} ${fn:toLowerCase(not empty log.description ? log.description : '')}">
                                    <td style="padding: 12px;">
                                        <fmt:parseDate value="${log.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="logDate" type="both"/>
                                        <fmt:formatDate value="${logDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td style="padding: 12px; color: var(--on-surface-variant); font-weight: 600;">
                                        <c:choose>
                                            <c:when test="${not empty log.userName}">${log.userName}</c:when>
                                            <c:when test="${not empty log.userId}">Người dùng #${log.userId}</c:when>
                                            <c:otherwise>Hệ thống</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px;">
                                        <c:choose>
                                            <c:when test="${log.action == 'CREATE'}">
                                                <span style="background:#E8F5E9; color:#2E7D32; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Tạo Mới</span>
                                            </c:when>
                                            <c:when test="${log.action == 'UPDATE'}">
                                                <span style="background:#E3F2FD; color:#1565C0; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Cập Nhật</span>
                                            </c:when>
                                            <c:when test="${log.action == 'DELETE'}">
                                                <span style="background:#FFEBEE; color:#C62828; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Xóa</span>
                                            </c:when>
                                            <c:when test="${log.action == 'HIDE'}">
                                                <span style="background:#FFF3E0; color:#EF6C00; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Ẩn Xe</span>
                                            </c:when>
                                            <c:when test="${log.action == 'SHOW'}">
                                                <span style="background:#E8F5E9; color:#2E7D32; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Hiện Xe</span>
                                            </c:when>
                                            <c:when test="${log.action == 'SETPRIMARYIMAGE'}">
                                                <span style="background:#F3E5F5; color:#7B1FA2; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Đặt Ảnh Chính</span>
                                            </c:when>
                                            <c:when test="${log.action == 'UPDATESTATUS'}">
                                                <span style="background:#E3F2FD; color:#1565C0; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Cập Nhật Trạng Thái</span>
                                            </c:when>
                                            <c:when test="${log.action == 'HIDEREVIEW'}">
                                                <span style="background:#FFF3E0; color:#EF6C00; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Ẩn Đánh Giá</span>
                                            </c:when>
                                            <c:when test="${log.action == 'SHOWREVIEW'}">
                                                <span style="background:#E8F5E9; color:#2E7D32; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Hiện Đánh Giá</span>
                                            </c:when>
                                            <c:when test="${log.action == 'DELETEIMAGE'}">
                                                <span style="background:#FFEBEE; color:#C62828; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">Xóa Ảnh</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="background:#ECEFF1; color:#37474F; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; white-space:nowrap;">${log.action}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px; color: var(--on-surface-variant);">
                                        ${not empty log.description ? log.description : log.oldValue}
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div id="auditEmptyState" style="display:none; text-align:center; padding:24px; background:var(--surface-container-low); border-radius:8px; color:var(--on-surface-variant);">
                    Không tìm thấy kết quả phù hợp.
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-top:16px; padding-top:12px; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                    <div style="font-size:13px; color:var(--on-surface-variant);">
                        Hiển thị <span id="auditPagStart" style="font-weight:600;">0</span> đến <span id="auditPagEnd" style="font-weight:600;">0</span> trong số <span id="auditPagTotal" style="font-weight:600;">0</span> bản ghi
                    </div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <label style="font-size:13px; color:var(--on-surface-variant);">Số hàng:</label>
                        <select id="auditPageSizeSelect" onchange="changeAuditPageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                            <option value="5" selected="selected">5</option>
                            <option value="10">10</option>
                            <option value="20">20</option>
                            <option value="50">50</option>
                        </select>
                        <div id="auditPaginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;"></div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Maintenance Schedules Section -->
    <div class="bento-card" style="margin-top: 24px; padding: 24px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 16px;">
            <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 8px;">
                <span class="material-symbols-outlined">construction</span> Lịch Bảo Trì
            </h3>
            <a href="${pageContext.request.contextPath}/vehicles/maintenance?action=list&vehicleId=${vehicle.vehicleId}" class="bk-btn bk-btn-sm bk-btn-outline" style="font-size:12px;">
                Quản lý bảo trì
            </a>
        </div>

        <c:choose>
            <c:when test="${empty maintenances}">
                <div style="text-align: center; padding: 24px; background: var(--surface-container-low); border-radius: 8px; color: var(--on-surface-variant);">
                    Chưa có lịch bảo trì nào cho xe này.
                </div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 10px;">
                    <c:forEach var="maintenance" items="${maintenances}">
                        <c:set var="mColor" value="#1565C0"/>
                        <c:set var="mBg" value="#E3F2FD"/>
                        <c:set var="mIcon" value="event"/>
                        <c:if test="${maintenance.status == 'COMPLETED'}">
                            <c:set var="mColor" value="#2E7D32"/>
                            <c:set var="mBg" value="#E8F5E9"/>
                            <c:set var="mIcon" value="check_circle"/>
                        </c:if>
                        <c:if test="${maintenance.status == 'CANCELLED'}">
                            <c:set var="mColor" value="#C62828"/>
                            <c:set var="mBg" value="#FFEBEE"/>
                            <c:set var="mIcon" value="cancel"/>
                        </c:if>
                        <c:if test="${maintenance.status == 'IN_PROGRESS'}">
                            <c:set var="mColor" value="#EF6C00"/>
                            <c:set var="mBg" value="#FFF3E0"/>
                            <c:set var="mIcon" value="sync"/>
                        </c:if>
                        <div style="display:flex; align-items:center; gap:14px; padding: 12px 16px; background: var(--surface-container-low); border-radius: 10px; border-left: 4px solid ${mColor};">
                            <div style="width:38px; height:38px; border-radius:50%; background:${mBg}; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                <span class="material-symbols-outlined" style="color:${mColor}; font-size:20px;">${mIcon}</span>
                            </div>
                            <div style="flex:1; min-width:0;">
                                <div style="font-weight: 700; color: var(--on-surface); font-size:14px;">
                                    <c:choose>
                                        <c:when test="${maintenance.maintenanceType == 'OIL_CHANGE'}">Thay Dầu</c:when>
                                        <c:when test="${maintenance.maintenanceType == 'TIRE_CHANGE'}">Thay Lốp</c:when>
                                        <c:when test="${maintenance.maintenanceType == 'INSPECTION'}">Kiểm Tra Định Kỳ</c:when>
                                        <c:when test="${maintenance.maintenanceType == 'REPAIR'}">Sửa Chữa</c:when>
                                        <c:when test="${maintenance.maintenanceType == 'INSURANCE'}">Bảo Hiểm</c:when>
                                        <c:otherwise>${maintenance.maintenanceType}</c:otherwise>
                                    </c:choose>
                                </div>
                                <div style="font-size: 12px; color: var(--on-surface-variant); margin-top: 2px;">
                                    <span class="material-symbols-outlined" style="font-size:14px; vertical-align:middle;">calendar_today</span>
                                    <fmt:parseDate value="${maintenance.scheduledDate}" pattern="yyyy-MM-dd" var="mDate" type="date"/>
                                    <fmt:formatDate value="${mDate}" pattern="dd/MM/yyyy"/>
                                </div>
                            </div>
                            <span style="background: ${mBg}; color: ${mColor}; padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; white-space: nowrap; flex-shrink:0;">
                                <c:choose>
                                    <c:when test="${maintenance.status == 'SCHEDULED'}">Đã Lên Lịch</c:when>
                                    <c:when test="${maintenance.status == 'IN_PROGRESS'}">Đang Thực Hiện</c:when>
                                    <c:when test="${maintenance.status == 'COMPLETED'}">Hoàn Tất</c:when>
                                    <c:when test="${maintenance.status == 'CANCELLED'}">Đã Hủy</c:when>
                                    <c:otherwise>${maintenance.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Reviews Management Section -->
    <div class="bento-card" style="margin-top: 24px; padding: 24px; margin-bottom: 40px;">
        <h3 style="margin: 0 0 16px 0; font-size: 18px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">rate_review</span> Quản Lý Đánh Giá
        </h3>

        <div style="display: flex; gap: 20px; margin-bottom: 20px; padding: 16px; background: var(--surface-container-low); border-radius: 8px;">
            <div>
                <div style="font-size: 12px; color: var(--on-surface-variant); margin-bottom: 4px;">Trung bình đánh giá</div>
                <div style="font-size: 24px; font-weight: 700; color: var(--primary);">⭐ ${not empty avgRating ? avgRating : '0.0'}</div>
            </div>
            <div>
                <div style="font-size: 12px; color: var(--on-surface-variant); margin-bottom: 4px;">Tổng số đánh giá</div>
                <div style="font-size: 24px; font-weight: 700; color: var(--primary);">${reviewCount}</div>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty reviews}">
                <div style="text-align: center; padding: 24px; background: var(--surface-container-low); border-radius: 8px; color: var(--on-surface-variant);">
                    Chưa có đánh giá nào cho xe này.
                </div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <c:forEach var="review" items="${reviews}">
                        <div style="padding: 12px; background: var(--surface-container-low); border-radius: 8px; border: 1px solid var(--outline-variant);">
                            <div style="display: flex; justify-content: space-between; align-items: start;">
                                <div style="flex: 1;">
                                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
                                        <div style="font-weight: 700; color: var(--on-surface);">
                                            Khách hàng #${review.customerId}
                                        </div>
                                        <div style="color: #f59e0b; font-weight: 700;">
                                            <c:forEach var="i" begin="1" end="${review.rating}">★</c:forEach>
                                        </div>
                                    </div>
                                    <div style="font-size: 13px; color: var(--on-surface-variant); margin-bottom: 6px;">
                                        ${review.comment}
                                    </div>
                                    <div style="font-size: 12px; color: var(--on-surface-variant);">
                                        <fmt:parseDate value="${review.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="revDate" type="both"/>
                                        <fmt:formatDate value="${revDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>
                                <c:if test="${userRole == 'ADMIN'}">
                                    <div style="display: flex; gap: 6px;">
                                        <c:choose>
                                            <c:when test="${review.visible}">
                                                <button type="button" class="bk-btn bk-btn-sm bk-btn-outline"
                                                        onclick="hideReview(${review.reviewId})"
                                                        style="font-size: 11px; padding: 4px 8px; color: #EF6C00;">
                                                    Ẩn
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="bk-btn bk-btn-sm bk-btn-outline"
                                                        onclick="showReview(${review.reviewId})"
                                                        style="font-size: 11px; padding: 4px 8px; color: #2E7D32;">
                                                    Hiện
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</c:if>

<script>
    let auditCurrentPage = 1;
    let auditPageSize = 5;
    let auditFilteredRows = [];

    function filterAuditTable() {
        const keyword = document.getElementById('auditSearchInput').value.trim().toLowerCase();
        const allRows = Array.from(document.querySelectorAll('#auditTable tbody tr'));
        auditFilteredRows = allRows.filter(row => {
            const searchText = row.getAttribute('data-search') || '';
            return searchText.indexOf(keyword) !== -1;
        });
        auditCurrentPage = 1;
        applyAuditPagination();
    }

    function changeAuditPageSize() {
        auditPageSize = parseInt(document.getElementById('auditPageSizeSelect').value);
        auditCurrentPage = 1;
        applyAuditPagination();
    }

    function applyAuditPagination() {
        const allRows = Array.from(document.querySelectorAll('#auditTable tbody tr'));
        allRows.forEach(row => row.style.display = 'none');

        const totalItems = auditFilteredRows.length;
        const totalPages = Math.max(1, Math.ceil(totalItems / auditPageSize));
        if (auditCurrentPage > totalPages) auditCurrentPage = totalPages;

        const start = (auditCurrentPage - 1) * auditPageSize;
        const end = Math.min(start + auditPageSize, totalItems);
        const pageRows = auditFilteredRows.slice(start, end);
        pageRows.forEach(row => row.style.display = '');

        document.getElementById('auditPagStart').textContent = totalItems === 0 ? 0 : start + 1;
        document.getElementById('auditPagEnd').textContent = end;
        document.getElementById('auditPagTotal').textContent = totalItems;

        document.getElementById('auditTableContainer').style.display = totalItems === 0 ? 'none' : '';
        document.getElementById('auditEmptyState').style.display = totalItems === 0 ? '' : 'none';

        renderAuditPaginationButtons(totalPages);
    }

    function renderAuditPaginationButtons(totalPages) {
        const container = document.getElementById('auditPaginationButtons');
        container.innerHTML = '';

        const makeBtn = (label, page, disabled, active) => {
            const btn = document.createElement('button');
            btn.textContent = label;
            btn.disabled = disabled;
            btn.style.cssText = 'padding:4px 10px; border-radius:6px; border:1px solid var(--outline-variant); background:' + (active ? 'var(--primary)' : 'var(--surface)') + '; color:' + (active ? '#fff' : 'var(--on-surface)') + '; font-size:12px; cursor:' + (disabled ? 'not-allowed' : 'pointer') + '; opacity:' + (disabled ? '0.5' : '1') + ';';
            btn.onclick = () => { auditCurrentPage = page; applyAuditPagination(); };
            return btn;
        };

        container.appendChild(makeBtn('«', auditCurrentPage - 1, auditCurrentPage <= 1, false));
        for (let p = 1; p <= totalPages; p++) {
            container.appendChild(makeBtn(String(p), p, false, p === auditCurrentPage));
        }
        container.appendChild(makeBtn('»', auditCurrentPage + 1, auditCurrentPage >= totalPages, false));
    }

    document.addEventListener('DOMContentLoaded', function() {
        const auditTable = document.getElementById('auditTable');
        if (auditTable) {
            auditFilteredRows = Array.from(auditTable.querySelectorAll('tbody tr'));
            applyAuditPagination();
        }
    });

    function updateVehicleStatus(newStatus) {
        const vehicleId = ${vehicle.vehicleId};
        const params = new URLSearchParams();
        params.append('action', 'updateStatus');
        params.append('vehicleId', vehicleId);
        params.append('status', newStatus);

        fetch('${pageContext.request.contextPath}/vehicles/admin/detail', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('Cập nhật trạng thái thất bại: ' + (data.error || data.message));
            }
        })
        .catch(error => alert('Lỗi: ' + error));
    }

    function hideReview(reviewId) {
        if (confirm('Bạn chắc chắn muốn ẩn đánh giá này?')) {
            fetch('${pageContext.request.contextPath}/vehicles/admin/detail', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=hideReview&reviewId=' + reviewId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Lỗi: ' + (data.error || data.message));
                }
            });
        }
    }

    function showReview(reviewId) {
        if (confirm('Bạn chắc chắn muốn hiện đánh giá này?')) {
            fetch('${pageContext.request.contextPath}/vehicles/admin/detail', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=showReview&reviewId=' + reviewId
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                } else {
                    alert('Lỗi: ' + (data.error || data.message));
                }
            });
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
