<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Thanh toán chuyển khoản QR"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/bookings/detail?id=${payment.bookingId}">Chi tiết đơn thuê</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Thanh toán chuyển khoản</span>
        </div>
        <h2>Thanh toán chuyển khoản VietQR</h2>
        <p>Quét mã QR bằng ứng dụng ngân hàng của bạn để hoàn tất thanh toán tự động.</p>
    </div>
</div>

<div class="page-content" style="max-width: 800px; margin: 0 auto; padding-top: 0; text-align: center;">

    <div class="bk-card" style="padding: 32px; border-radius: 16px; box-shadow: var(--shadow-lg); background: var(--bg-white);">
        
        <!-- Dynamic Alert Panel (for underpayment/overpayment warnings) -->
        <div id="dynamic-alert" style="display: none; margin-bottom: 24px; padding: 16px; border-radius: 12px; text-align: left; font-size: 13px; line-height: 1.5;">
        </div>

        <!-- Awaiting payment state -->
        <div id="awaiting-panel">
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; margin-bottom: 24px;">
                <div class="checkout-spinner" style="margin-bottom: 16px;"></div>
                <h3 style="font-size: 20px; font-weight: 700; color: var(--primary); margin: 0 0 4px 0;">Đang đợi thanh toán...</h3>
                <p style="font-size: 13px; color: var(--text-secondary); margin: 0;">Hệ thống đang kiểm tra tự động mỗi 5 giây. Không cần tải lại trang.</p>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px; align-items: start; text-align: left; margin-top: 16px; border-top: 1px solid var(--outline-variant); padding-top: 24px;">
                
                <!-- QR Code View -->
                <div style="text-align: center; border-right: 1px solid var(--outline-variant); padding-right: 16px;">
                    <c:choose>
                        <c:when test="${not empty bankBin && not empty bankAccountNumber}">
                            <img id="qrImage"
                                 src="https://img.vietqr.io/image/${bankBin}-${bankAccountNumber}-compact2.png?amount=${payment.amount.intValue()}&addInfo=${transferDesc}&accountName=${bankAccountName}"
                                 alt="VietQR code"
                                 style="width: 240px; height: 240px; border-radius: 12px; border: 1.5px solid var(--outline-variant); box-shadow: var(--shadow-sm);"/>
                            <div style="font-size: 12px; color: var(--text-secondary); margin-top: 8px; font-weight: 600;">MÃ QR THANH TOÁN TỰ ĐỘNG</div>
                        </c:when>
                        <c:otherwise>
                            <div style="width: 240px; height: 240px; border-radius: 12px; border: 2px dashed var(--outline-variant); display: flex; align-items: center; justify-content: center; flex-direction: column; color: var(--text-secondary); font-size: 13px; margin: 0 auto;">
                                <span class="material-symbols-outlined" style="font-size:40px; margin-bottom:8px;">account_balance</span>
                                Chưa cấu hình ngân hàng
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Transaction Details Info -->
                <div style="display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 14px; font-weight: 700; color: var(--primary); text-transform: uppercase; margin-bottom: 8px;">Thông tin tài khoản</div>
                    
                    <div style="display:flex; justify-content:space-between; font-size: 13px;">
                        <span style="color: var(--text-secondary); white-space: nowrap;">Ngân hàng:</span>
                        <strong style="text-align: right;">${bankName} <c:if test="${not empty bankBranch}">(${bankBranch})</c:if></strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; font-size: 13px;">
                        <span style="color: var(--text-secondary); white-space: nowrap;">Số tài khoản:</span>
                        <strong style="color: var(--primary); font-family: monospace; font-size: 14px;">${bankAccountNumber}</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; font-size: 13px;">
                        <span style="color: var(--text-secondary); white-space: nowrap;">Chủ tài khoản:</span>
                        <strong style="text-align: right;">${bankAccountName}</strong>
                    </div>
                    <div style="border-top: 1px dashed var(--outline-variant); margin: 6px 0;"></div>
                    
                    <div style="display:flex; justify-content:space-between; font-size: 13px;">
                        <span style="color: var(--text-secondary); white-space: nowrap;">Số tiền cần chuyển:</span>
                        <strong style="color: #2F5ACD; font-size: 15px;"><fmt:formatNumber value="${payment.amount}" pattern="#,##0"/> đ</strong>
                    </div>
                    
                    <div style="background: #EBF8FF; border-radius: 8px; padding: 12px; margin-top: 8px;">
                        <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 4px; font-weight: 700; text-transform: uppercase;">Nội dung chuyển khoản (Bắt buộc):</div>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <code id="transferDescDisplay" style="font-size:14px; font-weight:800; color:#1A365D; background:#BEE3F8; padding: 4px 10px; border-radius:6px; font-family: monospace;">${transferDesc}</code>
                            <button type="button" onclick="copyTransferDesc()" style="border:none; background:none; cursor:pointer; color:var(--primary); font-size:12px; display:flex; align-items:center; gap:2px; font-weight: 600;">
                                <span class="material-symbols-outlined" style="font-size:16px;">content_copy</span> Sao chép
                            </button>
                        </div>
                    </div>
                    <p style="font-size: 11px; color: var(--error); margin: 6px 0 0 0; line-height: 1.4; text-align: left;">⚠️ Chuyển đúng số tiền và nội dung chuyển khoản để giao dịch được xác nhận tự động lập tức.</p>
                </div>
            </div>
        </div>

        <!-- Success state -->
        <div id="success-panel" style="display: none; padding: 16px 0;">
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 16px;">
                <div class="success-checkmark">
                    <span class="material-symbols-outlined" style="font-size: 64px; color: #fff;">check</span>
                </div>
                <h2 style="color: #039C74; font-weight: 800; margin: 8px 0 4px 0;">Thanh Toán Thành Công!</h2>
                <p style="color: var(--text-secondary); font-size: 14px; margin: 0 0 16px 0;">Hệ thống đã tự động ghi nhận thanh toán của bạn.</p>
                <div style="font-size: 13px; color: var(--text-secondary);">Đang chuyển hướng về chi tiết đơn đặt xe...</div>
            </div>
        </div>

    </div>

    <div style="margin-top: 24px; text-align: center;">
        <a href="${pageContext.request.contextPath}/bookings/detail?id=${payment.bookingId}" class="bk-btn bk-btn-outline" style="padding: 10px 24px;">
            <span class="material-symbols-outlined">arrow_back</span> Quay lại đơn đặt xe
        </a>
    </div>

</div>

<script>
function copyTransferDesc() {
    var code = document.getElementById('transferDescDisplay');
    if (code) {
        navigator.clipboard.writeText(code.textContent.trim()).then(function() {
            var btn = code.nextElementSibling;
            if (btn) { 
                var orig = btn.innerHTML; 
                btn.innerHTML = '✓ Đã chép'; 
                setTimeout(function(){ btn.innerHTML = orig; }, 1500); 
            }
        });
    }
}

// Config variables for QR rebuilding
const bankBin = '${bankBin}';
const bankAccountNumber = '${bankAccountNumber}';
const bankAccountName = encodeURIComponent('${bankAccountName}');
const transferDesc = '${transferDesc}';

// Polling status
const paymentId = ${payment.paymentId};
const bookingId = ${payment.bookingId};
const checkUrl = '${pageContext.request.contextPath}/payments/status?paymentId=' + paymentId;

const pollInterval = setInterval(function() {
    fetch(checkUrl)
        .then(response => response.json())
        .then(data => {
            if (data) {
                const amount = Number(data.amount);
                const amountPaid = Number(data.amountPaid);

                // 1. Underpayment (Partial Payment) State
                if (data.status === 'PENDING' && amountPaid > 0 && amountPaid < amount) {
                    const remaining = amount - amountPaid;
                    const alertDiv = document.getElementById('dynamic-alert');
                    if (alertDiv) {
                        alertDiv.style.display = 'block';
                        alertDiv.style.background = '#FFF9E6';
                        alertDiv.style.border = '1.5px solid #FCD34D';
                        alertDiv.style.color = '#B45309';
                        alertDiv.innerHTML = 
                            '<div style="display:flex; align-items:center; gap:8px; margin-bottom:6px; font-weight:700;">' +
                                '<span class="material-symbols-outlined" style="font-size:20px; color:#D97706;">warning</span>' +
                                '<span>Thanh toán thiếu (Chưa đủ số tiền yêu cầu)!</span>' +
                            '</div>' +
                            '<div style="margin-left:28px;">' +
                                'Bạn đã chuyển khoản: <strong style="color:#039C74;">' + amountPaid.toLocaleString('vi-VN') + ' đ</strong>.<br>' +
                                'Số tiền còn thiếu cần chuyển tiếp là: <strong style="font-size:15px; color:#C2410C;">' + remaining.toLocaleString('vi-VN') + ' đ</strong>.' +
                            '</div>';
                    }

                    // Dynamically rebuild the VietQR image source with the remaining amount
                    const qrImg = document.getElementById('qrImage');
                    if (qrImg) {
                        const newSrc = 'https://img.vietqr.io/image/' + bankBin + '-' + bankAccountNumber + '-compact2.png?amount=' + remaining + '&addInfo=' + transferDesc + '&accountName=' + bankAccountName;
                        if (qrImg.src !== newSrc) {
                            qrImg.src = newSrc;
                        }
                    }
                }

                // 2. Completed / Overpayment State
                if (data.status === 'COMPLETED') {
                    clearInterval(pollInterval);
                    
                    // Hide alerts and display success screen
                    const alertDiv = document.getElementById('dynamic-alert');
                    if (alertDiv) alertDiv.style.display = 'none';
                    
                    document.getElementById('awaiting-panel').style.display = 'none';
                    document.getElementById('success-panel').style.display = 'block';
                    
                    // Display specific warning on the success panel if they paid too much
                    if (amountPaid > amount) {
                        const overpaid = amountPaid - amount;
                        const successText = document.querySelector('#success-panel p');
                        if (successText) {
                            successText.innerHTML = 'Hệ thống tự động ghi nhận thanh toán của bạn.<br>' +
                            '<span style="color:#C53030; font-weight:700; display:inline-block; margin-top:12px; padding:8px 16px; background:#FFF5F5; border:1px solid #FC8181; border-radius:8px; text-align:left; font-size:13px; line-height:1.5;">' +
                                '⚠️ Bạn đã chuyển thừa ' + overpaid.toLocaleString('vi-VN') + ' đ.<br>' +
                                'Vui lòng liên hệ quầy để nhận lại tiền mặt từ nhân viên.' +
                            '</span>';
                        }
                    }
                    
                    // Redirect after 4s (to let them read the warning if present)
                    setTimeout(function() {
                        window.location.href = '${pageContext.request.contextPath}/bookings/detail?id=' + bookingId;
                    }, 4000);
                }
            }
        })
        .catch(err => {
            console.error('Error polling payment status:', err);
        });
}, 5000);
</script>

<style>
.checkout-spinner {
    width: 48px;
    height: 48px;
    border: 4.5px solid var(--outline-variant);
    border-top: 4.5px solid #2F5ACD;
    border-radius: 50%;
    animation: spin-checkout 1s linear infinite;
}
@keyframes spin-checkout {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}
.success-checkmark {
    width: 96px;
    height: 96px;
    border-radius: 50%;
    background: #05CD99;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(5,205,153,0.3);
    animation: scale-up-check 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) both;
}
@keyframes scale-up-check {
    0% { transform: scale(0); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
