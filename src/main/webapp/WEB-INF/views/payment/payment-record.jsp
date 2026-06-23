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
<c:if test="${not empty errorMsg}">
    <div class="bk-alert bk-alert-error" style="margin-bottom: 24px;">
        <span class="material-symbols-outlined">warning</span> ${errorMsg}
    </div>
</c:if>

<div class="page-content" style="max-width: 1200px; margin: 0 auto; padding-top: 0;">
    
    <c:choose>
        <%-- CASE 1: SPECIFIC BOOKING TRANSACTION RECORDING (Image 2 style) --%>
        <c:when test="${not empty booking}">
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
                                         onclick="selectPaymentType('DEPOSIT', ${booking.depositAmount}, ${remainingAmount})"
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
                                         onclick="selectPaymentType('RENTAL', ${remainingAmount}, ${remainingAmount})"
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
                                         onclick="selectPaymentType('ADDITIONAL_FEE', ${remainingAmount}, ${remainingAmount})"
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
                                
                                <c:if test="${rentalPaid && excessAmount > 0}">
                                    <%-- Refund Card --%>
                                    <div class="payment-type-card ${defaultPaymentType == 'REFUND' ? 'active' : ''}" 
                                         onclick="selectPaymentType('REFUND', ${excessAmount != null ? excessAmount : 0}, ${remainingAmount})"
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
                                       style="padding-left: 40px; font-size: 16px; font-weight: 600; color: var(--primary);">
                                <input type="hidden" id="amount" name="amount" value="${defaultPaymentType == 'DEPOSIT' ? booking.depositAmount : (defaultPaymentType == 'REFUND' ? excessAmount : remainingAmount)}">
                            </div>
                        </div>

                        <%-- Phương thức thanh toán --%>
                        <div class="bk-form-group" style="margin-bottom: 20px; text-align: left;">
                            <label class="bk-form-label" for="paymentMethod" style="font-weight: 700; margin-bottom: 8px;">Phương thức thanh toán</label>
                            <div class="bk-form-input-wrap">
                                <span class="material-symbols-outlined" style="font-size:20px; color:var(--outline);">credit_card</span>
                                <select id="paymentMethod" name="paymentMethod" class="bk-form-select" required style="padding-left: 40px; font-size: 15px;">
                                    <c:if test="${sessionScope.currentUser.role != 'CUSTOMER' && enabledMethods['CASH']}">
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
                        </div>

                        <%-- Ghi chú giao dịch --%>
                        <div class="bk-form-group" style="margin-bottom: 24px; text-align: left;">
                            <label class="bk-form-label" for="notes" style="font-weight: 700; margin-bottom: 8px;">Ghi chú giao dịch</label>
                            <textarea id="notes" name="notes" class="bk-form-textarea" rows="4" 
                                      placeholder="Nhập chi tiết về giao dịch này..." style="padding: 12px; font-size: 15px; font-family: inherit; resize: none;"></textarea>
                        </div>

                        <%-- Submit/Cancel --%>
                        <div style="display: flex; gap: 16px; justify-content: flex-end; border-top: 1px solid var(--outline-variant); padding-top: 20px;">
                            <a href="${pageContext.request.contextPath}/bookings/detail?id=${booking.bookingId}" class="bk-btn bk-btn-outline" style="padding: 10px 24px;">Hủy bỏ</a>
                            <button type="submit" id="paySubmitBtn" class="bk-btn bk-btn-primary" 
                                    ${depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0 ? 'disabled' : ''}
                                    style="padding: 10px 28px; ${depositPaid && rentalPaid && remainingAmount <= 0 && excessAmount <= 0 ? 'background: var(--outline-variant); border-color: var(--outline-variant); cursor: not-allowed;' : 'background: #2F5ACD; border-color: #2F5ACD;'}" 
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

        <%-- CASE 2: GLOBAL TRANSACTION LOGS FOR STAFF/ADMIN ONLY --%>
        <c:otherwise>
            <div class="bk-card">
                <div class="bk-card-title" style="margin-bottom: 20px;">
                    <span class="material-symbols-outlined">history</span>
                    <span>Nhật Ký Giao Dịch Thanh Toán Hệ Thống</span>
                </div>
                
                <div class="bk-table-toolbar" style="margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center;">
                    <div class="bk-table-search" style="width: 320px;">
                        <span class="material-symbols-outlined">search</span>
                        <input type="text" id="searchInput" placeholder="Tìm kiếm theo mã, số tiền, ngày thanh toán,..." oninput="filterTable()">
                    </div>
                    
                    <select id="filterType" onchange="filterTable()" class="bk-form-select" style="width: 200px; height: 42px; border-radius: 8px; font-size: 14px; border: 1px solid var(--outline-variant); padding: 0 12px; background: var(--bg-white);">
                        <option value="All">Tất cả loại giao dịch</option>
                        <option value="DEPOSIT">Đặt cọc (DEPOSIT)</option>
                        <option value="RENTAL">Tiền thuê xe (RENTAL)</option>
                        <option value="ADDITIONAL_FEE">Phụ phí (ADDITIONAL_FEE)</option>
                        <option value="REFUND">Hoàn tiền (REFUND)</option>
                    </select>
                    
                    <select id="filterMethod" onchange="filterTable()" class="bk-form-select" style="width: 200px; height: 42px; border-radius: 8px; font-size: 14px; border: 1px solid var(--outline-variant); padding: 0 12px; background: var(--bg-white);">
                        <option value="All">Tất cả phương thức</option>
                        <option value="CASH">Tiền mặt (CASH)</option>
                        <option value="BANK_TRANSFER">Chuyển khoản (BANK_TRANSFER)</option>
                        <option value="VNPAY">VNPay</option>
                        <option value="MOMO">Momo</option>
                        <option value="ZALOPAY">ZaloPay</option>
                    </select>
                    
                    <select id="filterStatus" onchange="filterTable()" class="bk-form-select" style="width: 200px; height: 42px; border-radius: 8px; font-size: 14px; border: 1px solid var(--outline-variant); padding: 0 12px; background: var(--bg-white);">
                        <option value="All">Tất cả trạng thái</option>
                        <option value="COMPLETED">Thành công (COMPLETED)</option>
                        <option value="PENDING">Chờ xử lý (PENDING)</option>
                        <option value="FAILED">Thất bại (FAILED)</option>
                    </select>
                </div>

                <div class="bk-table-container">
                    <table class="bk-table" id="paymentTable" style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background: var(--surface-container-low); border-bottom: 1px solid var(--outline-variant);">
                                <th style="padding: 12px 16px;">Mã GD</th>
                                <th style="padding: 12px 16px;">Đơn Hàng & Hợp Đồng</th>
                                <th style="padding: 12px 16px;">Số Tiền</th>
                                <th style="padding: 12px 16px;">Loại Giao Dịch</th>
                                <th style="padding: 12px 16px;">Phương Thức</th>
                                <th style="padding: 12px 16px;">Trạng Thái</th>
                                <th style="padding: 12px 16px;">Ngày Thanh Toán</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${payments}">
                                <tr style="border-bottom: 1px solid var(--outline-variant); height: 60px; ${p.paymentType == 'REFUND' ? 'background: rgba(238,93,80,0.05);' : ''}" data-type="${p.paymentType}" data-method="${p.paymentMethod}" data-status="${p.status}">
                                    <td class="code" style="padding: 12px 16px; font-weight: 700; color: var(--primary);">
                                        PAY-${p.paymentId}
                                        <c:if test="${not empty p.transactionRef}">
                                            <div class="sub" style="font-size:11px; font-weight:normal; color: var(--text-secondary);">Ref: ${p.transactionRef}</div>
                                        </c:if>
                                    </td>
                                    <td style="padding: 12px 16px;">
                                        <div>
                                            <a href="${pageContext.request.contextPath}/bookings/detail?id=${p.bookingId}" style="font-weight:600; color:var(--primary);">
                                                #BK-${p.bookingId}
                                            </a>
                                        </div>
                                        <c:if test="${not empty p.contractId && p.contractId > 0}">
                                            <div class="sub" style="font-size:11px;">
                                                <a href="${pageContext.request.contextPath}/contracts/detail?id=${p.contractId}" style="color: var(--text-secondary);">
                                                    Hợp đồng: #CT-${p.contractId}
                                                </a>
                                            </div>
                                        </c:if>
                                    </td>
                                    <td style="padding: 12px 16px; font-weight: 700; color: ${p.paymentType == 'REFUND' ? '#C9392D' : 'var(--primary)'}">
                                        <c:if test="${p.paymentType == 'REFUND'}">-</c:if><fmt:formatNumber value="${p.amount}" pattern="#,##0"/> VND
                                    </td>
                                    <td style="padding: 12px 16px;">
                                        <c:choose>
                                            <c:when test="${p.paymentType == 'DEPOSIT'}"><span style="font-weight:600; color:#505F76;">💵 Đặt cọc</span></c:when>
                                            <c:when test="${p.paymentType == 'RENTAL'}"><span style="font-weight:600; color:#041638;">🚗 Tiền thuê xe</span></c:when>
                                            <c:when test="${p.paymentType == 'ADDITIONAL_FEE'}"><span style="font-weight:600; color:var(--error);"><span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">warning</span> Phụ phí</span></c:when>
                                            <c:when test="${p.paymentType == 'REFUND'}"><span style="font-weight:600; color:#C9392D;">🔄 Hoàn tiền</span></c:when>
                                            <c:otherwise>${p.paymentType}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px 16px; font-weight: 500;">
                                        <c:choose>
                                            <c:when test="${p.paymentMethod == 'CASH'}">Tiền mặt</c:when>
                                            <c:when test="${p.paymentMethod == 'BANK_TRANSFER'}">Chuyển khoản</c:when>
                                            <c:when test="${p.paymentMethod == 'VNPAY'}">VNPay</c:when>
                                            <c:when test="${p.paymentMethod == 'MOMO'}">Momo</c:when>
                                            <c:when test="${p.paymentMethod == 'ZALOPAY'}">ZaloPay</c:when>
                                            <c:otherwise>${p.paymentMethod}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px 16px;">
                                        <c:choose>
                                            <c:when test="${p.status == 'COMPLETED'}"><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> Thành công</span></c:when>
                                            <c:when test="${p.status == 'PENDING'}"><span class="bk-badge bk-badge-pending"><span class="bk-badge-dot"></span> Chờ xử lý</span></c:when>
                                            <c:otherwise><span class="bk-badge bk-badge-rejected"><span class="bk-badge-dot"></span> Thất bại</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px 16px; font-size:13px; color:var(--text-secondary);">
                                        ${p.paidAt != null ? p.paidAt.format(dateTimeFormatter) : '—'}
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <!-- Phân trang -->
                <div class="bk-pagination-container" style="display:flex; justify-content:space-between; align-items:center; margin-top:20px; padding:12px 0; border-top:1px solid var(--outline-variant); flex-wrap:wrap; gap:12px;">
                    <div style="font-size:13px; color:var(--on-surface-variant);">
                        Hiển thị <span id="pag-start" style="font-weight:600;">0</span> đến <span id="pag-end" style="font-weight:600;">0</span> trong số <span id="pag-total" style="font-weight:600;">0</span> bản ghi
                    </div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <label style="font-size:13px; color:var(--on-surface-variant);">Số hàng:</label>
                        <select id="pageSizeSelect" onchange="changePageSize()" style="padding:4px 8px; border-radius:6px; border:1px solid var(--outline-variant); background:var(--surface); color:var(--on-surface); font-size:13px; outline:none; cursor:pointer;">
                            <option value="5">5</option>
                            <option value="10" selected="selected">10</option>
                            <option value="20">20</option>
                            <option value="50">50</option>
                        </select>
                        <div id="paginationButtons" style="display:flex; gap:4px; align-items:center; margin-left:12px;">
                            <!-- nút chuyển trang -->
                        </div>
                    </div>
                </div>
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
    // Remove all non-digit chars
    var raw = input.value.replace(/[^\d]/g, '');
    // Update hidden field with plain number
    document.getElementById('amount').value = raw;
    // Re-format display
    if (raw) {
        input.value = Number(raw).toLocaleString('vi-VN') + ' đ';
        // Keep caret at end
        setTimeout(function() {
            input.setSelectionRange(input.value.length - 2, input.value.length - 2);
        }, 0);
    } else {
        input.value = '';
    }
}

function selectPaymentType(type, val, remain) {
    document.getElementById('selectedPaymentType').value = type;
    
    // Toggle active visual class
    var cards = document.querySelectorAll('.payment-type-card');
    cards.forEach(function(card) {
        card.classList.remove('active');
    });
    
    var clickedCard = event.currentTarget;
    clickedCard.classList.add('active');
    
    // Set formatted value in display input and raw value in hidden field
    document.getElementById('amount').value = val;
    document.getElementById('amountDisplay').value = val ? Number(val).toLocaleString('vi-VN') + ' đ' : '';
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

let currentPage = 1;
let pageSize = 10;
let filteredRows = [];

function changePageSize() {
    var sizeSelect = document.getElementById('pageSizeSelect');
    if (sizeSelect) {
        pageSize = parseInt(sizeSelect.value);
        currentPage = 1;
        applyPagination();
    }
}

function filterTable() {
    var searchInputEl = document.getElementById('searchInput');
    var searchInput = searchInputEl ? searchInputEl.value.toLowerCase() : '';
    var filterType = document.getElementById('filterType') ? document.getElementById('filterType').value : 'All';
    var filterMethod = document.getElementById('filterMethod') ? document.getElementById('filterMethod').value : 'All';
    var filterStatus = document.getElementById('filterStatus') ? document.getElementById('filterStatus').value : 'All';
    
    var rows = document.querySelectorAll('#paymentTable tbody tr');
    filteredRows = [];
    
    rows.forEach(function(row) {
        var rowText = row.textContent.toLowerCase();
        var type = row.getAttribute('data-type') || '';
        var method = row.getAttribute('data-method') || '';
        var status = row.getAttribute('data-status') || '';
        
        var matchesSearch = rowText.includes(searchInput);
        var matchesType = (filterType === 'All' || type === filterType);
        var matchesMethod = (filterMethod === 'All' || method === filterMethod);
        var matchesStatus = (filterStatus === 'All' || status === filterStatus);
        
        if (matchesSearch && matchesType && matchesMethod && matchesStatus) {
            filteredRows.push(row);
        } else {
            row.style.display = 'none';
        }
    });
    
    currentPage = 1;
    applyPagination();
}

function applyPagination() {
    var paymentTable = document.getElementById('paymentTable');
    if (!paymentTable) return; // Exit if not in global log view
    
    const totalRows = filteredRows.length;
    const totalPages = Math.ceil(totalRows / pageSize) || 1;
    
    if (currentPage > totalPages) currentPage = totalPages;
    if (currentPage < 1) currentPage = 1;
    
    const allRows = document.querySelectorAll('#paymentTable tbody tr');
    allRows.forEach(row => row.style.display = 'none');
    
    const startIdx = (currentPage - 1) * pageSize;
    const endIdx = Math.min(startIdx + pageSize, totalRows);
    
    for (let i = startIdx; i < endIdx; i++) {
        filteredRows[i].style.display = '';
    }
    
    const startDisplay = document.getElementById('pag-start');
    const endDisplay = document.getElementById('pag-end');
    const totalDisplay = document.getElementById('pag-total');
    if (startDisplay) startDisplay.innerText = totalRows > 0 ? (startIdx + 1) : 0;
    if (endDisplay) endDisplay.innerText = endIdx;
    if (totalDisplay) totalDisplay.innerText = totalRows;
    
    const btnContainer = document.getElementById('paginationButtons');
    if (btnContainer) {
        btnContainer.innerHTML = '';
        
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        prevBtn.style.padding = '4px 8px';
        prevBtn.style.border = '1px solid var(--outline-variant)';
        prevBtn.style.borderRadius = '6px';
        prevBtn.style.cursor = 'pointer';
        prevBtn.disabled = (currentPage === 1);
        prevBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_left</span>';
        prevBtn.onclick = () => { currentPage--; applyPagination(); };
        btnContainer.appendChild(prevBtn);
        
        let startPage = Math.max(1, currentPage - 2);
        let endPage = Math.min(totalPages, startPage + 4);
        if (endPage - startPage < 4) {
            startPage = Math.max(1, endPage - 4);
        }
        
        for (let p = startPage; p <= endPage; p++) {
            if (p < 1) continue;
            const pBtn = document.createElement('button');
            pBtn.type = 'button';
            pBtn.className = p === currentPage ? 'bk-btn bk-btn-sm bk-btn-primary' : 'bk-btn bk-btn-sm bk-btn-outline';
            pBtn.style.padding = '4px 10px';
            pBtn.style.border = '1px solid ' + (p === currentPage ? 'var(--primary)' : 'var(--outline-variant)');
            pBtn.style.borderRadius = '6px';
            pBtn.style.cursor = 'pointer';
            if (p === currentPage) {
                pBtn.style.background = 'var(--primary)';
                pBtn.style.color = 'var(--on-primary)';
            }
            pBtn.innerText = p;
            pBtn.onclick = () => { currentPage = p; applyPagination(); };
            btnContainer.appendChild(pBtn);
        }
        
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'bk-btn bk-btn-sm bk-btn-outline';
        nextBtn.style.padding = '4px 8px';
        nextBtn.style.border = '1px solid var(--outline-variant)';
        nextBtn.style.borderRadius = '6px';
        nextBtn.style.cursor = 'pointer';
        nextBtn.disabled = (currentPage === totalPages);
        nextBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px; vertical-align:middle;">chevron_right</span>';
        nextBtn.onclick = () => { currentPage++; applyPagination(); };
        btnContainer.appendChild(nextBtn);
    }
}

// Init on page load
document.addEventListener('DOMContentLoaded', function() {
    var hiddenAmt = document.getElementById('amount');
    var displayAmt = document.getElementById('amountDisplay');
    if (hiddenAmt && displayAmt && hiddenAmt.value) {
        displayAmt.value = Number(hiddenAmt.value).toLocaleString('vi-VN') + ' đ';
    }
    
    // Initialize global log pagination if on the global logs view
    if (document.getElementById('paymentTable')) {
        filterTable();
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
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
