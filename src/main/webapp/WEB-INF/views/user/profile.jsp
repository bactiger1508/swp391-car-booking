<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Hồ Sơ Cá Nhân"/>
</jsp:include>
<div class="page-content">
    <div class="detail-layout">
        
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                <span class="material-symbols-outlined">check_circle</span>
                ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <span class="material-symbols-outlined">error</span>
                ${error}
            </div>
        </c:if>

        <div class="card">
            <div class="card-header">
                <h3>Hồ Sơ Thành Viên</h3>
                <span class="badge ${profile.verificationStatus == 'VERIFIED' ? 'badge-completed' : (profile.verificationStatus == 'REJECTED' ? 'badge-cancelled' : 'badge-pending')}">
                    Trạng thái xác minh: ${profile.verificationStatus}
                </span>
            </div>
            
            <form method="post" action="${pageContext.request.contextPath}/profile">
                <div class="form-row" style="margin-bottom: 20px;">
                    <div class="form-group">
                        <label for="fullName">Họ và tên</label>
                        <input type="text" id="fullName" name="fullName" class="form-control" 
                               value="${sessionScope.currentUser.fullName}" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Địa chỉ Email (Không thể thay đổi)</label>
                        <input type="email" id="email" class="form-control" 
                               value="${sessionScope.currentUser.email}" readonly style="background: var(--bg-body); cursor: not-allowed;">
                    </div>
                </div>

                <div class="form-row" style="margin-bottom: 20px;">
                    <div class="form-group">
                        <label for="phone">Số điện thoại</label>
                        <input type="tel" id="phone" name="phone" class="form-control" 
                               value="${sessionScope.currentUser.phone}">
                    </div>
                    <div class="form-group">
                        <label for="dateOfBirth">Ngày sinh</label>
                        <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control" 
                               value="${profile.dateOfBirth}">
                    </div>
                </div>

                <div class="form-group" style="margin-bottom: 20px;">
                    <label for="address">Địa chỉ thường trú</label>
                    <input type="text" id="address" name="address" class="form-control" 
                           value="${profile.address}" placeholder="Nhập địa chỉ của bạn">
                </div>

                <hr style="border: 0; border-top: 1px dashed var(--border-color); margin: 28px 0;">
                
                <h4 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin-bottom: 20px;">Thông Tin Định Danh & Bằng Lái Xe</h4>

                <div class="form-group" style="margin-bottom: 20px;">
                    <label for="idCardNumber">Số CCCD / Hộ chiếu</label>
                    <input type="text" id="idCardNumber" name="idCardNumber" class="form-control" 
                           value="${profile.idCardNumber}" placeholder="Nhập số căn cước công dân">
                </div>

                <div class="form-row" style="margin-bottom: 20px;">
                    <div class="form-group">
                        <label for="driverLicenseNumber">Số Giấy phép lái xe</label>
                        <input type="text" id="driverLicenseNumber" name="driverLicenseNumber" class="form-control" 
                               value="${profile.driverLicenseNumber}" placeholder="Nhập số bằng lái xe (B2, B1...)">
                    </div>
                    <div class="form-group">
                        <label for="driverLicenseExpiry">Ngày hết hạn Giấy phép lái xe</label>
                        <input type="date" id="driverLicenseExpiry" name="driverLicenseExpiry" class="form-control" 
                               value="${profile.driverLicenseExpiry}">
                    </div>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 32px;">
                    <button type="submit" class="btn btn-primary" style="padding: 12px 30px; font-size: 15px;">Lưu Thay Đổi</button>
                </div>
            </form>
        </div>

    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
