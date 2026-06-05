<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="User Management"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header">
            <h3>User Management</h3>
            <button class="btn btn-primary">+ Add User</button>
        </div>
        <c:if test="${not empty users}">
            <table class="table">
                <thead><tr><th>ID</th><th>Full Name</th><th>Email</th><th>Role</th><th>Status</th><th>Actions</th></tr></thead>
                <tbody>
                    <c:forEach var="u" items="${users}">
                        <tr>
                            <td>${u.userId}</td>
                            <td>${u.fullName}</td>
                            <td>${u.email}</td>
                            <td><span class="badge badge-confirmed">${u.role}</span></td>
                            <td><span class="badge ${u.active ? 'badge-available' : 'badge-cancelled'}">${u.active ? 'Active' : 'Inactive'}</span></td>
                            <td><a href="#" class="btn btn-outline" style="padding:4px 10px;font-size:12px;">Edit</a></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty users}">
            <div class="placeholder-content"><p>No users found.</p></div>
        </c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
