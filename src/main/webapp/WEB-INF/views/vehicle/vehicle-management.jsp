<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle Management"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header">
            <h3>Vehicle Management</h3>
            <a href="${pageContext.request.contextPath}/maintenance" class="btn btn-outline">Maintenance Schedule</a>
        </div>

        <div class="filter-section" style="padding:0 20px 16px;">
            <form method="get" style="display:flex;gap:10px;align-items:center;">
                <select name="status" class="form-control">
                    <option value="">All Status</option>
                    <option value="AVAILABLE" ${selectedStatus == 'AVAILABLE' ? 'selected' : ''}>Available</option>
                    <option value="RENTED" ${selectedStatus == 'RENTED' ? 'selected' : ''}>Rented</option>
                    <option value="MAINTENANCE" ${selectedStatus == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                    <option value="INACTIVE" ${selectedStatus == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                </select>
                <button type="submit" class="btn btn-secondary">Filter</button>
                <a href="${pageContext.request.contextPath}/vehicles/manage" class="btn btn-outline">Clear</a>
            </form>
        </div>

        <c:if test="${not empty cars}">
            <table class="table">
                <thead>
                    <tr>
                        <th>License Plate</th>
                        <th>Vehicle</th>
                        <th>Status</th>
                        <th>Daily Rate (VND)</th>
                        <th>Deposit (1 day)</th>
                        <th>Maintenance</th>
                        <th>Location</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="car" items="${cars}">
                        <c:set var="maintenance" value="${nextMaintenance[car.carId]}"/>
                        <tr>
                            <td><strong>${car.licensePlate}</strong></td>
                            <td>${car.brand} ${car.model} (${car.year})</td>
                            <td>
                                <span class="badge badge-${car.status == 'AVAILABLE' ? 'success' : car.status == 'RENTED' ? 'warning' : car.status == 'MAINTENANCE' ? 'danger' : 'secondary'}">
                                    ${car.status}
                                </span>
                            </td>
                            <td><fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/></td>
                            <td>
                                <fmt:formatNumber value="${depositAmounts[car.carId]}" type="number" groupingUsed="true"/>
                                <span style="font-size:11px;color:var(--text-secondary);">(${depositPercentage}%)</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty maintenance}">
                                        ${maintenance.maintenanceType}<br/>
                                        <span style="font-size:12px;color:var(--text-secondary);">
                                            ${maintenance.scheduledDate} &middot; ${maintenance.status}
                                        </span>
                                    </c:when>
                                    <c:when test="${car.status == 'MAINTENANCE'}">
                                        <span style="color:var(--warning-color,#e67e22);">In maintenance (no schedule)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--text-secondary);">—</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${car.location}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="btn btn-sm btn-outline">View</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>

        <c:if test="${empty cars}">
            <div class="placeholder-content">
                <p>No vehicles match the selected filter.</p>
            </div>
        </c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
