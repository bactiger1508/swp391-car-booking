<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Booking Approval"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Pending Booking Approvals</h3></div>
        <c:if test="${not empty pendingBookings}">
            <table class="table">
                <thead><tr><th>ID</th><th>Customer</th><th>Car</th><th>Dates</th><th>Amount</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="b" items="${pendingBookings}">
                        <tr>
                            <td>${b.bookingId}</td>
                            <td>User #${b.customerId}</td>
                            <td>Car #${b.carId}</td>
                            <td>${b.startDate} - ${b.endDate}</td>
                            <td>${b.totalAmount} VND</td>
                            <td>
                                <form method="post" style="display:inline;"><input type="hidden" name="bookingId" value="${b.bookingId}"/><input type="hidden" name="action" value="approve"/>
                                    <button type="submit" class="btn btn-success" style="padding:4px 10px;font-size:12px;">Approve</button></form>
                                <form method="post" style="display:inline;"><input type="hidden" name="bookingId" value="${b.bookingId}"/><input type="hidden" name="action" value="reject"/>
                                    <button type="submit" class="btn btn-danger" style="padding:4px 10px;font-size:12px;">Reject</button></form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty pendingBookings}"><div class="placeholder-content"><p>No pending bookings to approve.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
