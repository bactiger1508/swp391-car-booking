<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${param.pageTitle != null ? param.pageTitle : 'CarPro - Quản lý thuê xe'}</title>
        <meta name="description" content="Hệ thống quản lý thuê ô tô tự lái - CarPro">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    </head>
    <body class="bk-layout">

        <%-- SIDEBAR --%>
        <aside class="bk-sidebar">
            <div class="bk-sidebar-brand">
                <h1>CarPro</h1>
                <p>Quản lý đội xe thông minh</p>
            </div>

            <%
                String reqURI = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
                if (reqURI == null) {
                    reqURI = request.getRequestURI();
                }
                String ctx = request.getContextPath();
                String currentPath = reqURI.startsWith(ctx) ? reqURI.substring(ctx.length()) : reqURI;
                request.setAttribute("_cp", currentPath);
            %>

            <nav class="bk-sidebar-nav">
                <a href="${pageContext.request.contextPath}/home" class="bk-sidebar-link ${_cp == '/home' || _cp == '/' ? 'active' : ''}">
                    <span class="material-symbols-outlined">home</span> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/vehicles" class="bk-sidebar-link ${_cp == '/vehicles' ? 'active' : ''}">
                    <span class="material-symbols-outlined">directions_car</span> Danh sách xe
                </a>

                <c:if test="${sessionScope.currentUser == null}">
                    <a href="${pageContext.request.contextPath}/bookings/my" class="bk-sidebar-link ${_cp == '/bookings/my' || _cp == '/bookings/detail' ? 'active' : ''}">
                        <span class="material-symbols-outlined mi-filled">receipt_long</span> Đơn thuê của tôi
                    </a>
                    <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                        <span class="material-symbols-outlined">policy</span> Chính sách
                    </a>
                </c:if>

                <c:if test="${sessionScope.currentUser != null}">
                    <a href="${pageContext.request.contextPath}/notifications" class="bk-sidebar-link ${_cp == '/notifications' ? 'active' : ''}">
                        <span class="material-symbols-outlined">notifications</span> Thông báo
                    </a>
                    <a href="${pageContext.request.contextPath}/profile" class="bk-sidebar-link ${_cp == '/profile' ? 'active' : ''}">
                        <span class="material-symbols-outlined">person</span> Hồ sơ cá nhân
                    </a>
                    <a href="${pageContext.request.contextPath}/change-password"
                       class="bk-sidebar-link ${_cp == '/change-password' ? 'active' : ''}">
                        <span class="material-symbols-outlined">lock_reset</span>
                        Đổi mật khẩu
                    </a>

                    <%-- Check permissions dynamically --%>
                    <c:set var="isAdmin" value="${sessionScope.currentUser.role == 'ADMIN'}" />
                    <c:set var="hasCreateBooking" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('CREATE_BOOKING'))}" />
                    <c:set var="hasViewBooking" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_BOOKING'))}" />
                    <c:set var="hasViewContract" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_CONTRACT'))}" />
                    
                    <c:set var="hasProcessBooking" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('PROCESS_BOOKING_REQUEST'))}" />
                    <c:set var="hasVerifyProfile" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VERIFY_CUSTOMER_PROFILE'))}" />
                    <c:set var="hasViewCalendar" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_BOOKINGS_CALENDAR'))}" />
                    
                    <c:set var="hasManageVehicle" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_VEHICLE_DETAIL_STAFF'))}" />
                    <c:set var="hasCheckAvailability" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('CHECK_VEHICLE_AVAILABILITY'))}" />
                    <c:set var="hasMaintenance" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('RECORD_VEHICLE_MAINTENANCE'))}" />
                    
                    <c:set var="hasHandover" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('PROCESS_HANDOVER'))}" />
                    <c:set var="hasReturn" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('PROCESS_RETURN'))}" />
                    <c:set var="hasAdditionalFee" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('RECORD_ADDITIONAL_FEE'))}" />
                    
                    <c:set var="hasRevenueReport" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_REVENUE_REPORT'))}" />
                    <c:set var="hasUtilizationReport" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_VEHICLE_UTILIZATION_REPORT'))}" />
                    <c:set var="hasPaymentRecord" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('RECORD_PAYMENT'))}" />
                    <c:set var="hasRentalPolicy" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('CONFIGURE_RENTAL_POLICY'))}" />
                    
                    <c:set var="hasUserList" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_USER_LIST'))}" />
                    <c:set var="hasTaxInvoice" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('EXPORT_VAT_INVOICE'))}" />
                    <c:set var="hasPaymentSetting" value="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('CONFIGURE_PAYMENT_METHOD'))}" />

                    <%-- Section: Đặt Xe (Customer) --%>
                    <c:if test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Đặt Xe</div>
                        <c:if test="${hasCreateBooking}">
                            <a href="${pageContext.request.contextPath}/bookings/create" class="bk-sidebar-link ${_cp == '/bookings/create' ? 'active' : ''}">
                                <span class="material-symbols-outlined">add_circle</span> Đặt xe mới
                            </a>
                        </c:if>
                        <c:if test="${hasViewBooking}">
                            <a href="${pageContext.request.contextPath}/bookings/my" class="bk-sidebar-link ${_cp == '/bookings/my' || _cp == '/bookings/detail' ? 'active' : ''}">
                                <span class="material-symbols-outlined mi-filled">receipt_long</span> Đơn thuê của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/payments/history" class="bk-sidebar-link ${_cp == '/payments/history' ? 'active' : ''}">
                                <span class="material-symbols-outlined">payments</span> Lịch sử thanh toán
                            </a>
                        </c:if>
                        <c:if test="${hasCheckAvailability}">
                            <a href="${pageContext.request.contextPath}/vehicles/availability" class="bk-sidebar-link ${_cp == '/vehicles/availability' ? 'active' : ''}">
                                <span class="material-symbols-outlined">calendar_today</span> Kiểm tra xe trống
                            </a>
                        </c:if>
                        <c:if test="${hasViewContract}">
                            <a href="${pageContext.request.contextPath}/contracts" class="bk-sidebar-link ${_cp == '/contracts' ? 'active' : ''}">
                                <span class="material-symbols-outlined">description</span> Hợp đồng của tôi
                            </a>
                        </c:if>
                    </c:if>

                    <%-- Section: Quản lý Đặt xe (Staff / Admin) --%>
                    <c:if test="${(hasProcessBooking || hasVerifyProfile || hasViewCalendar) && sessionScope.currentUser.role != 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Quản lý Đặt xe</div>
                        <c:if test="${hasProcessBooking}">
                            <a href="${pageContext.request.contextPath}/bookings/manage" class="bk-sidebar-link ${_cp == '/bookings/manage' ? 'active' : ''}">
                                <span class="material-symbols-outlined">assignment</span> Quản lý đặt xe
                            </a>
                            <a href="${pageContext.request.contextPath}/bookings/approval" class="bk-sidebar-link ${_cp == '/bookings/approval' ? 'active' : ''}">
                                <span class="material-symbols-outlined">fact_check</span> Duyệt đặt xe
                            </a>
                        </c:if>
                        <c:if test="${hasVerifyProfile}">
                            <a href="${pageContext.request.contextPath}/user/customer-profiles" class="bk-sidebar-link ${_cp == '/user/customer-profiles' ? 'active' : ''}">
                                <span class="material-symbols-outlined">id_card</span> Duyệt hồ sơ KH
                            </a>
                        </c:if>
                        <c:if test="${hasViewCalendar}">
                            <a href="${pageContext.request.contextPath}/bookings/calendar" class="bk-sidebar-link ${_cp == '/bookings/calendar' ? 'active' : ''}">
                                <span class="material-symbols-outlined">calendar_month</span> Lịch đặt xe
                            </a>
                        </c:if>
                    </c:if>

                    <%-- Section: Nghiệp vụ xe (Staff / Admin) --%>
                    <c:if test="${(hasManageVehicle || hasCheckAvailability || hasMaintenance) && sessionScope.currentUser.role != 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Nghiệp vụ xe</div>
                        <c:if test="${hasManageVehicle}">
                            <a href="${pageContext.request.contextPath}/vehicles/manage" class="bk-sidebar-link ${_cp == '/vehicles/manage' ? 'active' : ''}">
                                <span class="material-symbols-outlined">garage</span> Quản lý xe
                            </a>
                        </c:if>
                        <c:if test="${hasCheckAvailability}">
                            <a href="${pageContext.request.contextPath}/vehicles/availability" class="bk-sidebar-link ${_cp == '/vehicles/availability' ? 'active' : ''}">
                                <span class="material-symbols-outlined">calendar_today</span> Kiểm tra xe trống
                            </a>
                        </c:if>
                        <c:if test="${hasMaintenance}">
                            <a href="${pageContext.request.contextPath}/vehicles/maintenance" class="bk-sidebar-link ${_cp == '/vehicles/maintenance' ? 'active' : ''}">
                                <span class="material-symbols-outlined">build</span> Lịch bảo dưỡng
                            </a>
                        </c:if>
                    </c:if>

                    <%-- Section: Vận hành & Hợp đồng (Staff / Admin) --%>
                    <c:if test="${(hasViewContract || hasHandover || hasReturn || hasAdditionalFee) && sessionScope.currentUser.role != 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Vận hành & Hợp đồng</div>
                        <c:if test="${hasViewContract}">
                            <a href="${pageContext.request.contextPath}/contracts" class="bk-sidebar-link ${_cp == '/contracts' ? 'active' : ''}">
                                <span class="material-symbols-outlined">description</span> Hợp đồng
                            </a>
                        </c:if>
                        <c:if test="${hasHandover}">
                            <a href="${pageContext.request.contextPath}/handovers" class="bk-sidebar-link ${_cp == '/handovers' ? 'active' : ''}">
                                <span class="material-symbols-outlined">key</span> Giao xe
                            </a>
                        </c:if>
                        <c:if test="${hasReturn}">
                            <a href="${pageContext.request.contextPath}/returns" class="bk-sidebar-link ${_cp == '/returns' ? 'active' : ''}">
                                <span class="material-symbols-outlined">keyboard_return</span> Nhận lại xe
                            </a>
                        </c:if>
                    </c:if>

                    <%-- Section: Báo cáo & Cấu hình --%>
                    <c:if test="${(hasRevenueReport || hasUtilizationReport || hasPaymentRecord || hasRentalPolicy) && sessionScope.currentUser.role != 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Báo cáo & Cấu hình</div>
                        <c:if test="${hasRevenueReport}">
                            <a href="${pageContext.request.contextPath}/reports/revenue" class="bk-sidebar-link ${_cp == '/reports/revenue' ? 'active' : ''}">
                                <span class="material-symbols-outlined">analytics</span> Báo cáo doanh thu
                            </a>
                        </c:if>
                        <c:if test="${hasUtilizationReport}">
                            <a href="${pageContext.request.contextPath}/reports/vehicle-utilization" class="bk-sidebar-link ${_cp == '/reports/vehicle-utilization' ? 'active' : ''}">
                                <span class="material-symbols-outlined">query_stats</span> Hiệu suất sử dụng xe
                            </a>
                        </c:if>
                        <c:if test="${hasPaymentRecord}">
                            <a href="${pageContext.request.contextPath}/payments/history" class="bk-sidebar-link ${_cp == '/payments/history' ? 'active' : ''}">
                                <span class="material-symbols-outlined">payments</span> Nhật ký thanh toán
                            </a>
                        </c:if>
                        <c:if test="${hasRentalPolicy}">
                            <a href="${pageContext.request.contextPath}/policies" class="bk-sidebar-link ${_cp == '/policies' ? 'active' : ''}">
                                <span class="material-symbols-outlined">settings_suggest</span> Cấu hình chính sách
                            </a>
                        </c:if>
                    </c:if>

                    <%-- Section: Hệ thống (Admin only or system configurators) --%>
                    <c:if test="${(hasUserList || hasTaxInvoice || hasPaymentSetting || isAdmin) && sessionScope.currentUser.role != 'CUSTOMER'}">
                        <div class="bk-sidebar-section">Hệ thống</div>
                        <c:if test="${hasUserList}">
                            <a href="${pageContext.request.contextPath}/users" class="bk-sidebar-link ${_cp == '/users' ? 'active' : ''}">
                                <span class="material-symbols-outlined">manage_accounts</span> Quản lý thành viên
                            </a>
                        </c:if>
                        <c:if test="${hasTaxInvoice}">
                            <a href="${pageContext.request.contextPath}/tax-invoice-settings" class="bk-sidebar-link ${_cp == '/tax-invoice-settings' ? 'active' : ''}">
                                <span class="material-symbols-outlined">receipt</span> Cấu hình hóa đơn thuế
                            </a>
                        </c:if>
                        <c:if test="${hasPaymentSetting}">
                            <a href="${pageContext.request.contextPath}/admin/payment-settings" class="bk-sidebar-link ${_cp == '/admin/payment-settings' ? 'active' : ''}">
                                <span class="material-symbols-outlined">payment</span> Cấu hình thanh toán
                            </a>
                        </c:if>
                        <c:if test="${isAdmin}">
                            <a href="${pageContext.request.contextPath}/roles" class="bk-sidebar-link ${_cp == '/roles' ? 'active' : ''}">
                                <span class="material-symbols-outlined">security</span> Quyền & Vai trò
                            </a>
                        </c:if>
                        <c:if test="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('MANAGE_VEHICLE_BRANDS'))}">
                            <a href="${pageContext.request.contextPath}/vehicles/brands" class="bk-sidebar-link ${_cp == '/vehicles/brands' ? 'active' : ''}">
                                <span class="material-symbols-outlined">branding_watermark</span> Hãng xe & Model
                            </a>
                        </c:if>
                        <c:if test="${isAdmin || (not empty sessionScope.userPermissions && sessionScope.userPermissions.contains('VIEW_ACTIVITY_HISTORY'))}">
                            <a href="${pageContext.request.contextPath}/audit-logs" class="bk-sidebar-link ${_cp == '/audit-logs' ? 'active' : ''}">
                                <span class="material-symbols-outlined">history</span> Lịch sử hoạt động
                            </a>
                        </c:if>
                    </c:if>
                </c:if>
            </nav>

            <div class="bk-sidebar-footer">
                <c:if test="${sessionScope.currentUser != null}">
                    <a href="${pageContext.request.contextPath}/logout" class="bk-sidebar-link">
                        <span class="material-symbols-outlined">logout</span> Đăng xuất
                    </a>
                </c:if>
                <c:if test="${sessionScope.currentUser == null}">
                    <a href="${pageContext.request.contextPath}/login" class="bk-sidebar-link">
                        <span class="material-symbols-outlined">login</span> Đăng nhập
                    </a>
                </c:if>
            </div>
        </aside>

        <%-- MAIN AREA --%>
        <div class="bk-main">
            <%-- TOP HEADER --%>
            <header class="bk-header">
                <a href="${pageContext.request.contextPath}/home" class="bk-header-brand">Quản lý CarPro</a>

                <div class="bk-header-actions">
                    <c:if test="${sessionScope.currentUser != null}">
                        <div class="bk-header-noti-wrapper" style="position:relative; display:inline-block;">
                            <button type="button" class="bk-header-icon" id="notiBellBtn" onclick="toggleNotiDropdown(event)" style="position:relative; cursor:pointer; background:none; border:none; color:inherit;">
                                <span class="material-symbols-outlined" style="font-size:22px;">notifications</span>
                                <span id="notiBadgeCount" class="bk-noti-badge" style="position:absolute; top:-2px; right:-2px; background:#EE5D50; color:#fff; font-size:10px; font-weight:700; border-radius:10px; padding:1px 5px; min-width:14px; height:14px; line-height:12px; text-align:center; border:2px solid var(--surface, #fff); display:none;">0</span>
                            </button>

                            <%-- Popup Dropdown --%>
                            <div id="notiDropdownPopup" class="bk-noti-dropdown" style="display:none; position:absolute; right:0; top:calc(100% + 8px); width:340px; background:var(--surface, #fff); border:1px solid var(--outline-variant, #e0e0e0); border-radius:12px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:10000; overflow:hidden;">
                                <div style="display:flex; justify-content:space-between; align-items:center; padding:12px 16px; border-bottom:1px solid var(--outline-variant, #eee); background:var(--surface-variant, #f8f9fa);">
                                    <strong style="font-size:14px; color:var(--on-surface);">Thông báo</strong>
                                    <button type="button" onclick="markAllNotisReadHeader()" style="background:none; border:none; color:var(--primary, #2F5ACD); font-size:12px; font-weight:600; cursor:pointer;">Đánh dấu tất cả đã đọc</button>
                                </div>
                                <div id="notiDropdownList" style="max-height:300px; overflow-y:auto;">
                                    <div style="padding:20px; text-align:center; color:var(--secondary); font-size:13px;">Đang tải thông báo...</div>
                                </div>
                                <div style="padding:10px; text-align:center; border-top:1px solid var(--outline-variant, #eee); background:var(--surface-variant, #f8f9fa);">
                                    <a href="${pageContext.request.contextPath}/notifications" style="font-size:12px; font-weight:700; color:var(--primary, #2F5ACD); text-decoration:none;">Xem tất cả thông báo &rarr;</a>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    <c:if test="${sessionScope.currentUser == null}">
                        <button class="bk-header-icon"><span class="material-symbols-outlined">notifications</span></button>
                    </c:if>
                    <button class="bk-header-icon"><span class="material-symbols-outlined">settings</span></button>

                    <c:if test="${sessionScope.currentUser != null}">
                        <div class="bk-header-user">
                            <span>${sessionScope.currentUser.fullName}</span>
                            <div class="bk-header-avatar">
                                ${sessionScope.currentUser.fullName.substring(0,1)}
                            </div>
                        </div>
                    </c:if>

                    <c:if test="${sessionScope.currentUser == null}">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="padding:6px 16px;font-size:13px;">Đăng Nhập</a>
                    </c:if>
                </div>
            </header>

            <c:if test="${sessionScope.currentUser != null}">
                <script>
                function fetchUnreadCountHeader() {
                    fetch('${pageContext.request.contextPath}/notifications?action=getUnreadCount')
                        .then(r => r.json())
                        .then(data => {
                            var badge = document.getElementById('notiBadgeCount');
                            if (badge) {
                                if (data.unreadCount > 0) {
                                    badge.textContent = data.unreadCount > 99 ? '99+' : data.unreadCount;
                                    badge.style.display = 'inline-block';
                                } else {
                                    badge.style.display = 'none';
                                }
                            }
                        }).catch(e => console.log(e));
                }

                function toggleNotiDropdown(event) {
                    if (event) event.stopPropagation();
                    var popup = document.getElementById('notiDropdownPopup');
                    if (!popup) return;
                    
                    if (popup.style.display === 'none' || popup.style.display === '') {
                        popup.style.display = 'block';
                        loadNotiListHeader();
                    } else {
                        popup.style.display = 'none';
                    }
                }

                function loadNotiListHeader() {
                    var container = document.getElementById('notiDropdownList');
                    container.innerHTML = '<div style="padding:20px; text-align:center; color:var(--secondary); font-size:13px;">Đang tải thông báo...</div>';
                    
                    fetch('${pageContext.request.contextPath}/notifications?action=getAll')
                        .then(r => r.json())
                        .then(list => {
                            if (!list || list.length === 0) {
                                container.innerHTML = '<div style="padding:24px; text-align:center; color:var(--secondary); font-size:13px;">Không có thông báo nào.</div>';
                                return;
                            }
                            var html = '';
                            var displayList = list.slice(0, 6);
                            displayList.forEach(n => {
                                var bg = n.isRead ? 'transparent' : 'rgba(47, 90, 205, 0.06)';
                                var dot = n.isRead ? '' : '<span style="width:7px; height:7px; border-radius:50%; background:#2F5ACD; display:inline-block; margin-right:6px;"></span>';
                                html += '<div onclick="readNotiHeader(' + n.notificationId + ')" style="padding:12px 16px; border-bottom:1px solid rgba(0,0,0,0.05); background:' + bg + '; cursor:pointer; text-align:left;">' +
                                        '<div style="font-size:13px; font-weight:700; color:var(--text-primary); display:flex; align-items:center; justify-content:space-between;">' +
                                        '<span>' + dot + n.title + '</span>' +
                                        '<span style="font-size:10px; font-weight:400; color:var(--text-secondary);">' + n.createdAt + '</span>' +
                                        '</div>' +
                                        '<div style="font-size:12px; color:var(--text-secondary); margin-top:4px; line-height:1.4;">' + n.message + '</div>' +
                                        '</div>';
                            });
                            container.innerHTML = html;
                        })
                        .catch(e => {
                            container.innerHTML = '<div style="padding:20px; text-align:center; color:var(--error); font-size:13px;">Lỗi tải thông báo.</div>';
                        });
                }

                function readNotiHeader(id) {
                    fetch('${pageContext.request.contextPath}/notifications?action=markAsRead&notificationId=' + id, {method: 'POST'})
                        .then(() => {
                            fetchUnreadCountHeader();
                            window.location.href = '${pageContext.request.contextPath}/notifications';
                        });
                }

                function markAllNotisReadHeader() {
                    fetch('${pageContext.request.contextPath}/notifications?action=markAllAsRead', {method: 'POST'})
                        .then(() => {
                            fetchUnreadCountHeader();
                            loadNotiListHeader();
                        });
                }

                document.addEventListener('click', function(e) {
                    var wrapper = document.querySelector('.bk-header-noti-wrapper');
                    var popup = document.getElementById('notiDropdownPopup');
                    if (wrapper && popup && !wrapper.contains(e.target)) {
                        popup.style.display = 'none';
                    }
                });

                document.addEventListener('DOMContentLoaded', fetchUnreadCountHeader);
                </script>
            </c:if>

            <%-- CONTENT START --%>
            <div class="bk-content">

        <style>
            .bk-notification-container {
                position: relative;
                display: inline-block;
            }

            .notification-badge {
                position: absolute;
                top: -8px;
                right: -8px;
                background: #e74c3c;
                color: white;
                border-radius: 50%;
                width: 20px;
                height: 20px;
                font-size: 12px;
                font-weight: bold;
                display: flex;
                align-items: center;
                justify-content: center;
                min-width: 20px;
            }

            .notification-dropdown {
                position: absolute;
                top: 100%;
                right: 0;
                background: white;
                border: 1px solid #e0e0e0;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                width: 360px;
                max-height: 500px;
                display: none;
                z-index: 1000;
                margin-top: 8px;
            }

            .notification-dropdown.show {
                display: flex;
                flex-direction: column;
            }

            .notification-header {
                padding: 12px 16px;
                border-bottom: 1px solid #e0e0e0;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .notification-header h3 {
                margin: 0;
                font-size: 14px;
                font-weight: 600;
            }

            .mark-all-btn {
                background: none;
                border: none;
                color: #3498db;
                font-size: 12px;
                cursor: pointer;
                padding: 0;
            }

            .mark-all-btn:hover {
                color: #2980b9;
            }

            .notification-list {
                overflow-y: auto;
                flex: 1;
            }

            .notification-item {
                padding: 12px 16px;
                border-bottom: 1px solid #f0f0f0;
                cursor: pointer;
                transition: background-color 0.2s;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
            }

            .notification-item:hover {
                background-color: #f9f9f9;
            }

            .notification-item.unread {
                background-color: #f0f8ff;
            }

            .notification-content {
                flex: 1;
            }

            .notification-title {
                font-weight: 600;
                font-size: 13px;
                margin: 0 0 4px 0;
                color: #333;
            }

            .notification-message {
                font-size: 12px;
                color: #666;
                margin: 0;
                line-height: 1.4;
            }

            .notification-time {
                font-size: 11px;
                color: #999;
                margin-top: 4px;
            }

            .notification-unread-indicator {
                width: 8px;
                height: 8px;
                background: #3498db;
                border-radius: 50%;
                margin-left: 8px;
                flex-shrink: 0;
                margin-top: 6px;
            }

            .no-notifications {
                padding: 24px 16px;
                text-align: center;
                color: #999;
                font-size: 13px;
            }

            @media (prefers-color-scheme: dark) {
                .notification-dropdown {
                    background: #2c3e50;
                    border-color: #34495e;
                }

                .notification-header {
                    border-bottom-color: #34495e;
                }

                .notification-header h3 {
                    color: #ecf0f1;
                }

                .notification-item {
                    border-bottom-color: #34495e;
                }

                .notification-item:hover {
                    background-color: #34495e;
                }

                .notification-item.unread {
                    background-color: #1a3a52;
                }

                .notification-title {
                    color: #ecf0f1;
                }

                .notification-message {
                    color: #bdc3c7;
                }

                .notification-time {
                    color: #95a5a6;
                }
            }
        </style>

        <script>
            let notificationDropdownOpen = false;
            let notificationPollInterval;

            document.addEventListener('DOMContentLoaded', function() {
                if (document.querySelector('#notificationBell')) {
                    loadNotifications();
                    notificationPollInterval = setInterval(loadNotifications, 60000);
                }
            });

            function toggleNotificationDropdown() {
                const dropdown = document.getElementById('notificationDropdown');
                notificationDropdownOpen = !notificationDropdownOpen;
                if (notificationDropdownOpen) {
                    dropdown.classList.add('show');
                    loadNotifications();
                } else {
                    dropdown.classList.remove('show');
                }
            }

            function loadNotifications() {
                fetch('${pageContext.request.contextPath}/notifications?action=getAll')
                    .then(response => response.json())
                    .then(notifications => {
                        updateNotificationUI(notifications);
                    })
                    .catch(error => console.error('Error loading notifications:', error));
            }

            function updateNotificationUI(notifications) {
                const unreadCount = notifications.filter(n => !n.isRead).length;
                const badge = document.getElementById('notificationBadge');
                const list = document.getElementById('notificationList');

                if (unreadCount > 0) {
                    badge.textContent = unreadCount;
                    badge.style.display = 'flex';
                } else {
                    badge.style.display = 'none';
                }

                if (notifications.length === 0) {
                    list.innerHTML = '<div class="no-notifications">Không có thông báo</div>';
                    return;
                }

                list.innerHTML = notifications.map(notif => {
                    const date = new Date(notif.createdAt);
                    const timeStr = formatNotificationTime(date);
                    const unreadClass = !notif.isRead ? 'unread' : '';
                    const unreadIndicator = !notif.isRead ? '<div class="notification-unread-indicator"></div>' : '';
                    const escapedTitle = escapeHtml(notif.title);
                    const escapedMessage = escapeHtml(notif.message);

                    return `
                        <div class="notification-item ${unreadClass}" onclick="clickNotification(${notif.notificationId}, '${notif.referenceType}', ${notif.referenceId})">
                            <div class="notification-content">
                                <p class="notification-title">${escapedTitle}</p>
                                <p class="notification-message">${escapedMessage}</p>
                                <div class="notification-time">${timeStr}</div>
                            </div>
                            ${unreadIndicator}
                        </div>
                    `;
                }).join('');
            }

            function formatNotificationTime(date) {
                const now = new Date();
                const diff = now - date;
                const seconds = Math.floor(diff / 1000);
                const minutes = Math.floor(seconds / 60);
                const hours = Math.floor(minutes / 60);
                const days = Math.floor(hours / 24);

                if (seconds < 60) return 'Vừa xong';
                if (minutes < 60) return minutes + ' phút trước';
                if (hours < 24) return hours + ' giờ trước';
                if (days < 7) return days + ' ngày trước';

                return date.toLocaleDateString('vi-VN');
            }

            function clickNotification(notificationId, referenceType, referenceId) {
                markNotificationAsRead(notificationId);

                let redirectUrl = '${pageContext.request.contextPath}/notifications';
                if (referenceType && referenceId) {
                    switch(referenceType) {
                        case 'BOOKING':
                            redirectUrl = '${pageContext.request.contextPath}/bookings/detail?id=' + referenceId;
                            break;
                        case 'CONTRACT':
                            redirectUrl = '${pageContext.request.contextPath}/contracts/detail?id=' + referenceId;
                            break;
                        case 'PAYMENT':
                            redirectUrl = '${pageContext.request.contextPath}/payments/record?bookingId=' + referenceId;
                            break;
                        case 'HANDOVER':
                            redirectUrl = '${pageContext.request.contextPath}/handovers';
                            break;
                        case 'RETURN':
                            redirectUrl = '${pageContext.request.contextPath}/returns';
                            break;
                    }
                }

                window.location.href = redirectUrl;
            }

            function markNotificationAsRead(notificationId) {
                fetch('${pageContext.request.contextPath}/notifications', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=markAsRead&notificationId=' + notificationId
                }).then(() => {
                    loadNotifications();
                }).catch(error => console.error('Error marking notification as read:', error));
            }

            function markAllNotificationsAsRead() {
                fetch('${pageContext.request.contextPath}/notifications', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=markAllAsRead'
                }).then(() => {
                    loadNotifications();
                }).catch(error => console.error('Error marking all notifications as read:', error));
            }

            function escapeHtml(text) {
                const map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text.replace(/[&<>"']/g, m => map[m]);
            }

            document.addEventListener('click', function(event) {
                const bell = document.getElementById('notificationBell');
                const dropdown = document.getElementById('notificationDropdown');
                if (bell && dropdown && !bell.contains(event.target) && !dropdown.contains(event.target)) {
                    notificationDropdownOpen = false;
                    dropdown.classList.remove('show');
                }
            });
        </script>
