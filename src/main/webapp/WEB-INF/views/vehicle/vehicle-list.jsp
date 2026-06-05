<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle List"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header">
            <h3>Vehicle List</h3>
        </div>
        <c:if test="${not empty cars}">
            <table class="table">
                <thead><tr><th>Plate</th><th>Brand</th><th>Model</th><th>Year</th><th>Seats</th><th>Daily Rate</th><th>Status</th><th>Action</th></tr></thead>
                <tbody>
                    <c:forEach var="car" items="${cars}">
                        <tr>
                            <td>${car.licensePlate}</td>
                            <td>${car.brand}</td>
                            <td>${car.model}</td>
                            <td>${car.year}</td>
                            <td>${car.seats}</td>
                            <td>${car.dailyRate} VND</td>
                            <td><span class="badge badge-${car.status == 'AVAILABLE' ? 'available' : car.status == 'RENTED' ? 'rented' : 'maintenance'}">${car.status}</span></td>
                            <td><a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="btn btn-outline" style="padding:4px 10px;font-size:12px;">View</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty cars}"><div class="placeholder-content"><p>No vehicles found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
