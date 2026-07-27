<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Xem Biên bản Bàn giao xe"/>
</jsp:include>

<style>
    /* Premium CSS for fuel segment radio styling */
    .fuel-radio {
        position: absolute;
        opacity: 0;
        width: 100%;
        height: 100%;
        cursor: pointer;
    }
    .fuel-label {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100%;
        font-size: 13px;
        font-weight: 700;
        color: var(--text-secondary);
        transition: all 0.25s ease;
    }
    .fuel-radio:checked + .fuel-label {
        background: var(--primary);
        color: #ffffff !important;
    }
    .checklist-label {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 14px;
        cursor: pointer;
        color: var(--text-primary);
        transition: color 0.2s ease;
        padding: 4px 0;
    }
    .checklist-label:hover {
        color: var(--primary);
    }
    .checklist-checkbox {
        width: 16px;
        height: 16px;
        border-radius: 4px;
        border: 1.5px solid var(--outline-variant);
        accent-color: var(--primary);
        cursor: pointer;
    }
    .preview-remove-btn {
        position: absolute;
        top: 4px;
        right: 4px;

        width: 20px;
        height: 20px;

        border: none;
        border-radius: 50%;

        background: black;
        color: white;

        cursor: pointer;

        display: flex;
        align-items: center;
        justify-content: center;

        font-size: 12px;
    }
</style>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/bookings/my">Đơn thuê của tôi</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/detail">Chi tiết đơn #BK-${booking.bookingId}</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Thanh toán</span>
        </div>
        <h2>Biên bản Nhận lại xe</h2>
        <p>Kiểm tra kỹ lưỡng quãng đường thực tế, mức nhiên liệu, hư hỏng và tính toán các phụ phí phát sinh khi khách hàng trả xe. (BR-07, BR-08)</p>
    </div>
</div>

<div class="page-content" style="max-width: 1200px; margin: 0 auto; padding-top: 0;">

    <c:if test="${not empty error}">
        <div style="background: rgba(211, 47, 47, 0.1); border-left: 5px solid #d32f2f; color: #d32f2f; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/return/view" method="POST" enctype="multipart/form-data">
        <!-- Hidden Inputs for Booking and Car IDs -->
        <input type="hidden" name="bookingId" value="${bookingId}" />
        <input type="hidden" name="vehicleId" value="${vehicleId}" />

        <fieldset style="border:none;" disabled>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; align-items: stretch;">
                <%-- Cột bên phải: Thông tin đặt xe --%>
                <!-- Card Thông tin đặt xe -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0; ">
                    <div class="bk-card-title">
                        <span class="material-symbols-outlined">assignment</span>
                        <span>Thông Tin Đặt Xe</span>
                    </div>
                    <div style="margin-top: 12px; display: flex; flex-direction: column; gap: 8px; font-size: 14px;">
                        <div style="display:flex; justify-content:space-between; border-bottom: 1px solid var(--outline-variant); padding-bottom: 6px;">
                            <span style="color:var(--text-secondary);">Mã đặt xe:</span>
                            <span style="font-weight:700; color:var(--primary);">#BK-${not empty bookingId ? bookingId : ''}</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; border-bottom: 1px solid var(--outline-variant); padding-bottom: 6px; margin-top: 4px;">
                            <span style="color:var(--text-secondary);">Khách hàng:</span>
                            <span style="font-weight:600; color: var(--text-primary);">${not empty customer ? customer.fullName : ''}</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; padding-bottom: 2px; margin-top: 4px;">
                            <span style="color:var(--text-secondary);">Nhân viên lập:</span>
                            <span style="font-weight:600; color: var(--text-primary);">${not empty staff ? staff.fullName : (not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : 'N/A')}</span>
                        </div>
                    </div>
                </div>

                <%-- Cột bên phải: Thông tin xe --%>
                <!-- Card Thông tin xe -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0;">
                    <div class="bk-card-title">
                        <span class="material-symbols-outlined">directions_car</span>
                        <span>Chi tiết xe</span>
                    </div>
                    <div style="margin-top: 16px; display: flex; align-items: center; gap: 16px;">
                        <div style="width: 56px; height: 56px; border-radius: 8px; background: var(--primary-light); display:flex; align-items:center; justify-content:center; color: var(--primary); flex-shrink: 0; overflow:hidden;">
                            <c:set var="carImgUrl" value="${car.primaryImageUrl}" />
                            <c:if test="${not empty carImgUrl}">
                                <c:set var="carImgUrl" value="${fn:trim(carImgUrl)}" />
                                <c:choose>
                                    <c:when test="${carImgUrl.startsWith('http://') || carImgUrl.startsWith('https://')}">
                                        <%-- keep as is --%>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${not carImgUrl.startsWith('/')}">
                                            <c:set var="carImgUrl" value="/${carImgUrl}" />
                                        </c:if>
                                        <c:if test="${not empty pageContext.request.contextPath && not carImgUrl.startsWith(pageContext.request.contextPath)}">
                                            <c:set var="carImgUrl" value="${pageContext.request.contextPath}${carImgUrl}" />
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:choose>
                                <c:when test="${not empty carImgUrl}">
                                    <img src="${carImgUrl}" alt="${car.brand} ${car.model}" style="width:100%;height:100%;object-fit:cover;" onerror="this.src='${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg'; this.onerror=null;">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg" alt="Vehicle Placeholder" style="width:100%;height:100%;object-fit:cover;">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 16px;">
                                ${not empty vehicle ? vehicle.brand : ''} ${not empty vehicle ? vehicle.model : ''}
                            </div>
                            <div style="font-size: 13px; color: var(--text-secondary); margin-top: 2px;">
                                Biển số: <span style="font-weight:600; color: var(--text-primary);">${not empty vehicle ? vehicle.licensePlate : ''}</span>
                            </div>
                            <div style="font-size: 13px; color: var(--text-secondary); margin-top: 1px;">
                                Màu sắc: <span style="font-weight:600; color: var(--text-primary);">${not empty vehicle ? vehicle.color : ''}</span>
                            </div>
                        </div>
                    </div>
                    <div style="margin-top: 16px; background: var(--surface-container-low); padding: 12px; border-radius: 8px;">
                        <span style="font-size: 11px; font-weight: 700; color: var(--text-secondary); letter-spacing: 0.5px; text-transform: uppercase;">SỐ KM GHI NHẬN LÚC BÀN GIAO</span>
                        <div style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin-top: 4px;">
                            <fmt:formatNumber value="${handover.mileageAtHandover}" pattern="#,##0"/> km
                        </div>
                    </div>
                </div>
            </div>

            <%-- Chỉ số đo km và nhiên liệu --%>
            <div class="bk-card" style="padding: 24px; margin-bottom: 24px; display: flex; flex-direction: column; grid-column:1 / span 2;">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">speed</span>
                    <span>Chỉ số trạng thái hiện tại</span>
                </div>

                <div style="display: flex; flex-direction: column; gap: 20px; margin-top: 16px; flex-grow: 1; justify-content: center;">
                    <!-- Số Odo hiện tại -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" for="currentOdo" style="font-weight:600;">Số km đã đi trong chuyến (km)*</label>
                        <div class="bk-form-input-wrap" style="margin-top: 6px;">
                            <span class="material-symbols-outlined">speed</span>
                            <input type="number" id="currentOdo" name="currentOdo" value="${not empty distanceDriven ? distanceDriven : (not empty returns && returns.mileageAtReturn > 0 ? returns.mileageAtReturn - handover.mileageAtHandover : '')}" class="bk-form-input" placeholder="Số km đã đi trong chuyến" readonly="readonly"/>
                        </div>
                        <span class="font-body-sm text-body-sm text-on-surface-variant mt-1 text-[13px]" style="display: block; margin-top: 8px; line-height: 1.6;">
                            Số km dự kiến khi nhận lại xe: <strong id="distance-value" style="font-weight: 700;"><fmt:formatNumber value="${(not empty handover ? handover.mileageAtHandover : 0) + (not empty distanceDriven ? distanceDriven : 0)}" pattern="#,##0"/></strong> <strong style="font-weight: 700;">km</strong>
                            <span id="distance-value-error" style="color:red; font-size:12px;"></span>
                        </span>
                        <c:if test="${not empty currentOdoError}">
                            <div style="color:red; margin-top:5px;">
                                ${currentOdoError}
                            </div>
                        </c:if>
                    </div>

                    <!-- Mức nhiên liệu radio segment selector -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" style="font-weight:600;">Mức nhiên liệu tại thời điểm nhận lại *</label>
                        <div style="display: flex; background: var(--surface-container-low); border: 1.5px solid var(--outline-variant); border-radius: 8px; overflow: hidden; height: 42px; margin-top: 6px;">
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="E" required="required" class="fuel-radio" ${returns.fuelLevel == 'EMPTY' || returns.fuelLevel == 'E' ? 'checked="checked"' : ''}/>
                                <span class="fuel-label">E</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="1/4" required="required" class="fuel-radio" ${returns.fuelLevel == '1/4' ? 'checked="checked"' : ''}/>
                                <span class="fuel-label">1/4</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="1/2" required="required" class="fuel-radio" ${returns.fuelLevel == '1/2' ? 'checked="checked"' : ''}/>
                                <span class="fuel-label">1/2</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="3/4" required="required" class="fuel-radio" ${returns.fuelLevel == '3/4' ? 'checked="checked"' : ''}/>
                                <span class="fuel-label">3/4</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                                <input type="radio" name="fuel" value="F" required="required" class="fuel-radio" ${returns.fuelLevel == 'FULL' || returns.fuelLevel == 'F' ? 'checked="checked"' : ''}/>
                                <span class="fuel-label">F</span>
                            </label>
                        </div>

                        <span class="font-body-sm text-body-sm text-on-surface-variant mt-1 text-[12px]" style="display: flex; align-items: center; gap: 8px; margin-top: 8px;">
                            Mức lúc nhận:
                            <span class="bk-btn bk-btn-primary" style="padding: 4px 12px; font-size: 12px; font-weight: 600; cursor: default; pointer-events: none; text-transform: uppercase;">
                                ${not empty handover ? handover.fuelLevel : ''}
                            </span>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Checklist Kiểm tra tình trạng xe -->
            <div class="bk-card" style="margin-bottom: 24px; padding: 24px;">
                <div class="bk-card-title" style="border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <span class="material-symbols-outlined">fact_check</span>
                        <span>Danh sách kiểm tra tình trạng</span>
                    </div>
                    <label class="checklist-label" style="font-weight: 700; font-size: 14px; color: var(--primary); margin: 0; cursor: default;">
                        <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${not empty returns && not empty returns.notes && returns.notes.contains('[CẦN BẢO DƯỠNG]') ? 'checked="checked"' : ''} />
                        <span>Cần bảo dưỡng sau khi trả xe</span>
                    </label>
                </div>

                <div id="maintenanceChecklistContainer" style="display: ${not empty returns && not empty returns.notes && returns.notes.contains('[CẦN BẢO DƯỠNG]') ? 'grid' : 'none'}; grid-template-columns: repeat(3, 1fr); gap: 32px;">
                    <!-- Ngoại thất -->
                    <div style="display: flex; flex-direction: column; gap: 12px;">
                        <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 6px; display:flex; align-items:center; gap:6px;">
                            <span>Ngoại thất</span>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.exteriorCondition.contains('trầy xước') ? 'checked="checked"' : ''} />
                                <span>Thân xe có vết trầy xước mới</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.exteriorCondition.contains('nứt hoặc vỡ') ? 'checked="checked"' : ''} />
                                <span>Kính chắn gió bị nứt hoặc vỡ</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.exteriorCondition.contains('mòn') || returns.exteriorCondition.contains('lốp xe') ? 'checked="checked"' : ''} />
                                <span>Lốp xe mòn hoặc hư hỏng</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.exteriorCondition.contains('Gương') ? 'checked="checked"' : ''} />
                                <span>Gương chiếu hậu hư hỏng</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.exteriorCondition.contains('Đèn') ? 'checked="checked"' : ''} />
                                <span>Đèn ngoại thất hư hỏng</span>
                            </label>
                        </div>
                    </div>

                    <!-- Nội thất -->
                    <div style="display: flex; flex-direction: column; gap: 12px;">
                        <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 6px; display:flex; align-items:center; gap:6px;">
                            <span>Nội thất</span>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.interiorCondition.contains('bụi') || returns.interiorCondition.contains('bẩn') ? 'checked="checked"' : ''} />
                                <span>Nội thất bẩn hoặc nhiều bụi</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.interiorCondition.contains('mùi hôi') ? 'checked="checked"' : ''} />
                                <span>Có mùi hôi trong xe</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.interiorCondition.contains('Thiếu thảm') ? 'checked="checked"' : ''} />
                                <span>Thiếu thảm hoặc phụ kiện</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.interiorCondition.contains('Ghế ngồi') ? 'checked="checked"' : ''} />
                                <span>Ghế ngồi bị rách hoặc hư hỏng</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.interiorCondition.contains('Taplo') ? 'checked="checked"' : ''} />
                                <span>Taplo / bảng điều khiển hư hỏng</span>
                            </label>
                        </div>
                    </div>

                    <!-- Động cơ / Máy móc -->
                    <div style="display: flex; flex-direction: column; gap: 12px;">
                        <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 6px; display:flex; align-items:center; gap:6px;">
                            <span>Động cơ / Máy móc</span>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 10px;">
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.mechanicalCondition.contains('bất thường') ? 'checked="checked"' : ''} />
                                <span>Động cơ khởi động bất thường</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.mechanicalCondition.contains('đèn cảnh báo') ? 'checked="checked"' : ''} />
                                <span>Có đèn cảnh báo trên bảng điều khiển</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.mechanicalCondition.contains('tiếng ồn') ? 'checked="checked"' : ''} />
                                <span>Có tiếng ồn hoặc rung bất thường</span>
                            </label>
                            <label class="checklist-label">
                                <input type="checkbox" disabled="disabled" class="checklist-checkbox" ${returns.mechanicalCondition.contains('Rò rỉ') ? 'checked="checked"' : ''} />
                                <span>Rò rỉ dầu hoặc nước làm mát</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bằng chứng hình ảnh & Ghi chú thêm -->
            <div style="display: grid; grid-template-columns: 7fr 5fr; gap: 24px; margin-bottom: 24px;">
                <!-- Photo Upload Area -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0;">
                    <div class="bk-card-title" style="margin-bottom: 14px;">
                        <span class="material-symbols-outlined">add_a_photo</span>
                        <span>Bằng Chứng Bằng Hình Ảnh</span>
                        <span style="font-size: 12px; font-weight: 400; color: var(--text-secondary); margin-left: auto;">Tùy chọn nhưng được khuyến nghị</span>
                    </div>

                    <div style="border: 2px dashed var(--outline-variant); border-radius: 8px; padding: 24px; text-align: center; background: var(--surface-container-low); position: relative; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background = 'var(--surface-container-high)'" onmouseout="this.style.background = 'var(--surface-container-low)'">
                        <input type="file" id="evidencePhotos" name="evidencePhotos" value="${returns.photosUrl}" accept="image/*" multiple="multiple" style="position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%;" />
                        <input type="hidden" name="remainingPhotos" id="remainingPhotos"/>
                        <div id="uploadPhotosError" style="color:red; margin-top:8px;"></div>
                        <span class="material-symbols-outlined" style="font-size: 42px; color: var(--text-secondary);">upload_file</span>
                        <p style="font-weight: 700; color: var(--primary); margin-top: 8px; font-size: 14px;">Nhấp để tải lên hoặc kéo và thả</p>
                        <p style="font-size: 11px; color: var(--text-secondary); margin-top: 4px;">Định dạng SVG, PNG, JPG hoặc GIF (Tối đa 10MB)</p>
                    </div>

                    <div id="imagePreviewContainer" style="display:flex; flex-wrap:wrap; gap:12px; margin-top:16px;"></div>
                    <c:if test="${not empty returns.photosUrl}">
                        <c:set var="photos" value="${returns.photosUrl.split(',')}" />
                        <div id="existingImages">
                            <c:forEach var="photo" items="${photos}">
                                <c:set var="cleanPhoto" value="${fn:trim(photo)}" />
                                <c:if test="${not empty cleanPhoto}">
                                    <c:set var="photoUrl" value="${cleanPhoto}" />
                                    <c:choose>
                                        <c:when test="${photoUrl.startsWith('http://') || photoUrl.startsWith('https://')}">
                                            <%-- keep as is --%>
                                        </c:when>
                                        <c:otherwise>
                                            <c:if test="${not photoUrl.startsWith('/')}">
                                                <c:set var="photoUrl" value="/${photoUrl}" />
                                            </c:if>
                                            <c:if test="${not empty pageContext.request.contextPath && not photoUrl.startsWith(pageContext.request.contextPath)}">
                                                <c:set var="photoUrl" value="${pageContext.request.contextPath}${photoUrl}" />
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="img-wrapper" data-src="${cleanPhoto}" style="position:relative; display:inline-block;">
                                        <img src="${photoUrl}"
                                             style="width:120px;
                                             height:120px;
                                             object-fit:cover;
                                             border:1px solid #ddd;"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/vehicles/placeholder.jpg'; this.onerror=null;" />
                                        <button type="button" class="del-old preview-remove-btn">&times;</button>
                                    </span>
                                </c:if>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>

                <!-- Ghi chú thêm -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0; display: flex; flex-direction: column;">
                    <div class="bk-card-title" style="margin-bottom: 12px;">
                        <span class="material-symbols-outlined">edit_note</span>
                        <span>Ghi Chú Thêm</span>
                    </div>
                    <div style="flex-grow: 1;">
                        <textarea name="notes" placeholder="Nhập ghi chú chi tiết về tình trạng xe tại thời điểm nhận lại xe (nếu có)..." style="width: 100%; height: 100%; min-height: 100px; padding: 12px; border: 1.5px solid var(--outline-variant); border-radius: 8px; background: var(--surface); color: var(--text-primary); font-size: 13px; font-family: inherit; resize: none; outline: none;" onfocus="this.style.borderColor = 'var(--primary)'" onblur="this.style.borderColor = 'var(--outline-variant)'">${returns.notes}</textarea>
                    </div>
                </div>
            </div>

            <div class="bk-detail-grid">
                <%-- LEFT: Máy tính phụ thu tương tác --%>
                <div>
                    <div class="bk-card">
                        <div class="bk-card-title">
                            <span class="material-symbols-outlined">calculate</span> Máy tính giả lập Phụ thu nhận xe
                        </div>

                        <div class="bk-form-grid" style="gap:20px;">
                            <div class="bk-form-group">
                                <label class="bk-form-label">Số giờ trả xe trễ hạn (Giờ)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">schedule</span>
                                    <input type="number" id="lateHours" name="lateHours" class="bk-form-input" value="${returns.lateHours}" min="0" style="padding-left:40px;" readonly="readonly" />
                                </div>
                                <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: 100,000đ / giờ)</span>
                            </div>

                            <div class="bk-form-group">
                                <label class="bk-form-label">Quãng đường đi vượt định mức (km)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">speed</span>
                                    <input type="number" id="extraKmFee" name="extraKmFee" class="bk-form-input" value="${not empty autoExtraKm ? autoExtraKm : returns.extraKmFee}" min="0" style="padding-left:40px;" readonly="readonly" />
                                </div>
                                <c:if test="${not empty actualKm}">
                                    <div style="margin-top:8px; padding:10px 12px; background:var(--surface-container); border-radius:8px; border-left:3px solid var(--primary); font-size:12px; line-height:1.7; color:var(--on-surface-variant);">
                                        <strong style="color:var(--primary); font-size:13px;">📊 Phân tích km chuyến đi</strong><br/>
                                        Km thực tế đi: <strong id="calc-actual-km">${actualKm} km</strong> &nbsp;|&nbsp; Định mức: <strong>${kmLimit} km</strong><br/>
                                        Km vượt tổng: <strong id="calc-extra-total">${actualExtraKm} km</strong><br/>
                                        Km vượt đã thu lúc đặt (est. ${estimatedKm} km): <strong style="color:var(--success);">-${alreadyPaidExtraKm} km</strong><br/>
                                        <strong style="color:var(--error);">→ Km vượt cần thu thêm: <span id="calc-extra-additional">${not empty autoExtraKm ? autoExtraKm : returns.extraKmFee} km</span></strong>
                                    </div>
                                </c:if>
                                <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: <fmt:formatNumber value="${extraKmFeeRate}" pattern="#,##0"/>đ / km)</span>
                            </div>

                            <div class="bk-form-group">
                                <label class="bk-form-label">Vệ sinh khoang xe dơ bẩn</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">local_laundry_service</span>
                                    <select id="cleaningFee" name="cleaningFee" class="bk-form-select" disabled="disabled">
                                        <option value="0.00" ${returns.cleaningFee == 0 ? 'selected="selected"' : ''}>Sạch sẽ - 0đ</option>
                                        <option value="300000.00" ${returns.cleaningFee == 300000 ? 'selected="selected"' : ''}>Quá bẩn / Mùi thuốc lá - 300,000đ</option>
                                        <option value="600000.00" ${returns.cleaningFee == 600000 ? 'selected="selected"' : ''}>Cực kỳ dơ / Nôn trớ - 600,000đ</option>
                                    </select>
                                </div>
                            </div>

                            <div class="bk-form-group">
                                <label class="bk-form-label">Bồi thường hư hỏng linh kiện / mất đồ</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">handyman</span>
                                    <input type="number" id="damageFee" name="damageFee" class="bk-form-input" value="${returns.damageFee}" min="0" style="padding-left:40px;" placeholder="0" readonly="readonly" />
                                </div>
                            </div>
                            <div class="bk-form-group">
                                <label class="bk-form-label">Bồi thường phụ kiện bị mất</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">handyman</span>
                                    <input type="number" id="lostItemFee" name="lostItemFee" class="bk-form-input" value="${returns.lostItemFee}" min="0" style="padding-left:40px;" placeholder="0" readonly="readonly" />
                                </div>
                            </div>
                            <input type="hidden" id="totalAdditionalFee" name="totalAdditionalFee" value="0">
                        </div>
                    </div>
                </div>

                <%-- RIGHT: Bảng Tổng hợp chi phí tính toán động --%>
                <div>
                    <div class="bk-cost-card">
                        <h3><span class="material-symbols-outlined">receipt_long</span> Tóm tắt Phụ thu</h3>

                        <div class="bk-detail-rows" style="gap:16px;">
                            <div class="bk-detail-row">
                                <span class="label">Phí trễ hạn</span>
                                <span class="value" id="resLate"><fmt:formatNumber value="${not empty lateFeeCost ? lateFeeCost : 0}" pattern="#,##0"/>đ</span>
                            </div>
                            <div class="bk-detail-row">
                                <span class="label">Phí quá số km</span>
                                <span class="value" id="resKm"><fmt:formatNumber value="${not empty extraKmCost ? extraKmCost : 0}" pattern="#,##0"/>đ</span>
                            </div>
                            <div class="bk-detail-row">
                                <span class="label">Phí dọn dẹp xe</span>
                                <span class="value" id="resClean"><fmt:formatNumber value="${not empty cleaningFee ? cleaningFee : 0}" pattern="#,##0"/>đ</span>
                            </div>
                            <div class="bk-detail-row">
                                <span class="label">Phí đền bù hư hỏng</span>
                                <span class="value" id="resDamage"><fmt:formatNumber value="${not empty damageFee ? damageFee : 0}" pattern="#,##0"/>đ</span>
                            </div>
                            <div class="bk-detail-row">
                                <span class="label">Phí bồi thường phụ kiện bị mất</span>
                                <span class="value" id="resLostItem"><fmt:formatNumber value="${not empty lostItemFee ? lostItemFee : 0}" pattern="#,##0"/>đ</span>
                            </div>
                        </div>

                        <div class="bk-summary-total" style="border-top: 1px solid var(--outline-variant); padding-top: 12px; margin-top: 12px;">
                            <span class="label" style="font-weight: 500;">Tổng tiền thuê ban đầu</span>
                            <span class="value" style="font-weight: 600;"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/>đ</span>
                        </div>
                        <div class="bk-detail-row" style="font-size: 13px; opacity: 0.8; margin-top: -8px; margin-bottom: 8px;">
                            <span class="label">Trong đó tiền cọc:</span>
                            <span class="value" id="resDeposit"><fmt:formatNumber value="${booking.depositAmount}" pattern="#,##0"/>đ</span>
                        </div>

                        <div class="bk-summary-total">
                            <span class="label" style="font-weight: 500;">Khách đã thanh toán</span>
                            <span class="value" style="font-weight: 600; color: var(--success);"><fmt:formatNumber value="${not empty totalPaid ? totalPaid : booking.depositAmount}" pattern="#,##0"/>đ</span>
                        </div>

                        <div class="bk-summary-total">
                            <span class="label" style="font-weight: 500;">Tổng phụ thu phát sinh</span>
                            <span class="value" id="resTotal" style="font-weight: 600; color: var(--error);"><fmt:formatNumber value="${not empty totalAdditionalFee ? totalAdditionalFee : 0}" pattern="#,##0"/>đ</span>
                        </div>

                        <div class="bk-summary-total" style="border-top: 1.5px dashed var(--outline-variant); padding-top: 16px; margin-top: 16px;">
                            <span class="label" style="font-size: 16px; font-weight: 700;">Số tiền hoàn lại</span>
                            <span class="value" id="resRefund" style="color:var(--success);font-size:20px;font-weight:800;"><fmt:formatNumber value="${not empty refund ? refund : 0}" pattern="#,##0"/>đ</span>
                        </div>

                        <div class="bk-summary-total">
                            <span class="label" style="font-size: 16px; font-weight: 700;">Số tiền khách cần thanh toán</span>
                            <span class="value" id="resExtraPayment" style="color:var(--error);font-size:20px;font-weight:800;"><fmt:formatNumber value="${not empty extraPayment ? extraPayment : 0}" pattern="#,##0"/>đ</span>
                        </div>
                    </div>
                </div>
            </div>

        </fieldset>

        <!-- Action Footer -->
        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; border-top: 1px solid var(--outline-variant); padding-top: 16px;">
            <a href="${pageContext.request.contextPath}/bookings/detail?id=${bookingId}" class="bk-btn bk-btn-outline" style="display: inline-flex; align-items: center; gap: 8px; font-weight:600; text-decoration:none;">
                <span class="material-symbols-outlined" style="font-size: 18px;">arrow_back</span> Quay lại
            </a>
        </div>
    </form>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>