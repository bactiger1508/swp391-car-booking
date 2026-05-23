<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle Handover"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Vehicle Handover</h3></div>
        <p style="color:var(--text-secondary);margin-bottom:16px;">Record vehicle handover to customer. Document condition, mileage, and fuel level. (BR-06: Car becomes Rented after handover)</p>
        <c:if test="${not empty handovers}">
            <table class="table">
                <thead><tr><th>ID</th><th>Booking</th><th>Car</th><th>Date</th><th>Mileage</th><th>Fuel</th><th>Staff</th></tr></thead>
                <tbody>
                    <c:forEach var="h" items="${handovers}">
                        <tr><td>${h.handoverId}</td><td>#${h.bookingId}</td><td>Car #${h.carId}</td><td>${h.handoverDate}</td><td>${h.mileageAtHandover} km</td><td>${h.fuelLevel}</td><td>Staff #${h.handedBy}</td></tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty handovers}"><div class="placeholder-content"><p>No handover records found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
