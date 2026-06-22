<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Customer Profile Detail"/>
</jsp:include>

<div class="page-content">
    <div class="card">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
            <h2>Customer Profile Detail</h2>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/user/customer-profiles?status=${param.searchStatus}&keyword=${param.searchKeyword}">
                Back
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <table class="table table-bordered">
            <tr><th width="220">ID hồ sơ</th><td>${profile.profileId}</td></tr>
            <tr><th>Họ và tên</th><td>${customerName}</td></tr>
            <tr><th>Địa chỉ email</th><td>${customerEmail}</td></tr>
            <tr><th>ID Người dùng</th><td>${profile.userId}</td></tr>
            <tr><th>Ngày sinh</th><td>${profile.dateOfBirth}</td></tr>
            <tr><th>Địa chỉ thường trú</th><td>${profile.address}</td></tr>
            <tr><th>Số CCCD / Hộ chiếu</th><td>${profile.idCardNumber}</td></tr>
            <tr><th>Số Giấy phép lái xe</th><td>${profile.driverLicenseNumber}</td></tr>
            <tr><th>Ngày hết hạn Giấy phép lái xe</th><td>${profile.driverLicenseExpiry}</td></tr>
            <tr>
                <th>Ảnh Giấy phép lái xe</th>
                <td>
                    <c:choose>
                        <c:when test="${not empty profile.driverLicenseImage}">
                            <img src="${pageContext.request.contextPath}/${profile.driverLicenseImage}" width="450" style="border-radius:10px; border:1px solid #ccc;">
                        </c:when>
                        <c:otherwise><span style="color:red">Không có ảnh</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
            <tr>
                <th>Trạng thái</th>
                <td>
                    <c:choose>
                        <c:when test="${profile.verificationStatus == 'PENDING'}"><span class="badge badge-warning">Pending</span></c:when>
                        <c:when test="${profile.verificationStatus == 'VERIFIED'}"><span class="badge badge-success">Verified</span></c:when>
                        <c:otherwise><span class="badge badge-danger">Rejected</span></c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </table>
        <br>

        <c:if test="${profile.verificationStatus=='PENDING'}">
            <div style="display:flex; flex-direction: column; gap:15px; background: #f9f9f9; padding: 20px; border-radius: 8px;">
                <h3>Xử lý yêu cầu hồ sơ</h3>
                <div style="display: flex; gap: 15px;">
                    <form method="post" action="${pageContext.request.contextPath}/user/customer-profiles">
                        <input type="hidden" name="action" value="verify">
                        <input type="hidden" name="profileId" value="${profile.profileId}">
                        <button class="btn btn-success" onclick="return confirm('Bạn có chắc chắn muốn xác minh hồ sơ này?')">
                            Đồng ý
                        </button>
                    </form>

                    <form method="post" action="${pageContext.request.contextPath}/user/customer-profiles">
                        <input type="hidden" name="action" value="reject">
                        <input type="hidden" name="profileId" value="${profile.profileId}">
                        <button class="btn btn-danger" onclick="return confirm('Bạn có chắc chắn muốn từ chối hồ sơ này?')">
                            Từ chối
                        </button>
                    </form>
                </div>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>