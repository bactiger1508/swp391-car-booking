<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Cấu Hân Thanh Toán"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Cấu hình thanh toán</span>
        </div>
        <h2>Cấu hình Phương thức & Cài đặt Thanh toán</h2>
        <p>Kiểm soát các phương thức thanh toán của hệ thống, tỷ lệ đặt cọc mặc định, thời hạn thanh toán và thông tin ngân hàng doanh nghiệp.</p>
    </div>
</div>

<div class="page-content" style="max-width: 1000px; margin: 0 auto; padding-top: 0;">
    <div class="ps-page">

        <%-- Toast container for screen notifications --%>
        <div class="toast-container" id="toast-container">
            <c:if test="${not empty successMsg}">
                <div class="toast toast-success" id="toast-success">
                    <div class="toast-content">
                        <span class="toast-icon">✨</span>
                        <span class="toast-message">${successMsg}</span>
                    </div>
                    <button class="toast-close" onclick="closeToast('toast-success')">&times;</button>
                </div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="toast toast-error" id="toast-error">
                    <div class="toast-content">
                        <span class="toast-icon">⚠️</span>
                        <span class="toast-message">${errorMsg}</span>
                    </div>
                    <button class="toast-close" onclick="closeToast('toast-error')">&times;</button>
                </div>
            </c:if>
        </div>

        <div class="bk-card">
            <div class="bk-card-title" style="display:flex; justify-content:space-between; align-items:center;">
                <div style="display:flex; align-items:center; gap:8px;">
                    <span class="material-symbols-outlined">settings_suggest</span>
                    <span>Thiết lập Quy tắc Thanh toán Hệ thống</span>
                </div>
                <span style="font-size:13px; color:var(--text-secondary); font-weight:normal;">Quyền cấu hình: Admin duy nhất</span>
            </div>

            <%-- Tab Navigation --%>
            <div class="ps-tabs" style="padding: 12px 24px 0 24px;">
                <button class="ps-tab ${activeTab == 'methods' ? 'active' : ''}"
                        onclick="switchTab('methods', this)" type="button" id="tab-methods">
                    💳 Phương Thức Thanh Toán
                </button>
                <button class="ps-tab ${activeTab == 'settings' ? 'active' : ''}"
                        onclick="switchTab('settings', this)" type="button" id="tab-settings">
                    🔧 Cài Đặt Quy Tắc
                </button>
                <button class="ps-tab ${activeTab == 'bank' ? 'active' : ''}"
                        onclick="switchTab('bank', this)" type="button" id="tab-bank">
                    🏦 Tài Khoản Ngân Hàng
                </button>
            </div>

            <div style="padding: 24px;">

                <%-- ============================================================ --%>
                <%-- TAB 1: Payment Methods Toggle                                --%>
                <%-- ============================================================ --%>
                <div id="panel-methods" class="ps-panel ${activeTab == 'methods' ? 'active' : ''}">
                    <div class="info-box">
                        <strong>ℹ️ Quy tắc vận hành:</strong> Bật/tắt các cổng thanh toán sẽ thay đổi ngay lập tức luồng chọn cổng của Khách hàng khi tạo đơn đặt xe (`Create Booking`) và luồng thanh toán tại phân hệ nhân viên.
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/admin/payment-settings" id="form-methods">
                        <input type="hidden" name="action" value="updateMethods"/>
                        <input type="hidden" name="tab"    value="methods"/>

                        <div class="method-grid">
                            <%-- CASH --%>
                            <c:set var="cashEnabled" value="${methodMap['PAYMENT_METHOD_CASH_ENABLED'] != null && methodMap['PAYMENT_METHOD_CASH_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${cashEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_CASH_ENABLED')">
                                <span class="method-status ${cashEnabled ? 'status-on' : 'status-off'}">${cashEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">💵</div>
                                <div class="method-info">
                                    <div class="method-name">Tiền Mặt</div>
                                    <div class="method-desc">Thanh toán trực tiếp tại văn phòng</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_CASH_ENABLED" id="PAYMENT_METHOD_CASH_ENABLED" ${cashEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <%-- BANK TRANSFER --%>
                            <c:set var="bankEnabled" value="${methodMap['PAYMENT_METHOD_BANK_TRANSFER_ENABLED'] != null && methodMap['PAYMENT_METHOD_BANK_TRANSFER_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${bankEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_BANK_TRANSFER_ENABLED')">
                                <span class="method-status ${bankEnabled ? 'status-on' : 'status-off'}">${bankEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">🏦</div>
                                <div class="method-info">
                                    <div class="method-name">Chuyển Khoản</div>
                                    <div class="method-desc">Chuyển khoản liên ngân hàng 24/7</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_BANK_TRANSFER_ENABLED" id="PAYMENT_METHOD_BANK_TRANSFER_ENABLED" ${bankEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <%-- CARD --%>
                            <c:set var="cardEnabled" value="${methodMap['PAYMENT_METHOD_CARD_ENABLED'] != null && methodMap['PAYMENT_METHOD_CARD_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${cardEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_CARD_ENABLED')">
                                <span class="method-status ${cardEnabled ? 'status-on' : 'status-off'}">${cardEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">💳</div>
                                <div class="method-info">
                                    <div class="method-name">Thẻ Tín Dụng</div>
                                    <div class="method-desc">Visa, Mastercard, JCB, ATM nội địa</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_CARD_ENABLED" id="PAYMENT_METHOD_CARD_ENABLED" ${cardEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <%-- MOMO --%>
                            <c:set var="momoEnabled" value="${methodMap['PAYMENT_METHOD_MOMO_ENABLED'] != null && methodMap['PAYMENT_METHOD_MOMO_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${momoEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_MOMO_ENABLED')">
                                <span class="method-status ${momoEnabled ? 'status-on' : 'status-off'}">${momoEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">📱</div>
                                <div class="method-info">
                                    <div class="method-name">Ví MoMo</div>
                                    <div class="method-desc">Cổng thanh toán ví MoMo (Mockup)</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_MOMO_ENABLED" id="PAYMENT_METHOD_MOMO_ENABLED" ${momoEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <%-- VNPAY --%>
                            <c:set var="vnpayEnabled" value="${methodMap['PAYMENT_METHOD_VNPAY_ENABLED'] != null && methodMap['PAYMENT_METHOD_VNPAY_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${vnpayEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_VNPAY_ENABLED')">
                                <span class="method-status ${vnpayEnabled ? 'status-on' : 'status-off'}">${vnpayEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">🌐</div>
                                <div class="method-info">
                                    <div class="method-name">Cổng VNPay</div>
                                    <div class="method-desc">Cổng thanh toán quốc gia VNPay QR</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_VNPAY_ENABLED" id="PAYMENT_METHOD_VNPAY_ENABLED" ${vnpayEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>

                            <%-- ZALOPAY --%>
                            <c:set var="zaloEnabled" value="${methodMap['PAYMENT_METHOD_ZALOPAY_ENABLED'] != null && methodMap['PAYMENT_METHOD_ZALOPAY_ENABLED'].policyValue == 'true'}"/>
                            <div class="method-card ${zaloEnabled ? 'enabled' : 'disabled'}" onclick="toggleMethod('PAYMENT_METHOD_ZALOPAY_ENABLED')">
                                <span class="method-status ${zaloEnabled ? 'status-on' : 'status-off'}">${zaloEnabled ? 'BẬT' : 'TẤT'}</span>
                                <div class="method-icon">💬</div>
                                <div class="method-info">
                                    <div class="method-name">Ví ZaloPay</div>
                                    <div class="method-desc">Thanh toán nhanh qua ZaloPay</div>
                                </div>
                                <label class="toggle-switch" onclick="event.stopPropagation()">
                                    <input type="checkbox" name="PAYMENT_METHOD_ZALOPAY_ENABLED" id="PAYMENT_METHOD_ZALOPAY_ENABLED" ${zaloEnabled ? 'checked' : ''} onchange="updateCard(this)">
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>

                        <div class="save-row">
                            <button type="submit" class="bk-btn bk-btn-primary" id="btn-save-methods">
                                <span class="material-symbols-outlined">save</span> Lưu Phương Thức Thanh Toán
                            </button>
                        </div>
                    </form>
                </div>

                <%-- ============================================================ --%>
                <%-- TAB 2: General Payment Settings                              --%>
                <%-- ============================================================ --%>
                <div id="panel-settings" class="ps-panel ${activeTab == 'settings' ? 'active' : ''}">
                    <div class="info-box">
                        <strong>⚙️ Cài đặt hệ thống:</strong> Các chỉ số phần trăm cọc và hạn gia hạn thanh toán sẽ được tự động tính toán khi khách tạo đơn hàng và nhân viên tạo hợp đồng.
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/admin/payment-settings" id="form-settings">
                        <input type="hidden" name="action" value="updateSettings"/>
                        <input type="hidden" name="tab"    value="settings"/>

                        <div class="bk-form-grid">
                            <%-- Deposit Percentage --%>
                            <c:set var="depositPercentage" value="${settingMap['DEPOSIT_PERCENTAGE'] != null ? settingMap['DEPOSIT_PERCENTAGE'].policyValue : '30'}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">💰 Tỷ lệ đặt cọc bắt buộc (%)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">percent</span>
                                    <input type="number" class="bk-form-input" id="f-deposit" name="policy_DEPOSIT_PERCENTAGE"
                                           value="${depositPercentage}" min="0" max="100" placeholder="30" required>
                                </div>
                                <span style="font-size:11px; color:var(--text-secondary); margin-top:4px; display:block;">Mặc định tính cọc cho hợp đồng (Ví dụ: 30%)</span>
                            </div>

                            <%-- Grace Period --%>
                            <c:set var="gracePeriod" value="${settingMap['PAYMENT_GRACE_PERIOD_HOURS'] != null ? settingMap['PAYMENT_GRACE_PERIOD_HOURS'].policyValue : '24'}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">⏱️ Thời hạn giữ đơn chờ thanh toán (giờ)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">schedule</span>
                                    <input type="number" class="bk-form-input" id="f-grace" name="policy_PAYMENT_GRACE_PERIOD_HOURS"
                                           value="${gracePeriod}" min="1" max="168" placeholder="24" required>
                                </div>
                                <span style="font-size:11px; color:var(--text-secondary); margin-top:4px; display:block;">Thời gian chờ cọc trước khi hệ thống đánh giá hết hạn</span>
                            </div>
                        </div>

                        <%-- Partial Payment Toggle --%>
                        <div style="margin-top: 24px;">
                            <div class="section-title">🔀 Tùy Chọn Tính Năng Nâng Cao</div>
                            <c:set var="partialAllowed" value="${settingMap['PAYMENT_PARTIAL_ALLOWED'] != null && settingMap['PAYMENT_PARTIAL_ALLOWED'].policyValue == 'true'}"/>
                            <div class="toggle-wrap">
                                <div>
                                    <div class="toggle-label">Cho phép thanh toán từng phần (Partial Payment)</div>
                                    <div class="toggle-desc">Hệ thống chấp nhận ghi nhận các giao dịch cọc nhỏ hơn hoặc lớn hơn trước khi bàn giao xe.</div>
                                </div>
                                <label class="toggle-switch">
                                    <input type="checkbox" name="policy_PAYMENT_PARTIAL_ALLOWED" id="f-partial"
                                           value="true" ${partialAllowed ? 'checked' : ''}>
                                    <span class="toggle-slider"></span>
                                </label>
                            </div>
                        </div>

                        <div class="save-row">
                            <button type="submit" class="bk-btn bk-btn-primary" id="btn-save-settings">
                                <span class="material-symbols-outlined">save</span> Lưu Quy Tắc Thiết Lập
                            </button>
                        </div>
                    </form>
                </div>

                <%-- ============================================================ --%>
                <%-- TAB 3: Bank Account Information                              --%>
                <%-- ============================================================ --%>
                <div id="panel-bank" class="ps-panel ${activeTab == 'bank' ? 'active' : ''}">
                    <div class="info-box">
                        <strong>🏦 Tài khoản ngân hàng công ty:</strong> Thông tin này sẽ được đính kèm trực tiếp vào hướng dẫn thanh toán của Khách hàng và mã QR chuyển khoản tự động.
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/admin/payment-settings" id="form-bank">
                        <input type="hidden" name="action" value="updateSettings"/>
                        <input type="hidden" name="tab"    value="bank"/>

                        <div class="bk-form-grid">
                            <c:set var="bankName" value="${settingMap['BANK_NAME'] != null ? settingMap['BANK_NAME'].policyValue : ''}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">Tên Ngân Hàng (Bên nhận)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">account_balance</span>
                                    <input type="text" class="bk-form-input" id="f-bankname" name="policy_BANK_NAME"
                                           value="${bankName}" placeholder="Ví dụ: Vietcombank, Techcombank" maxlength="100" required>
                                </div>
                            </div>

                            <c:set var="bankBranch" value="${settingMap['BANK_BRANCH'] != null ? settingMap['BANK_BRANCH'].policyValue : ''}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">Chi Nhánh Quản Lý</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">storefront</span>
                                    <input type="text" class="bk-form-input" id="f-bankbranch" name="policy_BANK_BRANCH"
                                           value="${bankBranch}" placeholder="Ví dụ: Chi nhánh Thạch Thất" maxlength="200" required>
                                </div>
                            </div>

                            <c:set var="accNumber" value="${settingMap['BANK_ACCOUNT_NUMBER'] != null ? settingMap['BANK_ACCOUNT_NUMBER'].policyValue : ''}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">Số Tài Khoản Nhận</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">pin</span>
                                    <input type="text" class="bk-form-input" id="f-accnumber" name="policy_BANK_ACCOUNT_NUMBER"
                                           value="${accNumber}" placeholder="Ví dụ: 010987654321" maxlength="30" required>
                                </div>
                            </div>

                            <c:set var="accName" value="${settingMap['BANK_ACCOUNT_NAME'] != null ? settingMap['BANK_ACCOUNT_NAME'].policyValue : ''}"/>
                            <div class="bk-form-group">
                                <label class="bk-form-label">Tên Chủ Tài Khoản (Viết hoa không dấu)</label>
                                <div class="bk-form-input-wrap">
                                    <span class="material-symbols-outlined">person</span>
                                    <input type="text" class="bk-form-input" id="f-accname" name="policy_BANK_ACCOUNT_NAME"
                                           value="${accName}" placeholder="Ví dụ: CONG TY CP CARPRO VIET NAM" maxlength="200" required>
                                </div>
                            </div>
                        </div>

                        <%-- Premium Card Preview - Synced with Deep Navy Theme --%>
                        <div style="margin-top:28px;">
                            <div class="section-title">
                                <span class="material-symbols-outlined">credit_card</span>
                                <span>Xem trước Thẻ chuyển khoản của Doanh nghiệp</span>
                            </div>
                            <div style="max-width:400px; border:1px solid rgba(255,255,255,0.1); border-radius:18px; padding:28px; background:linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%); color:#fff; box-shadow:var(--shadow-hover); position:relative; overflow:hidden;">
                                <%-- Subtle background graphics to make it look extremely premium --%>
                                <div style="position:absolute; width:150px; height:150px; border-radius:50%; background:rgba(255,255,255,0.03); top:-50px; right:-50px;"></div>
                                <div style="position:absolute; width:100px; height:100px; border-radius:50%; background:rgba(255,255,255,0.02); bottom:-20px; left:-20px;"></div>
                                
                                <div style="font-size:11px; opacity:.8; text-transform:uppercase; letter-spacing:1.5px; margin-bottom:6px; font-weight:500;">Thẻ Nhận Tiền Doanh Nghiệp</div>
                                <div id="preview-bankname" style="font-size:20px; font-weight:700; margin-bottom:24px; letter-spacing:-0.5px;">${not empty bankName ? bankName : 'Tên ngân hàng'}</div>
                                <div style="font-size:11px; opacity:.7; margin-bottom:4px;">Số Tài Khoản</div>
                                <div id="preview-accnumber" style="font-size:24px; font-weight:800; letter-spacing:3px; margin-bottom:12px; font-family:'Inter', sans-serif;">${not empty accNumber ? accNumber : '•••• •••• ••••'}</div>
                                <div id="preview-accname" style="font-size:15px; font-weight:700; opacity:.95; text-transform:uppercase;">${not empty accName ? accName : 'Chủ tài khoản'}</div>
                                <div id="preview-branch" style="font-size:12px; opacity:.7; margin-top:4px;">${not empty bankBranch ? bankBranch : 'Chi nhánh'}</div>
                            </div>
                        </div>

                        <div class="save-row">
                            <button type="submit" class="bk-btn bk-btn-primary" id="btn-save-bank">
                                <span class="material-symbols-outlined">save</span> Lưu Thông Tin Ngân Hàng
                            </button>
                        </div>
                    </form>
                </div>

            </div><%-- /padding--%>
        </div><%-- /card --%>
    </div><%-- /ps-page --%>
</div><%-- /page-content --%>

<script>
// ─── Tab switching ────────────────────────────────────────────────────────────
function switchTab(name, btn) {
    document.querySelectorAll('.ps-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.ps-tab').forEach(b => b.classList.remove('active'));
    document.getElementById('panel-' + name).classList.add('active');
    btn.classList.add('active');
}

// ─── Method card toggle: clicking the whole card flips the checkbox ───────────
function toggleMethod(key) {
    const cb = document.getElementById(key);
    if (cb) { cb.checked = !cb.checked; updateCard(cb); }
}

// Updates card style when toggle changes
function updateCard(checkbox) {
    const card   = checkbox.closest('.method-card');
    const badge  = card.querySelector('.method-status');
    const on     = checkbox.checked;
    card.classList.toggle('enabled',  on);
    card.classList.toggle('disabled', !on);
    badge.textContent = on ? 'BẬT' : 'TẮT';
    badge.className   = 'method-status ' + (on ? 'status-on' : 'status-off');
}

// ─── Live preview for bank tab ────────────────────────────────────────────────
function livePreview(inputId, previewId) {
    const inp = document.getElementById(inputId);
    const prv = document.getElementById(previewId);
    if (inp && prv) inp.addEventListener('input', () => { prv.textContent = inp.value || '—'; });
}
livePreview('f-bankname',   'preview-bankname');
livePreview('f-accnumber',  'preview-accnumber');
livePreview('f-accname',    'preview-accname');
livePreview('f-bankbranch', 'preview-branch');

// ─── Confirm before saving ───────────────────────────────────────────────────
document.querySelectorAll('form[id^="form-"]').forEach(form => {
    form.addEventListener('submit', function(e) {
        const ok = confirm('Bạn có chắc muốn lưu các thay đổi cài đặt thanh toán?');
        if (!ok) e.preventDefault();
    });
});

// ─── Checkbox for partial payment: store as "true"/"false" string ─────────────
const partialCb = document.getElementById('f-partial');
if (partialCb) {
    partialCb.addEventListener('change', function() {
        this.value = this.checked ? 'true' : 'false';
    });
}

// ─── Toast control script ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    const successToast = document.getElementById('toast-success');
    const errorToast = document.getElementById('toast-error');
    
    if (successToast) {
        setTimeout(() => successToast.classList.add('show'), 100);
        setTimeout(() => fadeOutToast(successToast), 4000);
    }
    if (errorToast) {
        setTimeout(() => errorToast.classList.add('show'), 100);
        setTimeout(() => fadeOutToast(errorToast), 5000);
    }
});

function closeToast(id) {
    const toast = document.getElementById(id);
    if (toast) {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 400);
    }
}

function fadeOutToast(toast) {
    if (toast && toast.parentNode) {
        toast.classList.add('fade-out');
        setTimeout(() => toast.remove(), 300);
    }
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
