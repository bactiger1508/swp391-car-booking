<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Booking Management"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Booking Management</h3></div>
        <c:if test="${not empty bookings}">
            <table class="table">
                <thead><tr><th>ID</th><th>Customer</th><th>Car</th><th>Start</th><th>End</th><th>Amount</th><th>Status</th></tr></thead>
                <tbody>
                    <c:forEach var="b" items="${bookings}">
                        <tr>
                            <td>${b.bookingId}</td>
                            <td>User #${b.customerId}</td>
                            <td>Car #${b.carId}</td>
                            <td>${b.startDate}</td>
                            <td>${b.endDate}</td>
                            <td>${b.totalAmount} VND</td>
                            <td><span class="badge badge-${b.status == 'PENDING' ? 'pending' : b.status == 'CONFIRMED' ? 'confirmed' : b.status == 'COMPLETED' ? 'completed' : 'cancelled'}">${b.status}</span></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty bookings}"><div class="placeholder-content"><p>No bookings found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
