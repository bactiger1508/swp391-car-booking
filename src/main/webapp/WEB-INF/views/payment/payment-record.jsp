<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Payment Record"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Payment Record</h3><button class="btn btn-primary">+ Record Payment</button></div>
        <c:if test="${not empty payments}">
            <table class="table">
                <thead><tr><th>ID</th><th>Booking</th><th>Amount</th><th>Type</th><th>Method</th><th>Status</th><th>Date</th></tr></thead>
                <tbody>
                    <c:forEach var="p" items="${payments}">
                        <tr>
                            <td>${p.paymentId}</td>
                            <td>#${p.bookingId}</td>
                            <td>${p.amount} VND</td>
                            <td>${p.paymentType}</td>
                            <td>${p.paymentMethod}</td>
                            <td><span class="badge badge-${p.status == 'COMPLETED' ? 'completed' : 'pending'}">${p.status}</span></td>
                            <td>${p.paidAt}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty payments}"><div class="placeholder-content"><p>No payment records found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
