<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Server Error</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="auth-container">
    <div class="auth-card" style="text-align:center;">
        <div style="font-size:64px;margin-bottom:16px;">&#9888;</div>
        <h1>Server Error</h1>
        <p class="subtitle">An internal server error occurred. Please try again later.</p>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-primary" style="margin-top:24px;">Back to Home</a>
    </div>
</div>
</body>
</html>
