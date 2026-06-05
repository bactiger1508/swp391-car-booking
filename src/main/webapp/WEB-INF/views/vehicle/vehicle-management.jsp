<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Vehicle Management"/>
</jsp:include>
<div class="page-content">
    <div class="card">
        <div class="placeholder-content">
            <div class="icon">&#9881;</div>
            <h2>Vehicle Management</h2>
            <p>Add, edit, and manage vehicles in the fleet. Update status and maintenance info.</p>
            <p style="margin-top:16px;font-size:13px;color:var(--text-light);">This page is under development.</p>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
