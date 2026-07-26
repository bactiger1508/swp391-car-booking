<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết xe"/>
</jsp:include>

<c:if test="${not empty car}">
    <c:if test="${not empty sessionScope.successMessage}">
        <div class="bk-alert bk-alert-success" style="margin-bottom: 16px; background: #e8f5e9; color: #2e7d32; padding: 12px 16px; border-radius: 8px; font-weight: 600; display: flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">check_circle</span> ${sessionScope.successMessage}
        </div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="bk-alert bk-alert-error" style="margin-bottom: 16px; background: #ffebee; color: #c62828; padding: 12px 16px; border-radius: 8px; font-weight: 600; display: flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">error</span> ${sessionScope.errorMessage}
        </div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>
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
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg';"
                             style="width: 100%; height: 100%; object-fit: cover;">
                    </c:when>
                    <c:otherwise>
                        <img src="${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg"
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
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg';"
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
                            <a href="${pageContext.request.contextPath}/bookings/create?vehicleId=${car.vehicleId}" class="bk-btn bk-btn-primary" style="text-align: center; justify-content: center; height: 48px; width: 100%;">
                                Đặt xe ngay
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="bk-btn bk-btn-outline" style="height: 48px; width: 100%; cursor: not-allowed; opacity: 0.6;" disabled>
                                Xe hiện tại không sẵn sàng
                            </button>
                        </c:otherwise>
                    </c:choose>
                    <button type="button" class="bk-btn bk-btn-outline" style="text-align: center; justify-content: center; height: 48px; width: 100%;" onclick="openCalendarModal()">
                        <span class="material-symbols-outlined">calendar_month</span> Xem lịch bận của xe
                    </button>
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
                    <c:choose>
                        <c:when test="${car.transmission == 'AUTOMATIC'}">Tự Động</c:when>
                        <c:when test="${car.transmission == 'MANUAL'}">Số Sàn</c:when>
                        <c:otherwise>${car.transmission}</c:otherwise>
                    </c:choose>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: var(--secondary); font-size: 20px;">local_gas_station</span>
                    <c:choose>
                        <c:when test="${car.fuelType == 'GASOLINE'}">Xăng</c:when>
                        <c:when test="${car.fuelType == 'DIESEL'}">Dầu Diesel</c:when>
                        <c:when test="${car.fuelType == 'ELECTRIC'}">Điện</c:when>
                        <c:when test="${car.fuelType == 'HYBRID'}">Hybrid</c:when>
                        <c:otherwise>${car.fuelType}</c:otherwise>
                    </c:choose>
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
                <span style="font-size: 13px; color: var(--on-surface);">Tất cả hệ thống vận hành hoàn hảo, xe được vệ sinh sạch sẽ trước mỗi chuyến đi.</span>
            </div>
        </div>
    </div>

    <!-- Review & Rating Section -->
    <div class="bento-card" style="margin-top: 24px; padding: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--outline-variant); padding-bottom: 16px; margin-bottom: 20px;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--primary); display: flex; align-items: center; gap: 8px;">
                    <span class="material-symbols-outlined" style="color: #f59e0b;">star</span> Đánh Giá Từ Khách Hàng
                </h3>
                <span class="bk-badge bk-badge-info" style="font-size: 13px; font-weight: 600;">
                    ⭐ ${not empty avgRating ? avgRating : '0.0'} / 5.0 (${reviewCount} lượt đánh giá)
                </span>
            </div>
            <c:choose>
                <c:when test="${!isLoggedIn}">
                    <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/vehicles/detail?id=${car.vehicleId}" class="bk-btn bk-btn-primary" style="font-size: 13px; padding: 8px 16px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                        <span class="material-symbols-outlined" style="font-size: 18px;">rate_review</span> Viết Đánh Giá
                    </a>
                </c:when>
                <c:when test="${canReview}">
                    <button type="button" class="bk-btn bk-btn-primary" style="font-size: 13px; padding: 8px 16px;" onclick="document.getElementById('reviewFormContainer').style.display='block'">
                        <span class="material-symbols-outlined" style="font-size: 18px;">rate_review</span> Viết Đánh Giá
                    </button>
                </c:when>
                <c:otherwise>
                    <button type="button" class="bk-btn bk-btn-outline" style="font-size: 13px; padding: 8px 16px; opacity: 0.8;" onclick="showAppModalAlert('Chưa Thể Đánh Giá', 'Bạn cần hoàn tất ít nhất 1 chuyến thuê xe này trước khi gửi đánh giá!', 'warning')">
                        <span class="material-symbols-outlined" style="font-size: 18px;">rate_review</span> Viết Đánh Giá
                    </button>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Add Review Form Modal / Box -->
        <c:if test="${canReview}">
            <div id="reviewFormContainer" style="display: none; background: var(--surface-container-low); border: 1px solid var(--primary-container); border-radius: 12px; padding: 20px; margin-bottom: 24px;">
                <h4 style="margin-top: 0; font-size: 15px; color: var(--primary); display: flex; align-items: center; gap: 6px;">
                    <span class="material-symbols-outlined">edit_note</span> Gửi đánh giá trải nghiệm thuê xe của bạn
                </h4>
                <form action="${pageContext.request.contextPath}/vehicles/detail" method="post">
                    <input type="hidden" name="action" value="addReview" />
                    <input type="hidden" name="vehicleId" value="${car.vehicleId}" />
                    <input type="hidden" name="bookingId" value="${reviewBookingId}" />
                    
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px;">Đánh giá số sao:</label>
                        <div style="display: flex; gap: 12px; align-items: center;">
                            <c:forEach var="i" begin="1" end="5">
                                <label style="display: flex; align-items: center; gap: 4px; cursor: pointer; font-size: 14px; font-weight: 600; color: #f59e0b;">
                                    <input type="radio" name="rating" value="${6 - i}" ${i == 1 ? 'checked' : ''} /> ${6 - i} ★
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px;">Nội dung nhận xét:</label>
                        <textarea name="comment" rows="3" class="bk-form-control" placeholder="Chia sẻ trải nghiệm sử dụng xe, thái độ phục vụ..." required style="width: 100%; border-radius: 8px; padding: 10px; border: 1px solid var(--outline-variant);"></textarea>
                    </div>

                    <div style="display: flex; gap: 10px;">
                        <button type="submit" class="bk-btn bk-btn-primary" style="font-size: 13px; padding: 8px 20px;">Gửi Đánh Giá</button>
                        <button type="button" class="bk-btn bk-btn-outline" style="font-size: 13px; padding: 8px 16px;" onclick="document.getElementById('reviewFormContainer').style.display='none'">Hủy</button>
                    </div>
                </form>
            </div>
        </c:if>

        <!-- Reviews List -->
        <c:choose>
            <c:when test="${empty reviews}">
                <div style="text-align: center; padding: 32px; background: var(--surface-container-low); border-radius: 12px; color: var(--on-surface-variant);">
                    <span class="material-symbols-outlined" style="font-size: 48px; color: var(--outline); display: block; margin-bottom: 8px;">chat_bubble_outline</span>
                    <p style="margin: 0; font-size: 14px;">Chưa có đánh giá nào cho xe này. Hãy là người đầu tiên trải nghiệm và để lại nhận xét!</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 16px;">
                    <c:forEach var="rev" items="${reviews}">
                        <div style="padding: 16px; background: var(--surface-container-low); border-radius: 12px; border: 1px solid var(--outline-variant);">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--primary); color: white; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;">
                                        ${not empty rev.customerName ? rev.customerName.substring(0, 1) : 'U'}
                                    </div>
                                    <div>
                                        <div style="font-weight: 700; font-size: 14px; color: var(--on-surface);">
                                            ${not empty rev.customerName ? rev.customerName : 'Khách hàng'}
                                        </div>
                                        <div style="font-size: 12px; color: var(--on-surface-variant);">
                                            <fmt:parseDate value="${rev.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="pRevDate" type="both"/>
                                            <fmt:formatDate value="${pRevDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </div>
                                    </div>
                                </div>
                                <div style="color: #f59e0b; font-size: 14px; font-weight: 700; letter-spacing: 2px;">
                                    <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                    <c:forEach begin="${rev.rating + 1}" end="5"><span style="color: #cbd5e1;">★</span></c:forEach>
                                </div>
                            </div>
                            <p style="margin: 0; font-size: 14px; color: var(--on-surface); line-height: 1.5; padding-left: 46px;">
                                ${rev.comment}
                            </p>
                        </div>
                    </c:forEach>
                </div>

                <!-- Pagination UI for Reviews -->
                <c:if test="${totalReviewPages > 1}">
                    <div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 24px;">
                        <c:if test="${currentReviewPage > 1}">
                            <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.vehicleId}&reviewPage=${currentReviewPage - 1}" class="bk-btn bk-btn-outline" style="padding: 6px 12px; font-size: 13px; text-decoration: none;">
                                &laquo; Trang trước
                            </a>
                        </c:if>
                        <c:forEach var="p" begin="1" end="${totalReviewPages}">
                            <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.vehicleId}&reviewPage=${p}" class="bk-btn ${p == currentReviewPage ? 'bk-btn-primary' : 'bk-btn-outline'}" style="padding: 6px 12px; font-size: 13px; text-decoration: none; font-weight: 600;">
                                ${p}
                            </a>
                        </c:forEach>
                        <c:if test="${currentReviewPage < totalReviewPages}">
                            <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.vehicleId}&reviewPage=${currentReviewPage + 1}" class="bk-btn bk-btn-outline" style="padding: 6px 12px; font-size: 13px; text-decoration: none;">
                                Trang sau &raquo;
                            </a>
                        </c:if>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Active Bookings/Schedule Calendar Modal -->
    <div id="calendarModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; backdrop-filter:blur(4px); align-items:center; justify-content:center;">
        <div class="bk-card" style="width:90%; max-width:600px; padding:24px; max-height:85vh; overflow-y:auto; position:relative;">
            <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid var(--outline-variant); padding-bottom:12px; margin-bottom:16px;">
                <h3 style="margin:0; font-size:18px; color:var(--primary); display:flex; align-items:center; gap:8px;">
                    <span class="material-symbols-outlined">calendar_today</span> Lịch bận của xe
                </h3>
                <button type="button" class="bk-btn bk-btn-outline" style="padding:4px; border:none; background:none;" onclick="closeCalendarModal()">
                    <span class="material-symbols-outlined" style="font-size:24px; color:var(--outline);">close</span>
                </button>
            </div>
            
            <div style="font-size:14px; color:var(--on-surface-variant); margin-bottom:20px;">
                Dưới đây là các khoảng thời gian xe <strong>${car.brand} ${car.model} (${car.licensePlate})</strong> bận do có khách đặt hoặc đang bảo trì:
            </div>

            <!-- Section: Rental Bookings -->
            <div style="margin-bottom:20px;">
                <h4 style="margin:0 0 8px 0; font-size:14px; font-weight:700; color:var(--primary); text-transform:uppercase; letter-spacing:0.05em; display:flex; align-items:center; gap:6px;">
                    <span class="material-symbols-outlined" style="font-size:18px;">key</span> Lịch thuê xe
                </h4>
                <c:choose>
                    <c:when test="${empty activeBookings}">
                        <div style="padding:12px; background:var(--surface-container-low); border-radius:8px; font-size:13px; color:var(--success); font-weight:500;">
                            Không có lịch đặt thuê nào hiện tại.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <c:forEach var="bk" items="${activeBookings}">
                                <div style="display:flex; align-items:center; justify-content:space-between; padding:12px 16px; background:var(--surface-container-low); border-radius:8px; border-left:4px solid var(--error);">
                                    <div>
                                        <div style="font-size:13px; color:var(--on-surface);">
                                            Từ: <fmt:parseDate value="${bk.startDate}" pattern="yyyy-MM-dd'T'HH:mm" var="pSt" type="both"/>
                                            <strong><fmt:formatDate value="${pSt}" pattern="dd/MM/yyyy HH:mm"/></strong>
                                        </div>
                                        <div style="font-size:13px; color:var(--on-surface); margin-top:2px;">
                                            Đến: <fmt:parseDate value="${bk.endDate}" pattern="yyyy-MM-dd'T'HH:mm" var="pEd" type="both"/>
                                            <strong><fmt:formatDate value="${pEd}" pattern="dd/MM/yyyy HH:mm"/></strong>
                                        </div>
                                    </div>
                                    <span class="bk-badge bk-badge-pending" style="font-size:11px;">Đã đặt</span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Section: Maintenance Schedule -->
            <div style="margin-bottom:20px;">
                <h4 style="margin:0 0 8px 0; font-size:14px; font-weight:700; color:var(--secondary); text-transform:uppercase; letter-spacing:0.05em; display:flex; align-items:center; gap:6px;">
                    <span class="material-symbols-outlined" style="font-size:18px;">build</span> Lịch bảo trì dự kiến
                </h4>
                <c:choose>
                    <c:when test="${empty maintenances}">
                        <div style="padding:12px; background:var(--surface-container-low); border-radius:8px; font-size:13px; color:var(--on-surface-variant);">
                            Không có lịch bảo trì dự kiến.
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <c:forEach var="m" items="${maintenances}">
                                <div style="display:flex; align-items:center; justify-content:space-between; padding:12px 16px; background:var(--surface-container-low); border-radius:8px; border-left:4px solid var(--outline);">
                                    <div>
                                        <div style="font-size:13px; color:var(--on-surface); font-weight:600;">
                                            ${m.maintenanceType} - ${m.description}
                                        </div>
                                        <div style="font-size:12px; color:var(--on-surface-variant); margin-top:2px;">
                                            Ngày bảo trì: <strong>${m.scheduledDate}</strong>
                                        </div>
                                    </div>
                                    <span class="bk-badge bk-badge-confirmed" style="font-size:11px; background:#FFF3E0; color:#EF6C00;">Bảo trì</span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div style="margin-top:24px; text-align:right;">
                <button type="button" class="bk-btn bk-btn-primary" onclick="closeCalendarModal()">Đóng</button>
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

<!-- Custom App Modal Alert Dialog UI -->
<div id="appAlertModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15,23,42,0.6); z-index:99999; backdrop-filter:blur(6px); align-items:center; justify-content:center; animation: fadeIn 0.2s ease-out;">
    <div style="background:var(--surface, #ffffff); width:90%; max-width:440px; border-radius:20px; padding:28px 24px 24px 24px; box-shadow:0 25px 50px -12px rgba(0,0,0,0.25); text-align:center; position:relative; border:1px solid var(--outline-variant, #e2e8f0); animation: scaleIn 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
        <div id="appAlertIconContainer" style="width:64px; height:64px; border-radius:50%; background:#fef3c7; color:#d97706; display:flex; align-items:center; justify-content:center; margin:0 auto 16px auto;">
            <span id="appAlertIcon" class="material-symbols-outlined" style="font-size:36px;">warning</span>
        </div>
        <h3 id="appAlertTitle" style="margin:0 0 8px 0; font-size:18px; font-weight:700; color:var(--on-surface, #0f172a);">Thông báo</h3>
        <p id="appAlertMessage" style="margin:0 0 24px 0; font-size:14px; color:var(--on-surface-variant, #475569); line-height:1.6;"></p>
        <button type="button" class="bk-btn" style="width:100%; padding:12px; font-size:14px; font-weight:600; border-radius:12px; background:linear-gradient(135deg, var(--primary, #0f2c59) 0%, #1e3a8a 100%); color:#ffffff; border:none; cursor:pointer; box-shadow:0 4px 12px rgba(15,44,89,0.25); transition:all 0.2s ease;" onmouseover="this.style.opacity='0.9'; this.style.transform='translateY(-1px)';" onmouseout="this.style.opacity='1'; this.style.transform='translateY(0)';" onclick="closeAppModalAlert()">
            Đóng thông báo
        </button>
    </div>
</div>

<style>
@keyframes scaleIn {
    from { transform: scale(0.9); opacity: 0; }
    to { transform: scale(1); opacity: 1; }
}
</style>

<script>
function showAppModalAlert(title, message, type = 'warning') {
    document.getElementById('appAlertTitle').innerText = title || 'Thông báo';
    document.getElementById('appAlertMessage').innerText = message || '';
    
    var iconElem = document.getElementById('appAlertIcon');
    var containerElem = document.getElementById('appAlertIconContainer');
    
    if (type === 'warning') {
        iconElem.innerText = 'warning';
        containerElem.style.background = '#fef3c7';
        containerElem.style.color = '#d97706';
    } else if (type === 'error') {
        iconElem.innerText = 'error';
        containerElem.style.background = '#fee2e2';
        containerElem.style.color = '#dc2626';
    } else if (type === 'success') {
        iconElem.innerText = 'check_circle';
        containerElem.style.background = '#dcfce7';
        containerElem.style.color = '#16a34a';
    } else {
        iconElem.innerText = 'info';
        containerElem.style.background = '#e0f2fe';
        containerElem.style.color = '#0284c7';
    }
    
    document.getElementById('appAlertModal').style.display = 'flex';
}

function closeAppModalAlert() {
    document.getElementById('appAlertModal').style.display = 'none';
}
</script>

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

function openCalendarModal() {
    document.getElementById('calendarModal').style.display = 'flex';
}

function closeCalendarModal() {
    document.getElementById('calendarModal').style.display = 'none';
}

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    var modal = document.getElementById('calendarModal');
    if (event.target === modal) {
        closeCalendarModal();
    }
    var alertModal = document.getElementById('appAlertModal');
    if (event.target === alertModal) {
        closeAppModalAlert();
    }
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
