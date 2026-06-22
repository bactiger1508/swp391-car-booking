<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Trang chủ - Hệ thống quản lý thuê xe"/>
</jsp:include>

<!-- Load Tailwind CSS specifically for the home page -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
    tailwind.config = {
        darkMode: "class",
        theme: {
            extend: {
                colors: {
                    primary: "#041638",
                    "primary-container": "#1b2b4e",
                    "on-primary": "#ffffff",
                    "on-primary-container": "#8393bc",
                    "on-primary-fixed-variant": "#37466b",
                    secondary: "#505f76",
                    "secondary-container": "#d0e1fb",
                    "on-secondary-container": "#54647a",
                    surface: "#fbf8fc",
                    "surface-container-low": "#f5f3f6",
                    "surface-container-lowest": "#ffffff",
                    "on-surface": "#1b1b1e",
                    "on-surface-variant": "#45464e",
                    outline: "#75777f",
                    "outline-variant": "#c5c6cf",
                    error: "#ba1a1a",
                    "error-container": "#ffdad6",
                    "on-error-container": "#93000a",
                    background: "#fbf8fc"
                },
                borderRadius: {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "2xl": "1rem",
                    "full": "9999px"
                }
            }
        }
    }
</script>

<style>
    /* Prevent Tailwind from overriding the main layout container bounds */
    .bk-layout * {
        box-sizing: border-box;
    }
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
    .material-symbols-outlined[data-weight="fill"] {
        font-variation-settings: 'FILL' 1;
    }
    /* Hover micro-animations */
    .car-card-hover {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .car-card-hover:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 24px rgba(4, 22, 56, 0.08);
    }
</style>

<!-- Main Dashboard Container -->
<div class="w-full flex flex-col">
    <!-- Hero Banner (Bento style header) -->
    <div class="relative w-full rounded-2xl bg-gradient-to-br from-primary to-primary-container text-on-primary p-8 md:p-10 shadow-md overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8 mb-8">
        <div class="absolute inset-0 opacity-10" style="background-image: radial-gradient(circle at 2px 2px, white 1px, transparent 0); background-size: 24px 24px;"></div>
        <div class="relative z-10 max-w-2xl">
            <h2 class="text-3xl md:text-4xl font-extrabold mb-4 tracking-tight">Hệ thống quản lý thuê xe tự lái</h2>
            <p class="text-base text-[#8393bc] mb-8 max-w-xl">
                Khám phá các dòng xe đa dạng, theo dõi đơn thuê và quản lý hợp đồng một cách dễ dàng, tiện lợi và minh bạch.
            </p>
            <div class="flex flex-wrap items-center gap-4">
                <a href="${pageContext.request.contextPath}/vehicles" class="bg-white text-primary px-6 py-3 rounded-xl font-semibold shadow-sm hover:shadow-md hover:bg-slate-100 transition-all flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">directions_car</span>
                    Xem danh sách xe
                </a>
                <c:if test="${sessionScope.currentUser != null && sessionScope.currentUser.role == 'CUSTOMER'}">
                    <a href="${pageContext.request.contextPath}/bookings/create" class="bg-transparent border border-white/30 text-white px-6 py-3 rounded-xl font-semibold hover:bg-white/10 transition-all flex items-center gap-2">
                        <span class="material-symbols-outlined text-[20px]">add_circle</span>
                        Đặt xe ngay
                    </a>
                </c:if>
            </div>
        </div>
        <div class="hidden lg:flex relative z-10 w-48 h-48 items-center justify-center">
            <div class="absolute inset-0 bg-[#8393bc]/10 rounded-full blur-3xl"></div>
            <span class="material-symbols-outlined text-[120px] text-[#8393bc] opacity-90 drop-shadow-lg" data-weight="fill">car_rental</span>
        </div>
    </div>
    <!-- Quick Statistics Grid (Only visible to STAFF or ADMIN roles) -->
    <c:if test="${sessionScope.currentUser != null && (sessionScope.currentUser.role == 'STAFF' || sessionScope.currentUser.role == 'ADMIN')}">
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <!-- Stat Card 1 -->
            <div class="bg-white rounded-xl p-5 shadow-sm border border-outline-variant/40 flex flex-col justify-between group hover:shadow-md transition-shadow relative overflow-hidden">
                <div class="absolute -right-4 -top-4 w-24 h-24 bg-primary/5 rounded-full blur-xl"></div>
                <div>
                    <div class="flex items-center justify-between mb-4 relative z-10">
                        <div class="w-10 h-10 rounded-lg bg-slate-100 flex items-center justify-center text-primary">
                            <span class="material-symbols-outlined" data-weight="fill">directions_car</span>
                        </div>
                        <span class="text-xs font-semibold text-outline uppercase tracking-wider">Sẵn sàng</span>
                    </div>
                    <div class="text-3xl font-bold text-on-surface mb-1 relative z-10">${stats.availableCars}</div>
                    <p class="text-sm text-on-surface-variant relative z-10">Xe sẵn sàng cho thuê</p>
                </div>
                <div class="mt-4 pt-4 border-t border-outline-variant/30 flex justify-end relative z-10">
                    <a class="text-sm font-semibold text-primary hover:text-primary-container flex items-center gap-1" href="${pageContext.request.contextPath}/vehicles">
                        Xem chi tiết <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                    </a>
                </div>
            </div>
            
            <!-- Stat Card 2 -->
            <div class="bg-white rounded-xl p-5 shadow-sm border border-outline-variant/40 flex flex-col justify-between group hover:shadow-md transition-shadow relative overflow-hidden">
                <div class="absolute -right-4 -top-4 w-24 h-24 bg-amber-500/5 rounded-full blur-xl"></div>
                <div>
                    <div class="flex items-center justify-between mb-4 relative z-10">
                        <div class="w-10 h-10 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600">
                            <span class="material-symbols-outlined" data-weight="fill">event</span>
                        </div>
                        <span class="text-xs font-semibold text-outline uppercase tracking-wider">Chờ xử lý</span>
                    </div>
                    <div class="text-3xl font-bold text-on-surface mb-1 relative z-10">${stats.pendingBookings}</div>
                    <p class="text-sm text-on-surface-variant relative z-10">Đơn thuê chờ duyệt</p>
                </div>
                <div class="mt-4 pt-4 border-t border-outline-variant/30 flex justify-end relative z-10">
                    <a class="text-sm font-semibold text-amber-600 hover:text-amber-800 flex items-center gap-1" href="${pageContext.request.contextPath}/bookings/approval">
                        Duyệt đơn <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                    </a>
                </div>
            </div>

            <!-- Stat Card 3 -->
            <div class="bg-white rounded-xl p-5 shadow-sm border border-outline-variant/40 flex flex-col justify-between group hover:shadow-md transition-shadow relative overflow-hidden">
                <div class="absolute -right-4 -top-4 w-24 h-24 bg-emerald-500/5 rounded-full blur-xl"></div>
                <div>
                    <div class="flex items-center justify-between mb-4 relative z-10">
                        <div class="w-10 h-10 rounded-lg bg-emerald-50 flex items-center justify-center text-emerald-600">
                            <span class="material-symbols-outlined" data-weight="fill">key</span>
                        </div>
                        <span class="text-xs font-semibold text-outline uppercase tracking-wider">Đang thuê</span>
                    </div>
                    <div class="text-3xl font-bold text-on-surface mb-1 relative z-10">${stats.activeBookings}</div>
                    <p class="text-sm text-on-surface-variant relative z-10">Các xe đang di chuyển</p>
                </div>
                <div class="mt-4 pt-4 border-t border-outline-variant/30 flex justify-end relative z-10">
                    <a class="text-sm font-semibold text-emerald-600 hover:text-emerald-800 flex items-center gap-1" href="${pageContext.request.contextPath}/bookings/manage">
                        Quản lý <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                    </a>
                </div>
            </div>

            <!-- Stat Card 4 -->
            <div class="bg-white rounded-xl p-5 shadow-sm border border-outline-variant/40 flex flex-col justify-between group hover:shadow-md transition-shadow relative overflow-hidden">
                <div class="absolute -right-4 -top-4 w-24 h-24 bg-blue-500/5 rounded-full blur-xl"></div>
                <div>
                    <div class="flex items-center justify-between mb-4 relative z-10">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600">
                            <span class="material-symbols-outlined" data-weight="fill">payments</span>
                        </div>
                        <span class="text-xs font-semibold text-outline uppercase tracking-wider">Doanh thu</span>
                    </div>
                    <div class="text-3xl font-bold text-on-surface mb-1 relative z-10">
                        <fmt:formatNumber value="${stats.monthlyRevenue}" type="number" groupingUsed="true"/>đ
                    </div>
                    <p class="text-sm text-on-surface-variant relative z-10">Tổng doanh thu nhận (đ)</p>
                </div>
                <div class="mt-4 pt-4 border-t border-outline-variant/30 flex justify-end relative z-10">
                    <a class="text-sm font-semibold text-blue-600 hover:text-blue-800 flex items-center gap-1" href="${pageContext.request.contextPath}/reports/revenue">
                        Báo cáo <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                    </a>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Main Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8">
        <!-- Left Bento Column (Quick Search & Rental Process) -->
        <div class="lg:col-span-4 flex flex-col gap-8">
            <!-- Quick Availability Search Card -->
            <div class="bg-white rounded-2xl shadow-sm border border-outline-variant/40 p-6">
                <div class="flex items-center gap-3 mb-6 pb-4 border-b border-outline-variant/30">
                    <span class="material-symbols-outlined text-primary" data-weight="fill">search_check</span>
                    <h3 class="text-lg font-bold text-on-surface">Tìm kiếm nhanh</h3>
                </div>
                <form action="${pageContext.request.contextPath}/vehicles" method="GET" class="flex flex-col gap-4">
                    <div class="flex flex-col gap-1">
                        <label class="text-xs font-bold text-on-surface-variant uppercase tracking-wide">Hãng xe</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[20px]">directions_car</span>
                            <select name="brand" class="w-full pl-10 pr-8 py-2 border border-outline-variant rounded-lg text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none appearance-none text-on-surface bg-white">
                                <option value="">Tất cả các hãng</option>
                                <option value="Toyota">Toyota</option>
                                <option value="Honda">Honda</option>
                                <option value="Hyundai">Hyundai</option>
                                <option value="Ford">Ford</option>
                                <option value="VinFast">VinFast</option>
                            </select>
                            <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-outline pointer-events-none text-[20px]">expand_more</span>
                        </div>
                    </div>
                    <div class="flex flex-col gap-1">
                        <label class="text-xs font-bold text-on-surface-variant uppercase tracking-wide">Số chỗ ngồi</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[20px]">airline_seat_recline_normal</span>
                            <select name="seats" class="w-full pl-10 pr-8 py-2 border border-outline-variant rounded-lg text-sm focus:border-primary focus:ring-1 focus:ring-primary outline-none appearance-none text-on-surface bg-white">
                                <option value="">Tất cả</option>
                                <option value="4">4 Chỗ</option>
                                <option value="5">5 Chỗ</option>
                                <option value="7">7 Chỗ</option>
                                <option value="9">9 Chỗ</option>
                            </select>
                            <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-outline pointer-events-none text-[20px]">expand_more</span>
                        </div>
                    </div>
                    <div class="flex gap-3 mt-4 pt-4 border-t border-outline-variant/30">
                        <button class="flex-1 bg-white border border-outline-variant text-on-surface-variant py-2.5 rounded-lg text-sm font-semibold hover:bg-slate-50 transition-colors" type="reset">
                            Đặt lại
                        </button>
                        <button class="flex-[2] bg-primary text-white py-2.5 rounded-lg text-sm font-semibold shadow-sm hover:bg-primary-container transition-colors flex items-center justify-center gap-2" type="submit">
                            <span class="material-symbols-outlined text-[18px]">search</span> Tìm kiếm
                        </button>
                    </div>
                </form>
                
                <div class="mt-4 pt-4 border-t border-outline-variant/30">
                    <a href="${pageContext.request.contextPath}/vehicles/availability" class="w-full bg-white border border-primary text-primary py-2.5 rounded-lg text-sm font-semibold hover:bg-primary/5 transition-colors flex items-center justify-center gap-2 shadow-sm">
                        <span class="material-symbols-outlined text-[20px]">calendar_today</span> Kiểm tra xe trống
                    </a>
                </div>
            </div>
            
            <!-- Rental Process Timeline -->
            <div class="bg-white rounded-2xl shadow-sm border border-outline-variant/40 p-6">
                <h3 class="text-lg font-bold text-on-surface mb-6">Quy trình đặt xe</h3>
                <div class="relative flex flex-col gap-0">
                    <!-- Vertical Line Track -->
                    <div class="absolute left-[19px] top-4 bottom-4 w-px bg-outline-variant/40"></div>
                    <!-- Step 1 -->
                    <div class="flex items-start gap-4 relative py-3">
                        <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center z-10 border-4 border-white shrink-0">
                            <span class="material-symbols-outlined text-[18px] text-primary" data-weight="fill">list_alt</span>
                        </div>
                        <div class="flex flex-col pt-2">
                            <span class="text-xs font-bold text-primary tracking-wider uppercase">Bước 1</span>
                            <span class="text-sm font-semibold text-on-surface">Tìm xe &amp; Chọn cấu hình</span>
                        </div>
                    </div>
                    <!-- Step 2 -->
                    <div class="flex items-start gap-4 relative py-3">
                        <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center z-10 border-4 border-white shrink-0">
                            <span class="material-symbols-outlined text-[18px] text-[#75777f]">edit_document</span>
                        </div>
                        <div class="flex flex-col pt-2">
                            <span class="text-xs font-bold text-outline tracking-wider uppercase">Bước 2</span>
                            <span class="text-sm font-semibold text-on-surface-variant">Tạo đơn đặt &amp; Chờ duyệt</span>
                        </div>
                    </div>
                    <!-- Step 3 -->
                    <div class="flex items-start gap-4 relative py-3">
                        <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center z-10 border-4 border-white shrink-0">
                            <span class="material-symbols-outlined text-[18px] text-[#75777f]">contract</span>
                        </div>
                        <div class="flex flex-col pt-2">
                            <span class="text-xs font-bold text-outline tracking-wider uppercase">Bước 3</span>
                            <span class="text-sm font-semibold text-on-surface-variant">Ký hợp đồng &amp; Đặt cọc</span>
                        </div>
                    </div>
                    <!-- Step 4 -->
                    <div class="flex items-start gap-4 relative py-3">
                        <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center z-10 border-4 border-white shrink-0">
                            <span class="material-symbols-outlined text-[18px] text-[#75777f]">car_tag</span>
                        </div>
                        <div class="flex flex-col pt-2">
                            <span class="text-xs font-bold text-outline tracking-wider uppercase">Bước 4</span>
                            <span class="text-sm font-semibold text-on-surface-variant">Bàn giao &amp; Trải nghiệm</span>
                        </div>
                    </div>
                    <!-- Step 5 -->
                    <div class="flex items-start gap-4 relative py-3">
                        <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center z-10 border-4 border-white shrink-0">
                            <span class="material-symbols-outlined text-[18px] text-[#75777f]">done_all</span>
                        </div>
                        <div class="flex flex-col pt-2">
                            <span class="text-xs font-bold text-outline tracking-wider uppercase">Bước 5</span>
                            <span class="text-sm font-semibold text-on-surface-variant">Trả xe &amp; Thanh lý</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column (Featured Vehicles) -->
        <div class="lg:col-span-8 flex flex-col gap-6">
            <div class="flex items-center justify-between">
                <h3 class="text-2xl font-bold text-on-surface">Xe nổi bật</h3>
                <a href="${pageContext.request.contextPath}/vehicles" class="text-primary text-sm font-semibold hover:underline flex items-center gap-1">
                    Xem tất cả xe
                    <span class="material-symbols-outlined text-[16px]">chevron_right</span>
                </a>
            </div>
            
            <div class="flex flex-col gap-4">
                <c:if test="${not empty featuredCars}">
                    <c:forEach var="car" items="${featuredCars}">
                        <!-- Vehicle Bento Card -->
                        <div class="bg-white rounded-xl p-5 shadow-sm border border-outline-variant/40 flex flex-col sm:flex-row gap-6 items-center hover:shadow-md car-card-hover duration-300">
                            <!-- Image Section -->
                            <div class="w-full sm:w-48 h-32 bg-slate-100 rounded-lg overflow-hidden shrink-0 relative flex items-center justify-center">
                                <c:set var="thumb" value="${primaryImages[car.carId]}"/>
                                <img src="${pageContext.request.contextPath}${thumb}"
                                     alt="${car.brand} ${car.model}"
                                     class="w-full h-full object-cover"
                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/cars/placeholder.jpg'"/>
                                <div class="absolute top-2 left-2 bg-primary/80 text-white px-2 py-0.5 rounded text-[10px] font-bold">
                                    ${car.licensePlate}
                                </div>
                            </div>
                            
                            <!-- Information Section -->
                            <div class="flex-1 flex flex-col w-full">
                                <div class="flex justify-between items-start mb-2">
                                    <div>
                                        <h4 class="text-lg font-bold text-on-surface">${car.brand} ${car.model}</h4>
                                        <p class="text-xs text-on-surface-variant flex items-center gap-2 mt-1">
                                            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">group</span> ${car.seats} Chỗ</span> • 
                                            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">settings</span>
                                                <c:choose>
                                                    <c:when test="${car.transmission == 'AUTOMATIC'}">Tự động</c:when>
                                                    <c:when test="${car.transmission == 'MANUAL'}">Số sàn</c:when>
                                                    <c:otherwise>${car.transmission}</c:otherwise>
                                                </c:choose>
                                            </span> • 
                                            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">local_gas_station</span>
                                                <c:choose>
                                                    <c:when test="${car.fuelType == 'GASOLINE'}">Xăng</c:when>
                                                    <c:when test="${car.fuelType == 'DIESEL'}">Dầu Diesel</c:when>
                                                    <c:when test="${car.fuelType == 'ELECTRIC'}">Điện</c:when>
                                                    <c:when test="${car.fuelType == 'HYBRID'}">Hybrid</c:when>
                                                    <c:otherwise>${car.fuelType}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </p>
                                    </div>
                                    <div class="px-2.5 py-1 bg-[#10B981]/10 text-[#059669] rounded text-[11px] font-bold uppercase tracking-wide border border-[#10B981]/20">
                                        Sẵn sàng
                                    </div>
                                </div>
                                
                                <!-- Pricing and Action Buttons -->
                                <div class="flex items-end justify-between mt-auto pt-4 border-t border-outline-variant/30">
                                    <div>
                                        <div class="text-[11px] text-on-surface-variant uppercase tracking-wider font-bold">Giá thuê 1 ngày</div>
                                        <div class="text-lg font-extrabold text-primary mt-0.5">
                                            <fmt:formatNumber value="${car.dailyRate}" type="number" groupingUsed="true"/>đ
                                        </div>
                                    </div>
                                    <div class="flex gap-2">
                                        <a href="${pageContext.request.contextPath}/vehicles/detail?id=${car.carId}" class="px-4 py-2 border border-outline-variant rounded-lg text-on-surface-variant text-xs font-semibold hover:bg-slate-50 transition-colors flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[16px]">visibility</span> Chi tiết
                                        </a>
                                        <a href="${pageContext.request.contextPath}/bookings/create?carId=${car.carId}" class="px-4 py-2 bg-primary text-white rounded-lg text-xs font-semibold hover:bg-primary-container transition-colors shadow-sm flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[16px]">key</span> Đặt xe
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
                <c:if test="${empty featuredCars}">
                    <div class="flex flex-col items-center justify-center py-16 bg-white border border-dashed border-outline-variant/60 rounded-2xl">
                        <span class="material-symbols-outlined text-[48px] text-outline opacity-40">search_off</span>
                        <h3 class="text-base font-bold text-on-surface mt-4">Không có xe trống</h3>
                        <p class="text-sm text-on-surface-variant">Hiện tại tất cả xe đều đang được thuê hoặc đang bảo dưỡng.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
