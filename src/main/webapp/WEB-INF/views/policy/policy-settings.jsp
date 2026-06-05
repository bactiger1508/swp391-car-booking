<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Policy Settings"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="card-header"><h3>Policy Settings</h3></div>
        <c:if test="${not empty policies}">
            <table class="table">
                <thead><tr><th>Key</th><th>Value</th><th>Description</th><th>Category</th><th>Action</th></tr></thead>
                <tbody>
                    <c:forEach var="p" items="${policies}">
                        <tr>
                            <td><code>${p.policyKey}</code></td>
                            <td><strong>${p.policyValue}</strong></td>
                            <td>${p.description}</td>
                            <td><span class="badge badge-confirmed">${p.category}</span></td>
                            <td><button class="btn btn-outline" style="padding:4px 10px;font-size:12px;">Edit</button></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>
        <c:if test="${empty policies}"><div class="placeholder-content"><p>No policy settings found.</p></div></c:if>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
