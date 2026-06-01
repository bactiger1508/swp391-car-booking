<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Chi tiết Hợp đồng"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/contracts">Quản lý hợp đồng</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Chi tiết hợp đồng ${not empty contract ? contract.contractNumber : ''}</span>
        </div>
        <h2>Chi tiết Hợp đồng Thuê xe</h2>
    </div>
</div>

<c:if test="${empty contract}">
    <div class="bk-empty">
        <span class="material-symbols-outlined">warning</span>
        <h3>Không tìm thấy dữ liệu hợp đồng</h3>
        <p>Hợp đồng yêu cầu không tồn tại hoặc đã bị gỡ bỏ khỏi hệ thống.</p>
        <a href="${pageContext.request.contextPath}/contracts" class="bk-btn bk-btn-primary" style="margin-top:16px;">
            <span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách
        </a>
    </div>
</c:if>

<c:if test="${not empty contract}">
    <div class="bk-detail-grid">
        <%-- LEFT: Hợp đồng giấy mockup --%>
        <div>
            <div class="bk-card" style="background:#fff;border:1px solid #d0d0d0;box-shadow: 0 4px 20px rgba(0,0,0,0.05);padding:40px;position:relative;font-family:'Inter',sans-serif;color:#333;border-radius:12px;">
                <!-- Dấu mộc/Badge Trạng thái tuyệt đẹp đóng dấu chéo trên góc -->
                <div style="position:absolute;top:32px;right:32px;border:3px double ${contract.status == 'ACTIVE' ? 'var(--success)' : contract.status == 'COMPLETED' ? 'var(--info)' : 'var(--warning)'};color:${contract.status == 'ACTIVE' ? 'var(--success)' : contract.status == 'COMPLETED' ? 'var(--info)' : 'var(--warning)'};padding:8px 16px;font-size:14px;font-weight:800;text-transform:uppercase;letter-spacing:1px;border-radius:4px;transform:rotate(5deg);">
                    ${contract.status == 'ACTIVE' ? 'Đang hiệu lực' : contract.status == 'COMPLETED' ? 'Đã hoàn tất' : 'Bản nháp'}
                </div>

                <!-- Quốc hiệu -->
                <div style="text-align:center;margin-bottom:24px;line-height:1.4;">
                    <div style="font-weight:700;font-size:14px;text-transform:uppercase;letter-spacing:0.5px;">CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</div>
                    <div style="font-weight:600;font-size:12px;">Độc lập - Tự do - Hạnh phúc</div>
                    <div style="font-size:11px;margin-top:4px;color:#777;">---o0o---</div>
                </div>

                <div style="text-align:center;margin-bottom:32px;">
                    <h3 style="font-size:20px;font-weight:800;color:var(--primary);text-transform:uppercase;margin:0;">HỢP ĐỒNG THUÊ XE TỰ LÁI</h3>
                    <div style="font-size:13px;color:#666;margin-top:6px;font-weight:600;">Số: ${contract.contractNumber}</div>
                </div>

                <!-- BÊN A -->
                <div style="margin-bottom:20px;">
                    <h4 style="font-size:14px;font-weight:700;border-bottom:1px solid #eee;padding-bottom:6px;text-transform:uppercase;color:var(--primary);margin-bottom:12px;">BÊN CHO THUÊ XE (BÊN A): CÔNG TY CỔ PHẦN CARPRO VỆT NAM</h4>
                    <div style="font-size:13px;line-height:1.8;display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;">
                        <div><strong>Đại diện pháp luật:</strong> Nguyễn Văn Điều Hành</div>
                        <div><strong>Chức vụ:</strong> Giám Đốc</div>
                        <div><strong>Địa chỉ trụ sở:</strong> Khu CNC Hòa Lạc, Thạch Thất, Hà Nội</div>
                        <div><strong>Mã số thuế:</strong> 0109876543</div>
                    </div>
                </div>

                <!-- BÊN B -->
                <div style="margin-bottom:20px;">
                    <h4 style="font-size:14px;font-weight:700;border-bottom:1px solid #eee;padding-bottom:6px;text-transform:uppercase;color:var(--primary);margin-bottom:12px;">BÊN THUÊ XE (BÊN B): KHÁCH HÀNG THUÊ</h4>
                    <div style="font-size:13px;line-height:1.8;display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;">
                        <div><strong>Mã khách hàng:</strong> KH-${contract.customerId}</div>
                        <div><strong>Họ và tên:</strong> ${not empty customer ? customer.fullName : 'Chưa cập nhật'}</div>
                        <div><strong>Email:</strong> ${not empty customer ? customer.email : 'Chưa cập nhật'}</div>
                        <div><strong>Điện thoại liên hệ:</strong> ${not empty customer ? customer.phone : 'Chưa cập nhật'}</div>
                    </div>
                </div>
 
                <!-- ĐIỀU KHOẢN XE -->
                <div style="margin-bottom:20px;">
                    <h4 style="font-size:14px;font-weight:700;border-bottom:1px solid #eee;padding-bottom:6px;text-transform:uppercase;color:var(--primary);margin-bottom:12px;">ĐIỀU 1: THÔNG TIN XE CHO THUÊ</h4>
                    <div style="font-size:13px;line-height:1.8;display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;">
                        <div><strong>Tên xe:</strong> ${not empty car ? car.brand : ''} ${not empty car ? car.model : 'Xe #' + contract.carId}</div>
                        <div><strong>Biển kiểm soát:</strong> ${not empty car ? car.licensePlate : 'Chưa cập nhật'}</div>
                        <div><strong>Thời hạn thuê từ:</strong> <fmt:formatNumber value="${contract.startDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${contract.startDate.monthValue}" pattern="00"/>/${contract.startDate.year} <fmt:formatNumber value="${contract.startDate.hour}" pattern="00"/>:<fmt:formatNumber value="${contract.startDate.minute}" pattern="00"/></div>
                        <div><strong>Đến hết ngày:</strong> <fmt:formatNumber value="${contract.endDate.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${contract.endDate.monthValue}" pattern="00"/>/${contract.endDate.year} <fmt:formatNumber value="${contract.endDate.hour}" pattern="00"/>:<fmt:formatNumber value="${contract.endDate.minute}" pattern="00"/></div>
                    </div>
                </div>
 
                <!-- GIÁ TRỊ HỢP ĐỒNG -->
                <div style="margin-bottom:20px;">
                    <h4 style="font-size:14px;font-weight:700;border-bottom:1px solid #eee;padding-bottom:6px;text-transform:uppercase;color:var(--primary);margin-bottom:12px;">ĐIỀU 2: GIÁ TRỊ HỢP ĐỒNG VÀ THƯƠNG THẢO</h4>
                    <div style="font-size:13px;line-height:1.8;display:grid;grid-template-columns:1fr 1fr;gap:8px 16px;">
                        <div><strong>Đơn giá thuê theo ngày:</strong> <span style="font-weight:600;color:var(--primary);"><fmt:formatNumber value="${contract.dailyRate}" type="number" groupingUsed="true"/> đ / ngày</span></div>
                        <div><strong>Tiền cọc thế chấp:</strong> <span style="font-weight:600;color:var(--primary);"><fmt:formatNumber value="${contract.depositAmount}" type="number" groupingUsed="true"/> đ</span></div>
                        <div style="grid-column: span 2;"><strong>Tổng giá trị hợp đồng ước tính:</strong> <span style="font-size:16px;font-weight:700;color:var(--primary);"><fmt:formatNumber value="${contract.totalAmount}" type="number" groupingUsed="true"/> đ</span></div>
                    </div>
                </div>
 
                <!-- ĐIỀU KHOẢN CHUNG -->
                <div style="margin-bottom:32px;">
                    <h4 style="font-size:14px;font-weight:700;border-bottom:1px solid #eee;padding-bottom:6px;text-transform:uppercase;color:var(--primary);margin-bottom:12px;">ĐIỀU 3: ĐIỀU KHOẢN CHUNG VÀ CAM KẾT</h4>
                    <p style="font-size:12px;color:#555;line-height:1.6;margin:0;text-align:justify;">
                        Bên B cam kết tuân thủ luật giao thông đường bộ Việt Nam. Không sử dụng xe thuê vào các hoạt động phi pháp hoặc vận chuyển hàng cấm. Khi trả xe trễ hạn, bên B cam kết đóng các khoản phụ thu phát sinh theo đúng chính sách niêm yết của công ty. Hợp đồng có hiệu lực kể từ khi hai bên ký nhận bàn giao xe trên hệ thống.
                    </p>
                </div>
 
                <!-- CHỮ KÝ -->
                <div style="display:flex;justify-content:space-between;font-size:13px;margin-top:24px;border-top:1px dashed #ddd;padding-top:24px;">
                    <div style="text-align:center;width:45%;">
                        <div style="font-weight:700;text-transform:uppercase;">ĐẠI DIỆN BÊN A</div>
                        <div style="font-size:11px;color:#888;margin-top:2px;">(Ký, ghi rõ họ tên và đóng dấu)</div>
                        <div style="font-family:'Courier New',monospace;color:var(--secondary);font-weight:700;font-size:14px;margin-top:32px;height:40px;display:flex;align-items:center;justify-content:center;border:1px dashed var(--outline-variant);border-radius:4px;background:var(--surface);">
                            CARPRO DIGITAL SIGNED
                        </div>
                        <div style="font-weight:600;margin-top:8px;">Nguyễn Văn Điều Hành</div>
                    </div>
                    <div style="text-align:center;width:45%;">
                        <div style="font-weight:700;text-transform:uppercase;">ĐẠI DIỆN BÊN B</div>
                        <div style="font-size:11px;color:#888;margin-top:2px;">(Ký và ghi rõ họ tên)</div>
                        <div style="font-family:'Courier New',monospace;color:var(--secondary);font-weight:700;font-size:14px;margin-top:32px;height:40px;display:flex;align-items:center;justify-content:center;border:1px dashed var(--outline-variant);border-radius:4px;background:var(--surface);">
                            ${contract.status == 'ACTIVE' || contract.status == 'COMPLETED' ? 'CUSTOMER SECURE SIGNED' : 'CHỜ KÝ ĐIỆN TỬ'}
                        </div>
                        <div style="font-weight:600;margin-top:8px;">${not empty customer ? customer.fullName : 'Nguyễn Văn Khách Thuê'}</div>
                    </div>
                </div>
            </div>
        </div>
 
        <%-- RIGHT: Summary / Actions --%>
        <div>
            <div class="bk-cost-card" style="position:sticky;top:96px;">
                <h3><span class="material-symbols-outlined">receipt_long</span> Tóm tắt Hợp đồng</h3>
                <div class="bk-detail-rows">
                    <div class="bk-detail-row">
                        <span class="label">Mã đơn liên kết</span>
                        <span class="value" style="font-family:monospace;font-size:15px;">#BK-${contract.bookingId}</span>
                    </div>
                    <div class="bk-detail-row">
                        <span class="label">Mã số Hợp đồng</span>
                        <span class="value" style="font-family:monospace;font-size:15px;">${contract.contractNumber}</span>
                    </div>
                    <div class="bk-detail-row">
                        <span class="label">Ngày lập hợp đồng</span>
                        <span class="value"><fmt:formatNumber value="${contract.createdAt.dayOfMonth}" pattern="00"/>/<fmt:formatNumber value="${contract.createdAt.monthValue}" pattern="00"/>/${contract.createdAt.year}</span>
                    </div>
                    <div class="bk-detail-row">
                        <span class="label">Người tạo hợp đồng</span>
                        <span class="value">${not empty creator ? creator.fullName : 'Nhân viên #' + contract.createdBy}</span>
                    </div>
                </div>

                <div class="bk-summary-total">
                    <span class="label">Tổng số tiền</span>
                    <span class="value" style="font-size:20px;color:var(--primary);font-weight:700;"><fmt:formatNumber value="${contract.totalAmount}" type="number" groupingUsed="true"/>đ</span>
                </div>

                <div class="bk-summary-highlight" style="margin-top:16px;">
                    <div>
                        <div class="label" style="font-weight:700;color:var(--primary);">Tiền đặt cọc thế chấp</div>
                    </div>
                    <span class="value" style="font-weight:700;color:var(--primary);"><fmt:formatNumber value="${contract.depositAmount}" type="number" groupingUsed="true"/>đ</span>
                </div>

                <div style="margin-top:24px;display:flex;flex-direction:column;gap:12px;">
                    <button type="button" class="bk-btn bk-btn-primary" style="width:100%;justify-content:center;" onclick="window.print()">
                        <span class="material-symbols-outlined">print</span> In hợp đồng (PDF)
                    </button>
                    <a href="${pageContext.request.contextPath}/contracts" class="bk-btn bk-btn-outline" style="width:100%;justify-content:center;">
                        <span class="material-symbols-outlined">arrow_back</span> Quay lại danh sách
                    </a>
                </div>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
