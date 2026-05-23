<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="auth-container">
    <div class="auth-card" style="text-align:center;">
        <div style="font-size:64px;margin-bottom:16px;">&#128683;</div>
        <h1>Access Denied</h1>
        <p class="subtitle">You do not have permission to access this page. Contact your administrator if you believe this is an error.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary" style="margin-top:24px;">Back to Home</a>
    </div>
</div>
</body>
</html>
