<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.pageTitle != null ? param.pageTitle : 'Car Rental Management'}</title>
    <meta name="description" content="Hệ thống quản lý thuê ô tô tự lái - Car Rental Management System">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/WEB-INF/views/layout/sidebar.jsp"/>
    <div class="main-content">
        <header class="header">
            <div class="header-left">
                <button class="btn btn-outline sidebar-toggle" onclick="toggleSidebar()">&#9776;</button>
                <span class="page-title">${param.pageTitle}</span>
            </div>
            <div class="header-right">
                <c:if test="${sessionScope.currentUser != null}">
                    <div class="user-info">
                        <span>${sessionScope.currentUser.fullName}</span>
                        <span class="role-badge">${sessionScope.currentUser.role}</span>
                        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline" style="padding:4px 12px;font-size:13px;">Đăng Xuất</a>
                    </div>
                </c:if>
                <c:if test="${sessionScope.currentUser == null}">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="padding:6px 16px;font-size:13px;">Đăng Nhập</a>
                </c:if>
            </div>
        </header>
