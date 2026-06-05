<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Cấu hình Chính sách Thuê xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Cấu hình chính sách</span>
        </div>
        <h2>Thiết lập Chính sách & Phí phạt</h2>
        <p>Quản lý các quy tắc phạt trễ hạn, quá số km quy định, vệ sinh, mất đồ và cách tính phí thuê xe mặc định.</p>
    </div>
</div>

<div class="bk-table-container">
    <div class="bk-table-toolbar">
        <div class="bk-table-search">
            <span class="material-symbols-outlined">search</span>
            <input type="text" id="searchInput" placeholder="Tìm kiếm chính sách..." oninput="filterTable()">
        </div>
    </div>

    <c:if test="${not empty policies}">
        <div style="overflow-x:auto;">
            <table class="bk-table" id="policyTable">
                <thead>
                    <tr>
                        <th>Mã quy định</th>
                        <th>Giá trị thiết lập</th>
                        <th>Mô tả quy tắc chính sách</th>
                        <th>Phân loại</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${policies}">
                        <tr>
                            <td class="code"><code>${p.policyKey}</code></td>
                            <td>
                                <div style="font-weight:700;color:var(--primary);font-size:16px;">
                                    ${p.policyValue}
                                </div>
                            </td>
                            <td>
                                <div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">
                                    ${p.description}
                                </div>
                            </td>
                            <td>
                                <span class="bk-badge bk-badge-confirmed">
                                    <span class="bk-badge-dot"></span> ${p.category}
                                </span>
                            </td>
                            <td class="text-right">
                                <button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </c:if>
    <c:if test="${empty policies}">
        <!-- Dữ liệu mẫu fallback nếu CSDL trống để UI luôn lung linh -->
        <div style="overflow-x:auto;">
            <table class="bk-table" id="policyTable">
                <thead>
                    <tr>
                        <th>Mã quy định</th>
                        <th>Giá trị thiết lập</th>
                        <th>Mô tả quy tắc chính sách</th>
                        <th>Phân loại</th>
                        <th style="text-align:right;">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="code"><code>LATE_RETURN_FEE_HOUR</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">100,000đ / giờ</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Phí phạt trễ giờ trả xe theo quy định đã ký kết trong hợp đồng thuê.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                    <tr>
                        <td class="code"><code>OVER_KM_LIMIT_FEE</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">5,000đ / km</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Phí thu thêm trên mỗi kilômét vượt quá định mức tối đa của ngày thuê.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                    <tr>
                        <td class="code"><code>CLEANING_VIOLATION_FEE</code></td>
                        <td><div style="font-weight:700;color:var(--primary);font-size:16px;">300,000đ</div></td>
                        <td><div style="max-width:400px;font-size:13px;line-height:1.6;color:var(--on-surface-variant);">Khoản thu bổ sung nếu xe trả bị quá bẩn, có mùi hôi hoặc vết bẩn khó làm sạch.</div></td>
                        <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> PENALTY</span></td>
                        <td class="text-right"><button type="button" class="bk-btn bk-btn-outline bk-btn-sm" onclick="alert('Tính năng chỉnh sửa chính sách thuộc Iteration 2/3 (Left for later).')">Sửa</button></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </c:if>
</div>

<script>
function filterTable() {
    var input = document.getElementById('searchInput').value.toLowerCase();
    var rows = document.querySelectorAll('#policyTable tbody tr');
    rows.forEach(function(row) {
        row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
    });
}
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
