<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo tài khoản - CarPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="register-body">
<div class="split-container">
    <!-- Left Side Banner -->
    <div class="banner-side">
        <div class="banner-overlay"></div>
        <div class="banner-content">
            <div class="logo-area">
                <div class="logo-icon-wrapper">
                    <span class="material-symbols-outlined">directions_car</span>
                </div>
                <span class="logo-text">CarPro</span>
            </div>
            <div class="banner-text">
                <h2>Nâng tầm di chuyển doanh nghiệp.</h2>
                <p>Tạo tài khoản khách hàng để truy cập đặt xe theo thời gian thực, quản lý các chuyến đi đang hoạt động và tối ưu hóa hậu cần di chuyển của doanh nghiệp.</p>
            </div>
        </div>
    </div>
    
    <!-- Right Side Form -->
    <div class="form-side">
        <a href="${pageContext.request.contextPath}/" class="back-home-top">
            <span class="material-symbols-outlined">arrow_back</span>
            Về trang chủ
        </a>
        
        <div class="register-form-container">
            <div class="form-header">
                <h1>Tạo tài khoản</h1>
                <p>Đăng ký hồ sơ khách hàng mới để bắt đầu.</p>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <span class="material-symbols-outlined" style="margin-right: 8px; font-size: 20px;">error</span>
                    ${error}
                </div>
            </c:if>

            <!-- Form -->
            <form method="post" action="${pageContext.request.contextPath}/register" class="register-form">
                <!-- Name Field -->
                <div class="form-group">
                    <label for="fullName">Họ và tên</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">person</span>
                        <input type="text" id="fullName" name="fullName" class="form-control"
                               value="${fullName}" placeholder="vd: Nguyễn Văn A" required>
                    </div>
                </div>

                <!-- Email & Phone row -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <div class="input-relative">
                            <span class="material-symbols-outlined input-icon">mail</span>
                            <input type="email" id="email" name="email" class="form-control"
                                   value="${email}" placeholder="ten@congty.com" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="phone">Số điện thoại</label>
                        <div class="input-relative">
                            <span class="material-symbols-outlined input-icon">call</span>
                            <input type="tel" id="phone" name="phone" class="form-control"
                                   value="${phone}" placeholder="+84 900 000 000">
                        </div>
                    </div>
                </div>

                <!-- Password Field -->
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">lock</span>
                        <input type="password" id="password" name="password" class="form-control"
                               placeholder="••••••••" required minlength="6">
                    </div>
                </div>

                <!-- Confirm Password Field -->
                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">lock</span>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                               placeholder="••••••••" required>
                    </div>
                </div>

                <!-- Form Action Buttons -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        Tạo tài khoản
                        <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                    </button>
                    
                    <div class="login-link">
                        <span>Đã có tài khoản?</span>
                        <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
