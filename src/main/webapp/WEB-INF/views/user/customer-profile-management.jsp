<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core"%>
<%@page import="com.swp391.carrental.dao.CustomerProfileDAO"%>
<%
    // Khởi tạo nhanh đối tượng DAO để dùng trong vòng lặp c:forEach
    CustomerProfileDAO profileDAO = new CustomerProfileDAO();
    request.setAttribute("profileDAO", profileDAO);
%>

<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Customer Profile Verification"/>
</jsp:include>

<div class="page-content">
    <div class="card">
        <div class="card-header">
            <h2>Quản lý hồ sơ khách hàng</h2>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/user/customer-profiles" style="display:flex;gap:12px;margin-bottom:20px;">
            <input class="form-control" type="text" name="keyword" value="${param.keyword}" placeholder="Tìm kiếm...">
            <select class="form-control" name="status">
                <option value="">Tất cả trạng thái</option>
                <option value="PENDING" ${param.status=='PENDING'?'selected':''}>Pending</option>
                <option value="VERIFIED" ${param.status=='VERIFIED'?'selected':''}>Verified</option>
                <option value="REJECTED" ${param.status=='REJECTED'?'selected':''}>Rejected</option>
            </select>
            <button class="btn btn-primary">Tìm kiếm</button>
        </form>

        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.success=='verified'}">Xác minh hồ sơ thành công.</c:when>
                    <c:otherwise>Từ chối hồ sơ thành công.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <table class="table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên khách hàng</th> <th>Số CCCD / Hộ chiếu</th>
                    <th>Số Giấy phép lái xe</th>
                    <th>Trạng thái</th>
                    <th>Hoạt động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${profiles}" var="p">
                    <tr>
                        <td>${p.profileId}</td>
                        <td>
                            <strong>${profileDAO.getCustomerName(p.userId)}</strong><br>
                            <small class="text-muted">${profileDAO.getCustomerEmail(p.userId)}</small>
                        </td>
                        <td>${p.idCardNumber}</td>
                        <td>${p.driverLicenseNumber}</td>
                        <td>
                            <c:choose>
                                <c:when test="${p.verificationStatus=='PENDING'}">
                                    <span class="badge badge-warning">Pending</span>
                                </c:when>
                                <c:when test="${p.verificationStatus=='VERIFIED'}">
                                    <span class="badge badge-success">Verified</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">Rejected</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a class="btn btn-info" href="${pageContext.request.contextPath}/user/customer-profiles?action=view&id=${p.profileId}&searchStatus=${param.status}&searchKeyword=${param.keyword}">
                                Xem
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>