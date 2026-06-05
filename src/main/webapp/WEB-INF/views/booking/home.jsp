<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Home Page"/>
</jsp:include>

<div class="page-content">
    <div class="card">
        <h2>Chào mừng đến với Hệ thống Thuê Xe</h2>
        <p style="margin-top:8px;color:var(--text-secondary);">
            Hệ thống quản lý thuê ô tô tự lái — Khám phá các dòng xe đang có sẵn và đặt chuyến đi tiếp theo của bạn.
        </p>
    </div>

    <div class="card">
        <div class="card-header">
            <h3>🚘 Các xe đang có sẵn</h3>
            <a href="${pageContext.request.contextPath}/vehicles" class="btn btn-outline">Xem tất cả</a>
        </div>
        <c:if test="${not empty featuredCars}">
            <table class="table">
                <thead>
                    <tr>
                        <th>Hãng xe</th>
                        <th>Dòng xe</th>
                        <th>Đời xe</th>
                        <th>Số chỗ</th>
                        <th>Truyền động</th>
                        <th>Giá thuê (Ngày)</th>
                        <th>Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="car" items="${featuredCars}">
                        <tr>
                            <td>${car.brand}</td>
                            <td>${car.model}</td>
                            <td>${car.year}</td>
                            <td>${car.seats}</td>
                            <td>${car.transmission}</td>
                            <td><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/> VNĐ</td>
                            <td><a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="btn btn-primary" style="padding:4px 12px;font-size:13px;">Chi tiết</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty featuredCars}">
            <div class="placeholder-content">
                <p>Hiện tại chưa có xe nào trống.</p>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
