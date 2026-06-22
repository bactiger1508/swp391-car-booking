<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Cấu hình Chính sách Thuê xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Cấu hình chính sách</span>
        </div>
        <h2>Thiết lập Chính sách & Phí phạt</h2>
        <p>Quản lý các quy tắc phạt trễ hạn, quá số km quy định, vệ sinh, mất đồ và cách tính phí thuê xe mặc định.</p>
    </div>
</div>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="bk-alert bk-alert-success" style="margin-bottom: 20px; display: flex; align-items: center; gap: 8px; background: rgba(76, 175, 80, 0.1); border: 1px solid rgba(76, 175, 80, 0.3); color: #4caf50; padding: 12px 16px; border-radius: 8px; font-weight: 500;">
        <span class="material-symbols-outlined">check_circle</span>
        <span>${sessionScope.successMessage}</span>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 20px; display: flex; align-items: center; gap: 8px; background: rgba(244, 67, 54, 0.1); border: 1px solid rgba(244, 67, 54, 0.3); color: #f44336; padding: 12px 16px; border-radius: 8px; font-weight: 500;">
        <span class="material-symbols-outlined">error</span>
        <span>${sessionScope.errorMessage}</span>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm chính sách..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty policies}">
        <div style="overflow-x:auto;">
            <table class="bk-table" id="policyTable">
                <thead>
                    <tr>
                        <th>Mã quy định</th>
                        <th>Giá trị thiết lập</th>
                        <th>Mô tả quy tắc chính sách</th>
                        <th>Phân loại</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${policies}">
                        <tr>
                            <td class="code"><code>${p.policyKey}</code></td>
                            <td>
                                <div style="font-weight:700;color:var(--primary);font-size:16px;">
                                    ${p.policyValue}
                                </div>
                            </td>
                            <td>
                                <div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">
                                    ${p.description}
                                </div>
                            </td>
                            <td>
                                <span class="bk-badge bk-badge-confirmed">
                                    <span class="bk-badge-dot"></span> ${p.category}
                                </span>
                            </td>
                            <td class="text-right">
                                <button type="button" class="bk-btn bk-btn-outline bk-btn-sm btn-edit-policy" 
                                        data-key="${p.policyKey}" 
                                        data-value="${p.policyValue}" 
                                        data-desc="${p.description}">Sửa</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    <c:if test="${empty policies}">
        <!-- Dữ liệu mẫu fallback nếu CSDL trống để UI luôn lung linh -->
        <div style="overflow-x:auto;">
            <table class="bk-table" id="policyTable">
                <thead>
                    <tr>
                        <th>Mã quy định</th>
                        <th>Giá trị thiết lập</th>
                        <th>Mô tả quy tắc chính sách</th>
                        <th>Phân loại</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="code"><code>LATE_RETURN_FEE_HOUR</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">100,000đ / giờ</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Phí phạt trễ giờ trả xe theo quy định đã ký kết trong hợp đồng thuê.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                    <tr>
                        <td class="code"><code>OVER_KM_LIMIT_FEE</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">5,000đ / km</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Phí thu thêm trên mỗi kilômét vượt quá định mức tối đa của ngày thuê.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                    <tr>
                        <td class="code"><code>CLEANING_VIOLATION_FEE</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">300,000đ</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Khoản thu bổ sung nếu xe trả bị quá bẩn, có mùi hôi hoặc vết bẩn khó làm sạch.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </c:if>
</div>

<!-- Edit Modal -->
<div id="editModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.55); backdrop-filter: blur(4px); align-items: center; justify-content: center;">
    <div class="bk-card" style="width: 100%; max-width: 500px; margin: auto; padding: 24px; position: relative; box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3); border: 1px solid rgba(255, 255, 255, 0.08); background: var(--surface-container-high); border-radius: 12px;">
        <span class="material-symbols-outlined" style="position: absolute; right: 16px; top: 16px; cursor: pointer; color: var(--on-surface-variant); font-size: 24px;" onclick="closeModal()">close</span>
        <h3 style="margin-top: 0; margin-bottom: 20px; font-size: 20px; font-weight: 600; display: flex; align-items: center; gap: 8px; color: var(--on-surface);">
            <span class="material-symbols-outlined" style="color: var(--primary);">edit_square</span> Cấu hình chính sách
        </h3>
        <form method="post" action="${pageContext.request.contextPath}/policies">
            <input type="hidden" name="policyKey" id="modalPolicyKey">
            <div class="bk-form-group" style="margin-bottom: 16px;">
                <label class="bk-form-label" style="font-weight: 600; margin-bottom: 6px;">Mã chính sách</label>
                <input type="text" id="modalPolicyKeyDisplay" class="bk-form-input" readonly style="background: var(--surface-container-low); border-color: var(--outline-variant); color: var(--on-surface-variant); cursor: not-allowed; font-weight: 500;">
            </div>
            <div class="bk-form-group" style="margin-bottom: 16px;">
                <label class="bk-form-label" style="font-weight: 600; margin-bottom: 6px;">Mô tả quy định</label>
                <textarea id="modalDescription" class="bk-form-textarea" readonly style="background: var(--surface-container-low); border-color: var(--outline-variant); color: var(--on-surface-variant); resize: none; cursor: not-allowed; line-height: 1.5; font-size: 13px;" rows="3"></textarea>
            </div>
            <div class="bk-form-group" style="margin-bottom: 24px;">
                <label class="bk-form-label" style="font-weight: 600; margin-bottom: 6px;">Giá trị thiết lập <span style="color:var(--error);">*</span></label>
                <input type="text" name="policyValue" id="modalPolicyValue" class="bk-form-input" required style="font-size: 16px; font-weight: bold; color: var(--primary); border-color: var(--primary);">
            </div>
            <div class="bk-form-actions" style="justify-content: flex-end; gap: 12px; margin-top: 24px;">
                <button type="button" class="bk-btn bk-btn-outline" style="padding: 10px 20px;" onclick="closeModal()">Hủy</button>
                <button type="submit" class="bk-btn bk-btn-primary" style="padding: 10px 20px;">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#policyTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}

function openEditModal(key, value, description) {
    document.getElementById('modalPolicyKey').value = key;
    document.getElementById('modalPolicyKeyDisplay').value = key;
    document.getElementById('modalDescription').value = description;
    document.getElementById('modalPolicyValue').value = value;
    
    var modal = document.getElementById('editModal');
    modal.style.display = 'flex';
}

function closeModal() {
    document.getElementById('editModal').style.display = 'none';
}

document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners for edit buttons
    var editButtons = document.querySelectorAll('.btn-edit-policy');
    editButtons.forEach(function(btn) {
        btn.addEventListener('click', function() {
            var key = btn.getAttribute('data-key');
            var val = btn.getAttribute('data-value');
            var desc = btn.getAttribute('data-desc');
            openEditModal(key, val, desc);
        });
    });

    // Close when clicking outside of modal card
    var modal = document.getElementById('editModal');
    modal.addEventListener('click', function(event) {
        if (event.target === modal) {
            closeModal();
        }
    });
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
