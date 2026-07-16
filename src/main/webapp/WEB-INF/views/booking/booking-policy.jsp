<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chính Sách Đặt Xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Chính sách thuê xe</h2>
        <p>Các quy định và điều khoản thuê xe tại CarPro.</p>
    </div>
</div>

<%-- Policy Cards --%>
<div style="display:flex;flex-direction:column;gap:24px;">

    <div class="bk-card" style="position:relative;overflow:hidden;">
        <div style="position:absolute;top:-20px;right:-20px;opacity:0.04;">
            <span class="material-symbols-outlined" style="font-size:180px;">policy</span>
        </div>
        <div class="bk-card-title" style="color:var(--primary);">
            <span class="material-symbols-outlined">gavel</span> Điều kiện thuê xe
        </div>
        <div class="bk-policy-grid" style="position:relative;z-index:1;">
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--primary);"></span> Yêu cầu khách hàng
                </h4>
                <ul class="bk-policy-list">
                    <li>Khách hàng phải từ đủ 21 tuổi trở lên.</li>
                    <li>Có giấy phép lái xe hợp lệ (còn hạn ít nhất 6 tháng).</li>
                    <li>Cung cấp CCCD/CMND bản gốc khi nhận xe.</li>
                    <li>Đặt cọc theo quy định trước khi nhận xe.</li>
                </ul>
            </div>
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--primary);"></span> Trách nhiệm sử dụng
                </h4>
                <ul class="bk-policy-list">
                    <li>Không sử dụng xe vào mục đích phi pháp.</li>
                    <li>Không cho người khác sử dụng xe nếu chưa được phép.</li>
                    <li>Trả xe đúng thời hạn và địa điểm thỏa thuận.</li>
                    <li>Thông báo ngay khi xe gặp sự cố hoặc tai nạn.</li>
                </ul>
            </div>
        </div>
    </div>

    <div class="bk-card">
        <div class="bk-card-title" style="color:var(--primary);">
            <span class="material-symbols-outlined">edit_calendar</span> Chính sách thay đổi & Hủy bỏ
        </div>
        <div class="bk-policy-grid">
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--primary);"></span> Thay đổi lịch trình
                </h4>
                <ul class="bk-policy-list">
                    <li>Miễn phí thay đổi trước 24h kể từ giờ nhận xe.</li>
                    <li>Thay đổi trong vòng 24h tính phí 10% giá trị ngày đầu tiên.</li>
                    <li>Tối đa 02 lần thay đổi cho mỗi đơn thuê.</li>
                    <li>Việc thay đổi phụ thuộc vào tình trạng xe sẵn có.</li>
                </ul>
            </div>
            <div>
                <h4 style="font-weight:600;color:var(--error);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--error);"></span> Hủy đơn thuê
                </h4>
                <ul class="bk-policy-list">
                    <li>Hủy trước 48h: Hoàn tiền 100% (trừ phí chuyển khoản).</li>
                    <li>Hủy từ 24h đến 48h: Hoàn tiền 50%.</li>
                    <li>Hủy dưới 24h: Không áp dụng hoàn tiền cọc.</li>
                    <li>Booking PENDING có thể hủy miễn phí bất cứ lúc nào.</li>
                </ul>
            </div>
        </div>
    </div>

    <div class="bk-card">
        <div class="bk-card-title" style="color:var(--primary);">
            <span class="material-symbols-outlined">payments</span> Chính sách giá & Thanh toán
        </div>
        <div class="bk-policy-grid">
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--primary);"></span> Giá thuê
                </h4>
                <ul class="bk-policy-list">
                    <li>Giá thuê tính theo ngày, hiển thị trên trang chi tiết xe.</li>
                    <li>Thuế &amp; phí dịch vụ: ${not empty taxRate ? taxRate : 10}% giá thuê cơ bản.</li>
                    <li>Giá có thể thay đổi theo mùa và nhu cầu.</li>
                </ul>
            </div>
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:var(--primary);"></span> Thanh toán & Cọc
                </h4>
                <ul class="bk-policy-list">
                    <li>Tiền cọc được thu khi booking được xác nhận.</li>
                    <li>Cọc được hoàn lại sau khi trả xe (trừ phí phát sinh).</li>
                    <li>Hỗ trợ thanh toán: Tiền mặt, chuyển khoản ngân hàng.</li>
                </ul>
            </div>
        </div>
    </div>

    <div class="bk-card">
        <div class="bk-card-title" style="color:var(--primary);">
            <span class="material-symbols-outlined">warning</span> Phí phát sinh khi trả xe
        </div>
        <div class="bk-policy-grid">
            <div>
                <ul class="bk-policy-list">
                    <li><strong>Trả trễ:</strong> Phí tính theo giờ/ngày trễ.</li>
                    <li><strong>Vượt km:</strong> Phí = (Km vượt) × Đơn giá/km.</li>
                    <li><strong>Hư hỏng:</strong> Theo biên bản kiểm tra khi trả xe.</li>
                </ul>
            </div>
            <div>
                <ul class="bk-policy-list">
                    <li><strong>Vệ sinh:</strong> Phí phát sinh nếu xe quá bẩn.</li>
                    <li><strong>Mất đồ:</strong> Bồi thường theo giá trị vật phẩm.</li>
                    <li><strong>Nhiên liệu:</strong> Trả xe với mức nhiên liệu tương đương khi nhận.</li>
                </ul>
            </div>
        </div>
    </div>

    <%-- No-show Policy Card --%>
    <div class="bk-card" style="position:relative;overflow:hidden;">
        <div style="position:absolute;top:-20px;right:-20px;opacity:0.04;">
            <span class="material-symbols-outlined" style="font-size:180px;">person_off</span>
        </div>
        <div class="bk-card-title" style="color:#c62828;">
            <span class="material-symbols-outlined">person_off</span> Chính sách No-show (Không đến nhận xe)
        </div>
        <div class="bk-policy-grid" style="position:relative;z-index:1;">
            <div>
                <h4 style="font-weight:600;color:#c62828;margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:#c62828;"></span> Định nghĩa No-show
                </h4>
                <ul class="bk-policy-list">
                    <li>Khách hàng <strong>không đến nhận xe</strong> trong vòng <strong>2 giờ</strong> kể từ thời điểm nhận xe theo hợp đồng mà không có thông báo trước.</li>
                    <li>Booking sẽ tự động chuyển sang trạng thái <strong>"No-show"</strong> sau thời gian quy định.</li>
                </ul>
            </div>
            <div>
                <h4 style="font-weight:600;color:#c62828;margin-bottom:12px;display:flex;align-items:center;gap:8px;">
                    <span style="width:8px;height:8px;border-radius:50%;background:#c62828;"></span> Hậu quả No-show
                </h4>
                <ul class="bk-policy-list">
                    <li><strong>Mất toàn bộ tiền cọc</strong> — Tiền cọc đã thanh toán sẽ không được hoàn lại.</li>
                    <li><strong>Hạn chế đặt xe:</strong> Tài khoản có thể bị đánh dấu cảnh báo nếu vi phạm No-show nhiều lần.</li>
                    <li><strong>Liên hệ hỗ trợ:</strong> Nếu có lý do bất khả kháng, vui lòng liên hệ hotline trước giờ nhận xe.</li>
                </ul>
            </div>
        </div>
    </div>

    <%-- Dynamic System Configuration Section --%>
    <c:if test="${not empty bookingPolicies || not empty pricingPolicies || not empty penaltyPolicies}">
    <div class="bk-card" style="margin-top: 8px;">
        <div class="bk-card-title" style="color:var(--primary); margin-bottom: 16px;">
            <span class="material-symbols-outlined">settings_suggest</span> Thông số cấu hình hệ thống (Thời gian thực)
        </div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 32px;">
            <c:if test="${not empty bookingPolicies}">
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;border-bottom:2px solid var(--primary-container);padding-bottom:6px;">Quy định đặt xe</h4>
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                    <c:forEach var="p" items="${bookingPolicies}">
                        <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.05);">
                            <td style="padding: 8px 0; color: var(--on-surface-variant);">${p.description}</td>
                            <td style="padding: 8px 0; font-weight: 600; text-align: right; color: var(--primary);">${p.policyValue}</td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            </c:if>
            <c:if test="${not empty pricingPolicies}">
            <div>
                <h4 style="font-weight:600;color:var(--primary);margin-bottom:12px;border-bottom:2px solid var(--primary-container);padding-bottom:6px;">Biểu phí & Đơn giá</h4>
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                    <c:forEach var="p" items="${pricingPolicies}">
                        <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.05);">
                            <td style="padding: 8px 0; color: var(--on-surface-variant);">${p.description}</td>
                            <td style="padding: 8px 0; font-weight: 600; text-align: right; color: var(--primary);">${p.policyValue}</td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            </c:if>
            <c:if test="${not empty penaltyPolicies}">
            <div>
                <h4 style="font-weight:600;color:var(--warning);margin-bottom:12px;border-bottom:2px solid rgba(255, 193, 7, 0.2);padding-bottom:6px;">Chế tài & Phạt vi phạm</h4>
                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                    <c:forEach var="p" items="${penaltyPolicies}">
                        <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.05);">
                            <td style="padding: 8px 0; color: var(--on-surface-variant);">${p.description}</td>
                            <td style="padding: 8px 0; font-weight: 600; text-align: right; color: var(--warning);">${p.policyValue}</td>
                        </tr>
                    </c:forEach>
                </table>
            </div>
            </c:if>
        </div>
    </div>
    </c:if>

    <%-- Empty State: No policy data --%>
    <c:if test="${empty bookingPolicies && empty pricingPolicies && empty penaltyPolicies}">
    <div class="bk-card" style="text-align: center; padding: 40px;">
        <span class="material-symbols-outlined" style="font-size: 64px; color: var(--on-surface-variant); opacity: 0.5;">info</span>
        <h3 style="margin: 16px 0 8px; color: var(--on-surface);">Chưa có thông số cấu hình</h3>
        <p style="color: var(--on-surface-variant);">Thông tin cấu hình chính sách hệ thống tạm thời không khả dụng. Vui lòng quay lại sau.</p>
    </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>

