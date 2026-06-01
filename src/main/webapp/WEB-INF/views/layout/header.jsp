<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : 'CarPro - Quản lý thuê xe'}</title>
    <meta name="description" content="Hệ thống quản lý thuê ô tô tự lái - CarPro">
    <%-- Load both global styles and booking-style (which contains modern variable tokens) --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
</head>
<body class="bk-layout">

<%-- SIDEBAR --%>
<aside class="bk-sidebar">
    <div class="bk-sidebar-brand">
        <h1>CarPro</h1>
        <p>Quản lý đội xe thông minh</p>
    </div>

<%
    String reqURI = request.getRequestURI();
    String ctx = request.getContextPath();
    String currentPath = reqURI.startsWith(ctx) ? reqURI.substring(ctx.length()) : reqURI;
    request.setAttribute("_cp", currentPath);
%>

    <nav class="bk-sidebar-nav">
        <a href="${pageContext.request.contextPath}/home" class="bk-sidebar-link ${_cp == '/home' || _cp == '/' ? 'active' : ''}">
            <span class="material-symbols-outlined">home</span> Trang chủ
        </a>
        <a href="${pageContext.request.contextPath}/vehicles" class="bk-sidebar-link ${_cp == '/vehicles' ? 'active' : ''}">
            <span class="material-symbols-outlined">directions_car</span> Danh sách xe
        </a>

        <c:if test="${sessionScope.currentUser != null}">
            <a href="${pageContext.request.contextPath}/profile" class="bk-sidebar-link ${_cp == '/profile' ? 'active' : ''}">
                <span class="material-symbols-outlined">person</span> Hồ sơ cá nhân
            </a>

            <c:if test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                <div class="bk-sidebar-section">Đặt Xe</div>
                <a href="${pageContext.request.contextPath}/bookings/create" class="bk-sidebar-link ${_cp == '/bookings/create' ? 'active' : ''}">
                    <span class="material-symbols-outlined">add_circle</span> Đặt xe mới
                </a>
                <a href="${pageContext.request.contextPath}/bookings/my" class="bk-sidebar-link ${_cp == '/bookings/my' || _cp == '/bookings/detail' ? 'active' : ''}">
                    <span class="material-symbols-outlined mi-filled">receipt_long</span> Đơn thuê của tôi
                </a>
                <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                    <span class="material-symbols-outlined">policy</span> Chính sách
                </a>
            </c:if>

            <c:if test="${sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN'}">
                <div class="bk-sidebar-section">Quản lý Đặt xe</div>
                <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-sidebar-link ${_cp == '/bookings/manage' ? 'active' : ''}">
                    <span class="material-symbols-outlined">assignment</span> Quản lý đặt xe
                </a>
                <a href="${pageContext.request.contextPath}/bookings/approval" class="bk-sidebar-link ${_cp == '/bookings/approval' ? 'active' : ''}">
                    <span class="material-symbols-outlined">fact_check</span> Duyệt đặt xe
                </a>
                <a href="${pageContext.request.contextPath}/bookings/calendar" class="bk-sidebar-link ${_cp == '/bookings/calendar' ? 'active' : ''}">
                    <span class="material-symbols-outlined">calendar_month</span> Lịch đặt xe
                </a>
                <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                    <span class="material-symbols-outlined">policy</span> Chính sách
                </a>

                <div class="bk-sidebar-section">Nghiệp vụ</div>
                <a href="${pageContext.request.contextPath}/vehicles/manage" class="bk-sidebar-link ${_cp == '/vehicles/manage' ? 'active' : ''}">
                    <span class="material-symbols-outlined">garage</span> Quản lý xe
                </a>
                <a href="${pageContext.request.contextPath}/contracts" class="bk-sidebar-link ${_cp == '/contracts' ? 'active' : ''}">
                    <span class="material-symbols-outlined">description</span> Hợp đồng
                </a>
                <a href="${pageContext.request.contextPath}/payments/record" class="bk-sidebar-link ${_cp == '/payments/record' ? 'active' : ''}">
                    <span class="material-symbols-outlined">payments</span> Nhật ký thanh toán
                </a>
                <a href="${pageContext.request.contextPath}/handovers" class="bk-sidebar-link ${_cp == '/handovers' ? 'active' : ''}">
                    <span class="material-symbols-outlined">key</span> Giao xe
                </a>
                <a href="${pageContext.request.contextPath}/returns" class="bk-sidebar-link ${_cp == '/returns' ? 'active' : ''}">
                    <span class="material-symbols-outlined">keyboard_return</span> Nhận lại xe
                </a>
                <a href="${pageContext.request.contextPath}/reports/revenue" class="bk-sidebar-link ${_cp == '/reports/revenue' ? 'active' : ''}">
                    <span class="material-symbols-outlined">analytics</span> Báo cáo
                </a>
                <a href="${pageContext.request.contextPath}/policies" class="bk-sidebar-link ${_cp == '/policies' ? 'active' : ''}">
                    <span class="material-symbols-outlined">settings_suggest</span> Cấu hình chính sách
                </a>
            </c:if>
            
            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <div class="bk-sidebar-section">Hệ thống</div>
                <a href="${pageContext.request.contextPath}/users" class="bk-sidebar-link ${_cp == '/users' ? 'active' : ''}">
                    <span class="material-symbols-outlined">manage_accounts</span> Quản lý thành viên
                </a>
                <a href="${pageContext.request.contextPath}/roles" class="bk-sidebar-link ${_cp == '/roles' ? 'active' : ''}">
                    <span class="material-symbols-outlined">security</span> Quyền & Vai trò
                </a>
                <a href="${pageContext.request.contextPath}/tax-invoice-settings" class="bk-sidebar-link ${_cp == '/tax-invoice-settings' ? 'active' : ''}">
                    <span class="material-symbols-outlined">receipt</span> Cấu hình hóa đơn thuế
                </a>
                <a href="${pageContext.request.contextPath}/admin/payment-settings" class="bk-sidebar-link ${_cp == '/admin/payment-settings' ? 'active' : ''}">
                    <span class="material-symbols-outlined">payment</span> Cấu hình thanh toán
                </a>
            </c:if>
        </c:if>
    </nav>

    <div class="bk-sidebar-footer">
        <c:if test="${sessionScope.currentUser != null}">
            <a href="${pageContext.request.contextPath}/logout" class="bk-sidebar-link">
                <span class="material-symbols-outlined">logout</span> Đăng xuất
            </a>
        </c:if>
        <c:if test="${sessionScope.currentUser == null}">
            <a href="${pageContext.request.contextPath}/login" class="bk-sidebar-link">
                <span class="material-symbols-outlined">login</span> Đăng nhập
            </a>
        </c:if>
    </div>
</aside>

<%-- MAIN AREA --%>
<div class="bk-main">
    <%-- TOP HEADER --%>
    <header class="bk-header">
        <div></div>
        <div class="bk-header-actions">
            <button class="bk-header-icon"><span class="material-symbols-outlined">notifications</span></button>
            <button class="bk-header-icon"><span class="material-symbols-outlined">settings</span></button>
            <c:if test="${sessionScope.currentUser != null}">
                <div class="bk-header-user">
                    <span>${sessionScope.currentUser.fullName}</span>
                    <div class="bk-header-avatar">
                        ${sessionScope.currentUser.fullName.substring(0,1)}
                    </div>
                </div>
            </c:if>
        </div>
    </header>

    <%-- CONTENT START --%>
    <div class="bk-content">
