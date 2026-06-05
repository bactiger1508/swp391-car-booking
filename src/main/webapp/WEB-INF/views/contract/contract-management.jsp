<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    request.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Contract Management"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Contract Management</h3></div>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="alert alert-danger">
                <span>${sessionScope.errorMessage}</span>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty contracts}">
            <table class="table">
                <thead><tr><th>Contract #</th><th>Booking</th><th>Customer</th><th>Car</th><th>Period</th><th>Amount</th><th>Status</th><th>Action</th></tr></thead>
                <tbody>
                    <c:forEach var="c" items="${contracts}">
                        <tr>
                            <td>${c.contractNumber}</td>
                            <td>#${c.bookingId}</td>
                            <td>User #${c.customerId}</td>
                            <td>Car #${c.carId}</td>
                            <td>${c.startDate != null ? c.startDate.format(dateTimeFormatter) : ''} - ${c.endDate != null ? c.endDate.format(dateTimeFormatter) : ''}</td>
                            <td><fmt:formatNumber value="${c.totalAmount}" pattern="#,##0"/> VND</td>
                            <td><span class="badge badge-${c.status == 'ACTIVE' ? 'confirmed' : c.status == 'COMPLETED' ? 'completed' : 'pending'}">${c.status}</span></td>
                            <td><a href="${pageContext.request.contextPath}/contracts/detail?id=${c.contractId}" class="btn btn-outline" style="padding:4px 10px;font-size:12px;">View</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty contracts}"><div class="placeholder-content"><p>No contracts found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
