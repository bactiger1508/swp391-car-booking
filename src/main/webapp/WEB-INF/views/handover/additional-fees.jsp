<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Bảng tính Phụ phí Phát sinh"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Tính toán phụ thu</span>
        </div>
        <h2>Bảng tính Phụ thu & Máy tính Phụ phí</h2>
        <p>Hệ thống tự động tra cứu chính sách phạt trễ giờ, quá số km, vệ sinh và hư hỏng của nhà xe khi bàn giao xe. (BR-07)</p>
    </div>
</div>

<div class="bk-detail-grid">
    <%-- LEFT: Máy tính phụ thu tương tác --%>
    <div>
        <div class="bk-card">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">calculate</span> Máy tính giả lập Phụ thu nhận xe
            </div>
            
            <form style="margin-top:16px;" oninput="recalculateFees()">
                <div class="bk-form-grid" style="gap:20px;">
                    <div class="bk-form-group">
                        <label class="bk-form-label">Số giờ trả xe trễ hạn (Giờ)</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">schedule</span>
                            <input type="number" id="lateHours" class="bk-form-input" value="0" min="0" style="padding-left:40px;">
                        </div>
                        <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: 100,000đ / giờ)</span>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Quãng đường đi vượt định mức (km)</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">speed</span>
                            <input type="number" id="overKm" class="bk-form-input" value="0" min="0" style="padding-left:40px;">
                        </div>
                        <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: 5,000đ / km)</span>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Vệ sinh khoang xe dơ bẩn</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">local_laundry_service</span>
                            <select id="cleaningFee" class="bk-form-select">
                                <option value="0">Sạch sẽ - 0đ</option>
                                <option value="300000">Quá bẩn / Mùi thuốc lá - 300,000đ</option>
                                <option value="600000">Cực kỳ dơ / Nôn trớ - 600,000đ</option>
                            </select>
                        </div>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Bồi thường hư hỏng linh kiện / mất đồ</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">handyman</span>
                            <input type="number" id="damageFee" class="bk-form-input" value="0" min="0" style="padding-left:40px;" placeholder="Nhập số tiền...">
                        </div>
                    </div>

                    <div class="bk-form-group full">
                        <label class="bk-form-label">Ghi chú tình trạng chi tiết khi nhận lại xe</label>
                        <textarea class="bk-form-textarea" rows="3" placeholder="Nhập ghi chú chi tiết về vết trầy xước, mức nhiên liệu bị hụt..."></textarea>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <%-- RIGHT: Bảng Tổng hợp chi phí tính toán động --%>
    <div>
        <div class="bk-cost-card">
            <h3><span class="material-symbols-outlined">receipt_long</span> Tóm tắt Phụ thu</h3>
            
            <div class="bk-detail-rows" style="gap:16px;">
                <div class="bk-detail-row">
                    <span class="label">Phí trễ hạn</span>
                    <span class="value" id="resLate">0đ</span>
                </div>
                <div class="bk-detail-row">
                    <span class="label">Phí quá số km</span>
                    <span class="value" id="resKm">0đ</span>
                </div>
                <div class="bk-detail-row">
                    <span class="label">Phí dọn dẹp xe</span>
                    <span class="value" id="resClean">0đ</span>
                </div>
                <div class="bk-detail-row">
                    <span class="label">Phí đền bù hư hỏng</span>
                    <span class="value" id="resDamage">0đ</span>
                </div>
            </div>

            <div class="bk-summary-total">
                <span class="label">Tổng phụ thu</span>
                <span class="value" id="resTotal" style="color:var(--error);font-size:24px;font-weight:800;">0đ</span>
            </div>

            <div style="margin-top:24px;display:flex;flex-direction:column;gap:12px;">
                <button type="button" class="bk-btn bk-btn-primary" style="width:100%;justify-content:center;" onclick="alert('Đã lưu và áp dụng phụ thu vào đơn hàng!')">
                    <span class="material-symbols-outlined">check_circle</span> Áp dụng & Lưu biên bản
                </button>
                <a href="${pageContext.request.contextPath}/returns" class="bk-btn bk-btn-outline" style="width:100%;justify-content:center;">
                    <span class="material-symbols-outlined">arrow_back</span> Hủy bỏ
                </a>
            </div>
        </div>
    </div>
</div>

<script>
function formatMoney(amount) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount).replace('₫', 'đ');
}

function recalculateFees() {
    var lateHours = parseFloat(document.getElementById('lateHours').value) || 0;
    var overKm = parseFloat(document.getElementById('overKm').value) || 0;
    var cleaning = parseFloat(document.getElementById('cleaningFee').value) || 0;
    var damage = parseFloat(document.getElementById('damageFee').value) || 0;

    var lateFee = lateHours * 100000;
    var kmFee = overKm * 5000;

    var total = lateFee + kmFee + cleaning + damage;

    document.getElementById('resLate').textContent = formatMoney(lateFee);
    document.getElementById('resKm').textContent = formatMoney(kmFee);
    document.getElementById('resClean').textContent = formatMoney(cleaning);
    document.getElementById('resDamage').textContent = formatMoney(damage);
    document.getElementById('resTotal').textContent = formatMoney(total);
}

// Chạy lần đầu
recalculateFees();
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
