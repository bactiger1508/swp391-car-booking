<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Thiết lập chính sách hệ thống"/>
</jsp:include>

<div class="bk-page-header" style="margin-bottom: 24px;">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Cấu hình chính sách</span>
        </div>
        <h2>Cấu hình Chính sách Hệ thống</h2>
        <p>Điều chỉnh các thông số vận hành, quy tắc phạt vi phạm hợp đồng và định mức tính phí của doanh nghiệp.</p>
    </div>
</div>

<c:if test="${not empty sessionScope.successMessage}">
    <div class="bk-alert bk-alert-success" style="margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; background: #E6F4EA; border: 1.5px solid #34A853; color: #137333; padding: 14px 20px; border-radius: 12px; font-weight: 500;">
        <div style="display:flex; align-items:center; gap: 8px;">
            <span class="material-symbols-outlined" style="color: #34A853;">check_circle</span>
            <span>${sessionScope.successMessage}</span>
        </div>
        <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer; font-weight:bold; font-size:18px;">&times;</button>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; background: #FCE8E6; border: 1.5px solid #EA4335; color: #C5221F; padding: 14px 20px; border-radius: 12px; font-weight: 500;">
        <div style="display:flex; align-items:center; gap: 8px;">
            <span class="material-symbols-outlined" style="color: #EA4335;">error</span>
            <span>${sessionScope.errorMessage}</span>
        </div>
        <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer; font-weight:bold; font-size:18px;">&times;</button>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<%-- Category tab switcher --%>
<div style="display: flex; gap: 8px; border-bottom: 1.5px solid var(--outline-variant); padding-bottom: 8px; margin-bottom: 24px; align-items: center; justify-content: space-between;">
    <div style="display: flex; gap: 8px;">
        <button type="button" class="tab-btn active" onclick="switchCategory('ALL', this)" style="border:none; padding: 10px 20px; font-size:14px; font-weight:600; border-radius:8px; cursor:pointer; transition:all 0.2s; background:var(--primary); color:white;">Tất cả chính sách</button>
        <button type="button" class="tab-btn" onclick="switchCategory('PENALTY', this)" style="border:none; padding: 10px 20px; font-size:14px; font-weight:600; border-radius:8px; cursor:pointer; transition:all 0.2s; background:none; color:var(--text-secondary);">Chính sách phí phạt</button>
        <button type="button" class="tab-btn" onclick="switchCategory('BOOKING', this)" style="border:none; padding: 10px 20px; font-size:14px; font-weight:600; border-radius:8px; cursor:pointer; transition:all 0.2s; background:none; color:var(--text-secondary);">Quy định Đặt xe</button>
        <button type="button" class="tab-btn" onclick="switchCategory('PAYMENT', this)" style="border:none; padding: 10px 20px; font-size:14px; font-weight:600; border-radius:8px; cursor:pointer; transition:all 0.2s; background:none; color:var(--text-secondary);">Tài chính &amp; Webhook</button>
    </div>
    
    <%-- Add Policy Button --%>
    <button type="button" onclick="openCreateModal()" style="display: flex; align-items: center; gap: 6px; background: #34A853; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.2s;">
        <span class="material-symbols-outlined" style="font-size:18px;">add_box</span>
        Tạo cấu hình mới
    </button>
</div>

<%-- Search Toolbar --%>
<div style="margin-bottom: 20px; background: var(--surface-container-low); border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 12px 16px; display:flex; align-items:center; gap:10px;">
    <span class="material-symbols-outlined" style="color:var(--text-secondary);">search</span>
    <input type="text" id="searchInput" placeholder="Gõ từ khóa để tìm nhanh chính sách..." oninput="filterPolicies()" style="border:none; background:none; width:100%; outline:none; font-size:14px; font-weight:500; color:var(--on-surface);">
</div>

<%-- Card Container layout --%>
<div id="policy-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 20px;">
    <c:forEach var="p" items="${policies}">
        <div class="policy-card" data-category="${p.category}" style="background: white; border: 1.5px solid var(--outline-variant); border-radius: 16px; padding: 20px; display:flex; flex-direction:column; justify-content:space-between; box-shadow:0 2px 4px rgba(0,0,0,0.02); transition: transform 0.2s, box-shadow 0.2s; position:relative;">
            
            <%-- Badge & Category --%>
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                <span class="category-badge" style="font-size: 11px; font-weight: 700; background: #F1F3F9; color: var(--primary); padding: 4px 10px; border-radius: 20px; text-transform: uppercase;">
                    ${p.category}
                </span>
                <code style="font-size:11px; color:var(--text-secondary); font-weight:700;">${p.policyKey}</code>
            </div>

            <%-- Main Info --%>
            <div style="flex-grow:1; margin-bottom:16px;">
                <h4 style="margin: 0 0 6px 0; font-size: 15px; font-weight: 600; color: var(--on-surface); line-height: 1.4;">
                    ${p.description}
                </h4>
                
                <%-- Visual Value Highlight --%>
                <div style="display:inline-flex; align-items:center; gap:6px; background:#F4F7FE; border:1px solid #D1E4FF; border-radius:8px; padding:6px 12px; margin-top:8px;">
                    <span class="material-symbols-outlined" style="font-size:18px; color:var(--primary); font-variation-settings: 'FILL' 1">settings_suggest</span>
                    <span style="font-size:18px; font-weight:800; color:var(--primary);">${p.policyValue}</span>
                </div>
            </div>

            <%-- Actions --%>
            <div style="border-top:1px dashed var(--outline-variant); padding-top:12px; display:flex; justify-content:flex-end;">
                <button type="button" class="bk-btn bk-btn-outline bk-btn-sm btn-edit-policy"
                        data-key="${p.policyKey}" 
                        data-value="${p.policyValue}" 
                        data-desc="${p.description}"
                        style="border-radius:8px; padding: 6px 16px; font-weight:600;">Cấu hình</button>
            </div>
        </div>
    </c:forEach>
</div>

<!-- Edit Modal (Styled glassmorphic popup) -->
<div id="editModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.55); backdrop-filter: blur(6px); align-items: center; justify-content: center;">
    <div style="width: 100%; max-width: 500px; margin: auto; padding: 28px; position: relative; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.1); background: white; border-radius: 20px;">
        <span class="material-symbols-outlined" style="position: absolute; right: 18px; top: 18px; cursor: pointer; color: var(--text-secondary); font-size: 24px; hover:color:var(--on-surface);" onclick="closeModal()">close</span>
        
        <h3 style="margin-top: 0; margin-bottom: 20px; font-size: 20px; font-weight: 700; display: flex; align-items: center; gap: 8px; color: var(--on-surface);">
            <span class="material-symbols-outlined" style="color: var(--primary); font-size:24px;">settings_applications</span>
            Thay đổi thiết lập
        </h3>
        
        <form method="post" action="${pageContext.request.contextPath}/policies">
            <input type="hidden" name="policyKey" id="modalPolicyKey">
            
            <div style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--text-secondary);">MÃ QUY ĐỊNH</label>
                <input type="text" id="modalPolicyKeyDisplay" style="width:100%; background: #F1F3F9; border: 1.5px solid var(--outline-variant); border-radius:10px; padding:10px 14px; outline:none; color: var(--text-secondary); cursor: not-allowed; font-weight: 600; font-family:monospace;" readonly>
            </div>
            
            <div style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--text-secondary);">MÔ TẢ NGHIỆP VỤ</label>
                <div id="modalDescription" style="background:#F7FAFC; border:1px solid var(--outline-variant); border-radius:10px; padding:12px; font-size:13px; line-height:1.6; color:var(--on-surface-variant); font-weight:500;"></div>
            </div>
            
            <div style="margin-bottom: 24px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--on-surface);">GIÁ TRỊ THIẾT LẬP MỚI <span style="color:var(--error);">*</span></label>
                <input type="text" name="policyValue" id="modalPolicyValue" style="width:100%; border: 2px solid var(--primary); border-radius:10px; padding:10px 14px; outline:none; font-size: 16px; font-weight: 800; color: var(--primary);" required autofocus>
            </div>
            
            <div style="display:flex; justify-content: flex-end; gap: 12px; margin-top: 28px;">
                <button type="button" class="bk-btn bk-btn-outline" style="padding: 10px 22px; border-radius:10px;" onclick="closeModal()">Hủy</button>
                <button type="submit" class="bk-btn bk-btn-primary" style="padding: 10px 22px; border-radius:10px; background:var(--primary); color:white; border:none; cursor:pointer;">Lưu chính sách</button>
            </div>
        </form>
    </div>
</div>

<!-- Create Modal (Styled glassmorphic popup) -->
<div id="createModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.55); backdrop-filter: blur(6px); align-items: center; justify-content: center;">
    <div style="width: 100%; max-width: 500px; margin: auto; padding: 28px; position: relative; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.1); background: white; border-radius: 20px;">
        <span class="material-symbols-outlined" style="position: absolute; right: 18px; top: 18px; cursor: pointer; color: var(--text-secondary); font-size: 24px; hover:color:var(--on-surface);" onclick="closeCreateModal()">close</span>
        
        <h3 style="margin-top: 0; margin-bottom: 20px; font-size: 20px; font-weight: 700; display: flex; align-items: center; gap: 8px; color: var(--on-surface);">
            <span class="material-symbols-outlined" style="color: #34A853; font-size:24px;">add_circle</span>
            Thêm cấu hình chính sách mới
        </h3>
        
        <form method="post" action="${pageContext.request.contextPath}/policies">
            <input type="hidden" name="action" value="create">
            
            <div style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--on-surface);">MÃ CHÍNH SÁCH *</label>
                <input type="text" name="policyKey" placeholder="Ví dụ: MAX_KM_LIMIT, LATE_HOUR_FEE..." style="width:100%; border: 1.5px solid var(--outline-variant); border-radius:10px; padding:10px 14px; outline:none; font-weight: 600; font-family:monospace; text-transform:uppercase;" required>
            </div>

            <div style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--on-surface);">PHÂN LOẠI *</label>
                <div style="position:relative; width:100%;">
                    <select name="category" style="width:100%; border: 1.5px solid var(--outline-variant); border-radius:10px; padding:10px 14px; outline:none; background:white; cursor:pointer;" required>
                        <option value="PENALTY">PENALTY (Chính sách phí phạt)</option>
                        <option value="BOOKING">BOOKING (Quy định đặt xe)</option>
                        <option value="PAYMENT">PAYMENT (Tài chính &amp; Webhook)</option>
                        <option value="PRICING">PRICING (Bảng giá thuê)</option>
                        <option value="TAX">TAX (Thuế &amp; VAT)</option>
                        <option value="GENERAL">GENERAL (Chung)</option>
                    </select>
                </div>
            </div>
            
            <div style="margin-bottom: 18px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--on-surface);">MÔ TẢ NGHIỆP VỤ *</label>
                <textarea name="description" placeholder="Nhập mô tả cụ thể về nghiệp vụ này..." style="width:100%; border: 1.5px solid var(--outline-variant); border-radius:10px; padding:10px 14px; outline:none; font-size: 13px; font-weight: 500; resize:none; line-height:1.5;" rows="3" required></textarea>
            </div>
            
            <div style="margin-bottom: 24px;">
                <label style="font-weight: 700; font-size:13px; display:block; margin-bottom: 6px; color:var(--on-surface);">GIÁ TRỊ THIẾT LẬP BAN ĐẦU *</label>
                <input type="text" name="policyValue" placeholder="Ví dụ: 100000, 30, true, hoặc Vietcombank" style="width:100%; border: 2px solid var(--primary); border-radius:10px; padding:10px 14px; outline:none; font-size: 16px; font-weight: 400; color: var(--primary);" required>
            </div>
            
            <div style="display:flex; justify-content: flex-end; gap: 12px; margin-top: 28px;">
                <button type="button" class="bk-btn bk-btn-outline" style="padding: 10px 22px; border-radius:10px;" onclick="closeCreateModal()">Hủy</button>
                <button type="submit" class="bk-btn bk-btn-primary" style="padding: 10px 22px; border-radius:10px; background:#34A853; color:white; border:none; cursor:pointer;">Tạo chính sách</button>
            </div>
        </form>
    </div>
</div>

<script>
let currentCategory = 'ALL';

function filterPolicies() {
    let search = document.getElementById('searchInput').value.toLowerCase();
    let cards = document.querySelectorAll('.policy-card');
    
    cards.forEach(card => {
        let text = card.textContent.toLowerCase();
        let cat = card.getAttribute('data-category');
        
        let matchesSearch = text.includes(search);
        let matchesCat = (currentCategory === 'ALL' || cat === currentCategory);
        
        if (matchesSearch && matchesCat) {
            card.style.display = 'flex';
        } else {
            card.style.display = 'none';
        }
    });
}

function switchCategory(cat, btn) {
    currentCategory = cat;
    
    // Toggle active tab buttons UI
    let buttons = document.querySelectorAll('.tab-btn');
    buttons.forEach(b => {
        b.classList.remove('active');
        b.style.background = 'none';
        b.style.color = 'var(--text-secondary)';
    });
    
    btn.classList.add('active');
    btn.style.background = 'var(--primary)';
    btn.style.color = 'white';
    
    filterPolicies();
}

function openEditModal(key, value, description) {
    document.getElementById('modalPolicyKey').value = key;
    document.getElementById('modalPolicyKeyDisplay').value = key;
    document.getElementById('modalDescription').innerText = description;
    document.getElementById('modalPolicyValue').value = value;
    
    document.getElementById('editModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('editModal').style.display = 'none';
}

function openCreateModal() {
    document.getElementById('createModal').style.display = 'flex';
}

function closeCreateModal() {
    document.getElementById('createModal').style.display = 'none';
}

document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners to the config buttons
    document.querySelectorAll('.btn-edit-policy').forEach(btn => {
        btn.addEventListener('click', function() {
            let key = btn.getAttribute('data-key');
            let val = btn.getAttribute('data-value');
            let desc = btn.getAttribute('data-desc');
            openEditModal(key, val, desc);
        });
    });

    // Close when clicking outside modal card container
    let modal = document.getElementById('editModal');
    modal.addEventListener('click', function(event) {
        if (event.target === modal) closeModal();
    });

    let cModal = document.getElementById('createModal');
    cModal.addEventListener('click', function(event) {
        if (event.target === cModal) closeCreateModal();
    });
});
</script>

<style>
.policy-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 20px rgba(0,95,184,0.06) !important;
    border-color: var(--primary) !important;
}
.tab-btn:hover:not(.active) {
    background: var(--surface-container-high) !important;
    color: var(--on-surface) !important;
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
