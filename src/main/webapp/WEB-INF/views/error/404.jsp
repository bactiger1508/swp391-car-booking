<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="auth-container">
    <div class="auth-card" style="text-align:center;">
        <div style="font-size:64px;margin-bottom:16px;">&#128270;</div>
        <h1>Page Not Found</h1>
        <p class="subtitle">The page you are looking for does not exist or has been moved.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary" style="margin-top:24px;">Back to Home</a>
    </div>
</div>
</body>
</html>
