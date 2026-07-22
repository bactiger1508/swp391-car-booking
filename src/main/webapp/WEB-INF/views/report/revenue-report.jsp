<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Báo cáo Doanh thu"/>
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

    .filter-btn.active {
        background: var(--primary);
        color:white;
    }
    select.bk-form-select {
        padding-left: 12px !important;
        padding-right: 28px !important;
        min-width: 110px !important;
        width: auto !important;
    }
</style>

<div class="bk-page-header">
    <div>
        <div class="bk-breadcrumb">
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span class="current">Báo cáo doanh thu</span>
        </div>
        <h2>Báo cáo Doanh thu Tài chính</h2>
        <p>Phân tích nguồn thu chi tiết theo doanh số thuê xe, đặt cọc và các khoản phụ thu phát sinh.</p>
    </div>
</div>

<form action="${pageContext.request.contextPath}/reports/revenue" method="GET" enctype="multipart/form-data">
    <%-- STATS GRID --%>
    <div style="display: flex; flex-direction: column; gap: 20px; margin-bottom: 24px;">
        <%-- Row 1: Key Performance Metrics (3 columns) --%>
        <div class="bk-stats-grid-row-1" style="display:grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div class="bk-stat-card" style="padding: 20px;">
                <span class="label">Tổng Doanh thu</span>
                <span class="value" style="color:var(--primary); font-size: 28px;">
                    <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:${revenueGrowth > 0 ? 'var(--success)' : revenueGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:8px;font-weight:600;display:flex;align-items:center;gap:4px;">
                    <c:choose>
                        <c:when test="${revenueGrowth > 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--success);">trending_up</span>+${String.format("%.2f", revenueGrowth)}% so với kỳ trước
                        </c:when>

                        <c:when test="${revenueGrowth < 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--error);">trending_down</span>${String.format("%.2f", revenueGrowth)}% so với kỳ trước
                        </c:when>

                        <c:otherwise>
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--warning);">trending_flat</span>0% so với kỳ trước
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <div class="bk-stat-card" style="padding: 20px;">
                <span class="label">Lợi nhuận Ròng</span>
                <span class="value" style="color:var(--success); font-size: 28px;">
                    <fmt:formatNumber value="${netProfit}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:${netProfitGrowth > 0 ? 'var(--success)' : netProfitGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:8px;font-weight:600;display:flex;align-items:center;gap:4px;">
                    <c:choose>
                        <c:when test="${netProfitGrowth > 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--success);">trending_up</span>+${String.format("%.2f", netProfitGrowth)}% so với kỳ trước
                        </c:when>

                        <c:when test="${netProfitGrowth < 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--error);">trending_down</span>${String.format("%.2f", netProfitGrowth)}% so với kỳ trước
                        </c:when>

                        <c:otherwise>
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--warning);">trending_flat</span>0% so với kỳ trước
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <div class="bk-stat-card" style="padding: 20px;">
                <span class="label">Đơn thuê hoàn tất</span>
                <span class="value" style="color:var(--info); font-size: 28px;">${completedBooking}</span>
                <span style="font-size:12px;color:${bookingGrowth > 0 ? 'var(--success)' : bookingGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:8px;font-weight:600;display:flex;align-items:center;gap:4px;">
                    <c:choose>
                        <c:when test="${bookingGrowth > 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--success);">trending_up</span>+${String.format("%.2f", bookingGrowth)}% so với kỳ trước
                        </c:when>

                        <c:when test="${bookingGrowth < 0}">
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--error);">trending_down</span>${String.format("%.2f", bookingGrowth)}% so với kỳ trước
                        </c:when>

                        <c:otherwise>
                            <span class="material-symbols-outlined" style="font-size:18px;color:var(--warning);">trending_flat</span>0% so với kỳ trước
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <%-- Row 2: Breakdown Details (4 columns) --%>
        <div class="bk-stats-grid-row-2" style="display:grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
            <div class="bk-stat-card" style="padding: 16px;">
                <span class="label">Doanh thu Thuê xe</span>
                <span class="value" style="font-size: 20px;">
                    <fmt:formatNumber value="${rentalRevenue}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;display:block;">
                    Tỷ trọng: ${rentalRatio}% tổng thu
                </span>
            </div>

            <div class="bk-stat-card" style="padding: 16px;">
                <span class="label">Tiền cọc đang giữ</span>
                <span class="value" style="color:var(--warning); font-size: 20px;">
                    <fmt:formatNumber value="${depositRevenue}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;display:block;">
                    Tiền giữ thế chấp
                </span>
            </div>

            <div class="bk-stat-card" style="padding: 16px;">
                <span class="label">Phụ thu phát sinh</span>
                <span class="value" style="color:var(--error); font-size: 20px;">
                    <fmt:formatNumber value="${additionalRevenue}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:${additionalFeeGrowth > 0 ? 'var(--success)' : additionalFeeGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
                    <c:choose>
                        <c:when test="${additionalFeeGrowth > 0}">
                            <span class="material-symbols-outlined" style="font-size:16px;color:var(--success);">trending_up</span>+${String.format("%.2f", additionalFeeGrowth)}%
                        </c:when>
                        <c:when test="${additionalFeeGrowth < 0}">
                            <span class="material-symbols-outlined" style="font-size:16px;color:var(--error);">trending_down</span>${String.format("%.2f", additionalFeeGrowth)}%
                        </c:when>
                        <c:otherwise>
                            <span class="material-symbols-outlined" style="font-size:16px;color:var(--warning);">trending_flat</span>0%
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>

            <div class="bk-stat-card" style="padding: 16px;">
                <span class="label">Chi phí Bảo dưỡng</span>
                <span class="value" style="color:var(--error); font-size: 20px;">
                    <fmt:formatNumber value="${maintenanceCost}" type="number" maxFractionDigits="0"/>đ
                </span>
                <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;display:block;">
                    Phí bảo trì đã hoàn tất
                </span>
            </div>
        </div>
    </div>

    <%-- GRAPH & BREAKDOWN GRID --%>
    <div class="bk-detail-grid"
         style="display:grid;
         grid-template-columns:1.8fr 1.1fr 1.1fr;
         gap:20px;
         align-items:stretch;
         margin-top:24px;">

        <!-- ================= LEFT CARD ================= -->
        <div class="bk-card"
             style="padding:24px;
             display:flex;
             flex-direction:column;">

            <!-- HEADER -->
            <div class="bk-card-title"
                 style="display:flex;
                 justify-content:space-between;
                 align-items:center;
                 border-bottom:1px solid var(--outline-variant);
                 padding-bottom:12px;
                 margin-bottom:16px;">

                <div style="display:flex;align-items:center;gap:6px;">
                    <span class="material-symbols-outlined">bar_chart</span>
                    Doanh thu theo thời gian
                </div>

                <!-- SELECTORS -->
                <div style="display:flex;
                     gap:6px;
                     padding:4px;
                     border-radius:8px;
                     background:var(--surface-variant);
                     border:1px solid var(--outline-variant);">

                    <input type="hidden" name="type" id="revenueFilterType" value="${type}">

                    <!-- BUTTONS -->
                    <div style="display:flex;gap:2px;">

                        <button
                            type="button"
                            onclick="document.getElementById('revenueFilterType').value='MONTH'; this.form.submit();"
                            class="bk-btn bk-btn-sm filter-btn ${type=='MONTH'?'active':''}">
                            Tháng
                        </button>

                        <button
                            type="button"
                            onclick="document.getElementById('revenueFilterType').value='QUARTER'; this.form.submit();"
                            class="bk-btn bk-btn-sm filter-btn ${type=='QUARTER'?'active':''}">
                            Quý
                        </button>

                        <button
                            type="button"
                            onclick="document.getElementById('revenueFilterType').value='YEAR'; this.form.submit();"
                            class="bk-btn bk-btn-sm filter-btn ${type=='YEAR'?'active':''}">
                            Năm
                        </button>

                    </div>

                    <!-- MONTH -->
                    <c:if test="${type=='MONTH'}">

                        <select name="month"
                                class="bk-form-select"
                                onchange="this.form.submit()">

                            <c:forEach begin="1" end="12" var="m">
                                <option value="${m}" ${m==month?'selected':''}>
                                    Tháng ${m}
                                </option>
                            </c:forEach>

                        </select>

                        <select name="year"
                                class="bk-form-select"
                                onchange="this.form.submit()">

                            <c:forEach begin="2025" end="2035" var="y">
                                <option value="${y}" ${y==year?'selected':''}>
                                    ${y}
                                </option>
                            </c:forEach>

                        </select>

                    </c:if>

                    <!-- QUARTER -->
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
                                <option value="${y}" ${y==year?'selected':''}>
                                    ${y}
                                </option>
                            </c:forEach>

                        </select>

                    </c:if>

                    <!-- YEAR -->
                    <c:if test="${type=='YEAR'}">

                        <select name="year"
                                class="bk-form-select"
                                onchange="this.form.submit()">

                            <c:forEach begin="2025" end="2035" var="y">
                                <option value="${y}" ${y==year?'selected':''}>
                                    ${y}
                                </option>
                            </c:forEach>

                        </select>

                    </c:if>

                </div>

            </div>

            <!-- CHART -->
            <div style="margin-top:20px;">
                <!-- MAIN CHART BOX (PLOT AREA + Y-AXIS) -->
                <div style="display:flex; height:300px;">
                    <!-- Y AXIS -->
                    <div style="width:60px;
                         display:flex;
                         flex-direction:column;
                         justify-content:space-between;
                         align-items:flex-end;
                         padding-right:10px;
                         font-size:12px;
                         font-weight:600;
                         line-height:1;">

                        <span><fmt:formatNumber value="${chartMax/1000000}" maxFractionDigits="0"/>tr</span>
                        <span><fmt:formatNumber value="${step*4/1000000}" maxFractionDigits="0"/>tr</span>
                        <span><fmt:formatNumber value="${step*3/1000000}" maxFractionDigits="0"/>tr</span>
                        <span><fmt:formatNumber value="${step*2/1000000}" maxFractionDigits="0"/>tr</span>
                        <span><fmt:formatNumber value="${step/1000000}" maxFractionDigits="0"/>tr</span>
                        <span>0</span>

                    </div>

                    <!-- Chart Plot Area -->
                    <div style="flex:1;
                         position:relative;
                         display:flex;
                         justify-content:space-around;
                         align-items:flex-end;
                         border-left:1px solid var(--outline-variant);
                         border-bottom:2px solid var(--outline);
                         padding:0 20px;">

                        <div style="position:absolute;left:0;right:0;top:0;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                        <div style="position:absolute;left:0;right:0;top:20%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                        <div style="position:absolute;left:0;right:0;top:40%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                        <div style="position:absolute;left:0;right:0;top:60%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                        <div style="position:absolute;left:0;right:0;top:80%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>

                        <c:forEach items="${chartData}" var="c">
                            <div style="width:80px;
                                 height:100%;
                                 display:flex;
                                 flex-direction:column;
                                 justify-content:flex-end;
                                 align-items:center;
                                 position:relative;">

                                <span style="position:absolute; bottom:calc(${c.height}% + 6px); font-size:12px; font-weight:600; white-space:nowrap; color:var(--on-surface);">
                                    <fmt:formatNumber value="${c.revenue/1000000}" maxFractionDigits="0"/>tr
                                </span>

                                <div style="width:38px;
                                     height:${c.height}%;
                                     background:linear-gradient(180deg,var(--primary),var(--primary-container));
                                     border-radius:6px 6px 0 0;">
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- X AXIS LABELS -->
                <div style="display:flex; margin-left:60px; padding:8px 20px 0 20px;">
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

        <!-- ================= CENTER CARD: DOANH THU THEO PHAN KHUC ================= -->
        <div class="bk-card"
             style="padding:24px;
             display:flex;
             flex-direction:column;">

            <div class="bk-card-title">
                <span class="material-symbols-outlined">donut_large</span>
                Doanh thu theo hãng xe
            </div>

            <div class="pie-chart"
                 style="background:${segmentGradient};">
            </div>
            <c:if test="${segmentTotal == 0}">
                <p style="text-align:center;color:var(--secondary);font-size:13px;margin-top:40px;font-weight:600;">Chưa có dữ liệu hãng xe</p>
            </c:if>
            <c:forEach items="${segmentRevenue}" var="s" varStatus="loop">
                <c:if test="${s.value > 0}">
                    <c:set var="color" value="var(--secondary)"/>
                    <c:choose>
                        <c:when test="${loop.index % 6 == 0}"><c:set var="color" value="var(--primary)"/></c:when>
                        <c:when test="${loop.index % 6 == 1}"><c:set var="color" value="var(--success)"/></c:when>
                        <c:when test="${loop.index % 6 == 2}"><c:set var="color" value="var(--warning)"/></c:when>
                        <c:when test="${loop.index % 6 == 3}"><c:set var="color" value="var(--error)"/></c:when>
                        <c:when test="${loop.index % 6 == 4}"><c:set var="color" value="var(--info)"/></c:when>
                        <c:when test="${loop.index % 6 == 5}"><c:set var="color" value="var(--outline)"/></c:when>
                    </c:choose>

                    <div style="margin-bottom:14px;">
                        <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                            <span>${s.key}</span>
                            <span>
                                <fmt:formatNumber value="${s.value}" maxFractionDigits="0"/>đ
                                (<fmt:formatNumber value="${s.value * 100 / (segmentTotal == 0 ? 1 : segmentTotal)}" maxFractionDigits="1"/>%)
                            </span>
                        </div>

                        <div style="height:8px; background:var(--surface-container); border-radius:10px; overflow:hidden;">
                            <div style="height:100%; width:${s.value * 100 / (segmentTotal == 0 ? 1 : segmentTotal)}%; background:${color}; border-radius:10px;"></div>
                        </div>
                    </div>
                </c:if>
            </c:forEach>

        </div>

        <!-- ================= RIGHT CARD: CO CAU NGUON THU ================= -->
        <div class="bk-card"
             style="padding:24px;
             display:flex;
             flex-direction:column;
             justify-content:space-between;">

            <div>
                <div class="bk-card-title">
                    <span class="material-symbols-outlined">query_stats</span>
                    Cơ cấu nguồn thu
                </div>
                <p style="font-size:12px; color:var(--secondary); margin-top:4px; margin-bottom:20px;">Tỷ lệ đóng góp doanh thu thực tế.</p>
                
                <%-- Linear Stacked Progress Bar --%>
                <div style="height:20px; background:var(--surface-container); border-radius:10px; overflow:hidden; display:flex; margin-bottom:24px;">
                    <div style="width:${rentalRatio}%; background:var(--primary);" title="Thuê xe: ${rentalRatio}%"></div>
                    <div style="width:${depositRatio}%; background:var(--warning);" title="Đặt cọc: ${depositRatio}%"></div>
                    <div style="width:${additionalRatio}%; background:var(--error);" title="Phụ thu: ${additionalRatio}%"></div>
                </div>

                <div style="display:flex; flex-direction:column; gap:16px;">
                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:600; margin-bottom:4px;">
                            <span style="display:flex; align-items:center; gap:6px;">
                                <span style="width:10px; height:10px; border-radius:50%; background:var(--primary); display:inline-block;"></span>
                                Tiền thuê xe
                            </span>
                            <span>${rentalRatio}%</span>
                        </div>
                        <span style="font-size:11px; color:var(--secondary); padding-left:16px; display:block;">
                            <fmt:formatNumber value="${rentalRevenue}" type="number" maxFractionDigits="0"/>đ
                        </span>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:600; margin-bottom:4px;">
                            <span style="display:flex; align-items:center; gap:6px;">
                                <span style="width:10px; height:10px; border-radius:50%; background:var(--warning); display:inline-block;"></span>
                                Tiền cọc giữ lại
                            </span>
                            <span>${depositRatio}%</span>
                        </div>
                        <span style="font-size:11px; color:var(--secondary); padding-left:16px; display:block;">
                            <fmt:formatNumber value="${depositRevenue}" type="number" maxFractionDigits="0"/>đ
                        </span>
                    </div>

                    <div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; font-weight:600; margin-bottom:4px;">
                            <span style="display:flex; align-items:center; gap:6px;">
                                <span style="width:10px; height:10px; border-radius:50%; background:var(--error); display:inline-block;"></span>
                                Phụ thu phát sinh
                            </span>
                            <span>${additionalRatio}%</span>
                        </div>
                        <span style="font-size:11px; color:var(--secondary); padding-left:16px; display:block;">
                            <fmt:formatNumber value="${additionalRevenue}" type="number" maxFractionDigits="0"/>đ
                        </span>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <div class="bk-card" style="margin-top: 24px; padding: 24px;">
        <div class="bk-card-title" style="border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
            <span>Giao dịch gần đây</span>
            <button type="button" class="bk-btn bk-btn-sm" onclick="exportTableToCSV('giao_dich_gan_day.csv', 'transactions-table')" style="background: var(--primary); color: white; display: flex; align-items: center; gap: 4px; padding: 6px 12px; font-weight: 600; cursor: pointer;">
                <span class="material-symbols-outlined" style="font-size: 18px;">download</span> Xuất Excel
            </button>
        </div>
        <table class="bk-table" id="transactions-table">
            <thead>
                <tr style="background:#ffffff;">
                    <th>Mã GD</th>
                    <th>Ngày</th>
                    <th>Khách hàng</th>
                    <th>Xe</th>
                    <th>Loại thanh toán</th>
                    <th>Số tiền</th>
                    <th>Trạng thái</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${transactions}" var="t">
                    <tr>
                        <td>PAY-${t.payment.paymentId}</td>
                        <td>${t.payment.paidAt.dayOfMonth}/${t.payment.paidAt.monthValue}/${t.payment.paidAt.year}</td>
                        <td>${t.customerName}</td>
                        <td>${t.carName}</td>
                        <td>
                            <c:choose>
                                <c:when test="${t.payment.paymentMethod == 'CARD'}">Thẻ</c:when>
                                <c:when test="${t.payment.paymentMethod == 'BANK_TRANSFER'}">Ng.hàng</c:when>
                                <c:when test="${t.payment.paymentMethod == 'CASH'}">Tiền mặt</c:when>
                            </c:choose>
                        </td>
                        <td><fmt:formatNumber value="${t.payment.amount}" type="number" maxFractionDigits="0"/>đ</td>
                        <td>
                            <c:choose>
                                <c:when test="${t.payment.status == 'COMPLETED'}">
                                    <span class="bk-badge bk-badge-confirmed"style="background:var(--success-container); color:var(--on-success-container);">HOÀN THÀNH</span>
                                </c:when>
                                <c:when test="${t.payment.status == 'FAILED'}">
                                    <span class="bk-badge bk-badge-confirmed"style="background:var(--error-container); color:var(--on-error-container);">KHÔNG THÀNH CÔNG</span>
                                </c:when>
                                <c:when test="${t.payment.status == 'REFUNDED'}">
                                    <span class="bk-badge bk-badge-confirmed"style="background:var(--warning-container); color:var(--on-warning-container);">HOÀN TIỀN</span>
                                </c:when>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
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
    paginateTable('transactions-table', 5);
});
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
