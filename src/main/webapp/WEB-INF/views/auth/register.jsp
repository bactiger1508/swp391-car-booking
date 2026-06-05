<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — Car Rental</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="auth-container">
    <div class="auth-card">
        <h1>🚗 Tạo Tài Khoản</h1>
        <p class="subtitle">Đăng ký thành viên để bắt đầu thuê xe</p>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/register">
            <div class="form-group">
                <label for="fullName">Họ và Tên</label>
                <input type="text" id="fullName" name="fullName" class="form-control"
                       value="${fullName}" placeholder="Nguyễn Văn A" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" class="form-control"
                       value="${email}" placeholder="email@example.com" required>
            </div>
            <div class="form-group">
                <label for="phone">Số điện thoại</label>
                <input type="tel" id="phone" name="phone" class="form-control"
                       value="${phone}" placeholder="0901234567">
            </div>
            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="Ít nhất 6 ký tự" required minlength="6">
            </div>
            <div class="form-group">
                <label for="confirmPassword">Nhập lại mật khẩu</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                       placeholder="Nhập lại mật khẩu" required>
            </div>
            <button type="submit" class="btn btn-primary">Tạo Tài Khoản</button>
        </form>

        <div class="auth-footer">
            <p>Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập ngay</a></p>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>
