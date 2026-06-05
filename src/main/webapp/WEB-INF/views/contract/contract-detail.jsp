<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
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

                        <!-- Cột phải: Các điều khoản điều kiện và thao tác -->
                        <div style="display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <h4 style="font-size: 16px; font-weight: 700; border-left: 4px solid var(--text-secondary); padding-left: 10px; margin-bottom: 16px; color: var(--text-primary);">Điều Khoản Và Điều Kiện Hợp Đồng</h4>
                                <div style="background: #FAFBFD; border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 20px; font-size: 14px; line-height: 1.6; color: var(--text-primary); white-space: pre-wrap; height: 380px; overflow-y: auto; text-align: left;">${contract.termsAndConditions}</div>
                            </div>

                            <div style="margin-top: 24px; display: flex; gap: 16px; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 20px;">
                                <a href="${pageContext.request.contextPath}/contracts" class="btn btn-outline">Quay lại danh sách</a>
                                <c:if test="${contract.status == 'DRAFT'}">
                                    <form action="${pageContext.request.contextPath}/contracts" method="POST" style="margin: 0;">
                                        <input type="hidden" name="action" value="activate"/>
                                        <input type="hidden" name="contractId" value="${contract.contractId}"/>
                                        <button type="submit" class="btn btn-success">Ký kết & Kích hoạt</button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
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
                                    <strong>Lưu ý nghiệp vụ:</strong> Hợp đồng sau khi tạo lập sẽ được lưu ở trạng thái <strong>Nháp (DRAFT)</strong>. Nhân viên cần hoàn tất thủ tục bàn giao thực tế và khách hàng đồng ý ký trước khi chuyển đổi trạng thái sang <strong>Có hiệu lực (ACTIVE)</strong>.
                                </div>
                            </div>

                            <!-- Cột phải: Soạn thảo Điều khoản và nút bấm gửi -->
                            <div style="display: flex; flex-direction: column; justify-content: space-between;">
                                <div class="form-group" style="margin-bottom: 16px; text-align: left;">
                                    <label style="display: block; font-size: 14px; font-weight: 600; margin-bottom: 8px; color: var(--text-primary);">Nội dung Điều khoản và Cam kết của Hợp đồng</label>
                                    
                                    <c:set var="defaultTerms" value="CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM&#10;Độc lập - Tự do - Hạnh phúc&#10;&#10;HỢP ĐỒNG CHO THUÊ XE TỰ LÁI&#10;&#10;ĐIỀU 1: ĐỐI TƯỢNG VÀ THỜI GIAN THUÊ&#10;- Loại xe thuê: ${car.brand} ${car.model} (Biển kiểm soát: ${car.licensePlate})&#10;- Thời gian thuê: Từ ${booking.startDate != null ? booking.startDate.format(dateTimeFormatter) : ''} đến ${booking.endDate != null ? booking.endDate.format(dateTimeFormatter) : ''}.&#10;&#10;ĐIỀU 2: GIÁ TRỊ HỢP ĐỒNG VÀ PHƯƠNG THỨC THANH TOÁN&#10;- Đơn giá thuê: ${formattedDailyRate} VND/ngày.&#10;- Tổng trị giá hợp đồng: ${formattedTotalAmount} VND.&#10;- Tiền đặt cọc tài sản: ${formattedDepositAmount} VND.&#10;&#10;ĐIỀU 3: NGHĨA VỤ CỦA BÊN THUÊ (BÊN B)&#10;1. Bên B cam kết có giấy phép lái xe hợp lệ và sử dụng xe đúng mục đích, không cho người khác thuê lại hoặc dùng xe vi phạm pháp luật.&#10;2. Thanh toán tiền cọc và tiền thuê đầy đủ, đúng hạn.&#10;3. Hoàn trả xe đúng giờ và đúng tình trạng bàn giao ban đầu.&#10;&#10;ĐIỀU 4: CÁC CHI PHÍ PHÁT SINH KHI TRẢ XE&#10;- Phí trả xe trễ giờ: 100.000 VND/giờ.&#10;- Phí phụ trội km (vượt quá giới hạn): 5.000 VND/km (quá 300 km/ngày).&#10;- Phí rửa xe, dọn vệ sinh nếu xe bị bẩn: 200.000 VND."/>
                                    
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

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
