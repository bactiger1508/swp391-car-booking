<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <h2>🚗 Thuê Xe</h2>
        <div class="subtitle">Hệ Thống Quản Lý</div>
    </div>
    <ul class="sidebar-menu">
        <li class="menu-section">Chính</li>
        <li><a href="${pageContext.request.contextPath}/home">🏠 Trang Chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/vehicles">🚘 Danh Sách Xe</a></li>

        <c:if test="${sessionScope.currentUser != null}">
            <li class="menu-section">Tài Khoản</li>
            <li><a href="${pageContext.request.contextPath}/profile">👤 Hồ Sơ</a></li>

            <c:if test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                <li class="menu-section">Đặt Xe</li>
                <li><a href="${pageContext.request.contextPath}/bookings/create">📝 Đặt Xe Mới</a></li>
                <li><a href="${pageContext.request.contextPath}/bookings/my">📋 Chuyến Đi Của Tôi</a></li>
            </c:if>

            <c:if test="${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'}">
                <li class="menu-section">Nghiệp Vụ</li>
                <li><a href="${pageContext.request.contextPath}/vehicles/manage">⚙️ Quản Lý Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/vehicles/availability">📅 Lịch Trình Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/maintenance">🔧 Lịch Bảo Dưỡng</a></li>
                <li><a href="${pageContext.request.contextPath}/bookings/manage">📊 Quản Lý Đặt Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/bookings/approval">✅ Duyệt Đặt Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/contracts">📄 Quản Lý Hợp Đồng</a></li>
                <li><a href="${pageContext.request.contextPath}/handovers">🔑 Giao Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/returns">🔄 Nhận Lại Xe</a></li>
                <li><a href="${pageContext.request.contextPath}/additional-fees">💰 Phí Phát Sinh</a></li>
                <li><a href="${pageContext.request.contextPath}/payments/record">💳 Lịch Sử Thanh Toán</a></li>
                <li><a href="${pageContext.request.contextPath}/policies">⚖️ Cấu Hình Chính Sách</a></li>

                <li class="menu-section">Báo Cáo</li>
                <li><a href="${pageContext.request.contextPath}/reports/revenue">📈 Báo Cáo Doanh Thu</a></li>
                <li><a href="${pageContext.request.contextPath}/reports/vehicle-utilization">📊 Hiệu Suất Sử Dụng Xe</a></li>
            </c:if>

            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <li class="menu-section">Quản Trị Hệ Thống</li>
                <li><a href="${pageContext.request.contextPath}/users">👥 Quản Lý Người Dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/roles">🔐 Phân Quyền</a></li>
                <li><a href="${pageContext.request.contextPath}/tax-invoice-settings">🧾 Cấu Hình Thuế & Hóa Đơn</a></li>
            </c:if>
        </c:if>
    </ul>
</aside>
