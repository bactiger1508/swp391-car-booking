<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Cấu hình Hóa đơn thuế GTGT"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Cấu hình hóa đơn thuế</span>
        </div>
        <h2>Thiết lập Xuất Hóa đơn GTGT (VAT)</h2>
        <p>Quản lý thông tin doanh nghiệp mặc định và cấu hình tích hợp hóa đơn điện tử e-Invoice. (BR-10: Dùng nội bộ)</p>
    </div>
</div>

<div class="bk-card" style="max-width:800px;margin:0 auto;">
    <div class="bk-card-title">
        <span class="material-symbols-outlined">receipt</span> Thông tin Doanh nghiệp xuất hóa đơn GTGT
    </div>
    
    <form method="post" action="${pageContext.request.contextPath}/tax-invoice/settings" style="margin-top:16px;">
        <div class="bk-form-grid">
            <div class="bk-form-group full">
                <label class="bk-form-label">Tên đầy đủ của đơn vị (Bên bán)</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">corporate_fare</span>
                    <input type="text" class="bk-form-input" name="companyName" value="CÔNG TY CỔ PHẦN CARPRO VIỆT NAM" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Mã số thuế doanh nghiệp (MST)</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">pin</span>
                    <input type="text" class="bk-form-input" name="taxId" value="0109876543" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Thuế suất GTGT mặc định</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">percent</span>
                    <select class="bk-form-select" name="defaultVatRate">
                        <option value="8">8% (Thuế suất giảm nghị quyết)</option>
                        <option value="10" selected>10% (Thuế suất tiêu chuẩn)</option>
                        <option value="0">0% (Miễn thuế)</option>
                    </select>
                </div>
            </div>

            <div class="bk-form-group full">
                <label class="bk-form-label">Địa chỉ trụ sở chính đăng ký</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">location_on</span>
                    <input type="text" class="bk-form-input" name="address" value="Tòa nhà CarPro, Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Email nhận thông báo hóa đơn</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">mail</span>
                    <input type="email" class="bk-form-input" name="invoiceEmail" value="finance@carpro.com.vn" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Token tích hợp hệ thống e-Invoice</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">vpn_key</span>
                    <input type="password" class="bk-form-input" name="invoiceToken" value="••••••••••••••••••••••••" placeholder="Nhập API Token từ VNPT/Viettel...">
                </div>
            </div>
        </div>

        <div style="margin-top:32px;display:flex;justify-content:flex-end;gap:12px;">
            <a href="${pageContext.request.contextPath}/home" class="bk-btn bk-btn-outline">Hủy bỏ</a>
            <button type="submit" class="bk-btn bk-btn-primary" onclick="alert('Đã lưu cấu hình hóa đơn GTGT!'); return false;">
                <span class="material-symbols-outlined">save</span> Lưu thiết lập
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
