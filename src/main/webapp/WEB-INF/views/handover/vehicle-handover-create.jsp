<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Bàn Giao Xe & Nhận Chìa Khóa"/>
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
</style>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/handovers">Biên bản bàn giao</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Tạo biên bản mới</span>
        </div>
        <h2>Bàn Giao Xe & Ký Nhận</h2>
        <p>Ghi nhận chỉ số thực tế (số km, mức xăng) và danh mục kiểm tra an toàn trước khi trao chìa khóa xe cho khách thuê. (BR-06)</p>
    </div>
</div>

<div class="page-content" style="max-width: 1200px; margin: 0 auto; padding-top: 0;">
    
    <c:if test="${not empty error}">
        <div style="background: rgba(211, 47, 47, 0.1); border-left: 5px solid #d32f2f; color: #d32f2f; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/handovers/create" method="POST" enctype="multipart/form-data">
        <!-- Hidden Inputs for Booking and Car IDs -->
        <input type="hidden" name="bookingId" value="${bookingId}" />
        <input type="hidden" name="carId" value="${carId}" />

        <div style="display: grid; grid-template-columns: 4fr 8fr; gap: 24px; margin-bottom: 24px; align-items: start;">
            
            <%-- Cột bên trái: Chi tiết xe và Booking --%>
            <div style="display: flex; flex-direction: column; gap: 24px;">
                <!-- Card Thông tin đặt xe -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0;">
                    <div class="bk-card-title">
                        <span class="material-symbols-outlined">assignment</span>
                        <span>Thông Tin Đặt Xe</span>
                    </div>
                    <div style="margin-top: 12px; display: flex; flex-direction: column; gap: 8px; font-size: 14px;">
                        <div style="display:flex; justify-content:space-between; border-bottom: 1px solid var(--outline-variant); padding-bottom: 6px;">
                            <span style="color:var(--text-secondary);">Mã đặt xe:</span>
                            <span style="font-weight:700; color:var(--primary);">#BK-${not empty bookingId ? bookingId : '78291'}</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; border-bottom: 1px solid var(--outline-variant); padding-bottom: 6px; margin-top: 4px;">
                            <span style="color:var(--text-secondary);">Khách hàng:</span>
                            <span style="font-weight:600; color: var(--text-primary);">${not empty customer ? customer.fullName : 'John Doe'}</span>
                        </div>
                        <div style="display:flex; justify-content:space-between; padding-bottom: 2px; margin-top: 4px;">
                            <span style="color:var(--text-secondary);">Nhân viên lập:</span>
                            <span style="font-weight:600;">${not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : 'Admin'}</span>
                        </div>
                    </div>
                </div>

                <!-- Card Thông tin xe -->
                <div class="bk-card" style="padding: 24px; margin-bottom: 0;">
                    <div class="bk-card-title">
                        <span class="material-symbols-outlined">directions_car</span>
                        <span>Thông Tin Xe Bàn Giao</span>
                    </div>
                    <div style="margin-top: 16px; display: flex; align-items: center; gap: 16px;">
                        <div style="width: 56px; height: 56px; border-radius: 8px; background: var(--primary-light); display:flex; align-items:center; justify-content:center; color: var(--primary); flex-shrink: 0;">
                            <span class="material-symbols-outlined" style="font-size: 28px;">garage</span>
                        </div>
                        <div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 16px;">
                                ${not empty car ? car.brand : 'Toyota'} ${not empty car ? car.model : 'Camry'}
                            </div>
                            <div style="font-size: 13px; color: var(--text-secondary); margin-top: 2px;">
                                Biển số: <span style="font-weight:600; color: var(--text-primary);">${not empty car ? car.licensePlate : 'ABC-1234'}</span>
                            </div>
                            <div style="font-size: 13px; color: var(--text-secondary); margin-top: 1px;">
                                Màu sắc: <span style="font-weight:600; color: var(--text-primary);">${not empty car ? car.color : 'Bạc'}</span>
                            </div>
                        </div>
                    </div>
                    <div style="margin-top: 16px; background: var(--surface-container-low); padding: 12px; border-radius: 8px;">
                        <span style="font-size: 11px; font-weight: 700; color: var(--text-secondary); letter-spacing: 0.5px; text-transform: uppercase;">Số km ghi nhận cuối</span>
                        <div style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin-top: 4px;">
                            ${not empty car ? car.mileage : '45,210'} km
                        </div>
                    </div>
                </div>
            </div>

            <%-- Cột bên phải: Chỉ số đo km và nhiên liệu --%>
            <div class="bk-card" style="padding: 24px; margin-bottom: 0; min-height: 100%; display: flex; flex-direction: column;">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">speed</span>
                    <span>Chỉ Số Thực Tế Khi Bàn Giao</span>
                </div>
                
                <div style="display: flex; flex-direction: column; gap: 20px; margin-top: 16px; flex-grow: 1; justify-content: center;">
                    <!-- Số Odo hiện tại -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" for="currentOdo" style="font-weight:600;">Số km hiện tại (Odometer) *</label>
                        <div class="bk-form-input-wrap" style="margin-top: 6px;">
                            <span class="material-symbols-outlined">speed</span>
                            <input type="number" id="currentOdo" name="currentOdo" value="${not empty currentOdo ? currentOdo : (not empty car ? car.mileage : '')}" class="bk-form-input" placeholder="Nhập số liệu công-tơ-mét thực tế" required="required" />
                        </div>
                    </div>

                    <!-- Mức nhiên liệu radio segment selector -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" style="font-weight:600;">Mức Nhiên Liệu Thực Tế *</label>
                        <div style="display: flex; background: var(--surface-container-low); border: 1.5px solid var(--outline-variant); border-radius: 8px; overflow: hidden; height: 42px; margin-top: 6px;">
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="E" required="required" class="fuel-radio" ${fuel == 'E' ? 'checked="checked"' : ''} />
                                <span class="fuel-label">E</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="1/4" required="required" class="fuel-radio" ${fuel == '1/4' ? 'checked="checked"' : ''} />
                                <span class="fuel-label">1/4</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="1/2" required="required" class="fuel-radio" ${empty fuel || fuel == '1/2' ? 'checked="checked"' : ''} />
                                <span class="fuel-label">1/2</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                                <input type="radio" name="fuel" value="3/4" required="required" class="fuel-radio" ${fuel == '3/4' ? 'checked="checked"' : ''} />
                                <span class="fuel-label">3/4</span>
                            </label>
                            <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                                <input type="radio" name="fuel" value="F" required="required" class="fuel-radio" ${fuel == 'F' ? 'checked="checked"' : ''} />
                                <span class="fuel-label">F</span>
                            </label>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Checklist Kiểm tra tình trạng xe -->
        <div class="bk-card" style="margin-bottom: 24px; padding: 24px;">
            <div class="bk-card-title" style="border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px;">
                <span class="material-symbols-outlined">fact_check</span>
                <span>Danh Sách Kiểm Tra Tình Trạng Kỹ Thuật & An Toàn</span>
            </div>
            
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px;">
                <!-- Ngoại thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">NGOẠI THẤT</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorScratch" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Không có vết xước hoặc vết lõm mới</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkWindshield" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Kính chắn gió nguyên vẹn</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkTires" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Lốp xe trong tình trạng tốt</span>
                        </label>
                    </div>
                </div>

                <!-- Nội thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">NỘI THẤT</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkCleanliness" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Sạch sẽ và được hút bụi</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkOdor" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Không có mùi hôi</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkMatsAccessories" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Có đủ thảm và phụ kiện</span>
                        </label>
                    </div>
                </div>

                <!-- Máy móc / Động cơ -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">ĐỘNG CƠ / MÁY MÓC</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngine" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Động cơ khởi động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkDashboardLights" value="true" class="checklist-checkbox" checked="checked" />
                            <span>Không có đèn cảnh báo trên táp-lô</span>
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
                    <span style="font-size: 12px; font-weight: 400; color: var(--text-secondary); margin-left: auto;">Khuyến nghị đính kèm</span>
                </div>
                
                <div style="border: 2px dashed var(--outline-variant); border-radius: 8px; padding: 24px; text-align: center; background: var(--surface-container-low); position: relative; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='var(--surface-container-high)'" onmouseout="this.style.background='var(--surface-container-low)'">
                    <input type="file" name="evidencePhotos" accept="image/*" multiple="multiple" style="position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%;" />
                    <span class="material-symbols-outlined" style="font-size: 42px; color: var(--text-secondary);">upload_file</span>
                    <p style="font-weight: 700; color: var(--primary); margin-top: 8px; font-size: 14px;">Nhấp để tải lên hoặc kéo và thả hình ảnh</p>
                    <p style="font-size: 11px; color: var(--text-secondary); margin-top: 4px;">Hỗ trợ định dạng JPG, PNG, GIF (Tối đa 10MB)</p>
                </div>
            </div>

            <!-- Ghi chú thêm -->
            <div class="bk-card" style="padding: 24px; margin-bottom: 0; display: flex; flex-direction: column;">
                <div class="bk-card-title" style="margin-bottom: 12px;">
                    <span class="material-symbols-outlined">edit_note</span>
                    <span>Ghi Chú Thêm</span>
                </div>
                <div style="flex-grow: 1;">
                    <textarea name="notes" placeholder="Nhập ghi chú chi tiết về tình trạng xe tại thời điểm bàn giao (nếu có)..." style="width: 100%; height: 100%; min-height: 100px; padding: 12px; border: 1.5px solid var(--outline-variant); border-radius: 8px; background: var(--surface); color: var(--text-primary); font-size: 13px; font-family: inherit; resize: none; outline: none;" onfocus="this.style.borderColor='var(--primary)'" onblur="this.style.borderColor='var(--outline-variant)'">${notes}</textarea>
                </div>
            </div>
        </div>

        <!-- Action Footer -->
        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px; border-top: 1px solid var(--outline-variant); padding-top: 16px;">
            <c:choose>
                <c:when test="${not empty contract}">
                    <a href="${pageContext.request.contextPath}/contracts" class="bk-btn bk-btn-outline" style="min-width: 120px; text-align: center;">
                        Xem hợp đồng
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-btn bk-btn-outline" style="min-width: 120px; text-align: center;">
                        Quản lý đặt xe
                    </a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/handovers" class="bk-btn bk-btn-outline" style="background: rgba(0, 0, 0, 0.05); color: var(--text-primary); border-color: transparent;">
                Hủy bỏ
            </a>
            <button type="submit" class="bk-btn bk-btn-primary" style="display: inline-flex; align-items: center; gap: 8px; font-weight:600;">
                <span class="material-symbols-outlined" style="font-size: 18px;">check_circle</span> Xác nhận & Bàn giao xe
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
