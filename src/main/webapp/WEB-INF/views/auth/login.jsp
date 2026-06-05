<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - CarPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
</head>
<body class="auth-body">
<div class="auth-container">
    <div class="auth-card">
        <div class="auth-accent"></div>
        <div class="auth-card-body">
            <!-- Header -->
            <div class="auth-header">
                <div class="auth-icon-wrapper">
                    <span class="material-symbols-outlined">directions_car</span>
                </div>
                <h1>Quản trị CarPro</h1>
                <p class="subtitle">Đăng nhập để quản lý hoạt động đội xe của bạn</p>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <span class="material-symbols-outlined" style="margin-right: 8px; font-size: 20px;">error</span>
                    ${error}
                </div>
            </c:if>
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <span class="material-symbols-outlined" style="margin-right: 8px; font-size: 20px;">check_circle</span>
                    ${success}
                </div>
            </c:if>

            <!-- Form -->
            <form method="post" action="${pageContext.request.contextPath}/login">
                <!-- Email Field -->
                <div class="form-group">
                    <label for="email">Địa chỉ Email</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">mail</span>
                        <input type="email" id="email" name="email" class="form-control"
                               value="${email}" placeholder="quanly@fleetpro.com" required>
                    </div>
                </div>
                <!-- Password Field -->
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">lock</span>
                        <input type="password" id="password" name="password" class="form-control"
                               placeholder="••••••••" required>
                    </div>
                </div>
                
                <!-- Options -->
                <div class="form-options">
                    <div class="remember-me">
                        <input type="checkbox" id="remember-me" name="remember-me">
                        <label for="remember-me">Ghi nhớ đăng nhập</label>
                    </div>
                    <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-link">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="btn btn-primary">Đăng nhập</button>
            </form>

            <!-- Registration Link -->
            <div class="register-link">
                <p>Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký</a></p>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="auth-card-footer">
            <a href="${pageContext.request.contextPath}/" class="back-home-link">
                <span class="material-symbols-outlined">arrow_back</span>
                Quay về Trang chủ
            </a>
        </div>
    </div>
</div>
</body>
</html>
