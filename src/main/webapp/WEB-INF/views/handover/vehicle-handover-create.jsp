<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Bàn Giao Xe & Nhận Chìa Khóa"/>
</jsp:include>

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
    <form action="${pageContext.request.contextPath}/handovers/create" method="POST">
        <!-- Hidden Inputs for Booking and Car IDs -->
        <input type="hidden" name="bookingId" value="${bookingId}">
        <input type="hidden" name="carId" value="${carId}">

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
                        <div style="display:flex; justify-content:space-between;">
                            <span style="color:var(--text-secondary);">Mã đặt xe:</span>
                            <span style="font-weight:700; color:var(--primary);">#BK-${not empty bookingId ? bookingId : '78291'}</span>
                        </div>
                        <div style="display:flex; justify-content:space-between;">
                            <span style="color:var(--text-secondary);">Nhân viên phụ trách:</span>
                            <span style="font-weight:600;">Admin</span>
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
                        <div style="width: 56px; height: 56px; border-radius: 8px; background: var(--primary-light); display:flex; align-items:center; justify-content:center; color: var(--primary);">
                            <span class="material-symbols-outlined" style="font-size: 28px;">garage</span>
                        </div>
                        <div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 16px;">Xe #${not empty carId ? carId : '6'}</div>
                            <div style="font-size: 13px; color: var(--text-secondary); margin-top: 2px;">Vui lòng xác minh số sườn/biển số thực tế</div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Cột bên phải: Chỉ số đo km và nhiên liệu --%>
            <div class="bk-card" style="padding: 24px; margin-bottom: 0; min-height: 100%;">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">speed</span>
                    <span>Chỉ Số Trạng Thế Hiện Tại</span>
                </div>
                
                <div class="bk-form-grid" style="grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 16px;">
                    <!-- Số Odo hiện tại -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" for="currentOdo">Số km hiện tại (Odo) *</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">speed</span>
                            <input type="number" id="currentOdo" name="currentOdo" value="${not empty currentOdo ? currentOdo : ''}" class="bk-form-input" placeholder="Nhập số liệu hiện tại" required>
                        </div>
                    </div>

                    <!-- Mức nhiên liệu -->
                    <div class="bk-form-group">
                        <label class="bk-form-label" for="fuel">Mức Nhiên Liệu *</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">local_gas_station</span>
                            <select id="fuel" name="fuel" class="bk-form-select" required>
                                <option value="">-- Chọn mức xăng --</option>
                                <option value="E" ${fuel == 'E' ? 'selected' : ''}>Empty (E)</option>
                                <option value="1/4" ${fuel == '1/4' ? 'selected' : ''}>1/4 Bình xăng</option>
                                <option value="1/2" ${fuel == '1/2' ? 'selected' : ''}>1/2 Bình xăng</option>
                                <option value="3/4" ${fuel == '3/4' ? 'selected' : ''}>3/4 Bình xăng</option>
                                <option value="F" ${fuel == 'F' ? 'selected' : ''}>Full (F)</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Checklist Kiểm tra tình trạng xe -->
        <div class="bk-card" style="margin-bottom: 24px;">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">fact_check</span>
                <span>Danh Sách Kiểm Tra Tình Trạng An Toàn</span>
            </div>
            
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-top: 16px;">
                <!-- Ngoại thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px;">NGOẠI THẤT</div>
                    <label style="display: flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; color: var(--text-primary);">
                        <input type="checkbox" name="chkExteriorScratch" value="true" ${chkExteriorScratch == 'true' ? 'checked' : ''} style="width: 16px; height: 16px; border-radius: 4px; border: 1px solid var(--border-color);">
                        <span>Bình thường, không trầy xước</span>
                    </label>
                </div>

                <!-- Nội thất -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px;">NỘI THẤT</div>
                    <label style="display: flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; color: var(--text-primary);">
                        <input type="checkbox" name="chkCleanliness" value="true" ${chkCleanliness == 'true' ? 'checked' : ''} style="width: 16px; height: 16px; border-radius: 4px; border: 1px solid var(--border-color);">
                        <span>Sạch sẽ, được vệ sinh/hút bụi</span>
                    </label>
                </div>

                <!-- Động cơ -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px;">ĐỘNG CƠ / MÁY MÓC</div>
                    <label style="display: flex; align-items: center; gap: 8px; font-size: 14px; cursor: pointer; color: var(--text-primary);">
                        <input type="checkbox" name="chkEngine" value="true" ${chkEngine == 'true' ? 'checked' : ''} style="width: 16px; height: 16px; border-radius: 4px; border: 1px solid var(--border-color);">
                        <span>Khởi động êm, không báo lỗi</span>
                    </label>
                </div>
            </div>
        </div>

        <!-- Action Footer -->
        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px;">
            <a href="${pageContext.request.contextPath}/handovers" class="bk-btn bk-btn-outline">
                Hủy bỏ
            </a>
            <button type="submit" class="bk-btn bk-btn-primary">
                <span class="material-symbols-outlined">check_circle</span> Xác nhận & Bàn giao xe
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
