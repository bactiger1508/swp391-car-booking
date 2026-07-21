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
                    Trạng thái xác minh: ${profile.verificationStatus== 'VERIFIED' ? 'Đã xác minh' :
                                           (profile.verificationStatus == 'REJECTED' ? 'Đã từ chối' :
                                           (profile.verificationStatus == 'PENDING' ? 'Đang chờ xác minh' : 'Chưa xác minh'))}
                </span>
            </div>

            <form method="post" action="${pageContext.request.contextPath}/profile" enctype="multipart/form-data">
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
                        <label for="driverLicenseExpiry">Ngày hết hạn Giấy phép lái xe <small style="color:var(--text-secondary); font-weight: normal;">(Để trống nếu không thời hạn)</small></label>
                        <input type="date" id="driverLicenseExpiry" name="driverLicenseExpiry" class="form-control" 
                               value="${profile.driverLicenseExpiry}">
                    </div>
                </div>

                <%-- ===== ẢNH ĐỊNH DANH ===== --%>
                <hr style="border: 0; border-top: 1px dashed var(--border-color); margin: 8px 0 20px;">
                <h5 style="font-size:14px; font-weight:700; color:var(--text-primary); margin-bottom:16px;">Ảnh CCCD / Hộ chiếu</h5>

                <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:20px;">

                    <%-- Mặt trước CCCD --%>
                    <div>
                        <label style="font-weight:600; font-size:13px; display:block; margin-bottom:8px;">Mặt trước</label>
                        <div class="upload-box" onclick="document.getElementById('idCardImageFront').click()"
                             style="border:2px dashed var(--outline-variant); border-radius:12px; padding:20px; text-align:center; cursor:pointer; background:var(--surface-container-low); transition:.2s; position:relative; min-height:120px;"
                             onmouseover="this.style.background = 'var(--surface-container-high)'" onmouseout="this.style.background = 'var(--surface-container-low)'">
                            <input type="file" id="idCardImageFront" name="idCardImageFront" accept=".png,.jpg,.jpeg"
                                   style="display:none;" onchange="previewImg(this, 'prevFront')">
                            <span class="material-symbols-outlined" style="font-size:36px;color:var(--text-secondary);">id_card</span>
                            <p style="margin-top:6px; font-size:12px; color:var(--primary); font-weight:600;">Nhấp để tải lên</p>
                            <p style="font-size:11px; color:var(--text-secondary);">PNG, JPG • Tối đa 10MB</p>
                        </div>
                        <div id="prevFront" style="margin-top:10px;"></div>
                        <c:if test="${not empty profile.idCardImageFront}">
                            <div style="margin-top:8px;">
                                <p style="font-size:12px; color:var(--text-secondary); margin-bottom:4px;">Ảnh hiện tại:</p>
                                <img src="${pageContext.request.contextPath}/${profile.idCardImageFront}"
                                     alt="CCCD mặt trước"
                                     style="width:100%; max-width:200px; height:130px; object-fit:cover; border:1px solid var(--outline-variant); border-radius:8px; display:block;"/>
                            </div>
                        </c:if>
                    </div>

                    <%-- Mặt sau CCCD --%>
                    <div>
                        <label style="font-weight:600; font-size:13px; display:block; margin-bottom:8px;">Mặt sau</label>
                        <div class="upload-box" onclick="document.getElementById('idCardImageBack').click()"
                             style="border:2px dashed var(--outline-variant); border-radius:12px; padding:20px; text-align:center; cursor:pointer; background:var(--surface-container-low); transition:.2s; position:relative; min-height:120px;"
                             onmouseover="this.style.background = 'var(--surface-container-high)'" onmouseout="this.style.background = 'var(--surface-container-low)'">
                            <input type="file" id="idCardImageBack" name="idCardImageBack" accept=".png,.jpg,.jpeg"
                                   style="display:none;" onchange="previewImg(this, 'prevBack')">
                            <span class="material-symbols-outlined" style="font-size:36px;color:var(--text-secondary);">id_card</span>
                            <p style="margin-top:6px; font-size:12px; color:var(--primary); font-weight:600;">Nhấp để tải lên</p>
                            <p style="font-size:11px; color:var(--text-secondary);">PNG, JPG • Tối đa 10MB</p>
                        </div>
                        <div id="prevBack" style="margin-top:10px;"></div>
                        <c:if test="${not empty profile.idCardImageBack}">
                            <div style="margin-top:8px;">
                                <p style="font-size:12px; color:var(--text-secondary); margin-bottom:4px;">Ảnh hiện tại:</p>
                                <img src="${pageContext.request.contextPath}/${profile.idCardImageBack}"
                                     alt="CCCD mặt sau"
                                     style="width:100%; max-width:200px; height:130px; object-fit:cover; border:1px solid var(--outline-variant); border-radius:8px; display:block;"/>
                            </div>
                        </c:if>
                    </div>
                </div>

                <%-- Bằng lái xe --%>
                <h5 style="font-size:14px; font-weight:700; color:var(--text-primary); margin-bottom:12px;">Ảnh Giấy phép lái xe</h5>
                <div>
                    <div class="upload-box" onclick="document.getElementById('driverLicenseImage').click()"
                         style="border:2px dashed var(--outline-variant); border-radius:12px; padding:20px; text-align:center; cursor:pointer; background:var(--surface-container-low); transition:.2s; min-height:120px;"
                         onmouseover="this.style.background = 'var(--surface-container-high)'" onmouseout="this.style.background = 'var(--surface-container-low)'">
                        <input type="file" id="driverLicenseImage" name="driverLicenseImage" accept=".png,.jpg,.jpeg"
                               style="display:none;" onchange="previewImg(this, 'prevLicense')">
                        <span class="material-symbols-outlined" style="font-size:36px;color:var(--text-secondary);">drive_eta</span>
                        <p style="margin-top:6px; font-size:12px; color:var(--primary); font-weight:600;">Nhấp để tải lên</p>
                        <p style="font-size:11px; color:var(--text-secondary);">PNG, JPG • Tối đa 10MB</p>
                    </div>
                    <div id="prevLicense" style="margin-top:10px;"></div>
                    <c:if test="${not empty profile.driverLicenseImage}">
                        <div style="margin-top:8px;">
                            <p style="font-size:12px; color:var(--text-secondary); margin-bottom:4px;">Ảnh hiện tại:</p>
                            <img src="${pageContext.request.contextPath}/${profile.driverLicenseImage}"
                                 alt="Bằng lái xe"
                                 style="width:220px; height:150px; object-fit:cover; border:1px solid var(--outline-variant); border-radius:10px; display:block;"/>
                        </div>
                    </c:if>
                </div>



                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 32px;">
                    <button type="submit" class="btn btn-primary" style="padding: 12px 30px; font-size: 15px;">Lưu Thay Đổi</button>
                </div>
            </form>
        </div>

    </div>
</div>
<script>
    function previewImg(input, containerId) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';
        const file = input.files[0];
        if (!file)
            return;
        const allowed = ['image/png', 'image/jpeg'];
        if (!allowed.includes(file.type)) {
            container.innerHTML = '<small style="color:#d32f2f;">Chỉ chấp nhận PNG hoặc JPG.</small>';
            input.value = '';
            return;
        }
        if (file.size > 10 * 1024 * 1024) {
            container.innerHTML = '<small style="color:#d32f2f;">Ảnh không được vượt quá 10MB.</small>';
            input.value = '';
            return;
        }
        const reader = new FileReader();
        reader.onload = function (e) {
            container.innerHTML =
                    '<img src="' + e.target.result + '" style="width:200px;height:130px;object-fit:cover;border:1px solid #ddd;border-radius:8px;display:block;"/>' +
                    '<div style="font-size:11px;color:#666;margin-top:4px;">' + file.name + '</div>';
        };
        reader.readAsDataURL(file);
    }
</script>                        
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
