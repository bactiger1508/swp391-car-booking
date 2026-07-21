<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Đổi mật khẩu - CarPro" />
</jsp:include>



<div class="auth-container">

    <div class="auth-card">

        <div class="auth-accent"></div>

        <div class="auth-card-body">

            <div class="auth-header">
                <div class="auth-icon-wrapper">
                    <span class="material-symbols-outlined">
                        shield_lock
                    </span>
                </div>

                <h1>Đổi mật khẩu</h1>

                <p class="subtitle">
                    Vui lòng nhập mật khẩu hiện tại và mật khẩu mới.
                </p>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    ${error}
                </div>
            </c:if>

            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    ${success}
                </div>
            </c:if>

            <form method="post"
                  action="${pageContext.request.contextPath}/change-password">

                <div class="form-group">
                    <label>Mật khẩu hiện tại</label>

                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">
                            lock
                        </span>

                        <input type="password"
                               name="currentPassword"
                               class="form-control"
                               placeholder="Nhập mật khẩu hiện tại"
                               required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Mật khẩu mới</label>

                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">
                            lock_reset
                        </span>

                        <input type="password"
                               name="newPassword"
                               class="form-control"
                               placeholder="Nhập mật khẩu mới"
                               required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Xác nhận mật khẩu mới</label>

                    <div class="input-relative">
                        <span class="material-symbols-outlined input-icon">
                            verified_user
                        </span>

                        <input type="password"
                               name="confirmPassword"
                               class="form-control"
                               placeholder="Nhập lại mật khẩu mới"
                               required>
                    </div>
                </div>

                <button class="btn btn-primary"
                        type="submit">
                    Cập nhật mật khẩu
                </button>

            </form>
        </div>

        <div class="auth-card-footer">
            <a href="${pageContext.request.contextPath}/home"
               class="back-home-link">

                <span class="material-symbols-outlined">
                    arrow_back
                </span>

                Quay lại trang chủ
            </a>
        </div>

    </div>

</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp" />