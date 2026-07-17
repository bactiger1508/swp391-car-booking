<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Hiệu suất Sử dụng xe"/>
</jsp:include>

<style>
    .pie-chart{
        width:180px;
        height:180px;
        border-radius:50%;
        margin:20px auto;
        position:relative;
    }

    .pie-chart::after{
        content:"";
        position:absolute;
        inset:35px;
        background:white;
        border-radius:50%;
    }

    .filter-btn.active{
        background:var(--primary);
        color:#fff;
    }
</style>

<form action="${pageContext.request.contextPath}/reports/vehicle-utilization"method="GET">
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
            <span class="value" style="color:var(--primary);">
                <fmt:formatNumber value="${averageUsage}" maxFractionDigits="1"/>%
            </span>

            <span style="font-size:12px;color:var(--success);margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
                <span style="
                      font-size:12px;
                      color:${usageGrowth>0?'var(--success)':usageGrowth<0?'var(--error)':'var(--on-surface-variant)'};
                      margin-top:6px;
                      font-weight:600;
                      display:flex;
                      align-items:center;
                      gap:4px;">

                    <c:choose>

                        <c:when test="${usageGrowth>0}">
                            <span class="material-symbols-outlined"
                                  style="font-size:16px;color:var(--success);">
                                trending_up
                            </span>

                            <fmt:formatNumber value="${usageGrowth}" maxFractionDigits="2"/>%
                            so với ${compareLabel}

                        </c:when>

                        <c:when test="${usageGrowth<0}">

                            <span class="material-symbols-outlined"
                                  style="font-size:16px;color:var(--error);">
                                trending_down
                            </span>

                            <fmt:formatNumber value="${usageGrowth}" maxFractionDigits="2"/>%
                            so với ${compareLabel}

                        </c:when>

                        <c:otherwise>

                            <span class="material-symbols-outlined"
                                  style="font-size:16px;color:var(--warning);">
                                trending_flat
                            </span>

                            0%
                            so với ${compareLabel}

                        </c:otherwise>

                    </c:choose>

                </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Tổng ngày lăn bánh</span>
            <span class="value" style="color:var(--info);">
                ${totalUsedDays} ngày
            </span>
            <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
                Tính trên tổng đội xe 18 chiếc
            </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Xe được thuê nhiều nhất</span>
            <c:choose>
                <c:when test="${not empty mostUsedCar}">
                    <span class="value" style="font-size:18px; font-weight:700; color:var(--primary); margin-top:8px; display:block;">
                        ${mostUsedCar.car.brand} ${mostUsedCar.car.model}
                    </span>
                    <span style="font-size:12px;color:var(--primary);margin-top:4px;font-weight:700;display:block;">
                        ${mostUsedCar.usedDays} ngày hoạt động
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="value" style="font-size:18px; font-weight:700; color:var(--on-surface-variant); margin-top:8px; display:block;">
                        Không có dữ liệu
                    </span>
                    <span style="font-size:12px;color:var(--secondary);margin-top:4px;font-weight:600;display:block;">
                        Chưa có lịch thuê trong kỳ
                    </span>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="bk-stat-card">
            <span class="label">Tỷ lệ bảo dưỡng</span>
            <span class="value" style="color:var(--error);">4.2%</span>
            <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
                Chỉ số xe nằm xưởng thấp
            </span>
        </div>
    </div>

    <%-- GRAPH & BREAKDOWN GRID --%>
    <div class="bk-detail-grid" style="margin-top:24px; align-items:stretch;">
        <%-- LEFT: Biểu đồ hiệu suất SVG --%>
        <div style="display:flex;">
            <div class="bk-card" style="width:100%; height:100%;">
                <div class="bk-card-title" style="display:flex; align-items:center; justify-content:space-between;">
                    <!-- Bên trái -->
                    <div style="display:flex; align-items:center; gap:8px;">
                        <span class="material-symbols-outlined">bar_chart</span>
                        <span>Hiệu suất sử dụng theo thời gian</span>
                    </div>

                    <!--Bên phải-->
                    <div style="display:flex;
                         gap:6px;
                         padding:4px;
                         border-radius:8px;
                         background:var(--surface-variant);
                         border:1px solid var(--outline-variant);">

                        <button
                            type="submit"
                            name="type"
                            value="MONTH"
                            class="bk-btn bk-btn-sm filter-btn ${type=='MONTH'?'active':''}">
                            Tháng
                        </button>

                        <button
                            type="submit"
                            name="type"
                            value="QUARTER"
                            class="bk-btn bk-btn-sm filter-btn ${type=='QUARTER'?'active':''}">
                            Quý
                        </button>

                        <button
                            type="submit"
                            name="type"
                            value="YEAR"
                            class="bk-btn bk-btn-sm filter-btn ${type=='YEAR'?'active':''}">
                            Năm
                        </button>
                        <c:if test="${type=='MONTH'}">

                            <select name="month"
                                    class="bk-form-select"
                                    onchange="this.form.submit()">

                                <c:forEach begin="1" end="12" var="m">
                                    <option value="${m}"
                                            ${m==month?'selected':''}>
                                        Tháng ${m}
                                    </option>
                                </c:forEach>

                            </select>

                            <select name="year"
                                    class="bk-form-select"
                                    onchange="this.form.submit()">

                                <c:forEach begin="2025" end="2035" var="y">
                                    <option value="${y}"
                                            ${y==year?'selected':''}>
                                        ${y}
                                    </option>
                                </c:forEach>

                            </select>

                        </c:if>
                        <c:if test="${type=='QUARTER'}">

                            <select name="quarter"
                                    class="bk-form-select"
                                    onchange="this.form.submit()">

                                <option value="1" ${quarter==1?'selected':''}>Quý I</option>
                                <option value="2" ${quarter==2?'selected':''}>Quý II</option>
                                <option value="3" ${quarter==3?'selected':''}>Quý III</option>
                                <option value="4" ${quarter==4?'selected':''}>Quý IV</option>

                            </select>

                            <select name="year"
                                    class="bk-form-select"
                                    onchange="this.form.submit()">

                                <c:forEach begin="2025" end="2035" var="y">
                                    <option value="${y}"
                                            ${y==year?'selected':''}>
                                        ${y}
                                    </option>
                                </c:forEach>

                            </select>

                        </c:if>

                        <c:if test="${type=='YEAR'}">

                            <select name="year"
                                    class="bk-form-select"
                                    onchange="this.form.submit()">

                                <c:forEach begin="2025" end="2035" var="y">

                                    <option value="${y}"
                                            ${y==year?'selected':''}>
                                        ${y}
                                    </option>

                                </c:forEach>

                            </select>

                        </c:if>
                    </div>
                </div>

                <!--Card biểu đồ-->
                <div style="display:flex; height:360px; width:100%;">

                    <!-- Y AXIS -->
                    <c:set var="maxY" value="${chartMax * 1.2}" />
                    <div style="width:55px; height:360px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-end; padding-right:10px; padding-bottom:0px; color:var(--on-surface-variant); font-size:12px; font-weight:600;">
                        <span>
                            100<fmt:formatNumber value="${maxY/1000000}" maxFractionDigits="0"/>
                        </span>

                        <span>
                            80<fmt:formatNumber value="${maxY*0.8/1000000}" maxFractionDigits="0"/>
                        </span>

                        <span>
                            60<fmt:formatNumber value="${maxY*0.6/1000000}" maxFractionDigits="0"/>
                        </span>

                        <span>
                            40<fmt:formatNumber value="${maxY*0.4/1000000}" maxFractionDigits="0"/>
                        </span>

                        <span>
                            20<fmt:formatNumber value="${maxY*0.2/1000000}" maxFractionDigits="0"/>
                        </span>

                        <span>0</span>

                    </div>

                    <!-- CHART AREA -->
                    <div style="flex:1; height:360px; position:relative; border-left:1px solid var(--outline-variant); border-bottom:1px solid var(--outline-variant); display:flex; justify-content:space-around; align-items:flex-end; padding:0 30px 0;">
                        <!-- GRID -->
                        <div style="position:absolute; left:0; right:0; top:0; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                        <div style="position:absolute; left:0; right:0; top:20%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                        <div style="position:absolute; left:0; right:0; top:40%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                        <div style="position:absolute; left:0; right:0; top:60%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                        <div style="position:absolute; left:0; right:0; top:80%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>

                        <c:forEach items="${chartData}" var="c">
                            <div style="width:70px; height:100%; display:flex; flex-direction:column; align-items:center; justify-content:flex-end; position:relative; z-index:2;">
                                <!-- VALUE -->
                                <span style="margin-bottom:6px; font-size:12px; font-weight:700; color:${c.current ? 'var(--primary)' : 'var(--secondary)'};">
                                    <fmt:formatNumber value="${c.usage}" maxFractionDigits="0"/>tr
                                </span>

                                <!-- BAR -->
                                <div style="width:38px; height:${c.height*0.85}%; background:${c.current ? 'var(--primary)' : 'var(--secondary)'}; border-radius:8px 8px 0 0;"></div>

                                <!-- MONTH -->
                                <span style="margin-top:10px; font-size:12px; font-weight:600; color:${c.current ? 'var(--primary)' : 'var(--on-surface-variant)'};">
                                    ${c.label}
                                </span>
                            </div>
                        </c:forEach>
                    </div>
                </div>     
            </div>                
        </div>

        <%-- RIGHT: Cơ cấu hiệu suất theo phân khúc xe --%>
        <div style="display:flex;">
            <div class="bk-card" style="width:100%; height:100%; padding:24px;">
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">donut_large</span> Hiệu suất sử dụng theo phân khúc
                </div>
                <c:set var="c1" value="${segmentUsage['Sedan'] * 100 / totalSegmentUsage}" />
                <c:set var="c2" value="${segmentUsage['SUV / Crossover'] * 100 / totalSegmentUsage}" />
                <c:set var="c3" value="${segmentUsage['MPV gia đình'] * 100 / totalSegmentUsage}" />
                <c:set var="c4" value="${segmentUsage['Xe bán tải / Pickup'] * 100 / totalSegmentUsage}" />
                <c:set var="c5" value="${segmentUsage['Xe điện'] * 100 / totalSegmentUsage}" />

                <c:set var="p1" value="${c1}" />
                <c:set var="p2" value="${c1+c2}" />
                <c:set var="p3" value="${c1+c2+c3}" />
                <c:set var="p4" value="${c1+c2+c3+c4}" />

                <div class="pie-chart"
                     style="background:${segmentGradient};">
                </div>
                <div class="bk-detail-rows" style="margin-top:24px;gap:20px;">

                    <c:forEach items="${segmentUsage}" var="s" varStatus="st">

                        <c:set var="usedDays"
                               value="${segmentTotal==0?0:s.value*100.0/segmentTotal}"/>

                        <c:set var="color"
                               value="${st.index==0?'var(--primary)'
                                        :st.index==1?'var(--success)'
                                        :st.index==2?'var(--warning)'
                                        :st.index==3?'var(--error)'
                                        :'var(--secondary)'}"/>

                        <div>

                            <div style="display:flex;
                                 justify-content:space-between;
                                 margin-bottom:6px;
                                 font-size:13px;
                                 font-weight:600;">

                                <span>${s.key}</span>

                                <span>

                                    ${s.value} ngày

                                    (<fmt:formatNumber
                                        value="${usedDays}"
                                        maxFractionDigits="1"/>%)

                                </span>

                            </div>

                            <div style="background:var(--surface-container);
                                 height:8px;
                                 border-radius:4px;
                                 overflow:hidden;">

                                <div style="
                                     background:${color};
                                     width:${usedDays}%;
                                     height:100%;">
                                </div>

                            </div>

                        </div>

                    </c:forEach>

                </div>

            </div>
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

                    <c:forEach items="${vehicleUsage}" var="v">

                        <tr>

                            <td style="font-weight:700;color:var(--primary);">
                                ${v.car.brand}
                                ${v.car.model}
                            </td>

                            <td class="code">
                                ${v.car.licensePlate}
                            </td>

                            <td>
                                ${v.usedDays} ngày
                            </td>

                            <td style="font-weight:700;">

                                <fmt:formatNumber
                                    value="${v.usedDays}"
                                    maxFractionDigits="1"/>%

                            </td>

                            <td>

                                <div style="
                                     background:var(--surface-container);
                                     height:8px;
                                     border-radius:4px;
                                     overflow:hidden;">

                                    <div style="
                                         width:${v.usedDays}%;
                                         background:var(--primary);
                                         height:100%;">
                                    </div>

                                </div>

                            </td>

                            <td>

                                <c:choose>

                                    <c:when test="${v.car.status=='RENTED'}">

                                        <span class="bk-badge bk-badge-progress">
                                            <span class="bk-badge-dot"></span>
                                            ĐANG THUÊ
                                        </span>

                                    </c:when>

                                    <c:when test="${v.car.status=='AVAILABLE'}">

                                        <span class="bk-badge bk-badge-confirmed">
                                            <span class="bk-badge-dot"></span>
                                            SẴN SÀNG
                                        </span>

                                    </c:when>

                                    <c:otherwise>

                                        <span class="bk-badge bk-badge-pending">
                                            <span class="bk-badge-dot"></span>
                                            BẢO DƯỠNG
                                        </span>

                                    </c:otherwise>

                                </c:choose>

                            </td>

                        </tr>

                    </c:forEach>

                </tbody>
            </table>
        </div>
    </div>
</form>
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
