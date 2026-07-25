<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"  %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Ghi nhận giao dịch"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Thanh toán & Giao dịch</span>
        </div>
        <c:choose>
            <c:when test="${not empty booking}">
                <h2>Ghi nhận giao dịch</h2>
                <p>Cập nhật trạng thái tài chính cho đơn thuê <strong style="color:var(--primary);">#BK-${booking.bookingId}</strong></p>
            </c:when>
            <c:otherwise>
                <h2>Nhật Ký Giao Dịch & Lịch Sử Thanh Toán</h2>
                <p>Xem toàn bộ lịch sử thanh toán đặt cọc, thanh toán thuê xe và phụ phí trên hệ thống.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- Alerts/Toasts --%>
<c:if test="${not empty sessionScope.paymentSuccess}">
    <div class="bk-alert bk-alert-success" style="margin-bottom: 24px;">
        <span class="material-symbols-outlined">check_circle</span> ${sessionScope.paymentSuccess}
    </div>
    <c:remove var="paymentSuccess" scope="session"/>
</c:if>
<c:if test="${not empty sessionScope.paymentError}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 24px;">
        <span class="material-symbols-outlined">warning</span> ${sessionScope.paymentError}
    </div>
    <c:remove var="paymentError" scope="session"/>
</c:if>
<c:if test="${not empty errorMsg}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 24px;">
        <span class="material-symbols-outlined">warning</span> ${errorMsg}
    </div>
</c:if>

<div class="page-content" style="max-width: 1200px; margin: 0 auto; padding-top: 0;">
    
    <c:choose>
        <%-- CASE 1: SPECIFIC BOOKING TRANSACTION RECORDING --%>
        <c:when test="${not empty booking}">
            <%-- Overpayment alert --%>
            <c:if test="${excessAmount > 0}">
                <div class="bk-alert bk-alert-warning" style="margin-bottom: 24px; display: flex; align-items: center; gap: 12px; background: #FFF5F5; border: 1.5px solid #FC8181; border-radius: 12px; padding: 16px; color: #C53030;">
                    <span class="material-symbols-outlined" style="font-size: 24px; color: #E53E3E;">warning</span>
                    <div style="font-size: 14px; line-height: 1.5;">
                        <strong>Thông báo chuyển thừa:</strong> Hệ thống ghi nhận bạn đã chuyển thừa số tiền <strong><fmt:formatNumber value="${excessAmount}" pattern="#,##0"/> đ</strong>. Vui lòng liên hệ quầy giao dịch hoặc nhân viên để nhận lại tiền hoàn.
                    </div>
                </div>
            </c:if>

            <%-- Underpayment / Partial payment alert:
                 Only show to CUSTOMER when in the RENTAL stage and there is a partial rental payment.
                 Staff/Admin do not need this banner — they see the full payment summary on the right.
            --%>
            <c:if test="${sessionScope.currentUser.role == 'CUSTOMER' && depositPaid && !rentalPaid && totalPaid > booking.depositAmount && remainingAmount > 0}">
                <div class="bk-alert bk-alert-warning" style="margin-bottom: 24px; display: flex; align-items: center; gap: 12px; background: #FFF9E6; border: 1.5px solid #FCD34D; border-radius: 12px; padding: 16px; color: #B45309;">
                    <span class="material-symbols-outlined" style="font-size: 24px; color: #D97706;">info</span>
                    <div style="font-size: 14px; line-height: 1.5;">
                        <strong>Thông báo chuyển thiếu:</strong> Bạn đã thanh toán một phần tiền thuê (Đã nhận: <strong><fmt:formatNumber value="${totalPaid}" pattern="#,##0"/> đ</strong>). Vui lòng thanh toán thêm <strong><fmt:formatNumber value="${remainingAmount}" pattern="#,##0"/> đ</strong> còn lại để hoàn thành đơn thuê.
                    </div>
                </div>
            </c:if>

            <div class="bk-booking-grid" style="display: grid; grid-template-columns: 7fr 5fr; gap: 28px; align-items: start;">
                
                <%-- Left Column: Payment Form --%>
                <div class="bk-card" style="padding: 28px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--outline-variant); padding-bottom: 16px; margin-bottom: 24px;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span class="material-symbols-outlined" style="color: var(--primary); font-size: 24px;">payments</span>
                            <span style="font-size: 18px; font-weight: 700; color: var(--primary);">Thông tin thanh toán</span>
                        </div>
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/payments/record">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>
                        <input type="hidden" name="redirect" value="booking"/>
                        <c:if test="${not empty contract}">
                            <input type="hidden" name="contractId" value="${contract.contractId}"/>
                        </c:if>
                        
                        <input type="hidden" id="selectedPaymentType" name="paymentType" value="${not empty defaultPaymentType ? defaultPaymentType : 'DEPOSIT'}"/>

                        <div class="bk-form-group" style="margin-bottom: 24px;">
                            <label class="bk-form-label" style="font-weight: 700; margin-bottom: 10px; display: block;">Loại thanh toán</label>
                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 12px;">
                                
                                <c:if test="${!depositPaid}">
                                    <%-- Deposit Card --%>
                                    <div class="payment-type-card ${defaultPaymentType == 'DEPOSIT' ? 'active' : ''}" 
                                         onclick="selectPaymentType('DEPOSIT', ${remainingDeposit}, ${remainingAmount}, this)"
                                         style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                            <span class="material-symbols-outlined" style="font-size: 20px;">account_balance_wallet</span>
                                            <div class="radio-dot" style="width: 14px; height: 14px; border-radius: 50%; border: 1.5px solid var(--outline); display: flex; align-items: center; justify-content: center;">
                                                <div class="radio-inner" style="width: 8px; height: 8px; border-radius: 50%; background: transparent;"></div>
                                            </div>
                                        </div>
                                        <div style="font-weight: 700; font-size: 14px; color: var(--text-primary);">Đặt cọc</div>
                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 4px; line-height: 1.3;">Giữ chỗ & bảo đảm xe</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${depositPaid && !rentalPaid}">
                                    <%-- Rental Card --%>
                                    <div class="payment-type-card ${defaultPaymentType == 'RENTAL' ? 'active' : ''}" 
                                         onclick="selectPaymentType('RENTAL', ${remainingAmount}, ${remainingAmount}, this)"
                                         style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                            <span class="material-symbols-outlined" style="font-size: 20px;">directions_car</span>
                                            <div class="radio-dot" style="width: 14px; height: 14px; border-radius: 50%; border: 1.5px solid var(--outline); display: flex; align-items: center; justify-content: center;">
                                                <div class="radio-inner" style="width: 8px; height: 8px; border-radius: 50%; background: transparent;"></div>
                                            </div>
                                        </div>
                                        <div style="font-weight: 700; font-size: 14px; color: var(--text-primary);">Thuê xe</div>
                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 4px; line-height: 1.3;">Thanh toán cước thuê</div>
                                    </div>
                                </c:if>

                                <c:if test="${rentalPaid && remainingAmount > 0}">
                                    <%-- Additional Fee Card --%>
                                    <div class="payment-type-card ${defaultPaymentType == 'ADDITIONAL_FEE' ? 'active' : ''}" 
                                         onclick="selectPaymentType('ADDITIONAL_FEE', ${remainingAmount}, ${remainingAmount}, this)"
                                         style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                            <span class="material-symbols-outlined" style="font-size: 20px;">warning</span>
                                            <div class="radio-dot" style="width: 14px; height: 14px; border-radius: 50%; border: 1.5px solid var(--outline); display: flex; align-items: center; justify-content: center;">
                                                <div class="radio-inner" style="width: 8px; height: 8px; border-radius: 50%; background: transparent;"></div>
                                            </div>
                                        </div>
                                        <div style="font-weight: 700; font-size: 14px; color: var(--text-primary);">Phụ phí</div>
                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 4px; line-height: 1.3;">Thanh toán phụ phí phát sinh</div>
                                    </div>
                                </c:if>
                                
                                 <c:if test="${(sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN') && rentalPaid && excessAmount > 0}">
                                    <%-- Refund Card --%>
                                    <div class="payment-type-card ${defaultPaymentType == 'REFUND' ? 'active' : ''}" 
                                         onclick="selectPaymentType('REFUND', ${excessAmount != null ? excessAmount : 0}, ${remainingAmount}, this)"
                                         style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                            <span class="material-symbols-outlined" style="font-size: 20px;">keyboard_return</span>
                                            <div class="radio-dot" style="width: 14px; height: 14px; border-radius: 50%; border: 1.5px solid var(--outline); display: flex; align-items: center; justify-content: center;">
                                                <div class="radio-inner" style="width: 8px; height: 8px; border-radius: 50%; background: transparent;"></div>
                                            </div>
                                        </div>
                                        <div style="font-weight: 700; font-size: 14px; color: var(--text-primary);">Hoàn tiền</div>
                                        <div style="font-size: 11px; color: var(--text-secondary); margin-top: 4px; line-height: 1.3;">Trả lại tiền thừa/cọc</div>
                                    </div>
                                </c:if>
                                
                                <c:if test="${depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0}">
                                    <div style="grid-column: 1 / -1; padding: 24px; text-align: center; background: var(--surface-container-low); border-radius: 12px; border: 1.5px dashed var(--outline-variant); color: var(--text-secondary); width: 100%;">
                                        <span class="material-symbols-outlined" style="font-size: 32px; color: var(--success); margin-bottom: 8px;">check_circle</span>
                                        <div style="font-weight: 700; color: var(--text-primary);">Đơn hàng đã quyết toán xong!</div>
                                        <div style="font-size: 13px; margin-top: 4px;">Đơn đặt xe này đã thanh toán đầy đủ các khoản tiền cọc, tiền thuê và phụ thu phát sinh.</div>
                                    </div>
                                </c:if>
                                
                            </div>
                        </div>

                        <%-- Số tiền --%>
                        <div class="bk-form-group" style="margin-bottom: 20px; text-align: left;">
                            <label class="bk-form-label" for="amountDisplay" style="font-weight: 700; margin-bottom: 8px;">Số tiền (VNĐ)</label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined" style="font-size:20px; color:var(--outline);">payments</span>
                                <input type="text" id="amountDisplay" class="bk-form-input" required
                                       placeholder="0 đ"
                                       oninput="syncAmount(this)"
                                       ${sessionScope.currentUser.role == 'CUSTOMER' ? 'readonly' : ''}
                                       style="padding-left: 40px; font-size: 16px; font-weight: 600; color: var(--primary); ${sessionScope.currentUser.role == 'CUSTOMER' ? 'background-color: var(--surface-container-low);' : ''}">
                                <input type="hidden" id="amount" name="amount" value="${defaultPaymentType == 'DEPOSIT' ? remainingDeposit : (defaultPaymentType == 'REFUND' ? excessAmount : remainingAmount)}">
                            </div>
                        </div>

                        <%-- Phương thức thanh toán --%>
                        <c:if test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                            <input type="hidden" id="paymentMethod" name="paymentMethod" value="BANK_TRANSFER"/>
                        </c:if>
                        <div class="bk-form-group" style="margin-bottom: 20px; text-align: left;">
                            <label class="bk-form-label" style="font-weight: 700; margin-bottom: 10px; display: block;">Phương thức thanh toán</label>
                            <c:choose>
                                <c:when test="${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'}">
                                    <div class="bk-form-input-wrap">
                                        <span class="material-symbols-outlined" style="font-size:20px; color:var(--outline);">credit_card</span>
                                        <select id="paymentMethod" name="paymentMethod" class="bk-form-select" required style="padding-left: 40px; font-size: 15px;">
                                            <c:if test="${enabledMethods['CASH']}">
                                                <option value="CASH">Tiền mặt</option>
                                            </c:if>
                                            <c:if test="${enabledMethods['BANK_TRANSFER']}">
                                                <option value="BANK_TRANSFER" selected>Chuyển khoản</option>
                                            </c:if>
                                            <c:if test="${enabledMethods['VNPAY']}">
                                                <option value="VNPAY">VNPay</option>
                                            </c:if>
                                            <c:if test="${enabledMethods['MOMO']}">
                                                <option value="MOMO">Momo</option>
                                            </c:if>
                                            <c:if test="${enabledMethods['ZALOPAY']}">
                                                <option value="ZALOPAY">ZaloPay</option>
                                            </c:if>
                                        </select>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                                        <%-- Cash Card — always shown --%>
                                        <div id="method-card-cash" class="payment-method-card ${not empty defaultPaymentType ? '' : 'active'}"
                                             onclick="selectPaymentMethod('CASH')"
                                             style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                                                <span class="material-symbols-outlined" style="font-size: 22px; color: var(--primary);">payments</span>
                                                <span style="font-weight: 700; font-size: 14px;">Tiền mặt</span>
                                            </div>
                                            <div style="font-size: 11px; color: var(--text-secondary); line-height: 1.4;">Thanh toán trực tiếp tại quầy<br>Nhân viên xác nhận sau khi nhận tiền</div>
                                        </div>

                                        <%-- Bank Transfer Card — hidden for REFUND --%>
                                        <div id="method-card-bank" class="payment-method-card"
                                             onclick="selectPaymentMethod('BANK_TRANSFER')"
                                             style="border: 1.5px solid var(--outline-variant); border-radius: 12px; padding: 16px; cursor: pointer; text-align: left; transition: all 0.2s;">
                                            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                                                <span class="material-symbols-outlined" style="font-size: 22px; color: #2F5ACD;">qr_code_2</span>
                                                <span style="font-weight: 700; font-size: 14px;">Chuyển khoản QR</span>
                                            </div>
                                            <div style="font-size: 11px; color: var(--text-secondary); line-height: 1.4;">Quét mã QR để chuyển khoản<br>Tự động nhận diện qua nội dung CK</div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                            <%-- Cash Instructions Panel --%>
                            <div id="cash-instructions-panel" style="display:none; margin-top: 16px; background: #F0FFF4; border: 1px solid #9AE6B4; border-radius: 12px; padding: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                    <span class="material-symbols-outlined" style="font-size: 20px; color: #276749;">info</span>
                                    <strong style="color: #276749; font-size: 14px;">Hướng dẫn thanh toán tiền mặt</strong>
                                </div>
                                <p style="font-size: 13px; color: #2F855A; margin: 0; line-height: 1.6;">
                                    <c:choose>
                                        <c:when test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                                            Vui lòng mang đúng số tiền đến quầy giao dịch.<br>
                                            Nhân viên sẽ xác nhận và ghi nhận thanh toán của bạn.
                                        </c:when>
                                        <c:otherwise>
                                            Nhận trực tiếp tiền mặt từ khách hàng.<br>
                                            Vui lòng kiểm tra kỹ số tiền nhận được trước khi nhấn xác nhận.
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>

                            <%-- Bank Transfer Info Panel — same card style as cash instructions --%>
                            <c:if test="${sessionScope.currentUser.role != 'STAFF' && sessionScope.currentUser.role != 'ADMIN'}">
                            <div id="qr-panel" style="display:none; margin-top: 16px; background: #EBF8FF; border: 1px solid #90CDF4; border-radius: 12px; padding: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                    <span class="material-symbols-outlined" style="font-size: 20px; color: #2B6CB0;">info</span>
                                    <strong style="color: #2B6CB0; font-size: 14px;">Hướng dẫn thanh toán chuyển khoản</strong>
                                </div>
                                <p style="font-size: 13px; color: #2C5282; margin: 0 0 12px 0; line-height: 1.6;">
                                    Nhấn <strong>"Xác nhận thanh toán"</strong> để hệ thống tạo mã giao dịch.<br>
                                    Bạn sẽ được chuyển đến trang QR — quét mã để thanh toán tự động.
                                </p>
                                <c:if test="${not empty bankAccountNumber}">
                                <div style="border-top: 1px dashed #90CDF4; padding-top: 10px; display: flex; flex-direction: column; gap: 6px; font-size: 13px;">
                                    <div style="display:flex; justify-content:space-between; gap:8px;">
                                        <span style="color:#4A5568; white-space:nowrap;">Ngân hàng:</span>
                                        <span style="font-weight:600; text-align:right; color:#1A365D;">${not empty bankName ? bankName : '—'} <c:if test="${not empty bankBranch}">(${bankBranch})</c:if></span>
                                    </div>
                                    <div style="display:flex; justify-content:space-between; gap:8px;">
                                        <span style="color:#4A5568; white-space:nowrap;">Số tài khoản:</span>
                                        <span style="font-weight:700; color:var(--primary); font-family:monospace; font-size:14px;">${bankAccountNumber}</span>
                                    </div>
                                    <div style="display:flex; justify-content:space-between; gap:8px;">
                                        <span style="color:#4A5568; white-space:nowrap;">Chủ tài khoản:</span>
                                        <span style="font-weight:600; color:#1A365D;">${bankAccountName}</span>
                                    </div>
                                </div>
                                </c:if>
                            </div>
                            </c:if>

                        <%-- Số tiền thực nhận (Staff/Admin only — for overpayment tracking) --%>
                        <c:if test="${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'}">
                        <div class="bk-form-group" style="margin-bottom: 20px; text-align: left;">
                            <label class="bk-form-label" for="amountPaidDisplay" style="font-weight: 700; margin-bottom: 8px;">
                                Số tiền thực nhận (VNĐ)
                                <span style="font-size: 11px; color: var(--text-secondary); font-weight: 400;"> — để trống nếu bằng số tiền yêu cầu</span>
                            </label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined" style="font-size:20px; color:var(--outline);">price_check</span>
                                <input type="text" id="amountPaidDisplay" class="bk-form-input"
                                       placeholder="Nhập số tiền thực nhận từ khách..."
                                       oninput="syncAmountPaid(this)"
                                       style="padding-left: 40px; font-size: 15px; font-weight: 600;"/>
                                <input type="hidden" id="amountPaid" name="amountPaid" value=""/>
                            </div>
                        </div>
                        </c:if>

                        <%-- Ghi chú giao dịch --%>
                        <div class="bk-form-group" style="margin-bottom: 24px; text-align: left;">
                            <label class="bk-form-label" for="notes" style="font-weight: 700; margin-bottom: 8px;">Ghi chú giao dịch</label>
                            <textarea id="notes" name="notes" class="bk-form-textarea" rows="3" 
                                      placeholder="Nhập chi tiết về giao dịch này..." style="padding: 12px; font-size: 15px; font-family: inherit; resize: none;"></textarea>
                        </div>

                        <%-- Submit/Cancel --%>
                        <div style="display: flex; gap: 16px; justify-content: flex-end; border-top: 1px solid var(--outline-variant); padding-top: 20px;">
                            <a href="${pageContext.request.contextPath}/bookings/detail?id=${booking.bookingId}" class="bk-btn bk-btn-outline" style="padding: 10px 24px;">Hủy bỏ</a>
                            <button type="submit" id="paySubmitBtn" class="bk-btn bk-btn-primary" 
                                    ${(depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0) || (sessionScope.currentUser.role == 'CUSTOMER' && remainingAmount <= 0) ? 'disabled' : ''}
                                    style="padding: 10px 28px; ${(depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0) || (sessionScope.currentUser.role == 'CUSTOMER' && remainingAmount <= 0) ? 'background: var(--outline-variant); border-color: var(--outline-variant); cursor: not-allowed;' : 'background: #2F5ACD; border-color: #2F5ACD;'}" 
                                    onclick="return prepareSubmit()">
                                <c:choose>
                                    <c:when test="${depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0}">
                                        <span class="material-symbols-outlined">check_circle</span> Đã quyết toán xong
                                    </c:when>
                                    <c:otherwise>
                                        <span class="material-symbols-outlined">check</span> Xác nhận thanh toán
                                    </c:otherwise>
                                </c:choose>
                            </button>
                        </div>
                    </form>
                </div>

                <%-- Right Column: Summaries and Vehicle Info --%>
                <div style="display: flex; flex-direction: column; gap: 24px;">
                    
                    <%-- Bento Tóm tắt đơn thuê --%>
                    <div class="bk-card" style="padding: 24px; text-align: left;">
                        <div style="display: flex; align-items: center; gap: 8px; border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px;">
                            <span class="material-symbols-outlined" style="color: var(--primary); font-size: 20px;">receipt_long</span>
                            <span style="font-size: 15px; font-weight: 700; color: var(--primary);">Tóm tắt đơn thuê</span>
                        </div>
                        
                        <div class="bk-detail-rows" style="display: flex; flex-direction: column; gap: 12px;">
                            <div class="bk-detail-row" style="display: flex; justify-content: space-between; font-size: 14px;">
                                <span class="label" style="color: var(--text-secondary);">Tiền thuê gốc (${rentalDays} ngày)</span>
                                <span class="value" style="font-weight: 600;"><fmt:formatNumber value="${booking.baseAmount}" pattern="#,##0"/> đ</span>
                            </div>
                            <c:if test="${not empty booking.deliveryFee && booking.deliveryFee > 0}">
                                <div class="bk-detail-row" style="display: flex; justify-content: space-between; font-size: 14px;">
                                    <span class="label" style="color: var(--text-secondary);">Phí giao xe</span>
                                    <span class="value" style="font-weight: 600;"><fmt:formatNumber value="${booking.deliveryFee}" pattern="#,##0"/> đ</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty booking.taxAmount && booking.taxAmount > 0}">
                                <div class="bk-detail-row" style="display: flex; justify-content: space-between; font-size: 14px;">
                                    <span class="label" style="color: var(--text-secondary);">Thuế (VAT)</span>
                                    <span class="value" style="font-weight: 600;"><fmt:formatNumber value="${booking.taxAmount}" pattern="#,##0"/> đ</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty booking.discountAmount && booking.discountAmount > 0}">
                                <div class="bk-detail-row" style="display: flex; justify-content: space-between; font-size: 14px;">
                                    <span class="label" style="color: var(--text-secondary);">Giảm giá</span>
                                    <span class="value" style="font-weight: 600; color: var(--success);">-<fmt:formatNumber value="${booking.discountAmount}" pattern="#,##0"/> đ</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty returns && not empty returns.totalAdditionalFee && returns.totalAdditionalFee > 0}">
                                <div class="bk-detail-row" style="display: flex; justify-content: space-between; font-size: 14px;">
                                    <span class="label" style="color: var(--error);">Phụ phí phát sinh (trả xe)</span>
                                    <span class="value" style="font-weight: 600; color: var(--error);"><fmt:formatNumber value="${returns.totalAdditionalFee}" pattern="#,##0"/> đ</span>
                                </div>
                            </c:if>
                        </div>
                        
                        <div class="bk-summary-total" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed var(--outline-variant); padding-top: 16px; margin-top: 16px;">
                            <span style="font-weight: 700; font-size: 15px; color: var(--primary);">Tổng cộng</span>
                            <span style="font-weight: 800; font-size: 22px; color: #2F5ACD;"><fmt:formatNumber value="${not empty totalAmount ? totalAmount : booking.totalAmount}" pattern="#,##0"/> đ</span>
                        </div>
                    </div>

                    <%-- Bento Trạng thái hiện tại --%>
                    <div class="bk-card" style="padding: 24px; text-align: left;">
                        <div style="font-size: 13px; font-weight: 700; text-transform: uppercase; color: var(--text-secondary); letter-spacing: 0.5px; margin-bottom: 16px;">TRẠNG THÁI HIỆN TẠI</div>
                        
                        <div style="display: flex; flex-direction: column; gap: 12px;">
                            <%-- Paid amount card --%>
                            <div style="display: flex; align-items: center; gap: 14px; background: #EAF9F5; border-radius: 12px; padding: 16px; border: 1px solid rgba(5,205,153,0.15);">
                                <div style="width: 32px; height: 32px; border-radius: 50%; background: #05CD99; color: #fff; display: flex; align-items: center; justify-content: center;">
                                    <span class="material-symbols-outlined" style="font-size: 18px;">check</span>
                                </div>
                                <div>
                                    <div style="font-size: 12px; color: #039C74; font-weight: 600;">Đã thanh toán</div>
                                    <div style="font-size: 18px; font-weight: 800; color: #039C74; margin-top: 2px;"><fmt:formatNumber value="${totalPaid}" pattern="#,##0"/> đ</div>
                                </div>
                            </div>

                            <%-- Remaining amount card --%>
                            <div style="display: flex; align-items: center; gap: 14px; background: #FFF4F2; border-radius: 12px; padding: 16px; border: 1px solid rgba(238,93,80,0.15);">
                                <div style="width: 32px; height: 32px; border-radius: 50%; background: #EE5D50; color: #fff; display: flex; align-items: center; justify-content: center;">
                                    <span class="material-symbols-outlined" style="font-size: 18px;">info</span>
                                </div>
                                <div>
                                    <div style="font-size: 12px; color: #C9392D; font-weight: 600;">Còn lại cần thu</div>
                                    <div style="font-size: 18px; font-weight: 800; color: #C9392D; margin-top: 2px;"><fmt:formatNumber value="${remainingAmount}" pattern="#,##0"/> đ</div>
                                </div>
                            </div>

                            <%-- Overpayment warning (Staff/Admin only) --%>
                            <c:if test="${(sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN') && excessAmount > 0}">
                            <div style="background: #FFF5F5; border: 1.5px solid #FC8181; border-radius: 12px; padding: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                    <span class="material-symbols-outlined" style="font-size: 20px; color: #C53030;">warning</span>
                                    <strong style="color: #C53030; font-size: 13px;">Phát hiện thanh toán thừa!</strong>
                                </div>
                                <div style="font-size: 12px; color: #742A2A; line-height: 1.6;">
                                    Khách đã trả dư <strong><fmt:formatNumber value="${excessAmount}" pattern="#,##0"/> đ</strong><br>
                                    Vui lòng hoàn tiền mặt cho khách hàng.
                                </div>
                            </div>
                            </c:if>

                            <%-- Dynamic overpayment panel (JS-driven, shown when Staff enters amountPaid > amount) --%>
                            <div id="overpayment-warning" style="display:none; background: #FFF5F5; border: 1.5px solid #FC8181; border-radius: 12px; padding: 16px;">
                                <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                    <span class="material-symbols-outlined" style="font-size: 20px; color: #C53030;">warning</span>
                                    <strong style="color: #C53030; font-size: 13px;">Số tiền nhận vượt yêu cầu!</strong>
                                </div>
                                <div style="font-size: 12px; color: #742A2A; line-height: 1.8;">
                                    Yêu cầu: <strong id="ow-required">—</strong><br>
                                    Đã nhận: <strong id="ow-paid">—</strong><br>
                                    Cần hoàn: <strong id="ow-refund" style="color:#C53030;">—</strong><br>
                                    <span style="font-size:11px;">→ Xử lý bằng giao dịch Hoàn tiền (Tiền mặt)</span>
                                </div>
                            </div>

                        </div>
                    </div>

                    <%-- Bottom Card: Car detail --%>
                    <div style="border-radius: var(--radius-xl); overflow: hidden; box-shadow: var(--shadow); position: relative; height: 260px;">
                        <img src="${pageContext.request.contextPath}${carImageUrl}" alt="${car.brand}" 
                             style="width: 100%; height: 100%; object-fit: cover; filter: brightness(0.7);"
                             onerror="this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg'">
                        
                        <div style="position: absolute; top: 16px; left: 16px;">
                            <span class="bk-badge bk-badge-progress" style="background: rgba(255,255,255,0.9); color: var(--primary); border-radius: 4px; padding: 4px 8px; font-size: 10px; font-weight: 700;">
                                ĐANG PHỤC VỤ
                            </span>
                        </div>
                        
                        <div style="position: absolute; bottom: 20px; left: 20px; right: 20px; text-align: left; color: #fff;">
                            <h3 style="font-size: 20px; font-weight: 700; text-shadow: 0 2px 4px rgba(0,0,0,0.5);">${car.brand} ${car.model} ${car.year}</h3>
                            <p style="font-size: 13px; opacity: 0.9; margin-top: 4px; display: flex; align-items: center; gap: 4px; text-shadow: 0 1px 2px rgba(0,0,0,0.5);">
                                <span class="material-symbols-outlined" style="font-size: 16px;">location_on</span> ${not empty car.location ? car.location : 'Chi nhánh Quận 1, TP. HCM'}
                            </p>
                        </div>
                    </div>

                </div>

            </div>
        </c:when>

        <c:otherwise>
            <div class="bk-card" style="padding: 40px; text-align: center; margin-top: 28px;">
                <span class="material-symbols-outlined" style="font-size: 56px; color: var(--outline); margin-bottom: 12px; display:block;">warning</span>
                <h4 style="color: var(--on-surface); margin-bottom: 8px;">Không tìm thấy đơn đặt xe</h4>
                <p style="color: var(--text-secondary); font-size: 14px;">Vui lòng truy cập trang lịch sử/nhật ký giao dịch để xem toàn bộ danh sách.</p>
                <a href="${pageContext.request.contextPath}/payments/history" class="bk-btn bk-btn-primary" style="margin-top: 16px;">
                    Đi đến Nhật Ký Giao Dịch
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
// Format number to VND display string
function formatVND(val) {
    if (!val && val !== 0) return '';
    return Number(val).toLocaleString('vi-VN') + ' đ';
}

// Sync display input -> hidden amount field
function syncAmount(input) {
    var raw = input.value.replace(/[^\d]/g, '');
    document.getElementById('amount').value = raw;
    if (raw) {
        input.value = Number(raw).toLocaleString('vi-VN') + ' đ';
        setTimeout(function() {
            input.setSelectionRange(input.value.length - 2, input.value.length - 2);
        }, 0);
    } else {
        input.value = '';
    }
    updateQrAmount();
}

// Sync amountPaid display -> hidden field + show overpayment warning
function syncAmountPaid(input) {
    var raw = input.value.replace(/[^\d]/g, '');
    var hiddenField = document.getElementById('amountPaid');
    if (hiddenField) hiddenField.value = raw;
    if (raw) {
        input.value = Number(raw).toLocaleString('vi-VN') + ' đ';
        setTimeout(function() {
            input.setSelectionRange(input.value.length - 2, input.value.length - 2);
        }, 0);
    } else {
        input.value = '';
    }
    checkOverpayment();
}

function checkOverpayment() {
    var required = Number(document.getElementById('amount').value) || 0;
    var paidField = document.getElementById('amountPaid');
    if (!paidField) return;
    var paid = Number(paidField.value) || 0;
    var panel = document.getElementById('overpayment-warning');
    if (!panel) return;
    if (paid > 0 && paid > required) {
        document.getElementById('ow-required').textContent = formatVND(required);
        document.getElementById('ow-paid').textContent = formatVND(paid);
        document.getElementById('ow-refund').textContent = formatVND(paid - required);
        panel.style.display = 'block';
    } else {
        panel.style.display = 'none';
    }
}

function updateQrAmount() {
    var raw = document.getElementById('amount').value;
    var display = document.getElementById('qrAmountDisplay');
    if (display) {
        display.textContent = raw ? formatVND(Number(raw)) : '—';
    }
    // Rebuild QR image URL if bankBin is available
    var qrImg = document.getElementById('qrImage');
    if (qrImg && raw) {
        var src = qrImg.src.replace(/amount=[0-9]*/g, 'amount=' + raw);
        qrImg.src = src;
    }
}

// Payment method selection
function selectPaymentMethod(method) {
    document.getElementById('paymentMethod').value = method;
    var cards = document.querySelectorAll('.payment-method-card');
    cards.forEach(function(c) { c.classList.remove('active'); });
    var target = document.getElementById('method-card-' + method.toLowerCase().replace('_', '-'));
    if (!target) target = document.getElementById('method-card-bank');
    if (target) target.classList.add('active');

    var cashPanel = document.getElementById('cash-instructions-panel');
    var qrPanel   = document.getElementById('qr-panel');
    if (method === 'CASH') {
        if (cashPanel) cashPanel.style.display = 'block';
        if (qrPanel)   qrPanel.style.display   = 'none';
    } else {
        if (cashPanel) cashPanel.style.display = 'none';
        if (qrPanel)   qrPanel.style.display   = 'block';
        updateQrAmount();
    }
}

function selectPaymentType(type, val, remain, element) {
    document.getElementById('selectedPaymentType').value = type;
    
    var cards = document.querySelectorAll('.payment-type-card');
    cards.forEach(function(card) { card.classList.remove('active'); });
    var clickedCard = element || event.currentTarget;
    clickedCard.classList.add('active');
    
    document.getElementById('amount').value = val;
    document.getElementById('amountDisplay').value = val ? Number(val).toLocaleString('vi-VN') + ' đ' : '';

    // For REFUND: hide Bank Transfer option, force CASH
    var bankCard = document.getElementById('method-card-bank');
    var isStaffOrAdmin = ${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'};
    if (type === 'REFUND' || isStaffOrAdmin) {
        if (bankCard) bankCard.style.display = 'none';
        selectPaymentMethod('CASH');
    } else {
        if (bankCard) bankCard.style.display = 'block';
    }

    updateQrAmount();
}

function copyTransferDesc() {
    var code = document.getElementById('transferDescDisplay');
    if (code) {
        navigator.clipboard.writeText(code.textContent.trim()).then(function() {
            var btn = code.nextElementSibling;
            if (btn) { var orig = btn.textContent; btn.textContent = '✓ Đã sao chép'; setTimeout(function(){ btn.textContent = orig; }, 1500); }
        });
    }
}

// Validate before submit
function prepareSubmit() {
    var raw = document.getElementById('amount').value;
    if (!raw || isNaN(Number(raw)) || Number(raw) <= 0) {
        alert('Vui lòng nhập số tiền hợp lệ!');
        return false;
    }
    return true;
}

// Init on page load
document.addEventListener('DOMContentLoaded', function() {
    var hiddenAmt = document.getElementById('amount');
    var displayAmt = document.getElementById('amountDisplay');
    if (hiddenAmt && displayAmt && hiddenAmt.value) {
        displayAmt.value = Number(hiddenAmt.value).toLocaleString('vi-VN') + ' đ';
    }
    
    // Trigger click on the active payment type card to initialize inputs
    var activeCard = document.querySelector('.payment-type-card.active');
    if (activeCard) {
        activeCard.click();
    }

    // Initialize payment method display based on default payment type
    var defaultType = '${defaultPaymentType}';
    var isStaffOrAdmin = ${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'};
    if (defaultType === 'REFUND' || isStaffOrAdmin) {
        selectPaymentMethod('CASH');
    } else {
        selectPaymentMethod('BANK_TRANSFER');
    }
});
</script>

<style>
.payment-type-card.active {
    border-color: #2F5ACD !important;
    background: #F4F7FE;
}
.payment-type-card.active .radio-dot {
    border-color: #2F5ACD !important;
}
.payment-type-card.active .radio-inner {
    background: #2F5ACD !important;
}
.payment-method-card {
    transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
    user-select: none;
}
.payment-method-card:hover {
    border-color: var(--primary) !important;
    background: #F4F7FE;
}
.payment-method-card.active {
    border-color: #2F5ACD !important;
    background: #F4F7FE;
}
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
