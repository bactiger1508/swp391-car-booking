<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Không Tìm Thấy Trang - CarPro</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
</head>
<body class="auth-body">
<div class="auth-container">
    <div class="auth-card" style="max-width: 500px;">
        <div class="auth-accent" style="background: var(--danger, #EE5D50);"></div>
        <div class="auth-card-body" style="text-align:center; padding: 48px 40px;">
            <div style="display: inline-flex; align-items: center; justify-content: center; width: 80px; height: 80px; border-radius: 50%; background: rgba(238, 93, 80, 0.1); color: var(--danger, #EE5D50); margin-bottom: 24px;">
                <span class="material-symbols-outlined" style="font-size: 40px; font-variation-settings: 'FILL' 1;">error</span>
            </div>
            <h1 style="font-size: 28px; font-weight: 700; color: var(--primary); margin-bottom: 12px; letter-spacing: -0.02em;">404 - Không tìm thấy trang</h1>
            <p style="font-size: 15px; color: var(--on-surface-variant); line-height: 1.6; margin-bottom: 28px;">
                Trang bạn đang truy cập không tồn tại hoặc đã bị di chuyển, hoặc liên kết chứa ID dữ liệu không hợp lệ.
            </p>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-primary" style="width: auto; padding: 12px 32px; border-radius: 10px; font-weight: 600; margin: 0 auto; display: inline-flex;">
                Quay về Trang chủ
            </a>
        </div>
        <div class="auth-card-footer" style="padding: 16px;">
            <span style="font-size: 13px; color: var(--on-surface-variant); opacity: 0.8;">Hệ thống quản lý xe tự lái CarPro</span>
        </div>
    </div>
</div>
</body>
</html>
