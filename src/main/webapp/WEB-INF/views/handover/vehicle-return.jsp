<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle Return"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Vehicle Return</h3></div>
        <p style="color:var(--text-secondary);margin-bottom:16px;">Record vehicle return from customer. Inspect condition and calculate additional fees. (BR-07, BR-08)</p>
        <c:if test="${not empty returns}">
            <table class="table">
                <thead><tr><th>ID</th><th>Booking</th><th>Car</th><th>Return Date</th><th>Mileage</th><th>Additional Fees</th></tr></thead>
                <tbody>
                    <c:forEach var="r" items="${returns}">
                        <tr><td>${r.returnId}</td><td>#${r.bookingId}</td><td>Car #${r.carId}</td><td>${r.returnDate}</td><td>${r.mileageAtReturn} km</td><td>${r.totalAdditionalFee} VND</td></tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty returns}"><div class="placeholder-content"><p>No return records found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
