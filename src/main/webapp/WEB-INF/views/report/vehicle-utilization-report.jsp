<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Hiệu suất Sử dụng xe"/>
</jsp:include>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Báo cáo hiệu suất xe</span>
        </div>
        <h2>Báo cáo Hiệu suất & Tần suất Sử dụng xe</h2>
        <p>Thống kê tỷ lệ thuê xe trống, tổng số ngày hoạt động và hiệu suất quay vòng của từng đầu xe.</p>
    </div>
</div>

<%-- STATS GRID --%>
<div class="bk-stats-grid">
    <div class="bk-stat-card">
        <span class="label">Hiệu suất Trung bình</span>
        <span class="value" style="color:var(--primary);">78.4%</span>
        <span style="font-size:12px;color:var(--success);margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
            <span class="material-symbols-outlined" style="font-size:16px;">trending_up</span> +3.2% so với quý trước
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Tổng ngày lăn bánh</span>
        <span class="value" style="color:var(--info);">842 ngày</span>
        <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
            Tính trên tổng đội xe 18 chiếc
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Xe được thuê nhiều nhất</span>
        <span class="value" style="font-size:22px;margin-top:16px;">Mazda 3 (Biển 29A-888.88)</span>
        <span style="font-size:12px;color:var(--primary);margin-top:8px;font-weight:700;">
            26 ngày hoạt động/tháng
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Tỷ lệ bảo dưỡng</span>
        <span class="value" style="color:var(--error);">4.2%</span>
        <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
            Chỉ số xe nằm xưởng thấp
        </span>
    </div>
</div>

<%-- LIST OF POPULAR CARS --%>
<div class="bk-card" style="margin-top:24px;">
    <div class="bk-card-title">
        <span class="material-symbols-outlined">directions_car</span> Chi tiết Tần suất Sử dụng của từng Xe
    </div>
    
    <div style="overflow-x:auto;margin-top:16px;">
        <table class="bk-table">
            <thead>
                <tr>
                    <th>Thông tin Xe</th>
                    <th>Biển kiểm soát</th>
                    <th>Số ngày cho thuê</th>
                    <th>Mức độ sử dụng (%)</th>
                    <th style="width:250px;">Biểu đồ hiệu suất</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style="font-weight:700;color:var(--primary);">Mazda 3 Premium</td>
                    <td class="code">29A-888.88</td>
                    <td>26 ngày / 30 ngày</td>
                    <td style="font-weight:700;color:var(--success);">86.6%</td>
                    <td>
                        <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                            <div style="background:var(--success);height:100%;width:86.6%;"></div>
                        </div>
                    </td>
                    <td><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> ĐANG THUÊ</span></td>
                </tr>
                <tr>
                    <td style="font-weight:700;color:var(--primary);">VinFast VF8 Plus</td>
                    <td class="code">30H-999.66</td>
                    <td>24 ngày / 30 ngày</td>
                    <td style="font-weight:700;color:var(--success);">80.0%</td>
                    <td>
                        <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                            <div style="background:var(--success);height:100%;width:80%;"></div>
                        </div>
                    </td>
                    <td><span class="bk-badge bk-badge-progress"><span class="bk-badge-dot"></span> ĐANG THUÊ</span></td>
                </tr>
                <tr>
                    <td style="font-weight:700;color:var(--primary);">Toyota Camry 2.5Q</td>
                    <td class="code">30E-445.67</td>
                    <td>22 ngày / 30 ngày</td>
                    <td style="font-weight:700;color:var(--primary);">73.3%</td>
                    <td>
                        <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                            <div style="background:var(--primary);height:100%;width:73.3%;"></div>
                        </div>
                    </td>
                    <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> SẴN SÀNG</span></td>
                </tr>
                <tr>
                    <td style="font-weight:700;color:var(--primary);">Hyundai SantaFe 2.2D</td>
                    <td class="code">29K-777.89</td>
                    <td>20 ngày / 30 ngày</td>
                    <td style="font-weight:700;color:var(--primary);">66.6%</td>
                    <td>
                        <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                            <div style="background:var(--primary);height:100%;width:66.6%;"></div>
                        </div>
                    </td>
                    <td><span class="bk-badge bk-badge-confirmed"><span class="bk-badge-dot"></span> SẴN SÀNG</span></td>
                </tr>
                <tr>
                    <td style="font-weight:700;color:var(--primary);">Honda City RS</td>
                    <td class="code">30K-123.45</td>
                    <td>15 ngày / 30 ngày</td>
                    <td style="font-weight:700;color:var(--secondary);">50.0%</td>
                    <td>
                        <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                            <div style="background:var(--secondary);height:100%;width:50%;"></div>
                        </div>
                    </td>
                    <td><span class="bk-badge bk-badge-pending" style="background:var(--warning-container);color:var(--on-warning-container);"><span class="bk-badge-dot"></span> ĐANG BẢO DƯỠNG</span></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
