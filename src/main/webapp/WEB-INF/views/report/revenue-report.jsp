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
    <div class="bk-stats-grid" style="display:grid;grid-template-columns:repeat(5,1fr);gap:20px;">
        <div class="bk-stat-card">
            <span class="label">Tổng Doanh thu</span>
            <span class="value" style="color:var(--primary);">
                <fmt:formatNumber value="${totalRevenue}" type="number" maxFractionDigits="0"/>đ
            </span>
            <span style="font-size:12px;color:${revenueGrowth > 0 ? 'var(--success)' : revenueGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
                <c:choose>
                    <c:when test="${revenueGrowth > 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--success);">trending_up</span>+${String.format("%.2f", revenueGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:when test="${revenueGrowth < 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--error);">trending_down</span>${String.format("%.2f", revenueGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:otherwise>
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--warning);">trending_flat</span>0% so với ${compareLabel}
                    </c:otherwise>
                </c:choose>
            </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Doanh thu Thuê xe</span>
            <span class="value">
                <fmt:formatNumber value="${rentalRevenue}" type="number" maxFractionDigits="0"/>đ
            </span>
            <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
                Tỷ trọng: ${rentalRatio}% tổng thu
            </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Tiền cọc đang giữ</span>
            <span class="value" style="color:var(--warning);">
                <fmt:formatNumber value="${depositRevenue}" type="number" maxFractionDigits="0"/>đ
            </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Phụ thu phát sinh</span>
            <span class="value" style="color:var(--error);">
                <fmt:formatNumber value="${additionalRevenue}" type="number" maxFractionDigits="0"/>đ
            </span>
            <span style="font-size:12px;color:${additionalFeeGrowth > 0 ? 'var(--success)' : additionalFeeGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
                <c:choose>
                    <c:when test="${additionalFeeGrowth > 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--success);">trending_up</span>+${String.format("%.2f", additionalFeeGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:when test="${additionalFeeGrowth < 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--error);">trending_down</span>${String.format("%.2f", additionalFeeGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:otherwise>
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--warning);">trending_flat</span>0% so với ${compareLabel}
                    </c:otherwise>
                </c:choose>
            </span>
        </div>

        <div class="bk-stat-card">
            <span class="label">Đơn thuê hoàn tất</span>
            <span class="value" style="color:var(--info);">${completedBooking}</span>
            <span style="font-size:12px;color:${bookingGrowth > 0 ? 'var(--success)' : bookingGrowth < 0 ? 'var(--error)' : 'var(--on-surface-variant)'};margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
                <c:choose>
                    <c:when test="${bookingGrowth > 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--success);">trending_up</span>+${String.format("%.2f", bookingGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:when test="${bookingGrowth < 0}">
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--error);">trending_down</span>${String.format("%.2f", bookingGrowth)}% so với ${compareLabel}
                    </c:when>

                    <c:otherwise>
                        <span class="material-symbols-outlined" style="font-size:16px;color:var(--warning);">trending_flat</span>0% so với ${compareLabel}
                    </c:otherwise>
                </c:choose>
            </span>
        </div>
    </div>

    <%-- GRAPH & BREAKDOWN GRID --%>
    <div class="bk-detail-grid"
         style="display:grid;
         grid-template-columns:2fr 1fr;
         gap:24px;
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
                 align-items:center;">

                <div style="display:flex;align-items:center;gap:8px;">
                    <span class="material-symbols-outlined">bar_chart</span>
                    <span>Doanh thu theo thời gian</span>
                </div>

                <div style="display:flex;align-items:center;gap:12px;">

                    <!-- Filter -->
                    <div style="display:flex;
                         gap:6px;
                         padding:4px;
                         border-radius:8px;
                         background:var(--surface-variant);
                         border:1px solid var(--outline-variant);">

                        <button type="submit"
                                name="type"
                                value="MONTH"
                                class="bk-btn bk-btn-sm filter-btn ${type=='MONTH'?'active':''}">
                            Tháng
                        </button>

                        <button type="submit"
                                name="type"
                                value="QUARTER"
                                class="bk-btn bk-btn-sm filter-btn ${type=='QUARTER'?'active':''}">
                            Quý
                        </button>

                        <button type="submit"
                                name="type"
                                value="YEAR"
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
            <div style="display:flex;margin-top:20px;height:360px;">

                <!-- Y AXIS -->
                <div style="width:60px;
                     display:flex;
                     flex-direction:column;
                     justify-content:space-between;
                     align-items:flex-end;
                     padding-right:10px;
                     font-size:12px;
                     font-weight:600;">

                    <span><fmt:formatNumber value="${chartMax/1000000}" maxFractionDigits="0"/>tr</span>
                    <span><fmt:formatNumber value="${step*4/1000000}" maxFractionDigits="0"/>tr</span>
                    <span><fmt:formatNumber value="${step*3/1000000}" maxFractionDigits="0"/>tr</span>
                    <span><fmt:formatNumber value="${step*2/1000000}" maxFractionDigits="0"/>tr</span>
                    <span><fmt:formatNumber value="${step/1000000}" maxFractionDigits="0"/>tr</span>
                    <span>0</span>

                </div>

                <!-- Chart Area -->
                <div style="flex:1;
                     position:relative;
                     display:flex;
                     justify-content:space-around;
                     align-items:flex-end;
                     border-left:1px solid var(--outline-variant);
                     border-bottom:1px solid var(--outline-variant);
                     padding:0 20px;">

                    <div style="position:absolute;left:0;right:0;top:0;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                    <div style="position:absolute;left:0;right:0;top:20%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                    <div style="position:absolute;left:0;right:0;top:40%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                    <div style="position:absolute;left:0;right:0;top:60%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>
                    <div style="position:absolute;left:0;right:0;top:80%;border-top:1px dashed var(--outline-variant);opacity:.35;"></div>

                    <c:forEach items="${chartData}" var="c">

                        <div style="width:60px;
                             height:100%;
                             display:flex;
                             flex-direction:column;
                             justify-content:flex-end;
                             align-items:center;">

                            <span style="margin-bottom:6px;font-size:12px;font-weight:600;">
                                <fmt:formatNumber value="${c.revenue/1000000}" maxFractionDigits="0"/>tr
                            </span>

                            <div style="width:38px;
                                 height:${c.height}%;
                                 background:linear-gradient(180deg,var(--primary),var(--primary-container));
                                 border-radius:8px 8px 0 0;">
                            </div>

                            <span style="margin-top:10px;font-weight:600;">
                                ${c.label}
                            </span>

                        </div>

                    </c:forEach>

                </div>

            </div>

        </div>

        <!-- ================= RIGHT CARD ================= -->
        <div class="bk-card"
             style="padding:24px;
             display:flex;
             flex-direction:column;">

            <div class="bk-card-title">
                <span class="material-symbols-outlined">donut_large</span>
                Doanh thu theo phân khúc xe
            </div>

            <div class="pie-chart"
                 style="background:${segmentGradient};">
            </div>
            <c:forEach items="${segmentRevenue}" var="s">
                <c:choose>
                    <c:when test="${s.key == 'Sedan'}">
                        <c:set var="color" value="var(--primary)"/>
                    </c:when>

                    <c:when test="${s.key == 'SUV / Crossover'}">
                        <c:set var="color" value="var(--success)"/>
                    </c:when>

                    <c:when test="${s.key == 'MPV gia đình'}">
                        <c:set var="color" value="var(--warning)"/>
                    </c:when>

                    <c:when test="${s.key == 'Xe bán tải / Pickup'}">
                        <c:set var="color" value="var(--error)"/>
                    </c:when>

                    <c:otherwise>
                        <c:set var="color" value="var(--secondary)"/>
                    </c:otherwise>
                </c:choose>

                <div style="margin-bottom:14px;">
                    <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                        <span>${s.key}</span>
                        <span>
                            <fmt:formatNumber value="${s.value}" maxFractionDigits="0"/>đ
                            (<fmt:formatNumber value="${s.value * 100 / segmentTotal}" maxFractionDigits="1"/>%)
                        </span>
                    </div>

                    <div style="height:8px; background:var(--surface-container); border-radius:10px; overflow:hidden;">
                        <div style="height:100%; width:${s.value * 100 / segmentTotal}%; background:${color}; border-radius:10px;"></div>
                    </div>
                </div>
            </c:forEach>

        </div>

    </div>

    <div class="bk-card" style="margin-top: 24px; padding: 24px;">
        <div class="bk-card-title" style="border-bottom: 1px solid var(--outline-variant); padding-bottom: 12px; margin-bottom: 16px;">
            <span>Giao dịch gần đây</span>
        </div>
        <table class="bk-table" >
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
<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
