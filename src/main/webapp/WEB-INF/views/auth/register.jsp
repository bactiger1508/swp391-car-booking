<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo tài khoản - CarPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
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
            <form method="post" action="${pageContext.request.contextPath}/register" class="register-form" id="registerForm" novalidate>
                <!-- Name Field -->
                <div class="form-group">
                    <label for="fullName">Họ và tên <span style="color: var(--error);">*</span></label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">person</span>
                        <input type="text" id="fullName" name="fullName" class="form-control"
                               value="${fullName}" placeholder="vd: Nguyễn Văn A">
                    </div>
                    <span class="error-msg" style="color: var(--error); font-size: 12px; margin-top: 4px; display: none;" id="err-fullName"></span>
                </div>

                <!-- Email & Phone row -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email <span style="color: var(--error);">*</span></label>
                        <div class="input-relative">
                            <span class="material-symbols-outlined input-icon">mail</span>
                            <input type="email" id="email" name="email" class="form-control"
                                   value="${email}" placeholder="ten@congty.com">
                        </div>
                        <span class="error-msg" style="color: var(--error); font-size: 12px; margin-top: 4px; display: none;" id="err-email"></span>
                    </div>
                    <div class="form-group">
                        <label for="phone">Số điện thoại</label>
                        <div class="input-relative">
                            <span class="material-symbols-outlined input-icon">call</span>
                            <input type="tel" id="phone" name="phone" class="form-control"
                                   value="${phone}" placeholder="+84 900 000 000">
                        </div>
                        <span class="error-msg" style="color: var(--error); font-size: 12px; margin-top: 4px; display: none;" id="err-phone"></span>
                    </div>
                </div>

                <!-- Password Field -->
                <div class="form-group">
                    <label for="password">Mật khẩu <span style="color: var(--error);">*</span></label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">lock</span>
                        <input type="password" id="password" name="password" class="form-control"
                               placeholder="••••••••">
                    </div>
                    <span class="error-msg" style="color: var(--error); font-size: 12px; margin-top: 4px; display: none;" id="err-password"></span>
                </div>

                <!-- Confirm Password Field -->
                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu <span style="color: var(--error);">*</span></label>
                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">lock</span>
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                               placeholder="••••••••">
                    </div>
                    <span class="error-msg" style="color: var(--error); font-size: 12px; margin-top: 4px; display: none;" id="err-confirmPassword"></span>
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

<script>
document.addEventListener('DOMContentLoaded', function() {
    var form = document.getElementById('registerForm');
    if (form) {
        form.addEventListener('submit', function(event) {
            var hasErrors = false;
            
            // Helper function to show error
            function showError(id, msg) {
                var el = document.getElementById('err-' + id);
                if (el) {
                    el.textContent = msg;
                    el.style.display = 'block';
                }
                hasErrors = true;
            }
            
            // Clear previous errors
            var errElements = document.querySelectorAll('.error-msg');
            errElements.forEach(function(el) {
                el.textContent = '';
                el.style.display = 'none';
            });
            
            // Validate Họ và tên
            var fullName = document.getElementById('fullName').value.trim();
            if (!fullName) {
                showError('fullName', 'Vui lòng nhập họ và tên.');
            }
            
            // Validate Email
            var email = document.getElementById('email').value.trim();
            if (!email) {
                showError('email', 'Vui lòng nhập địa chỉ email.');
            } else {
                var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                if (!emailRegex.test(email)) {
                    showError('email', 'Email không đúng định dạng.');
                }
            }
            
            // Validate Số điện thoại (optional)
            var phone = document.getElementById('phone').value.trim();
            if (phone) {
                var phoneRegex = /^(0|\+84)[3|5|7|8|9][0-9]{8}$/;
                if (!phoneRegex.test(phone.replace(/\s+/g, ''))) {
                    showError('phone', 'Số điện thoại không đúng định dạng (phải có 10 chữ số).');
                }
            }
            
            // Validate Mật khẩu
            var password = document.getElementById('password').value;
            if (!password) {
                showError('password', 'Vui lòng nhập mật khẩu.');
            } else if (password.length < 6) {
                showError('password', 'Mật khẩu phải từ 6 ký tự trở lên.');
            }
            
            // Validate Xác nhận mật khẩu
            var confirmPassword = document.getElementById('confirmPassword').value;
            if (!confirmPassword) {
                showError('confirmPassword', 'Vui lòng xác nhận mật khẩu.');
            } else if (password !== confirmPassword) {
                showError('confirmPassword', 'Mật khẩu xác nhận không khớp.');
            }
            
            if (hasErrors) {
                event.preventDefault(); // Prevent submit
                
                // Scroll to first error
                var firstError = document.querySelector('.error-msg[style*="display: block"]');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        });
    }
});
</script>
