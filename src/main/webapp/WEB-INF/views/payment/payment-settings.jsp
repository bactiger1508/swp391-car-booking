<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/layout/header.jsp">
    <jsp:param name="pageTitle" value="Cấu Hình Quy Tắc & Phương Thức Thanh Toán"/>
</jsp:include>

<!-- Load Tailwind CSS specifically for this dashboard content -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
    tailwind.config = {
        darkMode: "class",
        theme: {
            extend: {
                colors: {
                    primary: "#005FB8",
                    "on-primary": "#FFFFFF",
                    "primary-container": "#D1E4FF",
                    "on-primary-container": "#001D36",
                    secondary: "#535F70",
                    "on-secondary": "#FFFFFF",
                    "secondary-container": "#D7E3F7",
                    "on-secondary-container": "#101C2B",
                    surface: "#F8F9FF",
                    "on-surface": "#191C20",
                    "surface-container-low": "#F1F3F9",
                    "surface-container-high": "#EBEFF4",
                    "surface-container-highest": "#E2E2E6",
                    "outline": "#72777F",
                    "outline-variant": "#C2C7CF",
                    "secondary-fixed-dim": "#B9C7DA",
                    "on-primary-fixed-variant": "#2A4765"
                },
                borderRadius: {
                    "DEFAULT": "0.25rem",
                    "lg": "0.5rem",
                    "xl": "0.75rem",
                    "full": "9999px"
                },
                fontFamily: {
                    "headline": ["Public Sans"],
                    "display": ["Public Sans"],
                    "body": ["Public Sans"],
                    "label": ["Public Sans"]
                }
            }
        }
    }
</script>

<style>
    body { font-family: 'Public Sans', sans-serif; }
    .glass-card {
        background: rgba(255, 255, 255, 0.7);
        backdrop-filter: blur(12px);
        border: 1px solid rgba(226, 226, 230, 0.5);
    }
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
</style>

<!-- Main Workspace Content inside parent .bk-main -->
<div class="px-8 py-6 max-w-[1400px] mx-auto bg-surface min-h-screen text-on-surface">
    
    <!-- Toast / Alerts Notification -->
    <c:if test="${not empty successMsg}">
        <div class="mb-6 p-4 bg-emerald-50 border-l-4 border-emerald-500 rounded-r-xl shadow-sm flex items-center justify-between transition-all duration-300">
            <div class="flex items-center gap-3">
                <span class="material-symbols-outlined text-emerald-600 font-bold" style="font-variation-settings: 'FILL' 1">check_circle</span>
                <span class="text-sm font-semibold text-emerald-800">${successMsg}</span>
            </div>
            <button onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700 text-lg font-bold">&times;</button>
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div class="mb-6 p-4 bg-red-50 border-l-4 border-red-500 rounded-r-xl shadow-sm flex items-center justify-between transition-all duration-300">
            <div class="flex items-center gap-3">
                <span class="material-symbols-outlined text-red-600 font-bold" style="font-variation-settings: 'FILL' 1">warning</span>
                <span class="text-sm font-semibold text-red-800">${errorMsg}</span>
            </div>
            <button onclick="this.parentElement.remove()" class="text-red-500 hover:text-red-700 text-lg font-bold">&times;</button>
        </div>
    </c:if>

    <!-- Unified Form wrapping the designed screen settings -->
    <form method="POST" action="${pageContext.request.contextPath}/admin/payment-settings" class="space-y-6">
        <input type="hidden" name="action" value="updateAll" />
        <input type="hidden" name="tab" value="methods" />

        <!-- Header Section -->
        <div class="mb-8 flex justify-between items-end">
            <div>
                <nav class="flex text-sm text-outline mb-2">
                    <a href="${pageContext.request.contextPath}/home" class="hover:text-primary">Hệ thống</a>
                    <span class="mx-2">/</span>
                    <span class="text-primary font-medium">Cấu hình chính sách &amp; Phương thức thanh toán</span>
                </nav>
                <h3 class="text-3xl font-bold tracking-tight text-on-surface">Thiết lập Quy tắc &amp; Thanh toán</h3>
                <p class="text-on-surface-variant mt-1">Điều chỉnh các thông số vận hành và quản lý luồng tiền tệ của hệ thống.</p>
            </div>
            <div class="flex gap-3">
                <a href="${pageContext.request.contextPath}/admin/payment-settings" class="px-6 py-2.5 rounded-full border border-outline text-on-surface font-medium hover:bg-surface-container-high transition-all active:scale-95 text-sm inline-flex items-center justify-center">
                    Hủy thay đổi
                </a>
                <button type="submit" class="px-6 py-2.5 rounded-full bg-primary text-on-primary font-medium shadow-lg shadow-primary/20 hover:bg-primary/90 transition-all active:scale-95 text-sm flex items-center gap-2 cursor-pointer">
                    <span class="material-symbols-outlined text-sm">save</span>
                    Lưu cấu hình
                </button>
            </div>
        </div>

        <!-- Bento Grid Layout -->
        <div class="grid grid-cols-12 gap-6">
            
            <!-- LEFT COLUMN: Deposits, Grace Hours, Cancellations & Bank Accounts (col-span-8) -->
            <div class="col-span-12 lg:col-span-8 space-y-6">
                
                <!-- Card 1: Deposits & Grace Period -->
                <div class="glass-card rounded-3xl p-8 shadow-sm">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary">
                            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">gavel</span>
                        </div>
                        <div>
                            <h4 class="text-xl font-bold text-on-surface">Quy tắc Đặt cọc &amp; Phí trễ hạn</h4>
                            <p class="text-sm text-on-surface-variant">Thiết lập các mức phí bảo đảm và phạt vi phạm thời gian.</p>
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-2 gap-8">
                        <div class="space-y-4">
                            <!-- Deposit Percentage -->
                            <c:set var="depositPercentage" value="${settingMap['DEPOSIT_PERCENTAGE'] != null ? settingMap['DEPOSIT_PERCENTAGE'].policyValue : '30'}"/>
                            <label class="block">
                                <span class="text-sm font-semibold text-on-surface flex items-center gap-2 mb-2">
                                    Tiền đặt cọc mặc định (%)
                                    <span class="material-symbols-outlined text-xs text-outline cursor-help" title="Phần trăm giá trị hợp đồng cần đặt cọc">info</span>
                                </span>
                                <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                    <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="number" name="policy_DEPOSIT_PERCENTAGE" value="${depositPercentage}" min="0" max="100" required/>
                                    <span class="absolute right-4 top-1/2 -translate-y-1/2 text-outline font-medium">%</span>
                                </div>
                            </label>
                            
                            <!-- Grace Period (Hours) -->
                            <c:set var="gracePeriod" value="${settingMap['PAYMENT_GRACE_PERIOD_HOURS'] != null ? settingMap['PAYMENT_GRACE_PERIOD_HOURS'].policyValue : '24'}"/>
                            <label class="block">
                                <span class="text-sm font-semibold text-on-surface mb-2 block">Thời gian gia hạn thanh toán (Giờ)</span>
                                <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                    <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="number" name="policy_PAYMENT_GRACE_PERIOD_HOURS" value="${gracePeriod}" min="1" max="168" required/>
                                    <span class="absolute right-4 top-1/2 -translate-y-1/2 text-outline font-medium">Giờ</span>
                                </div>
                            </label>
                        </div>
                        
                        <div class="space-y-4">
                            <!-- Delay Penalty (Placeholder view for compliance, styled premium) -->
                            <label class="block">
                                <span class="text-sm font-semibold text-on-surface mb-2 block">Phí trễ trả xe mỗi giờ (%)</span>
                                <div class="relative rounded-xl overflow-hidden border border-outline-variant bg-surface-container-high/40">
                                    <input class="w-full bg-transparent border-none px-4 py-3 outline-none font-medium text-outline" type="number" value="10" readonly disabled/>
                                    <span class="absolute right-4 top-1/2 -translate-y-1/2 text-outline font-medium">% giá ngày</span>
                                </div>
                            </label>
                            
                            <!-- Cancellation grace period minutes -->
                            <label class="block">
                                <span class="text-sm font-semibold text-on-surface mb-2 block">Thời gian ân hạn trả muộn (Phút)</span>
                                <div class="relative rounded-xl overflow-hidden border border-outline-variant bg-surface-container-high/40">
                                    <input class="w-full bg-transparent border-none px-4 py-3 outline-none font-medium text-outline" type="number" value="30" readonly disabled/>
                                    <span class="absolute right-4 top-1/2 -translate-y-1/2 text-outline font-medium">Phút</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Partial Payment option -->
                    <c:set var="partialAllowed" value="${settingMap['PAYMENT_PARTIAL_ALLOWED'] != null && settingMap['PAYMENT_PARTIAL_ALLOWED'].policyValue == 'true'}"/>
                    <div class="mt-6 pt-6 border-t border-outline-variant/30 flex items-center justify-between">
                        <div>
                            <span class="text-sm font-semibold text-on-surface block">Cho phép thanh toán từng phần (Partial Payment)</span>
                            <span class="text-xs text-on-surface-variant">Hệ thống ghi nhận các giao dịch cọc nhỏ hơn hoặc lớn hơn trước khi bàn giao xe.</span>
                        </div>
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" name="policy_PAYMENT_PARTIAL_ALLOWED" value="true" ${partialAllowed ? 'checked' : ''} class="sr-only peer">
                            <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                        </label>
                    </div>
                </div>

                <!-- Card 2: Cancellation Rules -->
                <div class="glass-card rounded-3xl p-8 shadow-sm">
                    <div class="flex items-center justify-between mb-6">
                        <div class="flex items-center gap-3">
                            <div class="w-12 h-12 rounded-2xl bg-secondary/10 flex items-center justify-center text-secondary">
                                <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">event_busy</span>
                            </div>
                            <div>
                                <h4 class="text-xl font-bold text-on-surface">Chính sách Hủy đơn & Hoàn cọc</h4>
                                <p class="text-sm text-on-surface-variant">Quản lý phần trăm hoàn trả tiền đặt cọc tự động dựa trên thời điểm hủy.</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="space-y-4">
                        <div class="flex items-center gap-4 bg-surface-container-low p-4 rounded-2xl border border-outline-variant/50">
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Thời điểm hủy đơn</span>
                                <p class="font-semibold text-on-surface">Trước 48 giờ kể từ giờ nhận xe</p>
                            </div>
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Hoàn trả tiền cọc</span>
                                <p class="font-semibold text-emerald-600">Hoàn 100% tiền cọc</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 bg-surface-container-low p-4 rounded-2xl border border-outline-variant/50">
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Thời điểm hủy đơn</span>
                                <p class="font-semibold text-on-surface">Từ 24 giờ đến 48 giờ kể từ giờ nhận xe</p>
                            </div>
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Hoàn trả tiền cọc</span>
                                <p class="font-semibold text-orange-500">Hoàn 50% tiền cọc</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4 bg-surface-container-low p-4 rounded-2xl border border-outline-variant/50 opacity-75">
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Thời điểm hủy đơn</span>
                                <p class="font-semibold text-on-surface">Dưới 24 giờ kể từ giờ nhận xe</p>
                            </div>
                            <div class="flex-1 col-span-5">
                                <span class="text-[10px] font-bold text-outline uppercase tracking-wider block">Hoàn trả tiền cọc</span>
                                <p class="font-semibold text-red-600">Không hoàn trả tiền cọc (Phạt cọc)</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 3: Collapsible Bank Account Configuration -->
                <div class="glass-card rounded-3xl p-8 shadow-sm scroll-mt-20" id="bank-config-card">
                    <div class="flex items-center gap-3 mb-6">
                        <div class="w-12 h-12 rounded-2xl bg-amber-500/10 flex items-center justify-center text-amber-600">
                            <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">account_balance</span>
                        </div>
                        <div>
                            <h4 class="text-xl font-bold text-on-surface">Cấu hình Tài khoản Ngân hàng Doanh nghiệp</h4>
                            <p class="text-sm text-on-surface-variant">Thông tin tài khoản nhận tiền chuyển khoản tự động và liên kết sinh mã VietQR.</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-6">
                        <!-- Bank Name -->
                        <c:set var="bankName" value="${settingMap['BANK_NAME'] != null ? settingMap['BANK_NAME'].policyValue : ''}"/>
                        <label class="block">
                            <span class="text-sm font-semibold text-on-surface mb-2 block">Tên Ngân Hàng Doanh Nghiệp *</span>
                            <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="text" name="policy_BANK_NAME" value="${bankName}" placeholder="Techcombank, Vietcombank..." required/>
                            </div>
                        </label>

                        <!-- Bank Branch -->
                        <c:set var="bankBranch" value="${settingMap['BANK_BRANCH'] != null ? settingMap['BANK_BRANCH'].policyValue : ''}"/>
                        <label class="block">
                            <span class="text-sm font-semibold text-on-surface mb-2 block">Chi Nhánh Của Ngân Hàng *</span>
                            <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="text" name="policy_BANK_BRANCH" value="${bankBranch}" placeholder="Chi nhánh Thạch Thất..." required/>
                            </div>
                        </label>

                        <!-- Account Number -->
                        <c:set var="accNumber" value="${settingMap['BANK_ACCOUNT_NUMBER'] != null ? settingMap['BANK_ACCOUNT_NUMBER'].policyValue : ''}"/>
                        <label class="block">
                            <span class="text-sm font-semibold text-on-surface mb-2 block">Số Tài Khoản Nhận *</span>
                            <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="text" name="policy_BANK_ACCOUNT_NUMBER" value="${accNumber}" placeholder="0987654321..." required/>
                            </div>
                        </label>

                        <!-- Account Name -->
                        <c:set var="accName" value="${settingMap['BANK_ACCOUNT_NAME'] != null ? settingMap['BANK_ACCOUNT_NAME'].policyValue : ''}"/>
                        <label class="block">
                            <span class="text-sm font-semibold text-on-surface mb-2 block">Tên Chủ Tài Khoản (Không dấu) *</span>
                            <div class="relative rounded-xl overflow-hidden border border-outline-variant focus-within:ring-2 focus-within:ring-primary/20 focus-within:border-primary transition-all">
                                <input class="w-full bg-surface-container-low border-none px-4 py-3 outline-none transition-all font-medium text-on-surface" type="text" name="policy_BANK_ACCOUNT_NAME" value="${accName}" placeholder="CONG TY TNHH CAR RENTAL..." required/>
                            </div>
                        </label>
                    </div>
                </div>
            </div>

            <!-- RIGHT COLUMN: Payment Method Toggles (col-span-4) -->
            <div class="col-span-12 lg:col-span-4 space-y-6">
                
                <div class="bg-white rounded-3xl p-8 shadow-xl border border-primary/5 relative overflow-hidden h-fit">
                    <div class="absolute -right-16 -top-16 w-48 h-48 bg-primary/5 rounded-full blur-3xl"></div>
                    <div class="relative z-10 space-y-6">
                        
                        <!-- Header inside right card -->
                        <div class="flex items-center gap-3 mb-4">
                            <div class="w-12 h-12 rounded-2xl bg-on-primary-container flex items-center justify-center text-primary-container shrink-0">
                                <span class="material-symbols-outlined" style="font-variation-settings: 'FILL' 1">account_balance_wallet</span>
                            </div>
                            <div>
                                <h4 class="text-xl font-bold text-on-surface">Phương thức nhận</h4>
                                <p class="text-xs text-on-surface-variant">Bật/tắt các cổng thanh toán hệ thống.</p>
                            </div>
                        </div>

                        <!-- 1. CASH method -->
                        <c:set var="cashEnabled" value="${methodMap['PAYMENT_METHOD_CASH_ENABLED'] != null && methodMap['PAYMENT_METHOD_CASH_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${cashEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        💵
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Tiền mặt</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Thanh toán trực tiếp tại quầy</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_CASH_ENABLED" value="on" ${cashEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                        </div>

                        <!-- 2. BANK TRANSFER method -->
                        <c:set var="bankEnabled" value="${methodMap['PAYMENT_METHOD_BANK_TRANSFER_ENABLED'] != null && methodMap['PAYMENT_METHOD_BANK_TRANSFER_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${bankEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        🏦
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Chuyển khoản</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Quét mã QR hoặc nhập số TK</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_BANK_TRANSFER_ENABLED" value="on" ${bankEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                            <div class="mt-3 pt-3 border-t border-outline-variant/30 text-xs text-primary font-semibold flex items-center gap-1 cursor-pointer hover:underline" onclick="scrollToBank()">
                                <span class="material-symbols-outlined text-[15px]" style="font-variation-settings: 'FILL' 1">settings</span>
                                Cấu hình tài khoản nhận tiền
                            </div>
                        </div>

                        <!-- 3. CREDIT CARD method -->
                        <c:set var="cardEnabled" value="${methodMap['PAYMENT_METHOD_CARD_ENABLED'] != null && methodMap['PAYMENT_METHOD_CARD_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${cardEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        💳
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Thẻ tín dụng</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Visa, Mastercard, JCB</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_CARD_ENABLED" value="on" ${cardEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                        </div>

                        <!-- 4. MOMO E-WALLET method -->
                        <c:set var="momoEnabled" value="${methodMap['PAYMENT_METHOD_MOMO_ENABLED'] != null && methodMap['PAYMENT_METHOD_MOMO_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${momoEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        📱
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Ví MoMo</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Ví điện tử MoMo (Thử nghiệm)</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_MOMO_ENABLED" value="on" ${momoEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                        </div>

                        <!-- 5. VNPAY method -->
                        <c:set var="vnpayEnabled" value="${methodMap['PAYMENT_METHOD_VNPAY_ENABLED'] != null && methodMap['PAYMENT_METHOD_VNPAY_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${vnpayEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        🌐
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Cổng VNPay</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Cổng VNPay QR Quốc Gia</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_VNPAY_ENABLED" value="on" ${vnpayEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                        </div>

                        <!-- 6. ZALOPAY method -->
                        <c:set var="zaloEnabled" value="${methodMap['PAYMENT_METHOD_ZALOPAY_ENABLED'] != null && methodMap['PAYMENT_METHOD_ZALOPAY_ENABLED'].policyValue == 'true'}"/>
                        <div class="group relative p-5 bg-surface-container-low rounded-2xl border-2 border-transparent hover:border-primary/20 transition-all ${zaloEnabled ? '' : 'opacity-60'}">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-4">
                                    <div class="w-10 h-10 rounded-lg bg-white flex items-center justify-center shadow-sm text-secondary font-bold">
                                        💬
                                    </div>
                                    <div>
                                        <p class="font-bold text-on-surface text-sm">Ví ZaloPay</p>
                                        <p class="text-[11px] text-on-surface-variant italic">Thanh toán qua ứng dụng ZaloPay</p>
                                    </div>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" name="PAYMENT_METHOD_ZALOPAY_ENABLED" value="on" ${zaloEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleCardOpacity(this)">
                                    <div class="w-11 h-6 bg-outline-variant peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Info Safety Card -->
                <div class="bg-primary-container/20 p-6 rounded-3xl border border-primary/10 shadow-sm">
                    <div class="flex gap-4">
                        <span class="material-symbols-outlined text-primary text-2xl" style="font-variation-settings: 'FILL' 1">security</span>
                        <div>
                            <p class="text-sm font-bold text-on-primary-container">Bảo mật giao dịch doanh nghiệp</p>
                            <p class="text-xs text-on-primary-container/80 mt-1 leading-relaxed">
                                Mọi quy tắc và cấu hình ngân hàng giao dịch trực tuyến đều tuân thủ chặt chẽ tiêu chuẩn bảo mật ngân hàng Việt Nam, liên kết trực tiếp với sinh QR thông minh (VietQR) theo tiêu chuẩn NAPAS 24/7.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Policy Preview Summary (Full Width Bottom) -->
        <div class="w-full">
            <div class="bg-surface-container-highest/40 rounded-3xl p-8 border border-outline-variant/60 shadow-sm">
                <div class="flex items-start gap-8">
                    <div class="w-24 h-24 rounded-2xl overflow-hidden shrink-0 border border-outline-variant bg-surface-container-high flex items-center justify-center">
                        <span class="material-symbols-outlined text-outline text-5xl" style="font-variation-settings: 'FILL' 0">description</span>
                    </div>
                    <div class="flex-1">
                        <h5 class="text-base font-bold text-on-surface mb-2">Tóm tắt điều khoản tài chính cho khách thuê</h5>
                        <p class="text-xs text-on-surface-variant leading-relaxed">
                            Hệ thống sẽ tự động hiển thị và cập nhật các "Điều khoản thanh toán & Chính sách hoàn tiền" trên giao diện Đặt xe của khách hàng dựa trên các cấu hình ở trên. Mức đặt cọc mặc định là <span class="font-bold text-primary">${depositPercentage}%</span> tổng giá trị đơn đặt, và thời gian chờ cọc là <span class="font-bold text-primary">${gracePeriod} giờ</span> trước khi tự động hủy. Phí vi phạm trả muộn sẽ tự động cộng vào biên bản bàn giao nhận lại xe.
                        </p>
                        <div class="flex gap-6 mt-4 text-[11px] font-semibold text-outline">
                            <div class="flex items-center gap-1">
                                <span class="material-symbols-outlined text-[14px]">history</span>
                                Cập nhật thời gian thực
                            </div>
                            <div class="flex items-center gap-1">
                                <span class="material-symbols-outlined text-[14px]">person_edit</span>
                                Quyền chỉnh sửa: Hệ thống Quản trị viên
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
    // Smooth scroll to bank config card
    function scrollToBank() {
        const card = document.getElementById('bank-config-card');
        if (card) {
            card.scrollIntoView({ behavior: 'smooth' });
            
            // Add brief flash highlight effect to card border
            card.style.borderColor = 'var(--primary)';
            card.style.boxShadow = '0 0 15px rgba(0, 95, 184, 0.2)';
            setTimeout(() => {
                card.style.borderColor = 'rgba(226, 226, 230, 0.5)';
                card.style.boxShadow = 'none';
            }, 1200);
        }
    }

    // Interactive opacity toggling on checkboxes change
    function toggleCardOpacity(input) {
        const parentCard = input.closest('.group');
        if (parentCard) {
            if (input.checked) {
                parentCard.classList.remove('opacity-60');
            } else {
                parentCard.classList.add('opacity-60');
            }
        }
    }
</script>

<jsp:include page="/WEB-INF/views/layout/footer.jsp"/>
