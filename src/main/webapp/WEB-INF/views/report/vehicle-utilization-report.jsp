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
    select.bk-form-select {
        padding-left: 12px !important;
        padding-right: 28px !important;
        min-width: 110px !important;
        width: auto !important;
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

                        <input type="hidden" name="type" id="utilizationFilterType" value="${type}">

                        <button
                            type="button"
                            onclick="document.getElementById('utilizationFilterType').value='MONTH'; this.form.submit();"
                            class="bk-btn bk-btn-sm filter-btn ${type=='MONTH'?'active':''}">
                            Tháng
                        </button>

                        <button
                            type="button"
                            onclick="document.getElementById('utilizationFilterType').value='QUARTER'; this.form.submit();"
                            class="bk-btn bk-btn-sm filter-btn ${type=='QUARTER'?'active':''}">
                            Quý
                        </button>

                        <button
                            type="button"
                            onclick="document.getElementById('utilizationFilterType').value='YEAR'; this.form.submit();"
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

                <!-- CHART BOX (PLOT AREA + Y-AXIS) -->
                <div>
                    <div style="display:flex; height:300px; width:100%;">
                        <!-- Y AXIS -->
                        <div style="width:55px; display:flex; flex-direction:column; justify-content:space-between; align-items:flex-end; padding-right:10px; color:var(--on-surface-variant); font-size:12px; font-weight:600; line-height:1;">
                            <span>100%</span>
                            <span>80%</span>
                            <span>60%</span>
                            <span>40%</span>
                            <span>20%</span>
                            <span>0%</span>
                        </div>

                        <!-- CHART AREA -->
                        <div style="flex:1; position:relative; border-left:1px solid var(--outline-variant); border-bottom:2px solid var(--outline); display:flex; justify-content:space-around; align-items:flex-end; padding:0 30px;">
                            <!-- GRID -->
                            <div style="position:absolute; left:0; right:0; top:0; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                            <div style="position:absolute; left:0; right:0; top:20%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                            <div style="position:absolute; left:0; right:0; top:40%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                            <div style="position:absolute; left:0; right:0; top:60%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>
                            <div style="position:absolute; left:0; right:0; top:80%; border-top:1px dashed var(--outline-variant); opacity:.35;"></div>

                            <c:forEach items="${chartData}" var="c">
                                <div style="width:80px; height:100%; display:flex; flex-direction:column; align-items:center; justify-content:flex-end; position:relative; z-index:2;">
                                    <!-- VALUE -->
                                    <span style="position:absolute; bottom:calc(${c.height}% + 6px); font-size:12px; font-weight:700; color:var(--primary); white-space:nowrap;">
                                        <fmt:formatNumber value="${c.usage}" maxFractionDigits="1"/>%
                                    </span>

                                    <!-- BAR -->
                                    <div style="width:38px; height:${c.height}%; background:var(--primary); border-radius:6px 6px 0 0;"></div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- X AXIS LABELS -->
                    <div style="display:flex; margin-left:55px; padding:8px 30px 0 30px;">
                        <div style="flex:1; display:flex; justify-content:space-around;">
                            <c:forEach items="${chartData}" var="c">
                                <div style="width:80px; text-align:center;">
                                    <span style="font-weight:600; font-size:12px; white-space:nowrap; color:var(--on-surface-variant);">
                                        ${c.label}
                                    </span>
                                </div>
                            </c:forEach>
                        </div>
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

                <div class="pie-chart"
                     style="background:${segmentGradient};">
                </div>
                <div class="bk-detail-rows" style="margin-top:24px;gap:20px;">

                    <c:if test="${segmentTotal == 0}">
                        <p style="text-align:center;color:var(--secondary);font-size:13px;margin-top:40px;font-weight:600;">Chưa có dữ liệu phân khúc</p>
                    </c:if>
                    <c:forEach items="${segmentUsage}" var="s" varStatus="st">
                        <c:if test="${s.value > 0}">
                            <c:set var="usedDays"
                                   value="${segmentTotal==0?0:s.value*100.0/segmentTotal}"/>

                            <c:set var="color"
                                   value="${st.index % 6 == 0 ? 'var(--primary)'
                                            : st.index % 6 == 1 ? 'var(--success)'
                                            : st.index % 6 == 2 ? 'var(--warning)'
                                            : st.index % 6 == 3 ? 'var(--error)'
                                            : st.index % 6 == 4 ? 'var(--secondary)'
                                            : 'var(--outline)'}"/>

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
                        </c:if>
                    </c:forEach>

                </div>

            </div>
        </div>
    </div>

    <%-- LIST OF POPULAR CARS --%>
    <div class="bk-card" style="margin-top:24px;">
        <div class="bk-card-title" style="display: flex; justify-content: space-between; align-items: center;">
            <span><span class="material-symbols-outlined" style="vertical-align: middle; margin-right: 6px;">directions_car</span> Chi tiết Tần suất Sử dụng của từng Xe</span>
            <button type="button" class="bk-btn bk-btn-sm" onclick="exportTableToCSV('hieu_suat_su_dung_xe.csv', 'utilization-table')" style="background: var(--primary); color: white; display: flex; align-items: center; gap: 4px; padding: 6px 12px; font-weight: 600; cursor: pointer;">
                <span class="material-symbols-outlined" style="font-size: 18px;">download</span> Xuất Excel
            </button>
        </div>

        <div style="overflow-x:auto;margin-top:16px;">
            <table class="bk-table" id="utilization-table">
                <thead>
                    <tr>
                        <th>Thông tin Xe</th>
                        <th>Biển kiểm soát</th>
                        <th>Số ngày cho thuê</th>
                        <th>Mức độ sử dụng (%)</th>
                        <th style="width:200px;">Biểu đồ hiệu suất</th>
                        <th>Khuyến nghị</th>
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
                                    value="${v.percent}"
                                    maxFractionDigits="1"/>%

                            </td>

                            <td>

                                <div style="
                                     background:var(--surface-container);
                                     height:8px;
                                     border-radius:4px;
                                     overflow:hidden;">

                                    <div style="
                                         width:${v.percent}%;
                                         background:var(--primary);
                                         height:100%;">
                                    </div>

                                </div>

                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${v.percent >= 70.0}">
                                        <span style="color:var(--success); font-weight:700; font-size: 12px; display: flex; align-items: center; gap: 4px;">
                                            <span class="material-symbols-outlined" style="font-size:16px;">add_circle</span> Nhu cầu cao (Đề xuất thêm xe)
                                        </span>
                                    </c:when>
                                    <c:when test="${v.percent <= 30.0}">
                                        <span style="color:var(--error); font-weight:700; font-size: 12px; display: flex; align-items: center; gap: 4px;">
                                            <span class="material-symbols-outlined" style="font-size:16px;">sell</span> Hiệu suất thấp (Nên giảm giá)
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--info); font-weight:700; font-size: 12px; display: flex; align-items: center; gap: 4px;">
                                            <span class="material-symbols-outlined" style="font-size:16px;">check_circle</span> Tối ưu
                                        </span>
                                    </c:otherwise>
                                </c:choose>
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

<script>
function exportTableToCSV(filename, tableId) {
    var csv = [];
    var rows = document.querySelectorAll("#" + tableId + " tr");
    
    for (var i = 0; i < rows.length; i++) {
        var row = [], cols = rows[i].querySelectorAll("td, th");
        
        for (var j = 0; j < cols.length; j++) {
            var text = cols[j].innerText.replace(/(\r\n|\n|\r)/gm, "").replace(/^\s+|\s+$/g, "");
            text = text.replace(/"/g, '""');
            row.push('"' + text + '"');
        }
        
        csv.push(row.join(","));        
    }

    var csvFile = new Blob(["\ufeff" + csv.join("\n")], {type: "text/csv;charset=utf-8;"});
    var downloadLink = document.createElement("a");
    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = "none";
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

function paginateTable(tableId, rowsPerPage) {
    var table = document.getElementById(tableId);
    if (!table) return;
    
    var tbody = table.querySelector("tbody");
    if (!tbody) return;
    
    var rows = tbody.querySelectorAll("tr");
    var totalRows = rows.length;
    if (totalRows <= rowsPerPage) return;
    
    var totalPages = Math.ceil(totalRows / rowsPerPage);
    var currentPage = 1;
    
    var navContainer = document.createElement("div");
    navContainer.className = "bk-pagination";
    navContainer.style.cssText = "display: flex; justify-content: center; gap: 8px; margin-top: 16px; align-items: center;";
    table.parentNode.appendChild(navContainer);
    
    function showPage(page) {
        currentPage = page;
        var start = (page - 1) * rowsPerPage;
        var end = start + rowsPerPage;
        
        for (var i = 0; i < totalRows; i++) {
            if (i >= start && i < end) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
        
        renderButtons();
    }
    
    function renderButtons() {
        navContainer.innerHTML = "";
        
        var prevBtn = document.createElement("button");
        prevBtn.type = "button";
        prevBtn.className = "bk-btn bk-btn-outline bk-btn-sm";
        prevBtn.innerText = "Trước";
        prevBtn.disabled = currentPage === 1;
        prevBtn.style.padding = "4px 8px";
        prevBtn.onclick = function() { if (currentPage > 1) showPage(currentPage - 1); };
        navContainer.appendChild(prevBtn);
        
        function createPageBtn(p) {
            var btn = document.createElement("button");
            btn.type = "button";
            btn.className = "bk-btn bk-btn-sm " + (p === currentPage ? "active" : "");
            btn.innerText = p;
            btn.style.padding = "4px 10px";
            if (p === currentPage) {
                btn.style.background = "var(--primary)";
                btn.style.color = "white";
            } else {
                btn.style.background = "transparent";
                btn.style.border = "1px solid var(--outline-variant)";
                btn.style.color = "var(--on-surface)";
            }
            btn.onclick = function() { showPage(p); };
            navContainer.appendChild(btn);
        }

        function createEllipsis() {
            var span = document.createElement("span");
            span.innerText = "...";
            span.style.cssText = "padding: 4px 6px; color: var(--secondary); font-weight: bold;";
            navContainer.appendChild(span);
        }

        if (totalPages <= 5) {
            for (var i = 1; i <= totalPages; i++) {
                createPageBtn(i);
            }
        } else {
            createPageBtn(1);

            if (currentPage <= 3) {
                createPageBtn(2);
                createPageBtn(3);
                createPageBtn(4);
                createEllipsis();
                createPageBtn(totalPages);
            } else if (currentPage >= totalPages - 2) {
                createEllipsis();
                createPageBtn(totalPages - 3);
                createPageBtn(totalPages - 2);
                createPageBtn(totalPages - 1);
                createPageBtn(totalPages);
            } else {
                createEllipsis();
                createPageBtn(currentPage - 1);
                createPageBtn(currentPage);
                createPageBtn(currentPage + 1);
                createEllipsis();
                createPageBtn(totalPages);
            }
        }
        
        var nextBtn = document.createElement("button");
        nextBtn.type = "button";
        nextBtn.className = "bk-btn bk-btn-outline bk-btn-sm";
        nextBtn.innerText = "Sau";
        nextBtn.disabled = currentPage === totalPages;
        nextBtn.style.padding = "4px 8px";
        nextBtn.onclick = function() { if (currentPage < totalPages) showPage(currentPage + 1); };
        navContainer.appendChild(nextBtn);
    }
    
    showPage(1);
}

document.addEventListener("DOMContentLoaded", function() {
    paginateTable('utilization-table', 5);
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
