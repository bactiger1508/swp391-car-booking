<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    request.setAttribute("dateOnlyFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Hóa Đơn VAT"/>
</jsp:include>

<style>
    .invoice-card {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        padding: 40px;
        margin-bottom: 30px;
        border: 1px solid #eef2f6;
    }
    .invoice-header {
        display: flex;
        justify-content: space-between;
        border-bottom: 2px solid #3498db;
        padding-bottom: 20px;
        margin-bottom: 30px;
    }
    .invoice-title {
        color: #2c3e50;
        font-size: 28px;
        font-weight: 800;
        letter-spacing: 0.5px;
        margin-bottom: 10px;
    }
    .invoice-meta {
        font-size: 14px;
        color: #7f8c8d;
        line-height: 1.6;
    }
    .invoice-section-title {
        font-size: 16px;
        font-weight: 700;
        color: #34495e;
        border-bottom: 1px solid #bdc3c7;
        padding-bottom: 8px;
        margin-bottom: 15px;
        text-transform: uppercase;
        margin-top: 20px;
    }
    .info-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }
    .info-table td {
        padding: 8px 0;
        font-size: 14px;
        color: #2c3e50;
    }
    .info-table td.label {
        color: #7f8c8d;
        width: 150px;
    }
    .info-table td.value {
        font-weight: 600;
    }
    .items-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
        margin-bottom: 30px;
    }
    .items-table th {
        background-color: #f8f9fa;
        color: #34495e;
        text-align: left;
        padding: 12px;
        font-size: 14px;
        font-weight: 700;
        border-bottom: 2px solid #dee2e6;
    }
    .items-table td {
        padding: 12px;
        font-size: 14px;
        border-bottom: 1px solid #dee2e6;
        color: #2c3e50;
    }
    .summary-box {
        margin-left: auto;
        width: 350px;
        background-color: #fdfefe;
        border: 1px solid #ebf5fb;
        border-radius: 8px;
        padding: 20px;
    }
    .summary-row {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        font-size: 14px;
        color: #2c3e50;
    }
    .summary-row.total {
        border-top: 2px solid #3498db;
        padding-top: 12px;
        margin-top: 8px;
        font-weight: 700;
        font-size: 18px;
        color: #e74c3c;
    }
    .badge-issued {
        background-color: #e8f8f5;
        color: #1abc9c;
        padding: 4px 12px;
        border-radius: 20px;
        font-weight: 600;
        font-size: 12px;
        display: inline-block;
    }
    
    @media print {
        body * {
            visibility: hidden;
        }
        .page-content, .page-content * {
            visibility: visible;
        }
        .page-content {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
        }
        .no-print {
            display: none !important;
        }
        .invoice-card {
            border: none;
            box-shadow: none;
            padding: 0;
        }
    }
    
    /* Modal Styles */
    .bk-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(4, 22, 56, 0.45);
        backdrop-filter: blur(4px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s ease-in-out;
    }
    .bk-modal.open {
        opacity: 1;
        pointer-events: auto;
    }
    .bk-modal-content {
        background: #ffffff;
        border: 1px solid var(--border-color, #e2e8f0);
        border-radius: 12px;
        width: 90%;
        max-width: 480px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        padding: 24px;
        transform: scale(0.95);
        transition: transform 0.2s ease-in-out;
    }
    .bk-modal.open .bk-modal-content {
        transform: scale(1);
    }
    .bk-modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid var(--border-color, #e2e8f0);
        padding-bottom: 12px;
    }
    .modal-close-icon {
        font-size: 24px;
        cursor: pointer;
        color: var(--text-secondary, #718096);
        transition: color 0.15s ease;
        line-height: 1;
    }
    .modal-close-icon:hover {
        color: var(--danger, #e53e3e);
    }
    .bk-modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        border-top: 1px solid var(--border-color, #e2e8f0);
        padding-top: 16px;
        margin-top: 8px;
    }
</style>

<div class="page-content">
    <div class="no-print" style="display: flex; gap: 16px; justify-content: flex-end; margin-bottom: 20px;">
        <c:if test="${sessionScope.currentUser.role == 'CUSTOMER' && contract.customerId == sessionScope.currentUser.userId && !invoice.customerSigned}">
            <form id="signInvoiceForm" action="${pageContext.request.contextPath}/contracts/vat-invoice/sign" method="POST" style="margin: 0;">
                <input type="hidden" name="contractId" value="${contract.contractId}"/>
                <input type="hidden" name="invoiceId" value="${invoice.invoiceId}"/>
                <button type="button" class="btn btn-success" style="display: inline-flex; align-items: center; gap: 8px;" onclick="openSignModal()">
                    <span class="material-symbols-outlined">draw</span> Xác nhận ký hóa đơn
                </button>
            </form>
        </c:if>
        <a href="${pageContext.request.contextPath}/contracts/detail?id=${contract.contractId}" class="btn btn-outline" style="display: inline-flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">arrow_back</span> Quay lại hợp đồng
        </a>
        <button type="button" class="btn btn-primary" onclick="window.print()" style="display: inline-flex; align-items: center; gap: 8px;">
            <span class="material-symbols-outlined">print</span> In Hóa Đơn
        </button>
    </div>

    <div class="invoice-card">
        <!-- Hóa đơn Header -->
        <div class="invoice-header">
            <div>
                <h1 class="invoice-title">HÓA ĐƠN GIÁ TRỊ GIA TĂNG (VAT)</h1>
                <div class="invoice-meta">
                    <p>Mã hóa đơn: <strong style="color: #2c3e50;">${invoice.invoiceCode}</strong></p>
                    <p>Ngày lập: <strong>${invoice.invoiceDate.format(dateTimeFormatter)}</strong></p>
                    <p>Trạng thái: <span class="badge-issued">ĐÃ PHÁT HÀNH (ISSUED)</span></p>
                </div>
            </div>
            <div style="text-align: right; line-height: 1.6;">
                <h2 style="font-size: 20px; font-weight: 700; color: #3498db; margin-bottom: 5px;">CARPRO RENTAL</h2>
                <p style="font-size: 13px; color: #7f8c8d;">Hệ thống cho thuê xe tự lái hàng đầu</p>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 40px;">
            <!-- Đơn vị bán hàng -->
            <div>
                <div class="invoice-section-title">Đơn vị bán hàng (Seller)</div>
                <table class="info-table">
                    <tr>
                        <td class="label">Tên đơn vị:</td>
                        <td class="value">${companyName}</td>
                    </tr>
                    <tr>
                        <td class="label">Mã số thuế:</td>
                        <td class="value">${companyTaxId}</td>
                    </tr>
                    <tr>
                        <td class="label">Địa chỉ:</td>
                        <td class="value">${companyAddress}</td>
                    </tr>
                </table>
            </div>

            <!-- Người mua hàng -->
            <div>
                <div class="invoice-section-title">Khách hàng (Buyer)</div>
                <table class="info-table">
                    <tr>
                        <td class="label">Họ và tên:</td>
                        <td class="value">${customer.fullName}</td>
                    </tr>
                    <tr>
                        <td class="label">Số điện thoại:</td>
                        <td class="value">${customer.phone != null ? customer.phone : '-'}</td>
                    </tr>
                    <tr>
                        <td class="label">Email:</td>
                        <td class="value">${customer.email}</td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- Chi tiết hợp đồng tham chiếu -->
        <div class="invoice-section-title">Chi tiết dịch vụ thuê xe</div>
        <table class="info-table">
            <tr>
                <td class="label" style="width: 200px;">Số Hợp Đồng Tham Chiếu:</td>
                <td class="value" style="color: #3498db;">${contract.contractNumber}</td>
                <td class="label" style="width: 150px; padding-left: 20px;">Phương tiện:</td>
                <td class="value">${car.brand} ${car.model} (${car.licensePlate})</td>
            </tr>
            <tr>
                <td class="label">Thời hạn thuê:</td>
                <td class="value">${contract.startDate.format(dateTimeFormatter)} - ${contract.endDate.format(dateTimeFormatter)}</td>
                <td class="label" style="padding-left: 20px;">Đơn giá ngày:</td>
                <td class="value"><fmt:formatNumber value="${contract.dailyRate}" pattern="#,##0"/> VND</td>
            </tr>
        </table>

        <!-- Bảng tổng hợp các khoản thanh toán -->
        <div class="invoice-section-title">Bảng tổng hợp các khoản thanh toán</div>
        <table class="items-table">
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Nội dung thanh toán</th>
                    <th>Phương thức</th>
                    <th>Ngày thanh toán</th>
                    <th style="text-align: right;">Số tiền</th>
                </tr>
            </thead>
            <tbody>
                <c:set var="stt" value="0"/>
                <c:forEach var="p" items="${payments}">
                    <c:if test="${p.status == 'COMPLETED'}">
                        <c:set var="stt" value="${stt + 1}"/>
                        <tr>
                            <td>${stt}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.paymentType == 'DEPOSIT'}">Tiền đặt cọc xe (Deposit)</c:when>
                                    <c:when test="${p.paymentType == 'RENTAL'}">Tiền thuê xe (Rental Fee)</c:when>
                                    <c:when test="${p.paymentType == 'ADDITIONAL_FEE'}">Phí phụ thu phát sinh (Additional Fee)</c:when>
                                    <c:when test="${p.paymentType == 'REFUND'}">Hoàn tiền khách hàng (Refund)</c:when>
                                    <c:otherwise>${p.paymentType}</c:otherwise>
                                </c:choose>
                            </td>
                            <td>${p.paymentMethod == 'CASH' ? 'Tiền mặt' : (p.paymentMethod == 'DEDUCTION' ? 'Khấu trừ' : 'Chuyển khoản')}</td>
                            <td>${p.paidAt != null ? p.paidAt.format(dateTimeFormatter) : ''}</td>
                            <td style="text-align: right; font-weight: 600;">
                                <c:if test="${p.paymentType == 'REFUND'}">-</c:if>
                                <fmt:formatNumber value="${p.amount}" pattern="#,##0"/> VND
                            </td>
                        </tr>
                    </c:if>
                </c:forEach>
            </tbody>
        </table>

        <!-- Summary -->
        <div class="summary-box">
            <div class="summary-row">
                <span>Cộng tiền hàng (Trước thuế):</span>
                <span style="font-weight: 600;"><fmt:formatNumber value="${invoice.amountBeforeTax}" pattern="#,##0"/> VND</span>
            </div>
            <div class="summary-row">
                <span>Thuế suất VAT (${invoice.taxRate}%):</span>
                <span><fmt:formatNumber value="${invoice.taxAmount}" pattern="#,##0"/> VND</span>
            </div>
            <div class="summary-row total">
                <span>Tổng cộng (Thanh toán):</span>
                <span><fmt:formatNumber value="${invoice.totalAmount}" pattern="#,##0"/> VND</span>
            </div>
        </div>

        <div style="margin-top: 50px; display: flex; justify-content: space-between; text-align: center; font-size: 14px;">
            <div style="width: 250px;">
                <p style="font-weight: 700; text-transform: uppercase;">Người Mua Hàng</p>
                <p style="font-size: 12px; color: #7f8c8d; margin-bottom: 15px;">(Ký, ghi rõ họ tên)</p>
                <c:choose>
                    <c:when test="${invoice.customerSigned}">
                        <div style="border: 2px dashed #27ae60; color: #27ae60; padding: 6px; border-radius: 4px; font-weight: bold; font-family: monospace; font-size: 10px; display: inline-block; margin-bottom: 15px;">
                            KHÁCH HÀNG XÁC NHẬN
                            <br/>
                            ĐÃ KÝ ĐIỆN TỬ
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p style="font-style: italic; color: #999; margin-bottom: 35px;">(Chờ xác nhận)</p>
                    </c:otherwise>
                </c:choose>
                <p style="font-weight: 600; text-decoration: underline;">${customer.fullName}</p>
            </div>
            <div style="width: 250px;">
                <p style="font-weight: 700; text-transform: uppercase;">Người Lập Hóa Đơn</p>
                <p style="font-size: 12px; color: #7f8c8d; margin-bottom: 60px;">(Ký, đóng dấu hoặc xác thực số)</p>
                <div style="border: 2px dashed #27ae60; color: #27ae60; padding: 6px; border-radius: 4px; font-weight: bold; font-family: monospace; font-size: 10px; display: inline-block;">
                    HỆ THỐNG CARPRO
                    <br/>
                    ĐÃ KÝ ĐIỆN TỬ
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Custom Sign Modal -->
<div id="customSignModal" class="bk-modal no-print">
    <div class="bk-modal-content">
        <div class="bk-modal-header">
            <div style="display: flex; align-items: center; gap: 10px;">
                <span class="material-symbols-outlined" style="color: var(--success, #2e7d32); font-size: 26px;">draw</span>
                <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Xác nhận ký hóa đơn VAT</h3>
            </div>
            <span class="modal-close-icon" onclick="closeSignModal()">&times;</span>
        </div>
        <div class="bk-modal-body" style="padding: 20px 0;">
            <p style="margin: 0; font-size: 14px; line-height: 1.6; color: var(--text-secondary);">
                Bạn có chắc chắn muốn xác nhận ký hóa đơn VAT này?
            </p>
        </div>
        <div class="bk-modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeSignModal()">Hủy bỏ</button>
            <button type="button" class="btn btn-success" style="display: inline-flex; align-items: center; gap: 8px;" onclick="document.getElementById('signInvoiceForm').submit()">
                <span class="material-symbols-outlined" style="font-size: 20px;">draw</span> Đồng ý ký
            </button>
        </div>
    </div>
</div>

<script>
    function openSignModal() {
        document.getElementById('customSignModal').classList.add('open');
    }
    function closeSignModal() {
        document.getElementById('customSignModal').classList.remove('open');
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
