<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - CarPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="auth-body">
<div class="auth-container">
    <div class="auth-card">
        <div class="auth-accent"></div>
        <div class="auth-card-body">
            <!-- Header -->
            <div class="auth-header">
                <div class="auth-icon-wrapper">
                    <span class="material-symbols-outlined">lock_reset</span>
                </div>
                <h1>Quên mật khẩu</h1>
                <p class="subtitle">Nhập địa chỉ email đăng ký để nhận liên kết đặt lại mật khẩu</p>
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
            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
                <!-- Email Field -->
                <div class="form-group">
                    <label for="email">Địa chỉ Email</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">mail</span>
                        <input type="email" id="email" name="email" class="form-control"
                               placeholder="quanly@fleetpro.com" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary">Gửi liên kết đặt lại</button>
            </form>
        </div>
        
        <!-- Footer -->
        <div class="auth-card-footer">
            <a href="${pageContext.request.contextPath}/login" class="back-home-link">
                <span class="material-symbols-outlined">arrow_back</span>
                Quay về Đăng nhập
            </a>
        </div>
    </div>
</div>
</body>
</html>
