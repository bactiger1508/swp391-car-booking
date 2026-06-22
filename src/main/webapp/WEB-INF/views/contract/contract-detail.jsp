<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    request.setAttribute("hourFormatter", java.time.format.DateTimeFormatter.ofPattern("HH"));
    request.setAttribute("minuteFormatter", java.time.format.DateTimeFormatter.ofPattern("mm"));
    request.setAttribute("dateOnlyFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="${contract != null ? 'Chi Tiết Hợp Đồng' : 'Soạn Thảo Hợp Đồng'}"/>
</jsp:include>

<div class="page-content">
    <!-- Hiển thị thông báo lỗi nếu có -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger" style="margin-bottom: 24px;">
            <span>${error}</span>
        </div>
        <div style="margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/bookings/manage" class="btn btn-outline">Quay lại quản lý đặt xe</a>
        </div>
    </c:if>

    <c:if test="${empty error}">
        <c:choose>
            <%-- TRƯỜNG HỢP 1: XEM CHI TIẾT HỢP ĐỒNG ĐÃ CÓ --%>
            <c:when test="${not empty contract}">
                <div class="card" style="margin-bottom: 24px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 16px; margin-bottom: 24px;">
                        <div>
                            <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px;">CHI TIẾT HỢP ĐỒNG THUÊ XE</h2>
                            <p style="font-size: 14px; color: var(--text-secondary);">Số hợp đồng: <strong style="color: var(--primary);">${contract.contractNumber}</strong></p>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${contract.status == 'DRAFT'}">
                                    <span class="badge badge-pending">Hợp đồng nháp (Draft)</span>
                                </c:when>
                                <c:when test="${contract.status == 'ACTIVE'}">
                                    <span class="badge badge-confirmed">Hiệu lực (Active)</span>
                                </c:when>
                                <c:when test="${contract.status == 'COMPLETED'}">
                                    <span class="badge badge-completed">Hoàn tất (Completed)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-cancelled">${contract.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
                        <!-- Cột trái: Thông tin các bên và tài sản -->
                        <div>
                            <div style="margin-bottom: 24px;">
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--primary); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Thông Tin Đặt Xe & Hợp Đồng</h4>
                                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; background: var(--primary-light); padding: 16px; border-radius: var(--radius-sm);">
                                    <div>
                                        <p style="font-size: 12px; color: var(--text-secondary);">Mã Đặt Xe</p>
                                        <p style="font-weight: 600;">#${contract.bookingId}</p>
                                    </div>
                                    <div>
                                        <p style="font-size: 12px; color: var(--text-secondary);">Nhân viên lập</p>
                                        <p style="font-weight: 600;">${creator != null ? creator.fullName : 'Hệ thống'}</p>
                                    </div>
                                    <div>
                                        <p style="font-size: 12px; color: var(--text-secondary);">Ngày lập hợp đồng</p>
                                        <p style="font-weight: 600;">${contract.createdAt != null ? contract.createdAt.format(dateTimeFormatter) : ''}</p>
                                    </div>
                                    <div>
                                        <p style="font-size: 12px; color: var(--text-secondary);">Ngày ký kết</p>
                                        <p style="font-weight: 600;">${contract.signedAt != null ? contract.signedAt.format(dateTimeFormatter) : 'Chưa ký kết'}</p>
                                    </div>
                                </div>
                            </div>

                            <div style="margin-bottom: 24px;">
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--success); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Thông Tin Khách Thuê</h4>
                                <table style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; width: 40%; border-bottom: 1px solid var(--border-color);">Họ tên khách hàng</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: 1px solid var(--border-color);">${customer.fullName}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: 1px solid var(--border-color);">Số điện thoại</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: 1px solid var(--border-color);">${customer.phone != null ? customer.phone : '-'}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: none;">Email liên hệ</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: none;">${customer.email}</td>
                                    </tr>
                                </table>
                            </div>

                            <div style="margin-bottom: 24px;">
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--info); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Thông Tin Phương Tiện</h4>
                                <table style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; width: 40%; border-bottom: 1px solid var(--border-color);">Tên xe</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: 1px solid var(--border-color);">${car.brand} ${car.model} (${car.year})</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: 1px solid var(--border-color);">Biển kiểm soát</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; color: var(--primary); border-bottom: 1px solid var(--border-color);">${car.licensePlate}</td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: none;">Màu sắc / Số ghế</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: none;">${car.color} / ${car.seats} chỗ</td>
                                    </tr>
                                </table>
                            </div>

                            <div style="margin-bottom: 24px;">
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--warning); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Thời Gian & Chi Phí Thuê</h4>
                                <table style="width: 100%; border-collapse: collapse;">
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: 1px solid var(--border-color);">Thời gian thuê</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: 1px solid var(--border-color);">
                                            ${contract.startDate != null ? contract.startDate.format(dateTimeFormatter) : ''} đến ${contract.endDate != null ? contract.endDate.format(dateTimeFormatter) : ''}
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: 1px solid var(--border-color);">Đơn giá thuê ngày</td>
                                        <td style="padding: 8px 0; font-weight: 600; text-align: right; border-bottom: 1px solid var(--border-color);">
                                            <fmt:formatNumber value="${contract.dailyRate}" pattern="#,##0"/> VND
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding: 8px 0; color: var(--text-secondary); font-size: 14px; border-bottom: 1px solid var(--border-color);">Tiền cọc đặt trước</td>
                                        <td style="padding: 8px 0; font-weight: 700; text-align: right; color: var(--danger); border-bottom: 1px solid var(--border-color);">
                                            <fmt:formatNumber value="${contract.depositAmount}" pattern="#,##0"/> VND
                                        </td>
                                    </tr>
                                    <tr style="border-top: 1px solid var(--border-color);">
                                        <td style="padding: 12px 0 0 0; color: var(--text-primary); font-weight: 700; font-size: 16px;">TỔNG TIỀN HỢP ĐỒNG</td>
                                        <td style="padding: 12px 0 0 0; font-weight: 700; font-size: 18px; text-align: right; color: var(--primary);">
                                            <fmt:formatNumber value="${contract.totalAmount}" pattern="#,##0"/> VND
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <!-- Cột phải: Trạng thái và thao tác -->
                        <div style="display: flex; flex-direction: column; justify-content: flex-start;">
                            <div>
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--text-secondary); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Thông Tin Hợp Đồng</h4>
                                <div style="background: #FAFBFD; border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 20px; font-size: 14px; line-height: 1.6; color: var(--text-secondary); text-align: left;">
                                    Nội dung đầy đủ của hợp đồng (bao gồm các điều khoản pháp lý và điều khoản bổ sung) được hiển thị dưới dạng bản in ở phần dưới trang này. Bạn có thể nhấn <strong>"In hợp đồng"</strong> để in hoặc lưu thành PDF.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="no-print" style="display: flex; gap: 16px; justify-content: flex-end; margin-bottom: 24px;">
                    <a href="${pageContext.request.contextPath}/contracts" class="btn btn-outline">Quay lại danh sách</a>
                    <button type="button" class="btn btn-outline" onclick="window.print()" style="display: inline-flex; align-items: center; gap: 8px;">
                        <span class="material-symbols-outlined" style="font-size: 20px; vertical-align: middle;">print</span> In hợp đồng
                    </button>
                    <c:if test="${contract.status == 'DRAFT'}">
                        <form action="${pageContext.request.contextPath}/contracts" method="POST" style="margin: 0;">
                            <input type="hidden" name="action" value="activate"/>
                            <input type="hidden" name="contractId" value="${contract.contractId}"/>
                            <button type="submit" class="btn btn-success">Ký kết & Kích hoạt</button>
                        </form>
                    </c:if>
                </div>

                <%-- Legally formalized printable A4 contract document layout — placed OUTSIDE .card so it is not hidden by @media print rules targeting .card --%>
                <div class="print-contract-document">
                                    <!-- Page 1 -->
                                    <div class="print-page">
                                        <div class="print-header">
                                            <div class="national-title">CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</div>
                                            <div class="national-subtitle">Độc lập - Tự do - Hạnh phúc</div>
                                            <div class="line-divider"></div>
                                            <h2 class="contract-title">HỢP ĐỒNG CHO THUÊ XE Ô TÔ TỰ LÁI</h2>
                                            <p class="contract-number">Số: ${contract.contractNumber}</p>
                                        </div>

                                        <div class="contract-bases">
                                            <p>- <i>Căn cứ Bộ Luật Dân sự số 91/2015/QH13 có hiệu lực thi hành từ ngày 01/01/2017;</i></p>
                                            <p>- <i>Căn cứ Luật Thương mại số 36/2005/QH11 có hiệu lực thi hành từ ngày 01/01/2006;</i></p>
                                            <p>- <i>Căn cứ Chính sách và Quy chế hoạt động của hệ thống ứng dụng đặt xe CarPro;</i></p>
                                            <p>- <i>Căn cứ theo nhu cầu thuê phương tiện và khả năng cung cấp dịch vụ của hai Bên.</i></p>
                                        </div>

                                        <p class="preamble" style="margin-top: 15px;">
                                            Hôm nay, ngày ${contract.createdAt.dayOfMonth} tháng ${contract.createdAt.monthValue} năm ${contract.createdAt.year}, tại văn phòng CarPro, hai Bên tiến hành ký kết Hợp đồng này bao gồm:
                                        </p>

                                        <div class="party-info">
                                            <h3 class="party-title">BÊN CHO THUÊ XE (BÊN A)</h3>
                                            <table class="party-table">
                                                <tr>
                                                    <td style="width: 50%;">Đại diện bởi: <strong>${creator != null ? creator.fullName : 'TRẦN THANH BẰNG'}</strong></td>
                                                    <td style="width: 50%;">Số điện thoại: <strong>${creator != null && creator.phone != null ? creator.phone : '0918.212.460'}</strong></td>
                                                </tr>
                                                <tr>
                                                    <td>CCCD số: <strong>019096006601</strong></td>
                                                    <td>Cấp ngày: <strong>09/12/2021</strong> tại: <strong>Cục CS QLHC</strong></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">Địa chỉ thường trú: <strong>Xóm Thượng Lập, Phổ Yên, Tỉnh Thái Nguyên</strong></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">Địa chỉ tạm trú: <strong>CH 1109 Tòa S4.01 TDP 12 Tây Mỗ - Hà Nội</strong></td>
                                                </tr>
                                            </table>

                                            <h3 class="party-title" style="margin-top: 15px;">BÊN THUÊ XE (BÊN B)</h3>
                                            <table class="party-table">
                                                <tr>
                                                    <td style="width: 50%;">Khách hàng: <strong>${customer.fullName}</strong></td>
                                                    <td style="width: 50%;">Số điện thoại: <strong>${customer.phone != null ? customer.phone : '........................'}</strong></td>
                                                </tr>
                                                <tr>
                                                    <td>CCCD số: <strong>${customerProfile.idCardNumber != null && !customerProfile.idCardNumber.isEmpty() ? customerProfile.idCardNumber : '........................'}</strong></td>
                                                    <td>Email liên hệ: <strong>${customer.email}</strong></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">Địa chỉ thường trú: <strong>${customerProfile.address != null && !customerProfile.address.isEmpty() ? customerProfile.address : '........................'}</strong></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">Giấy phép lái xe số: <strong>${customerProfile.driverLicenseNumber != null && !customerProfile.driverLicenseNumber.isEmpty() ? customerProfile.driverLicenseNumber : '........................'}</strong></td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 15px;">
                                            <h3 class="clause-title">ĐIỀU 1: ĐỐI TƯỢNG HỢP ĐỒNG</h3>
                                            <p>Bên A đồng ý cho Bên B thuê 01 (một) chiếc xe ô tô tự lái có thông tin như dưới đây:</p>
                                            <table class="vehicle-table">
                                                <tr>
                                                    <th>Biển số xe</th>
                                                    <td style="font-weight: bold; width: 30%;">${car.licensePlate}</td>
                                                    <th>Nhãn hiệu</th>
                                                    <td style="width: 30%;">${car.brand} ${car.model}</td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="page-footer-num">Trang 1/5</div>
                                    </div>

                                    <!-- Page 2 -->
                                    <div class="print-page">
                                        <div class="contract-clause" style="margin-top: 0;">
                                            <table class="vehicle-table" style="margin-top: 0; width: 100%;">
                                                <tr>
                                                    <th style="width: 25%;">Sản xuất năm</th>
                                                    <td style="width: 25%;">${car.year}</td>
                                                    <th style="width: 25%;">Màu sắc</th>
                                                    <td style="width: 25%;">${car.color}</td>
                                                </tr>
                                                <tr>
                                                    <th>Giấy đăng ký xe số</th>
                                                    <td>20004203</td>
                                                    <th>Ngày cấp</th>
                                                    <td>26/02/2025</td>
                                                </tr>
                                                <tr>
                                                    <th>Cấp tại</th>
                                                    <td>phó Yên Thái Nguyên</td>
                                                    <th>Tên chủ xe</th>
                                                    <td>Trần Thanh Bằng</td>
                                                </tr>
                                            </table>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 2: THỜI GIAN THUÊ, PHỤ PHÍ PHÁT SINH</h3>
                                            <h4 class="clause-subtitle">2.1 Thời gian thuê:</h4>
                                            <p style="margin-left: 10px;">- Từ: <strong>${contract.startDate.format(hourFormatter)}</strong> giờ <strong>${contract.startDate.format(minuteFormatter)}</strong> phút, ngày <strong>${contract.startDate.format(dateOnlyFormatter)}</strong></p>
                                            <p style="margin-left: 10px;">- Đến: <strong>${contract.endDate.format(hourFormatter)}</strong> giờ <strong>${contract.endDate.format(minuteFormatter)}</strong> phút, ngày <strong>${contract.endDate.format(dateOnlyFormatter)}</strong></p>
                                            <h4 class="clause-subtitle" style="margin-top: 10px;">2.2 Phụ phí phát sinh:</h4>
                                            <p>Quy định chi tiết tại phần thông tin xe hiển thị trên ứng dụng CarPro (hoặc ứng dụng Mioto liên kết).</p>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 3: GIÁ TRỊ HỢP ĐỒNG, HÌNH THỨC THANH TOÁN</h3>
                                            <h4 class="clause-subtitle">3.1 Giá trị Hợp đồng:</h4>
                                            <p style="margin-left: 10px;">- Đơn giá thuê xe: <strong><fmt:formatNumber value="${contract.dailyRate}" pattern="#,##0"/></strong> VND/ngày</p>
                                            <p style="margin-left: 10px;">- Giá trị Hợp đồng: <strong><fmt:formatNumber value="${contract.totalAmount}" pattern="#,##0"/></strong> VND</p>
                                            <p class="note" style="margin-left: 10px; font-style: italic;">(Giá trị Hợp đồng chưa bao gồm các khoản phụ phí phát sinh. Phụ phí được Bên B thanh toán cho Bên A khi kết thúc chuyến đi)</p>

                                            <h4 class="clause-subtitle" style="margin-top: 10px;">3.2 Chọn 1 trong 2 hình thức thanh toán mà các Bên đã thỏa thuận dưới đây:</h4>
                                            <p style="margin-left: 10px; display: flex; align-items: flex-start; gap: 8px; margin-bottom: 6px;">
                                                <span class="checkbox-box">[ ]</span>
                                                Bên B thanh toán trước 40% giá trị Hợp đồng khi kết nối thành công với Bên A thông qua ứng dụng CarPro. Ngay sau khi ký Hợp đồng này, Bên B thanh toán 60% giá trị Hợp đồng bằng tiền mặt/chuyển khoản cho Bên A.
                                            </p>
                                            <p style="margin-left: 10px; display: flex; align-items: flex-start; gap: 8px;">
                                                <span class="checkbox-box">[ ]</span>
                                                Bên B thanh toán 100% giá trị Hợp đồng khi kết nối thành công với Bên A thông qua ứng dụng CarPro.
                                            </p>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 4: QUYỀN VÀ NGHĨA VỤ CỦA BÊN A</h3>
                                            <h4 class="clause-subtitle">4.1 Quyền của Bên A:</h4>
                                            <p>- Nhận đủ tiền thuê theo phương thức đã thỏa thuận.</p>
                                            <p>- Khi hết hạn Hợp đồng có quyền nhận lại tài sản thuê như tình trạng thỏa thuận ban đầu, trừ hao mòn tự nhiên.</p>
                                            <p>- Trường hợp xe có phát sinh sự cố trong chuyến đi dẫn đến phải đưa xe đi kiểm tra, sửa chữa, Bên A có quyền yêu cầu Bên B cùng tham gia vào quá trình bao gồm nhưng không giới hạn: liên hệ bảo hiểm, cùng đi giám định và sửa chữa,... Trường hợp các Bên có thỏa thuận khác, phải ghi nhận thông tin ở Biên bản bàn giao xe.</p>
                                            <p>- Có quyền đơn phương chấm dứt Hợp đồng và yêu cầu bồi thường thiệt hại nếu Bên B có các hành vi sử dụng tài sản thuê không đúng mục đích như đã thỏa thuận, làm hư hỏng, mất mát tài sản thuê, giao xe cho người khác sử dụng mà không có sự đồng ý của Bên A.</p>
                                            <p>- Báo cho Cơ quan Công an và CarPro khi Bên A không liên lạc được với Bên B hoặc Bên B tắt/tháo thiết bị định vị trên xe hoặc quá thời gian thuê xe tại Hợp đồng này mà Bên B không hoàn trả xe cho Bên A.</p>
                                            <p>- Yêu cầu Bên B thực hiện nộp phạt vi phạm hành chính trong thời gian Bên B thuê xe (phạt nguội). Trường hợp Bên B không thể đi nộp phạt thì phải cung cấp giấy phép lái xe của Bên B và thanh toán trước chi phí phạt theo lỗi vi phạm cho Bên A để Bên A hỗ trợ thực hiện.</p>
                                            <p>- Đối với trường hợp các Bên có thỏa thuận về việc đặt cọc tài sản, Bên A có quyền giữ tài sản đặt cọc của Bên B từ lúc nhận xe đến khi Bên B hoàn tất việc trả xe và các khoản chi phí phát sinh (nếu có).</p>
                                        </div>
                                        <div class="page-footer-num">Trang 2/5</div>
                                    </div>

                                    <!-- Page 3 -->
                                    <div class="print-page">
                                        <div class="contract-clause" style="margin-top: 0;">
                                            <h4 class="clause-subtitle" style="margin-top: 0;">4.2 Nghĩa vụ của Bên A:</h4>
                                            <p>- Chịu trách nhiệm pháp lý về nguồn gốc và quyền sở hữu của xe.</p>
                                            <p>- Giao đúng xe và toàn bộ giấy tờ liên quan đến xe trong tình trạng xe an toàn, vệ sinh sạch sẽ nhằm đảm bảo chất lượng dịch vụ khi Bên B sử dụng. Các giấy tờ xe liên quan bao gồm: giấy đăng ký xe ô tô (bản photo sao y trong thời hạn 06 tháng), giấy kiểm định xe ô tô (bản chính), giấy bảo hiểm xe ô tô bắt buộc (bản chính).</p>
                                            <p>- Giao xe tại địa điểm bàn giao xe và đúng thời gian theo Hợp đồng này, trước khi giao xe cho Bên B, phải kiểm tra, đối chiếu thông tin khách thuê, sao chụp lại các giấy tờ nhân thân cần thiết để phục vụ nhu cầu liên hệ sau này.</p>
                                            <p>- Tự chịu trách nhiệm trong trường hợp ký Hợp đồng và giao xe cho khách thuê không đúng với thông tin đã giao kết trên Ứng dụng CarPro.</p>
                                            <p>- Đối với trường hợp các bên có thỏa thuận về việc đặt cọc tài sản: (i) Bên A chịu mọi trách nhiệm chi trả hoặc đền bù trong trường hợp tài sản đặt cọc của Bên B bị thiệt hại do lỗi Bên A; và (ii) Bên A có trách nhiệm hoàn trả đầy đủ tài sản đặt cọc của Bên B khi 2 Bên đã hoàn tất Hợp đồng và Bên B đã thanh toán đầy đủ các chi phí phát sinh (trường hợp có nghĩa vụ chưa hoàn thành, các Bên ghi nhận sự việc phát sinh vào Biên bản bàn giao xe để làm căn cứ).</p>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 5: QUYỀN VÀ NGHĨA VỤ CỦA BÊN B</h3>
                                            <h4 class="clause-subtitle">5.1 Quyền của Bên B:</h4>
                                            <p>- Nhận đúng xe và các giấy tờ liên quan đến xe theo Hợp đồng này.</p>
                                            <p>- Sửa chữa xe trong trường hợp cấp thiết. Trong trường hợp này, Bên B phải thông báo trước cho Bên A về tình trạng xe đang gặp phải và những vấn đề cần khắc phục trước khi tiến hành sửa chữa.</p>
                                            <p>- Yêu cầu Bên A sửa chữa nếu xe có hư hỏng do lỗi của Bên A hoặc do hao mòn tự nhiên của xe; và bồi thường thiệt hại nếu Bên A chậm giao hoặc giao xe không đúng như thỏa thuận.</p>
                                            <p>- Yêu cầu Bên A cung cấp hóa đơn, giấy tờ thể hiện chi phí sửa chữa trong trường hợp Bên B thay mặt Bên A làm việc với nhà bảo hiểm, gara để sửa chữa xe hư hỏng do lỗi của Bên B.</p>
                                            <p>- Đơn phương chấm dứt Hợp đồng và yêu cầu bồi thường thiệt hại nếu Bên A thực hiện các hành vi sau:</p>
                                            <p style="margin-left: 15px; text-indent: -15px;">+ Bên A giao xe không đúng thời hạn như thỏa thuận, trừ trường hợp bất khả kháng (Trường hợp bất khả kháng được hiểu là một Bên cố gắng thực hiện bằng mọi biện pháp để thực hiện nghĩa vụ của mình nhưng không thể thực hiện được vì trở ngại khách quan: mưa bão, dịch bệnh...). Bên nào viện dẫn trường hợp bất khả kháng thì Bên đó có nghĩa vụ chứng minh. Trường hợp giao xe chậm gây thiệt hại cho Bên B thì phải bồi thường.</p>
                                            <p style="margin-left: 15px; text-indent: -15px;">+ Xe có khuyết tật dẫn đến Bên B không đạt được mục đích thuê mà Bên B không biết.</p>
                                            <p style="margin-left: 15px; text-indent: -15px;">+ Xe có tranh chấp về quyền sở hữu giữa Bên A với Bên ba mà Bên B không biết dẫn đến Bên B không xác lập được mục đích sử dụng xe trong quá trình thuê như đã thỏa thuận.</p>

                                            <h4 class="clause-subtitle" style="margin-top: 10px;">5.2 Nghĩa vụ của Bên B:</h4>
                                            <p>- Cung cấp và tự chịu trách nhiệm về các thông tin nhân thân cần thiết theo nội dung ở phần đầu Hợp đồng và Giấy phép lái xe của mình.</p>
                                            <p>- Kiểm tra kỹ xe trước khi nhận và trước khi hoàn trả xe. Quay chụp tình trạng xe để làm căn cứ đồng thời ký xác nhận tình trạng xe khi nhận và khi hoàn trả.</p>
                                            <p>- Thanh toán cho Bên A đầy đủ tiền thuê xe và thanh toán toàn bộ phụ phí phát sinh trong chuyến đi ngay tại thời điểm hoàn trả xe.</p>
                                        </div>
                                        <div class="page-footer-num">Trang 3/5</div>
                                    </div>

                                    <!-- Page 4 -->
                                    <div class="print-page">
                                        <div class="contract-clause" style="margin-top: 0;">
                                            <p style="margin-top: 0;">- Kiểm tra kỹ và tự chịu trách nhiệm đối với tư trang, tài sản cá nhân của mình trước khi trả xe, đảm bảo không để quên, thất lạc đồ trên xe.</p>
                                            <p>- Đối với trường hợp các bên thỏa thuận về đặt cọc tài sản, Bên B cung cấp tài sản đặt cọc trước khi nhận xe và chịu trách nhiệm pháp lý về nguồn gốc, quyền sở hữu của tài sản đặt cọc bao gồm: CCCD gắn chip/ Passport và tiền mặt 15 triệu đồng/xe máy kèm giấy đăng ký xe.</p>
                                            <p>- Tuân thủ quy định trả xe như đã được ký kết trong Hợp đồng. Nếu trả xe không đúng thời hạn, Bên B sẽ phải trả thêm tiền phụ trội, và số tiền trả thêm sẽ được tính theo giờ/ngày như quy định tại Điều 2 Hợp đồng này.</p>
                                            <p>- Bên B chịu trách nhiệm đền bù mọi thất thoát về phụ tùng, phụ kiện của xe: đền bù 100% theo giá phụ tùng chính hãng nếu tráo đổi linh kiện, phụ tùng; chịu 100% chi phí sửa chữa nếu có xảy ra hỏng hóc được xác định do lỗi của Bên B, địa điểm sửa chữa theo sự chỉ định của Bên A hoặc 2 Bên tự thỏa thuận. Các ngày xe nghỉ không chạy được do lỗi của Bên B thì Bên B phải trả tiền hoàn toàn trong các ngày đó, giá được tính bằng giá thuê trong Hợp đồng (hoặc các bên có thỏa thuận khác). Ngoài ra, nếu xe trong tình trạng không được sạch sẽ, Bên B sẽ phải chịu thêm khoản phí vệ sinh xe (hoặc tùy 2 Bên tự thỏa thuận).</p>
                                            <p>- Nghiêm túc chấp hành đúng luật lệ giao thông đường bộ. Tự chịu trách nhiệm dân sự, hình sự, hành chính trong suốt thời gian thuê xe. Có nghĩa vụ thực hiện nộp phạt vi phạm hành chính trong lĩnh vực giao thông đường bộ căn cứ vào thời gian thuê xe của Hợp đồng này và thông báo phạt vi phạm từ cơ quan nhà nước có thẩm quyền.</p>
                                            <p>- Tuyệt đối không cho người khác thuê lại và không sử dụng xe cho các hành vi trái pháp luật: cầm cố, đua xe, chở hàng lậu, hàng cấm, ... Không giao tay lái cho người không đủ năng lực hành vi, không có GPLX từ B1 trở lên. Trường hợp Bên A có căn cứ thấy rằng Bên B có dấu hiệu vi phạm thì Bên A có quyền đơn phương chấm dứt hợp đồng, đồng thời sẽ thông báo với Cơ quan Công an và thực hiện biện pháp thu hồi xe. Bên B phải hoàn toàn chịu trách nhiệm hình sự trước pháp luật và chịu các chi phí tổn thất phát sinh khác.</p>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 6: CHÍNH SÁCH BẢO HIỂM THEO CHUYẾN ĐI</h3>
                                            <h4 class="clause-subtitle">6.1 Đối tượng bảo hiểm và thời gian bảo hiểm:</h4>
                                            <p>- Chỉ áp dụng với chuyến đi có mua bảo hiểm chuyến trên ứng dụng đặt xe CarPro (hoặc ứng dụng liên kết).</p>
                                            <p>- Thời gian bảo hiểm tính từ thời gian Bên B bắt đầu và hết hiệu lực theo thời gian Bên B kết thúc chuyến đi đã đăng ký trên ứng dụng CarPro.</p>

                                            <h4 class="clause-subtitle" style="margin-top: 10px;">6.2 Phạm vi bảo hiểm:</h4>
                                            <p>Nhà Bảo hiểm chịu trách nhiệm bồi thường những thiệt hại vật chất do thiên tai, tai nạn bất ngờ, va chạm xe, không lường trước được trong những trường hợp sau:</p>
                                            <p style="margin-left: 15px;">• Đâm, va (bao gồm cả va chạm với vật thể khác ngoài xe cơ giới)</p>
                                            <p style="margin-left: 15px;">• Hỏa hoạn, cháy, nổ</p>
                                            <p style="margin-left: 15px;">• Thủy kích (khấu trừ 20% số tiền bảo hiểm, tối thiểu 3.000.000 VND)</p>
                                            <p>Mức khấu trừ: 2.000.000 VND/vụ (không bao gồm trường hợp giảm trừ bồi thường theo quy định của Nhà bảo hiểm).</p>

                                            <h4 class="clause-subtitle" style="margin-top: 10px;">6.3 Nghĩa vụ:</h4>
                                            <p>- Quay chụp tình trạng xe để làm căn cứ đồng thời ký xác nhận tình trạng xe khi nhận và khi hoàn trả.</p>
                                            <p>- Trường hợp chuyến đi được hỗ trợ bảo hiểm chuyến do CarPro liên kết, khi xảy ra sự cố va chạm trong quá trình di chuyển, Bên B có trách nhiệm giữ nguyên hiện trường xảy ra sự cố và liên hệ ngay Tổng đài Nhà Bảo hiểm để khai báo và làm theo hướng dẫn xử lý.</p>
                                        </div>
                                        <div class="page-footer-num">Trang 4/5</div>
                                    </div>

                                    <!-- Page 5 -->
                                    <div class="print-page">
                                        <div class="contract-clause" style="margin-top: 0;">
                                            <p style="margin-top: 0;">- Bên B thông báo cho Bên A để nắm tình hình và phối hợp với Bên A để xử lý sự cố theo hướng dẫn của Nhà Bảo hiểm.</p>
                                            <p>- Bên B có trách nhiệm thanh toán chi phí theo quy định của Nhà Bảo hiểm.</p>
                                            <p>- Trường hợp Bên B gây ra sự cố nằm ngoài thời gian bảo hiểm hoặc phạm vi bảo hiểm hoặc thuộc phạm vi loại trừ bảo hiểm dẫn đến Nhà Bảo hiểm từ chối bồi thường thì Bên B có nghĩa vụ bồi thường toàn bộ tổn thất cho Bên A.</p>
                                            <p>- Các Bên có nghĩa vụ thực hiện theo những điều khoản về chính sách, quy định của nhà bảo hiểm: về chế tài, phạm vi bồi thường, mức bồi thường, trường hợp giảm trừ bồi thường và loại trừ bảo hiểm,...</p>
                                        </div>

                                        <div class="contract-clause" style="margin-top: 20px;">
                                            <h3 class="clause-title">ĐIỀU 7: ĐIỀU KHOẢN CHUNG</h3>
                                            <p>7.1 Hợp đồng này, Biên bản bàn giao xe và các phụ lục bổ sung Hợp đồng (nếu có) là bộ phận không tách rời của Hợp đồng, các Bên phải có nghĩa vụ thực hiện, cam kết thi hành đúng các điều khoản của Hợp đồng, không Bên nào tự ý đơn phương sửa đổi, đình chỉ hoặc hủy bỏ Hợp đồng. Mọi sự vi phạm phải được xử lý theo pháp luật.</p>
                                            <p>7.2 Trong quá trình thực hiện Hợp đồng, nếu có vấn đề phát sinh các Bên sẽ cùng bàn bạc giải quyết trên tinh thần hợp tác và tôn trọng lợi ích của cả hai Bên và được thể hiện bằng văn bản. Nếu không giải quyết được thì đưa ra Tòa án nhân dân có thẩm quyền để giải quyết. Bên thua kiện sẽ chịu toàn bộ chi phí.</p>
                                            <p>7.3 Hợp đồng này tự động chấm dứt khi Bên B hoàn trả xe cho Bên A và hai Bên hoàn tất mọi nghĩa vụ phát sinh từ Hợp đồng này.</p>
                                            <p>7.4 Hợp đồng có hiệu lực kể từ thời điểm ký kết và được lập thành 02 (hai) bản, mỗi Bên giữ 01 (một) bản.</p>

                                            <c:if test="${not empty contract.termsAndConditions}">
                                                <div class="custom-terms" style="margin-top: 15px; border-top: 1px dashed #000; padding-top: 10px;">
                                                    <h4 class="clause-subtitle" style="text-decoration: underline;">ĐIỀU KHOẢN BỔ SUNG KHÁC (NẾU CÓ):</h4>
                                                    <div style="font-size: 10pt; line-height: 1.4; white-space: pre-wrap; font-style: italic;">${contract.termsAndConditions}</div>
                                                </div>
                                            </c:if>
                                        </div>

                                        <div class="signature-block" style="margin-top: 30px;">
                                            <table style="width: 100%; border: none; text-align: center; font-size: 11pt;">
                                                <tr>
                                                    <td style="width: 50%; padding-bottom: 50px; vertical-align: top;">
                                                        <p style="font-weight: bold; margin: 0 0 5px 0; text-transform: uppercase;">ĐẠI DIỆN BÊN A (BÊN CHO THUÊ)</p>
                                                        <p style="font-size: 8.5pt; color: #666; margin: 0 0 15px 0;">(Ký, ghi rõ họ tên hoặc xác thực điện tử)</p>
                                                        <c:choose>
                                                            <c:when test="${contract.status == 'ACTIVE' || contract.status == 'COMPLETED'}">
                                                                <div style="border: 1.5px dashed green; color: green; width: 230px; margin: 0 auto; padding: 8px; border-radius: 4px; font-weight: bold; font-family: monospace; font-size: 8.5pt; background: #f9fff9; text-align: center; line-height: 1.4;">
                                                                    HỆ THỐNG CARPRO
                                                                    <br/>
                                                                    <span style="font-size: 9.5pt; color: #000; font-weight: bold;">ĐÃ KÝ ĐIỆN TỬ</span>
                                                                    <br/>
                                                                    <span style="font-size: 7.5pt; font-weight: normal; color: #666;">Bên A: ${creator != null ? creator.fullName : 'TRẦN THANH BẰNG'}</span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <p style="font-style: italic; color: #999; margin-top: 15px;">Chờ ký kết</p>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="width: 50%; padding-bottom: 50px; vertical-align: top;">
                                                        <p style="font-weight: bold; margin: 0 0 5px 0; text-transform: uppercase;">ĐẠI DIỆN BÊN B (BÊN THUÊ)</p>
                                                        <p style="font-size: 8.5pt; color: #666; margin: 0 0 15px 0;">(Ký, ghi rõ họ tên hoặc xác thực điện tử)</p>
                                                        <c:choose>
                                                            <c:when test="${contract.status == 'ACTIVE' || contract.status == 'COMPLETED'}">
                                                                <div style="border: 1.5px dashed green; color: green; width: 230px; margin: 0 auto; padding: 8px; border-radius: 4px; font-weight: bold; font-family: monospace; font-size: 8.5pt; background: #f9fff9; text-align: center; line-height: 1.4;">
                                                                    KHÁCH HÀNG XÁC NHẬN
                                                                    <br/>
                                                                    <span style="font-size: 9.5pt; color: #000; font-weight: bold;">ĐÃ KÝ ĐIỆN TỬ</span>
                                                                    <br/>
                                                                    <span style="font-size: 7.5pt; font-weight: normal; color: #666;">Bên B: ${customer.fullName}</span>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <p style="font-style: italic; color: #999; margin-top: 15px;">Chờ ký kết</p>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                                <tr style="height: 30px;"></tr>
                                                <tr>
                                                    <td style="font-weight: bold; text-decoration: underline;">${creator != null ? creator.fullName : 'TRẦN THANH BẰNG'}</td>
                                                    <td style="font-weight: bold; text-decoration: underline;">${customer.fullName}</td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="page-footer-num">Trang 5/5</div>
                                    </div>
                </div>
            </c:when>

            <%-- TRƯỜNG HỢP 2: BIỂU MẪU SOẠN THẢO HỢP ĐỒNG MỚI --%>
            <c:when test="${not empty booking}">
                <!-- Định dạng tiền trước để đưa vào ô nhập (readonly) và các điều khoản hợp đồng -->
                <fmt:formatNumber var="formattedDailyRate" value="${car.dailyRate}" pattern="#,##0"/>
                <fmt:formatNumber var="formattedDepositAmount" value="${booking.depositAmount}" pattern="#,##0"/>
                <fmt:formatNumber var="formattedTotalAmount" value="${booking.totalAmount}" pattern="#,##0"/>

                <div class="card" style="margin-bottom: 24px;">
                    <div style="border-bottom: 1px solid var(--border-color); padding-bottom: 16px; margin-bottom: 24px;">
                        <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin-bottom: 4px;">SOẠN THẢO HỢP ĐỒNG THUÊ XE</h2>
                        <p style="font-size: 14px; color: var(--text-secondary);">Khởi tạo hợp đồng cho đơn đặt xe số: <strong style="color: var(--primary);">#${booking.bookingId}</strong></p>
                    </div>

                    <form action="${pageContext.request.contextPath}/contracts" method="POST">
                        <input type="hidden" name="bookingId" value="${booking.bookingId}"/>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
                            <!-- Cột trái: Tóm tắt thông tin từ Đơn đặt xe (chỉ đọc) -->
                            <div>
                                <div style="margin-bottom: 24px; background: var(--primary-light); padding: 20px; border-radius: var(--radius);">
                                    <h4 style="font-size: 15px; font-weight: 700; color: var(--primary); margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                                        <span>&#128196;</span> Thông tin Tóm tắt đơn đặt xe
                                    </h4>
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 14px; text-align: left;">
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Khách hàng</span><br/>
                                            <strong>${customer.fullName}</strong>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Số điện thoại</span><br/>
                                            <strong>${customer.phone != null ? customer.phone : '-'}</strong>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Phương tiện</span><br/>
                                            <strong>${car.brand} ${car.model} (${car.licensePlate})</strong>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Màu sắc / Số ghế</span><br/>
                                            <strong>${car.color} / ${car.seats} chỗ</strong>
                                        </div>
                                    </div>
                                </div>

                                <div style="margin-bottom: 20px; text-align: left;">
                                    <label style="display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary);">Thời hạn thuê xe</label>
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Bắt đầu nhận xe</span>
                                            <input type="text" class="form-control" value="${booking.startDate != null ? booking.startDate.format(dateTimeFormatter) : ''}" readonly style="background: var(--bg-body); cursor: not-allowed;"/>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 12px;">Kết thúc thuê trả xe</span>
                                            <input type="text" class="form-control" value="${booking.endDate != null ? booking.endDate.format(dateTimeFormatter) : ''}" readonly style="background: var(--bg-body); cursor: not-allowed;"/>
                                        </div>
                                    </div>
                                </div>

                                <div style="margin-bottom: 20px; text-align: left;">
                                    <label style="display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary);">Chi phí tài chính (Tự động tính toán)</label>
                                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;">
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 11px;">Đơn giá ngày</span>
                                            <input type="text" class="form-control" value="${formattedDailyRate} VND" readonly style="background: var(--bg-body); cursor: not-allowed; font-weight:600;"/>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 11px;">Tiền cọc yêu cầu</span>
                                            <input type="text" class="form-control" value="${formattedDepositAmount} VND" readonly style="background: var(--bg-body); cursor: not-allowed; color: var(--danger); font-weight:700;"/>
                                        </div>
                                        <div>
                                            <span style="color: var(--text-secondary); font-size: 11px;">Tổng cộng tiền thuê</span>
                                            <input type="text" class="form-control" value="${formattedTotalAmount} VND" readonly style="background: var(--bg-body); cursor: not-allowed; color: var(--primary); font-weight:700;"/>
                                        </div>
                                    </div>
                                </div>

                                <div style="padding: 16px; background: rgba(255,206,32,0.1); border-left: 4px solid var(--warning); border-radius: var(--radius-sm); font-size: 13px; line-height: 1.5; text-align: left;">
                                    <strong>Lưu ý: </strong> Hợp đồng sau khi tạo lập sẽ được lưu ở trạng thái <strong>Nháp (DRAFT)</strong>. Nhân viên cần hoàn tất thủ tục bàn giao thực tế và khách hàng đồng ý ký trước khi chuyển đổi trạng thái sang <strong>Có hiệu lực (ACTIVE)</strong>.
                                </div>
                            </div>

                            <!-- Cột phải: Soạn thảo Điều khoản và nút bấm gửi -->
                            <div style="display: flex; flex-direction: column; justify-content: space-between;">
                                <div class="form-group" style="margin-bottom: 16px; text-align: left;">
                                    <label style="display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary);">Nội dung Điều khoản và Cam kết của Hợp đồng</label>

                                    <c:set var="defaultTerms" value="- Phí trả xe trễ giờ thỏa thuận: 100.000 đ/giờ.&#10;- Phí phụ trội quãng đường: 5.000 đ/km (vượt quá 300km/ngày).&#10;- Phí rửa xe, dọn vệ sinh nếu trả xe bẩn: 200.000 đ.&#10;- Khách hàng cam kết chịu các chi phí cầu đường, phạt nguội phát sinh trong thời gian thuê."/>

                                    <textarea class="form-control" name="termsAndConditions" rows="18" style="font-family: inherit; font-size: 13px; line-height: 1.6; padding: 16px; height: 380px; resize: none;">${defaultTerms}</textarea>
                                </div>

                                <div style="display: flex; gap: 16px; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 20px;">
                                    <a href="${pageContext.request.contextPath}/bookings/manage" class="btn btn-outline">Hủy bỏ</a>
                                    <button type="submit" class="btn btn-primary">Xác nhận & Tạo Hợp đồng Nháp</button>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </c:when>
        </c:choose>
    </c:if>
</div>

<style>
    .print-contract-document p {
        margin: 0 0 8px 0;
        font-size: 11pt;
        text-align: justify;
    }
    .print-contract-document .print-header {
        text-align: center;
        margin-bottom: 20px;
    }
    .print-contract-document .national-title {
        font-size: 13pt;
        font-weight: bold;
        text-transform: uppercase;
    }
    .print-contract-document .national-subtitle {
        font-size: 11pt;
        font-weight: bold;
        margin-top: 5px;
    }
    .print-contract-document .line-divider {
        margin: 5px auto;
        width: 120px;
        border-bottom: 1.5px solid #000;
    }
    .print-contract-document .contract-title {
        font-size: 15pt;
        font-weight: bold;
        margin: 15px 0 5px 0;
        text-transform: uppercase;
    }
    .print-contract-document .contract-number {
        font-size: 10pt;
        font-style: italic;
    }
    .print-contract-document .party-title {
        font-size: 11pt;
        font-weight: bold;
        text-transform: uppercase;
        margin: 15px 0 8px 0;
        border-bottom: 1px dashed #000;
        padding-bottom: 3px;
    }
    .print-contract-document .party-table,
    .print-contract-document .vehicle-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 10px;
        font-size: 10.5pt;
    }
    .print-contract-document .party-table td {
        padding: 4px 0;
        vertical-align: top;
    }
    .print-contract-document .vehicle-table th,
    .print-contract-document .vehicle-table td {
        border: 1px solid #000;
        padding: 6px 10px;
        text-align: left;
    }
    .print-contract-document .vehicle-table th {
        background: #f2f2f2;
        font-weight: bold;
    }
    .print-contract-document .clause-title {
        font-size: 11pt;
        font-weight: bold;
        margin: 15px 0 8px 0;
        text-transform: uppercase;
    }
    .print-contract-document .clause-subtitle {
        font-size: 11pt;
        font-weight: bold;
        margin: 10px 0 5px 0;
    }
    .print-contract-document .checkbox-box {
        font-family: monospace;
        font-weight: bold;
        font-size: 12pt;
    }
    .print-contract-document .page-footer-num {
        margin-top:auto;
        text-align: center;
        font-size: 10pt;
        font-style: italic;
    }

    @media print {
        /* Hide web page menus, sidebars, footers, headers and actions */
        body > aside,
        body > header,
        aside,
        header,
        footer,
        .bk-page-header,
        .bk-breadcrumb,
        .btn,
        button,
        a,
        form,
        .bk-btn,
        .card,
        .alert,
        .no-print {
            display: none !important;
        }

        html, body {
            background: #fff !important;
            color: #000 !important;
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;
            height: auto !important;
        }

        .page-content {
            margin: 0 !important;
            padding: 0 !important;
            max-width: 100% !important;
            box-shadow: none !important;
            border: none !important;
            background: transparent !important;
        }

        .print-contract-document {
            display: block !important;
            background: transparent !important;
            padding: 0 !important;
            margin: 0 !important;
            max-height: none !important;
            overflow: visible !important;
        }

        .print-page {
            display: flex !important;
            flex-direction: column !important;
            background: #fff !important;
            width: 100% !important;
            height: 296mm !important; /* Force exact A4 height */
            padding: 15mm 15mm 20mm 15mm !important;
            margin: 0 !important;
            box-shadow: none !important;
            page-break-after: always !important;
            box-sizing: border-box !important;
            position: relative !important;
        }

        .print-page:last-child {
            page-break-after: avoid !important;
        }
    }

    @media screen {
        .print-contract-document {
            display: block !important;
            background: #e2e2e6 !important; /* Gray background */
            padding: 40px 20px !important;
            max-width: 900px !important;
            margin: 0 auto !important;
            border-radius: 12px !important;
        }
        .print-page {
            background: #fff !important;
            width: 210mm !important;
            min-height: 297mm !important;
            margin: 0 auto 30px auto !important;
            padding: 20mm 15mm !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
            position: relative !important;
            box-sizing: border-box !important;
            transform-origin: top center;
        }
        .print-page:last-child {
            margin-bottom: 0 !important;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
