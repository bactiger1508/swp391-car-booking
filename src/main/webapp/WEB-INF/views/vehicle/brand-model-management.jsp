<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Hãng Xe & Model"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Hãng Xe &amp; Model</h2>
        <p>Quản lý danh sách hãng xe và model dùng cho form Thêm/Sửa xe. Ẩn thay vì xóa để không ảnh hưởng xe đang dùng model đó.</p>
    </div>
</div>

<div class="bk-card" style="margin-bottom:24px;">
    <div class="bk-card-title">
        <span class="material-symbols-outlined">add_circle</span> Thêm Hãng Xe Mới
    </div>
    <form id="addBrandForm" onsubmit="submitAddBrand(event)" style="display:flex; gap:12px; align-items:flex-end;">
        <div class="bk-form-group" style="flex:1; max-width:320px;">
            <label class="bk-form-label">Tên Hãng Xe *</label>
            <input type="text" name="brandName" id="newBrandName" class="bk-form-input" style="padding-left:12px;" required placeholder="VD: Peugeot">
        </div>
        <button type="submit" class="bk-btn bk-btn-primary">
            <span class="material-symbols-outlined" style="font-size:18px;">add</span> Thêm Hãng
        </button>
    </form>
</div>

<div id="brandList" style="display:flex; flex-direction:column; gap:16px;">
    <c:forEach items="${brands}" var="brand">
        <div class="bk-card" data-brand-id="${brand.brandId}">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                <div style="display:flex; align-items:center; gap:10px;">
                    <span style="font-size:18px; font-weight:600; color:var(--primary);">${brand.brandName}</span>
                    <c:choose>
                        <c:when test="${brand.active}"><span class="bk-badge bk-badge-completed"><span class="bk-badge-dot"></span> Đang hiện</span></c:when>
                        <c:otherwise><span class="bk-badge bk-badge-cancelled"><span class="bk-badge-dot"></span> Đã ẩn</span></c:otherwise>
                    </c:choose>
                </div>
                <button onclick="toggleBrandActive(${brand.brandId}, ${!brand.active})" class="bk-btn bk-btn-sm bk-btn-outline">
                    ${brand.active ? 'Ẩn hãng xe' : 'Hiện hãng xe'}
                </button>
            </div>

            <div class="model-list" id="modelList-${brand.brandId}" style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px;">
                <span style="font-size:13px; color:var(--on-surface-variant);">Đang tải model...</span>
            </div>

            <form onsubmit="submitAddModel(event, ${brand.brandId})" style="display:flex; gap:8px; align-items:flex-end;">
                <div class="bk-form-group" style="flex:1; max-width:280px;">
                    <label class="bk-form-label">Thêm Model Mới</label>
                    <input type="text" name="modelName" class="bk-form-input" style="padding-left:12px;" required placeholder="VD: 2008">
                </div>
                <button type="submit" class="bk-btn bk-btn-sm bk-btn-outline">
                    <span class="material-symbols-outlined" style="font-size:16px;">add</span> Thêm Model
                </button>
            </form>
        </div>
    </c:forEach>

    <c:if test="${empty brands}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">directions_car</span>
            <h3>Chưa có hãng xe nào</h3>
            <p>Thêm hãng xe đầu tiên bằng form phía trên.</p>
        </div>
    </c:if>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.bk-card[data-brand-id]').forEach(card => {
        loadModelsForCard(card.dataset.brandId);
    });
});

function loadModelsForCard(brandId) {
    const container = document.getElementById('modelList-' + brandId);
    fetch(contextPath + '/vehicles/brands', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=getModels&brandId=' + brandId
    })
    .then(response => response.json())
    .then(data => {
        container.innerHTML = '';
        if (!data.success || data.models.length === 0) {
            container.innerHTML = '<span style="font-size:13px; color:var(--on-surface-variant);">Chưa có model nào.</span>';
            return;
        }
        data.models.forEach(m => {
            const chip = document.createElement('span');
            chip.className = 'bk-badge ' + (m.isActive ? 'bk-badge-completed' : 'bk-badge-cancelled');
            chip.style.cursor = 'pointer';
            chip.title = m.isActive ? 'Nhấn để ẩn model' : 'Nhấn để hiện model';
            chip.textContent = m.modelName + (m.isActive ? '' : ' (đã ẩn)');
            chip.onclick = () => toggleModelActive(m.modelId, !m.isActive, brandId);
            container.appendChild(chip);
        });
    });
}

function submitAddBrand(event) {
    event.preventDefault();
    const brandName = document.getElementById('newBrandName').value;
    fetch(contextPath + '/vehicles/brands', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=addBrand&brandName=' + encodeURIComponent(brandName)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}

function toggleBrandActive(brandId, active) {
    fetch(contextPath + '/vehicles/brands', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=toggleBrandActive&brandId=' + brandId + '&active=' + active
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}

function submitAddModel(event, brandId) {
    event.preventDefault();
    const modelName = event.target.querySelector('input[name="modelName"]').value;
    fetch(contextPath + '/vehicles/brands', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=addModel&brandId=' + brandId + '&modelName=' + encodeURIComponent(modelName)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            event.target.reset();
            loadModelsForCard(brandId);
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}

function toggleModelActive(modelId, active, brandId) {
    fetch(contextPath + '/vehicles/brands', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'action=toggleModelActive&modelId=' + modelId + '&active=' + active
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            loadModelsForCard(brandId);
        } else {
            alert('Lỗi: ' + data.error);
        }
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
