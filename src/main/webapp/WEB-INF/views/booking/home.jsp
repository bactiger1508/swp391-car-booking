<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Trang chủ - CarPro"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <h2>Chào mừng đến với Hệ thống CarPro</h2>
        <p>Hệ thống quản lý thuê ô tô tự lái thông minh — Khám phá các dòng xe sẵn sàng phục vụ bạn.</p>
    </div>
</div>

<div class="bk-card" style="margin-bottom:24px;background:linear-gradient(135deg, var(--primary) 0%, var(--primary-container) 100%);color:#fff;border:none;">
    <div style="max-width:600px;">
        <h3 style="font-size:24px;font-weight:700;color:#fff;margin-bottom:8px;">Hành trình hoàn hảo của bạn bắt đầu từ đây</h3>
        <p style="font-size:14px;color:var(--on-primary-container);line-height:1.6;margin-bottom:20px;">
            Lựa chọn từ hàng chục mẫu xe Sedan đời mới, SUV gầm cao mạnh mẽ, xe bán tải đa năng hay những dòng xe điện tiết kiệm nhiên liệu ưu việt. Tất cả đều được bảo dưỡng định kỳ đạt chuẩn chất lượng an toàn cao nhất.
        </p>
        <a href="${pageContext.request.contextPath}/vehicles" class="bk-btn" style="background:#fff;color:var(--primary);font-weight:700;border:none;">
            <span class="material-symbols-outlined">directions_car</span> Khám phá ngay
        </a>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <h3 style="font-size:16px;font-weight:700;color:var(--primary);display:flex;align-items:center;gap:8px;">
            <span class="material-symbols-outlined" style="color:var(--primary);">workspace_premium</span> Danh sách Xe nổi bật đang có sẵn
        </h3>
        <a href="${pageContext.request.contextPath}/vehicles" class="bk-btn bk-btn-outline bk-btn-sm">
            <span class="material-symbols-outlined">visibility</span> Xem tất cả xe
        </a>
    </div>

    <c:if test="${not empty featuredCars}">
        <div style="overflow-x:auto;">
            <table class="bk-table">
                <thead>
                    <tr>
                        <th>Hãng xe</th>
                        <th>Dòng xe</th>
                        <th>Đời xe</th>
                        <th>Số chỗ ngồi</th>
                        <th>Hộp số</th>
                        <th>Giá thuê (Ngày)</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="car" items="${featuredCars}">
                        <tr>
                            <td style="font-weight:700;color:var(--primary);">${car.brand}</td>
                            <td style="font-weight:600;">${car.model}</td>
                            <td>${car.year}</td>
                            <td>${car.seats} chỗ</td>
                            <td>
                                <c:choose>
                                    <c:when test="${car.transmission == 'AUTOMATIC'}">Số tự động</c:when>
                                    <c:when test="${car.transmission == 'MANUAL'}">Số sàn</c:when>
                                    <c:otherwise>${car.transmission}</c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="font-weight:700;color:var(--primary);">
                                    <fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/>đ
                                </div>
                            </td>
                            <td class="text-right">
                                <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="bk-btn bk-btn-primary bk-btn-sm">
                                    Chi tiết xe
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    
    <c:if test="${empty featuredCars}">
        <div class="bk-empty">
            <span class="material-symbols-outlined">directions_car</span>
            <h3>Hiện tại tạm thời hết xe có sẵn</h3>
            <p>Hệ thống hiện tại chưa có xe ô tô nào khả dụng cho thuê. Vui lòng liên hệ hotline để biết thêm thông tin.</p>
        </div>
    </c:if>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
