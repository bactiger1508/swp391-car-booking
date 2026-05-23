<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle Detail"/>
</jsp:include>
<div class="page-content">
    <c:if test="${not empty car}">
        <div class="card">
            <div class="card-header"><h3>${car.brand} ${car.model} (${car.year})</h3>
                <span class="badge badge-${car.status == 'AVAILABLE' ? 'available' : car.status == 'RENTED' ? 'rented' : 'maintenance'}">${car.status}</span>
            </div>
            <table class="table">
                <tr><td><strong>License Plate</strong></td><td>${car.licensePlate}</td></tr>
                <tr><td><strong>Color</strong></td><td>${car.color}</td></tr>
                <tr><td><strong>Seats</strong></td><td>${car.seats}</td></tr>
                <tr><td><strong>Transmission</strong></td><td>${car.transmission}</td></tr>
                <tr><td><strong>Fuel Type</strong></td><td>${car.fuelType}</td></tr>
                <tr><td><strong>Daily Rate</strong></td><td>${car.dailyRate} VND</td></tr>
                <tr><td><strong>Mileage</strong></td><td>${car.mileage} km</td></tr>
                <tr><td><strong>Location</strong></td><td>${car.location}</td></tr>
                <tr><td><strong>Features</strong></td><td>${car.features}</td></tr>
                <tr><td><strong>Description</strong></td><td>${car.description}</td></tr>
            </table>
        </div>
    </c:if>
    <c:if test="${empty car}">
        <div class="card"><div class="placeholder-content"><h2>Vehicle not found</h2><p>The requested vehicle does not exist.</p></div></div>
    </c:if>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
