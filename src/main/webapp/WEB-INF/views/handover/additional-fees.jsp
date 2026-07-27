<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Bảng tính Phụ phí Phát sinh"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="${pageContext.request.contextPath}/returns">Nhận lại xe</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Xem biên bản nhận lại xe</span>
        </div>
        <h2>Bảng tính Phụ thu & Máy tính Phụ phí</h2>
        <p>Hệ thống tự động tra cứu chính sách phạt trễ giờ, quá số km, vệ sinh và hư hỏng của nhà xe khi bàn giao xe. (BR-07)</p>
    </div>
</div>

<form method="post" action="${pageContext.request.contextPath}/additional-fees">
    <input type="hidden" name="bookingId" value="${bookingId}">
    <input type="hidden" name="vehicleId" value="${vehicleId}">
    <div class="bk-detail-grid">
        <%-- LEFT: Máy tính phụ thu tương tác --%>
        <div>
            <div class="bk-card">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">calculate</span> Máy tính giả lập Phụ thu nhận xe
                </div>

                <div class="bk-form-grid" style="gap:20px;">
                    <div class="bk-form-group">
                        <label class="bk-form-label">Số giờ trả xe trễ hạn (Giờ)</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">schedule</span>
                            <input type="number" id="lateHours" name="lateHours" class="bk-form-input" value="${returns.lateHours}" min="0" style="padding-left:40px;" />
                        </div>
                        <div id="err-lateHours" style="display:none; color:var(--error); font-size:12px; font-weight:600; margin-top:4px;">️Không được nhập số âm!</div>
                        <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: <fmt:formatNumber value="${lateFeePerHour}" pattern="#,##0"/>đ / giờ)</span>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Quãng đường đi vượt định mức (km)</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">speed</span>
                            <input type="number" id="extraKmFee" name="extraKmFee"
                                   class="bk-form-input"
                                   value="${returns.extraKmFee}"
                                   min="0" style="padding-left:40px;" />
                        </div>
                        <div id="err-extraKmFee" style="display:none; color:var(--error); font-size:12px; font-weight:600; margin-top:4px;">️Không được nhập số âm!</div>
                        <c:if test="${not empty actualKm || not empty kmLimit}">
                            <div style="margin-top:8px; padding:10px 12px; background:var(--surface-container); border-radius:8px; border-left:3px solid var(--primary); font-size:12px; line-height:1.7; color:var(--on-surface-variant);">
                                <strong style="color:var(--primary); font-size:13px;">📊 Phân tích km chuyến đi</strong><br/>
                                Km thực tế đi: <strong id="calc-actual-km">${not empty actualKm ? actualKm : 0} km</strong> &nbsp;|&nbsp; Định mức: <strong>${not empty kmLimit ? kmLimit : 0} km</strong><br/>
                                Km vượt tổng: <strong id="calc-extra-total">${not empty actualExtraKm ? actualExtraKm : (returns.extraKmFee)} km</strong><br/>
                                Km vượt đã thu lúc đặt (est. ${not empty estimatedKm ? estimatedKm : 0} km): <strong style="color:var(--success);">-${not empty alreadyPaidExtraKm ? alreadyPaidExtraKm : 0} km</strong><br/>
                                <strong style="color:var(--error);">→ Km vượt cần thu thêm: <span id="calc-extra-additional">${returns.extraKmFee} km</span></strong>
                            </div>
                        </c:if>
                        <span style="font-size:12px;color:var(--outline);margin-top:2px;">(Quy định phạt: <fmt:formatNumber value="${extraKmFeeRate}" pattern="#,##0"/>đ / km)</span>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Vệ sinh khoang xe dơ bẩn</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">local_laundry_service</span>
                            <select id="cleaningFee" name="cleaningFee" class="bk-form-select">
                                <option value="0">Sạch sẽ - 0đ</option>
                                <option value="300000">Quá bẩn / Mùi thuốc lá - 300,000đ</option>
                                <option value="600000">Cực kỳ dơ / Nôn trớ - 600,000đ</option>
                            </select>
                        </div>
                    </div>

                    <div class="bk-form-group">
                        <label class="bk-form-label">Bồi thường hư hỏng</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">handyman</span>
                            <input type="number" id="damageFee" name="damageFee" class="bk-form-input" value="${returns.damageFee}" min="0" style="padding-left:40px;" placeholder="Nhập số tiền..." />
                        </div>
                        <div id="err-damageFee" style="display:none; color:var(--error); font-size:12px; font-weight:600; margin-top:4px;">️Không được nhập số âm!</div>
                    </div>
                    <div class="bk-form-group">
                        <label class="bk-form-label">Bồi thường phụ kiện bị mất</label>
                        <div class="bk-form-input-wrap">
                            <span class="material-symbols-outlined">handyman</span>
                            <input type="number" id="lostItemFee" name="lostItemFee" class="bk-form-input" value="${returns.lostItemFee}" min="0" style="padding-left:40px;" placeholder="Nhập số tiền..." />
                        </div>
                        <div id="err-lostItemFee" style="display:none; color:var(--error); font-size:12px; font-weight:600; margin-top:4px;">️Không được nhập số âm!</div>
                    </div>

                    <input type="hidden" id="totalAdditionalFee" name="totalAdditionalFee" value="0">
                    <input type="hidden" id="deposit" name="deposit" value="0">

                </div>
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
                    <div class="bk-detail-row">
                        <span class="label">Phí bồi thường phụ kiện bị mất</span>
                        <span class="value" id="resLostItem">0đ</span>
                    </div>
                </div>

                <div class="bk-summary-total" style="border-top: 1px solid var(--outline-variant); padding-top: 12px; margin-top: 12px;">
                    <span class="label" style="font-weight: 500;">Tổng tiền thuê ban đầu</span>
                    <span class="value" style="font-weight: 600;"><fmt:formatNumber value="${booking.totalAmount - booking.depositAmount}" pattern="#,##0"/>đ</span>
                </div>
                <div class="bk-detail-row" style="font-size: 13px; opacity: 0.8; margin-top: -8px; margin-bottom: 8px;">
                    <span class="label">Trong đó tiền cọc:</span>
                    <span class="value"><fmt:formatNumber value="${booking.depositAmount}" pattern="#,##0"/>đ</span>
                </div>

                <div class="bk-summary-total">
                    <span class="label" style="font-weight: 500;">Khách đã thanh toán</span>
                    <span class="value" style="font-weight: 600; color: var(--success);"><fmt:formatNumber value="${not empty totalPaid ? totalPaid : 0}" pattern="#,##0"/>đ</span>
                </div>

                <div class="bk-summary-total">
                    <span class="label" style="font-weight: 500;">Tổng phụ thu phát sinh</span>
                    <span class="value" id="resTotal" style="font-weight: 600; color: var(--error);">0đ</span>
                </div>

                <div id="rowRefund" class="bk-summary-total" style="border-top: 1.5px dashed var(--outline-variant); padding-top: 16px; margin-top: 16px;">
                    <span class="label" style="font-size: 16px; font-weight: 700;">Số tiền hoàn lại</span>
                    <span class="value" id="resRefund" style="color:var(--success);font-size:20px;font-weight:800;">0đ</span>
                </div>

                <div id="rowExtraPayment" class="bk-summary-total" style="border-top: 1.5px dashed var(--outline-variant); padding-top: 16px; margin-top: 16px; display: none;">
                    <span class="label" style="font-size: 16px; font-weight: 700; color: var(--error);">Số tiền cần thanh toán thêm</span>
                    <span class="value" id="resExtraPayment" style="color:var(--error);font-size:20px;font-weight:800;">0đ</span>
                </div>

                <div>${notification}</div>

                <div style="margin-top:24px;display:flex;flex-direction:column;gap:12px;">
                    <button type="submit" id="btnSaveFee" name="action" value="save" class="bk-btn bk-btn-primary" style="width:100%;justify-content:center;font-weight:600;">
                        <span class="material-symbols-outlined">check_circle</span> Áp dụng
                    </button>
                    <a href="${pageContext.request.contextPath}/returns/detail?bookingId=${bookingId}&vehicleId=${vehicleId}" class="bk-btn bk-btn-outline" style="width:100%;justify-content:center;">
                        <span class="material-symbols-outlined">arrow_back</span> Hủy bỏ
                    </a>
                </div>
            </div>
        </div>
    </div>
</form>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var savedCleaning = parseFloat("${returns.cleaningFee}") || 0;
        document.getElementById("cleaningFee").value = savedCleaning.toString();

        // Real-time live calculation on every input/change event
        document.getElementById("cleaningFee").addEventListener("change", recalculateFees);
        document.getElementById("damageFee").addEventListener("input", recalculateFees);
        document.getElementById("lostItemFee").addEventListener("input", recalculateFees);
        document.getElementById("lateHours").addEventListener("input", recalculateFees);
        document.getElementById("extraKmFee").addEventListener("input", recalculateFees);

        function formatMoney(amount) {
            return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(amount).replace('₫', 'đ');
        }

        function recalculateFees() {
            var fields = ['lateHours', 'extraKmFee', 'damageFee', 'lostItemFee'];
            var hasNegative = false;

            fields.forEach(function (id) {
                var el = document.getElementById(id);
                var errEl = document.getElementById('err-' + id);
                if (el) {
                    var val = parseFloat(el.value);
                    if (!isNaN(val) && val < 0) {
                        hasNegative = true;
                        if (errEl) errEl.style.display = 'block';
                    } else {
                        if (errEl) errEl.style.display = 'none';
                    }
                }
            });

            var btnSave = document.getElementById('btnSaveFee');
            if (btnSave) {
                if (hasNegative) {
                    btnSave.disabled = true;
                    btnSave.style.opacity = '0.5';
                    btnSave.style.cursor = 'not-allowed';
                } else {
                    btnSave.disabled = false;
                    btnSave.style.opacity = '1';
                    btnSave.style.cursor = 'pointer';
                }
            }

            var lateHours = Math.max(0, parseFloat(document.getElementById('lateHours').value) || 0);
            var extraKmFee = Math.max(0, parseFloat(document.getElementById('extraKmFee').value) || 0);
            var cleaning = parseFloat(document.getElementById('cleaningFee').value) || 0;
            var damage = Math.max(0, parseFloat(document.getElementById('damageFee').value) || 0);
            var lostItem = Math.max(0, parseFloat(document.getElementById('lostItemFee').value) || 0);

            var rateLate = parseFloat("${lateFeePerHour}") || 100000;
            var lateFee = lateHours * rateLate;

            var rateKm = parseFloat("${extraKmFeeRate}") || 5000;
            var kmFee = extraKmFee * rateKm;

            var totalAdditional = lateFee + kmFee + cleaning + damage + lostItem;

            var depositAmt = parseFloat("${booking.depositAmount}") || 0;
            var initialTotal = (parseFloat("${booking.totalAmount}") || 0) - depositAmt;
            var totalPaid = parseFloat("${not empty totalPaid ? totalPaid : 0}");
            if (totalPaid <= 0) {
                totalPaid = depositAmt;
            }

            var grandTotal = initialTotal + totalAdditional;

            var refund = 0;
            var extraPayment = 0;

            if (totalPaid >= grandTotal) {
                refund = totalPaid - grandTotal;
            } else {
                extraPayment = grandTotal - totalPaid;
            }

            document.getElementById('resLate').textContent = formatMoney(lateFee);
            document.getElementById('resKm').textContent = formatMoney(kmFee);
            document.getElementById('resClean').textContent = formatMoney(cleaning);
            document.getElementById('resDamage').textContent = formatMoney(damage);
            document.getElementById('resLostItem').textContent = formatMoney(lostItem);

            document.getElementById('resTotal').textContent = formatMoney(totalAdditional);

            if (extraPayment > 0) {
                document.getElementById('rowRefund').style.display = 'none';
                document.getElementById('rowExtraPayment').style.display = 'flex';
                document.getElementById('resExtraPayment').textContent = formatMoney(extraPayment);
            } else {
                document.getElementById('rowRefund').style.display = 'flex';
                document.getElementById('rowExtraPayment').style.display = 'none';
                document.getElementById('resRefund').textContent = formatMoney(refund);
            }

            document.getElementById('totalAdditionalFee').value = totalAdditional;
        }

        recalculateFees();
    });
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
