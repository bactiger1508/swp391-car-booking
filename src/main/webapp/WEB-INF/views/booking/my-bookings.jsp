<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="My Bookings"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>My Bookings</h3></div>
        <c:if test="${not empty bookings}">
            <table class="table">
                <thead><tr><th>ID</th><th>Car</th><th>Start Date</th><th>End Date</th><th>Amount</th><th>Status</th><th>Action</th></tr></thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr>
                            <td>${b.bookingId}</td>
                            <td>Car #${b.carId}</td>
                            <td>${b.startDate}</td>
                            <td>${b.endDate}</td>
                            <td>${b.totalAmount} VND</td>
                            <td><span class="badge badge-${b.status == 'PENDING' ? 'pending' : b.status == 'CONFIRMED' ? 'confirmed' : b.status == 'COMPLETED' ? 'completed' : b.status == 'IN_PROGRESS' ? 'progress' : 'cancelled'}">${b.status}</span></td>
                            <td><a href="${pageContext.request.contextPath}/bookings/edit?id=${b.bookingId}" class="btn btn-outline" style="padding:4px 10px;font-size:12px;">Detail</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty bookings}"><div class="placeholder-content"><p>You have no bookings yet. <a href="${pageContext.request.contextPath}/bookings/create">Create one now</a>.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
