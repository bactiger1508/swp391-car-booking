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
                    <input type="text" class="bk-form-input" name="companyName" value="${companyName}" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Mã số thuế doanh nghiệp (MST)</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">pin</span>
                    <input type="text" class="bk-form-input" name="taxId" value="${companyTaxId}" required>
                </div>
            </div>

            <div class="bk-form-group">
                <label class="bk-form-label">Thuế suất GTGT mặc định</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">percent</span>
                    <select class="bk-form-select" name="defaultVatRate">
                        <option value="8" ${taxRate == '8' ? 'selected' : ''}>8% (Thuế suất giảm nghị quyết)</option>
                        <option value="10" ${taxRate == '10' ? 'selected' : ''}>10% (Thuế suất tiêu chuẩn)</option>
                        <option value="0" ${taxRate == '0' ? 'selected' : ''}>0% (Miễn thuế)</option>
                    </select>
                </div>
            </div>

            <div class="bk-form-group full">
                <label class="bk-form-label">Địa chỉ trụ sở chính đăng ký</label>
                <div class="bk-form-input-wrap">
                    <span class="material-symbols-outlined">location_on</span>
                    <input type="text" class="bk-form-input" name="address" value="${companyAddress}" required>
                </div>
            </div>

        </div>

        <div style="margin-top:32px;display:flex;justify-content:flex-end;gap:12px;">
            <a href="${pageContext.request.contextPath}/home" class="bk-btn bk-btn-outline">Hủy bỏ</a>
            <button type="submit" class="bk-btn bk-btn-primary" onclick="alert('Đã lưu cấu hình hóa đơn GTGT!');">
                <span class="material-symbols-outlined">save</span> Lưu thiết lập
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
