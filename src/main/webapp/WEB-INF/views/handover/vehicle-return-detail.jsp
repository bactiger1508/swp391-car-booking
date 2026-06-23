<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/returns">Nhận lại xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Xem biên bản nhận lại xe</span>
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

    <form action="${pageContext.request.contextPath}/returns/detail" method="POST" enctype="multipart/form-data">
        <!-- Hidden Inputs for Booking and Car IDs -->
        <input type="hidden" name="bookingId" value="${bookingId}" />
        <input type="hidden" name="carId" value="${carId}" />

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
                        <span style="font-weight:600;">${not empty sessionScope.currentUser ? sessionScope.currentUser.fullName : ''}</span>
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
                    <div style="width: 56px; height: 56px; border-radius: 8px; background: var(--primary-light); display:flex; align-items:center; justify-content:center; color: var(--primary); flex-shrink: 0;">
                        <span class="material-symbols-outlined" style="font-size: 28px;">garage</span>
                    </div>
                    <div>
                        <div style="font-weight: 700; color: var(--primary); font-size: 16px;">
                            ${not empty car ? car.brand : ''} ${not empty car ? car.model : ''}
                        </div>
                        <div style="font-size: 13px; color: var(--text-secondary); margin-top: 2px;">
                            Biển số: <span style="font-weight:600; color: var(--text-primary);">${not empty car ? car.licensePlate : ''}</span>
                        </div>
                        <div style="font-size: 13px; color: var(--text-secondary); margin-top: 1px;">
                            Màu sắc: <span style="font-weight:600; color: var(--text-primary);">${not empty car ? car.color : ''}</span>
                        </div>
                    </div>
                </div>
                <div style="margin-top: 16px; background: var(--surface-container-low); padding: 12px; border-radius: 8px;">
                    <span style="font-size: 11px; font-weight: 700; color: var(--text-secondary); letter-spacing: 0.5px; text-transform: uppercase;">SỐ KM GHI NHẬN CUỐI CÙNG</span>
                    <div style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin-top: 4px;">
                        ${not empty car ? car.mileage : ''} km
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
                        <input type="number" id="currentOdo" name="currentOdo" value="${not empty distanceDriven ? distanceDriven : 0}" class="bk-form-input" placeholder="Nhập số km đã đi"/>
                    </div>
                    <span
                        class="font-body-sm text-body-sm text-on-surface-variant mt-1 text-[12px]">Quãng đường đã đi:
                        <span id="distance-value" style="font-weight:600; color: var(--primary);">0</span> km
                        <br><span id="distance-value-error" style="font-weight:600; color: var(--primary);">
                        </span>
                        <c:if test="${not empty currentOdoError}">
                            <div style="color:red; margin-top:5px;">
                                ${currentOdoError}
                            </div>
                        </c:if>
                </div>

                <!-- Mức nhiên liệu radio segment selector -->
                <div class="bk-form-group">
                    <label class="bk-form-label" style="font-weight:600;">Mức nhiên liệu *</label>
                    <div style="display: flex; background: var(--surface-container-low); border: 1.5px solid var(--outline-variant); border-radius: 8px; overflow: hidden; height: 42px; margin-top: 6px;">
                        <label style="flex: 1; text-align: center; position: relative; cursor: pointer; display: flex; align-items: center; justify-content: center; border-right: 1px solid var(--outline-variant);">
                            <input type="radio" name="fuel" value="E" required="required" class="fuel-radio" ${returns.fuelLevel == 'EMPTY' ? 'checked="checked"' : ''}/>
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
                            <input type="radio" name="fuel" value="F" required="required" class="fuel-radio" ${returns.fuelLevel == 'FULL' ? 'checked="checked"' : ''}/>
                            <span class="fuel-label">F</span>
                        </label>
                    </div>
                    <span class="font-body-sm text-body-sm text-on-surface-variant mt-1 text-[12px]">Mức lúc nhận: ${handover.fuelLevel}</span>
                </div>
            </div>
        </div>

        <!-- Checklist Kiểm tra tình trạng xe -->
        <div class="bk-card" style="margin-bottom: 24px; padding: 24px;">
            <div class="bk-card-title" style="border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px;">
                <span class="material-symbols-outlined">fact_check</span>
                <span>Danh sách kiểm tra tình trạng</span>
            </div>

            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px;">
                <!-- Ngoại thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">NGOẠI THẤT</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorScratch" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Không vết xước/lõm mới') ? 'checked' : ''} />
                            <span>Thân xe không có vết trầy xước mới</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorBumper" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Cản trước và cản sau nguyên vẹn') ? 'checked' : ''} />
                            <span>Cản trước và cản sau nguyên vẹn</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorGlass" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Kính chắn gió và cửa kính không nứt vỡ') ? 'checked' : ''} />
                            <span>Kính chắn gió và cửa kính không nứt vỡ</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorLights" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Đèn pha, đèn hậu hoạt động bình thường') ? 'checked' : ''} />
                            <span>Đèn pha, đèn hậu hoạt động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorMirror" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Gương chiếu hậu đầy đủ, không hư hỏng') ? 'checked' : ''} />
                            <span>Gương chiếu hậu đầy đủ, không hư hỏng</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorTireWheel" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Lốp xe và mâm xe trong tình trạng tốt') ? 'checked' : ''} />
                            <span>Lốp xe và mâm xe trong tình trạng tốt</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkExteriorLicensePlate" value="true" class="checklist-checkbox" ${returns.exteriorCondition.contains('Biển số xe đầy đủ và rõ ràng') ? 'checked' : ''} />
                            <span>Biển số xe đầy đủ và rõ ràng</span>
                        </label>
                    </div>
                </div>

                <!-- Nội thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">NỘI THẤT</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorSeats" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Ghế ngồi sạch sẽ, không rách hỏng') ? 'checked' : ''} />
                            <span>Ghế ngồi sạch sẽ, không rách hỏng</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorDashboard" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Taplo và bảng điều khiển hoạt động bình thường') ? 'checked' : ''} />
                            <span>Taplo và bảng điều khiển hoạt động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorAirConditioner" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Điều hòa hoạt động tốt') ? 'checked' : ''} />
                            <span>Điều hòa hoạt động tốt</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorAudioSystem" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Hệ thống âm thanh hoạt động bình thường') ? 'checked' : ''} />
                            <span>Hệ thống âm thanh hoạt động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorCleanliness" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Không có mùi lạ hoặc rác thải trong xe') ? 'checked' : ''} />
                            <span>Không có mùi lạ hoặc rác thải trong xe</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkInteriorAccessories" value="true" class="checklist-checkbox" ${returns.interiorCondition.contains('Đầy đủ phụ kiện đi kèm') ? 'checked' : ''} />
                            <span>Đầy đủ phụ kiện đi kèm</span>
                        </label>
                    </div>
                </div>

                <!-- Máy móc / Động cơ -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 11px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 4px;">ĐỘNG CƠ / MÁY MÓC</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineStart" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Động cơ khởi động bình thường') ? 'checked' : ''} />
                            <span>Động cơ khởi động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineWarningLight" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Không có đèn cảnh báo trên bảng đồng hồ') ? 'checked' : ''} />
                            <span>Không có đèn cảnh báo trên bảng đồng hồ</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineFuelLevel" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Mức nhiên liệu đúng theo ghi nhận') ? 'checked' : ''} />
                            <span>Mức nhiên liệu đúng theo ghi nhận</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineNoise" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Không phát hiện tiếng ồn bất thường') ? 'checked' : ''} />
                            <span>Không phát hiện tiếng ồn bất thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineBrakeSystem" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Hệ thống phanh hoạt động bình thường') ? 'checked' : ''} />
                            <span>Hệ thống phanh hoạt động bình thường</span>
                        </label>
                        <label class="checklist-label">
                            <input type="checkbox" name="chkEngineFluidLeak" value="true"  class="checklist-checkbox" ${returns.mechanicalCondition.contains('Không phát hiện rò rỉ dầu hoặc chất lỏng') ? 'checked' : ''} />
                            <span>Không phát hiện rò rỉ dầu hoặc chất lỏng</span>
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
                            <span class="img-wrapper" data-src="${photo}" style="position:relative; display:inline-block;">
                                <img src="${pageContext.request.contextPath}${photo}"
                                     style="width:120px;
                                     height:120px;
                                     object-fit:cover;
                                     border:1px solid #ddd;" />
                                <button type="button" class="del-old preview-remove-btn">&times;</button>
                            </span>
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

        <!-- Action Footer -->
        <div style="display: flex; justify-content: flex-end; align-items: center; gap: 12px; margin-top: 24px; border-top: 1px solid var(--outline-variant); padding-top: 16px;">
            <div id="calc-warning" style="color: var(--error); font-size: 13px; font-weight: 500; display: none; margin-right: auto; align-items: center; gap: 6px;">
                <span class="material-symbols-outlined" style="font-size: 18px; vertical-align: middle;">warning</span>
                Thông tin thay đổi. Vui lòng bấm "Tính phí" trước khi xác nhận!
            </div>
            <button type="submit" name="action" value="calculate" class="bk-btn bk-btn-outline" style="display: inline-flex; align-items: center; gap: 8px; font-weight:600;">
                <span class="material-symbols-outlined" style="font-size: 18px;">calculate</span> Tính phí
            </button>
            <button type="submit" id="btnConfirmReturn" name="action" value="confirm" class="bk-btn bk-btn-primary" 
                    ${(empty returns || returns.mileageAtReturn == 0) ? 'disabled="disabled"' : ''}
                    style="display: inline-flex; align-items: center; gap: 8px; font-weight:600; ${(empty returns || returns.mileageAtReturn == 0) ? 'opacity:0.5; cursor:not-allowed;' : ''}">
                <span class="material-symbols-outlined" style="font-size: 18px;">check_circle</span> Xác nhận trả xe
            </button>
        </div>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {

        const odoInput = document.getElementById('currentOdo');
        const distanceDisplay1 = document.getElementById('distance-value');
        const distanceDisplay2 = document.getElementById('distance-value-error');

        const mileageAtHandover = parseFloat("${handover.mileageAtHandover}") || 0;

        function updateDistance() {
            const distance = parseFloat(odoInput.value);

            if (!isNaN(distance) && distance >= 0) {
                const finalOdo = mileageAtHandover + distance;

                distanceDisplay1.innerText = distance.toLocaleString();
                distanceDisplay1.style.color = "var(--primary)";

                distanceDisplay2.innerText = " (Số Odo lúc trả xe dự kiến: " + finalOdo.toLocaleString() + " km)";
                distanceDisplay2.style.color = "var(--on-surface-variant)";
            } else if (odoInput.value === "") {
                distanceDisplay1.innerText = "0";
                distanceDisplay2.innerText = "";
                distanceDisplay1.style.color = "var(--primary)";
            } else {
                distanceDisplay1.innerText = "0";
                distanceDisplay2.innerText = "Lỗi: Số km không hợp lệ";
                distanceDisplay1.style.color = "red";
                distanceDisplay2.style.color = "red";
            }
        }
        function triggerChange() {
            const btn = document.getElementById('btnConfirmReturn');
            if (btn) {
                btn.disabled = true;
                btn.style.opacity = '0.5';
                btn.style.cursor = 'not-allowed';
            }
            const warning = document.getElementById('calc-warning');
            if (warning) {
                warning.style.display = 'inline-flex';
            }
        }

        odoInput.addEventListener("input", function() {
            updateDistance();
            triggerChange();
        });
        updateDistance();

        document.querySelectorAll('.checklist-checkbox').forEach(function(cb) {
            cb.addEventListener('change', triggerChange);
        });

        document.querySelectorAll('.fuel-radio').forEach(function(rad) {
            rad.addEventListener('change', triggerChange);
        });

        const notesTextarea = document.querySelector('textarea[name="notes"]');
        if (notesTextarea) {
            notesTextarea.addEventListener('input', triggerChange);
        }

        const fileInput = document.getElementById("evidencePhotos");
        const previewContainer = document.getElementById("imagePreviewContainer");
        const errorDiv = document.getElementById("uploadPhotosError");
        const remainingPhotosInput = document.getElementById("remainingPhotos");

        let selectedFiles = [];
        let existingPhotos = [];

        document.querySelectorAll(".img-wrapper").forEach(function (imgWrapper) {
            existingPhotos.push(imgWrapper.dataset.src);
        });

        remainingPhotosInput.value = existingPhotos.join(",");

        fileInput.addEventListener("change", function () {

            const files = Array.from(fileInput.files);

            files.forEach(function (file) {

                if (file.size > 10 * 1024 * 1024) {
                    showError(file.name + " vượt quá 10MB");
                    return;
                }

                selectedFiles.push(file);

                previewNewImage(file);
            });

            updateFileInput();
            triggerChange();
        });

        function previewNewImage(file) {

            const reader = new FileReader();

            reader.onload = function (e) {

                const wrapper = document.createElement("div");
                wrapper.style.position = "relative";
                wrapper.style.display = "inline-block";

                const img = document.createElement("img");
                img.src = e.target.result;
                img.style.width = "120px";
                img.style.height = "120px";
                img.style.objectFit = "cover";

                const deleteBtn = document.createElement("button");
                deleteBtn.type = "button";
                deleteBtn.innerHTML = "&times;";
                deleteBtn.classList.add("preview-remove-btn");

                deleteBtn.onclick = function () {

                    selectedFiles = selectedFiles.filter(function (f) {
                        return f !== file;
                    });

                    wrapper.remove();

                    updateFileInput();
                    triggerChange();
                };

                wrapper.appendChild(img);
                wrapper.appendChild(deleteBtn);

                previewContainer.appendChild(wrapper);
            };

            reader.readAsDataURL(file);
        }

        function updateFileInput() {

            const dt = new DataTransfer();

            selectedFiles.forEach(function (file) {
                dt.items.add(file);
            });

            fileInput.files = dt.files;
        }


        document.querySelectorAll(".del-old").forEach(function (btn) {

            btn.addEventListener("click", function () {

                const wrapper = btn.parentElement;
                const photoUrl = wrapper.dataset.src;

                existingPhotos = existingPhotos.filter(function (url) {
                    return url !== photoUrl;
                });

                remainingPhotosInput.value = existingPhotos.join(",");

                wrapper.remove();
                triggerChange();
            });
        });

        function showError(message) {
            errorDiv.innerText = message;
            setTimeout(function () {
                errorDiv.innerText = "";
            }, 3000);
        }
    });
</script>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>