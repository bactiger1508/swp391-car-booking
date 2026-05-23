<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password — Car Rental</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="auth-container">
    <div class="auth-card">
        <h1>🔑 Forgot Password</h1>
        <p class="subtitle">Enter your email to reset your password</p>
        <form method="post" action="${pageContext.request.contextPath}/forgot-password">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" class="form-control" placeholder="Enter your email" required>
            </div>
            <button type="submit" class="btn btn-primary">Send Reset Link</button>
        </form>
        <div class="auth-footer">
            <p><a href="${pageContext.request.contextPath}/login">← Back to Login</a></p>
        </div>
    </div>
</div>
</body>
</html>
