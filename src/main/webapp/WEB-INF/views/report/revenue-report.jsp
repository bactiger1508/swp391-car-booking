<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Báo cáo Doanh thu"/>
</jsp:include>

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

<%-- STATS GRID --%>
<div class="bk-stats-grid">
    <div class="bk-stat-card">
        <span class="label">Tổng Doanh thu</span>
        <span class="value" style="color:var(--primary);">350,850,000đ</span>
        <span style="font-size:12px;color:var(--success);margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
            <span class="material-symbols-outlined" style="font-size:16px;">trending_up</span> +14.5% so với tháng trước
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Doanh thu Thuê xe</span>
        <span class="value">280,500,000đ</span>
        <span style="font-size:12px;color:var(--secondary);margin-top:6px;font-weight:600;">
            Tỷ trọng: 80% tổng thu
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Phụ thu phát sinh</span>
        <span class="value" style="color:var(--error);">70,350,000đ</span>
        <span style="font-size:12px;color:var(--success);margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
            <span class="material-symbols-outlined" style="font-size:16px;">trending_up</span> +8.2% quá cước, phạt trễ
        </span>
    </div>

    <div class="bk-stat-card">
        <span class="label">Đơn thuê hoàn tất</span>
        <span class="value" style="color:var(--info);">112 đơn</span>
        <span style="font-size:12px;color:var(--success);margin-top:6px;font-weight:600;display:flex;align-items:center;gap:4px;">
            <span class="material-symbols-outlined" style="font-size:16px;">task_alt</span> Tỷ lệ lấp đầy xe: 85%
        </span>
    </div>
</div>

<%-- GRAPH & BREAKDOWN GRID --%>
<div class="bk-detail-grid" style="margin-top:24px;">
    <%-- LEFT: Biểu đồ doanh thu SVG --%>
    <div>
        <div class="bk-card" style="padding:24px;">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">bar_chart</span> Phân tích Doanh thu 6 tháng đầu năm
            </div>
            
            <div style="height:240px;margin-top:32px;display:flex;align-items:flex-end;justify-content:space-between;border-bottom:2px solid var(--outline-variant);padding-bottom:12px;position:relative;">
                <!-- Trục Y Guide Lines -->
                <div style="position:absolute;left:0;right:0;top:0;border-top:1px dashed var(--outline-variant);opacity:0.3;"></div>
                <div style="position:absolute;left:0;right:0;top:80px;border-top:1px dashed var(--outline-variant);opacity:0.3;"></div>
                <div style="position:absolute;left:0;right:0;top:160px;border-top:1px dashed var(--outline-variant);opacity:0.3;"></div>

                <!-- Cột 1 -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:var(--secondary);width:100%;height:45%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T1: 45M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:700;color:var(--secondary);">45tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:600;color:var(--on-surface-variant);">T1</span>
                </div>
                <!-- Cột 2 -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:var(--secondary);width:100%;height:55%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T2: 55M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:700;color:var(--secondary);">55tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:600;color:var(--on-surface-variant);">T2</span>
                </div>
                <!-- Cột 3 -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:var(--secondary);width:100%;height:68%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T3: 68M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:700;color:var(--secondary);">68tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:600;color:var(--on-surface-variant);">T3</span>
                </div>
                <!-- Cột 4 -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:var(--secondary);width:100%;height:80%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T4: 80M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:700;color:var(--secondary);">80tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:600;color:var(--on-surface-variant);">T4</span>
                </div>
                <!-- Cột 5 -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:var(--secondary);width:100%;height:75%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T5: 75M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:700;color:var(--secondary);">75tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:600;color:var(--on-surface-variant);">T5</span>
                </div>
                <!-- Cột 6 (Tháng hiện tại - Nổi bật) -->
                <div style="display:flex;flex-direction:column;align-items:center;width:12%;height:100%;justify-content:flex-end;z-index:2;">
                    <div style="background:linear-gradient(to top, var(--primary), var(--info));width:100%;height:92%;border-top-left-radius:6px;border-top-right-radius:6px;position:relative;" title="T6: 92M">
                        <div style="position:absolute;top:-20px;left:50%;transform:translateX(-50%);font-size:11px;font-weight:800;color:var(--primary);">92tr</div>
                    </div>
                    <span style="font-size:12px;margin-top:8px;font-weight:800;color:var(--primary);">T6 (Hiện tại)</span>
                </div>
            </div>
        </div>
    </div>

    <%-- RIGHT: Cơ cấu doanh thu theo phân khúc xe --%>
    <div>
        <div class="bk-card" style="padding:24px;">
            <div class="bk-card-title">
                <span class="material-symbols-outlined">donut_large</span> Doanh thu theo phân khúc
            </div>
            
            <div class="bk-detail-rows" style="margin-top:24px;gap:20px;">
                <div>
                    <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                        <span>Sedan phổ thông (5 chỗ)</span>
                        <span>175tr (50%)</span>
                    </div>
                    <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                        <div style="background:var(--primary);height:100%;width:50%;"></div>
                    </div>
                </div>

                <div>
                    <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                        <span>SUV / Crossover (7 chỗ)</span>
                        <span>105tr (30%)</span>
                    </div>
                    <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                        <div style="background:var(--info);height:100%;width:30%;"></div>
                    </div>
                </div>

                <div>
                    <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                        <span>Xe bán tải / Pickup</span>
                        <span>35tr (10%)</span>
                    </div>
                    <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                        <div style="background:var(--secondary);height:100%;width:10%;"></div>
                    </div>
                </div>

                <div>
                    <div style="display:flex;justify-content:space-between;font-size:13px;font-weight:600;margin-bottom:6px;">
                        <span>Xe điện (VinFast VF5/VF8)</span>
                        <span>35tr (10%)</span>
                    </div>
                    <div style="background:var(--surface-container);height:8px;border-radius:4px;overflow:hidden;">
                        <div style="background:var(--success);height:100%;width:10%;"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
