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

        <c:if test="${sessionScope.currentUser != null}">
            <a href="${pageContext.request.contextPath}/notifications" class="bk-sidebar-link ${_cp == '/notifications' ? 'active' : ''}">
                <span class="material-symbols-outlined">notifications</span> Thông báo
            </a>
            <a href="${pageContext.request.contextPath}/profile" class="bk-sidebar-link ${_cp == '/profile' ? 'active' : ''}">
                <span class="material-symbols-outlined">person</span> Hồ sơ cá nhân
            </a>

            <c:if test="${sessionScope.currentUser.role == 'CUSTOMER'}">
                <div class="bk-sidebar-section">Đặt Xe</div>
                <a href="${pageContext.request.contextPath}/bookings/create" class="bk-sidebar-link ${_cp == '/bookings/create' ? 'active' : ''}">
                    <span class="material-symbols-outlined">add_circle</span> Đặt xe mới
                </a>
                <a href="${pageContext.request.contextPath}/bookings/my" class="bk-sidebar-link ${_cp == '/bookings/my' || _cp == '/bookings/detail' ? 'active' : ''}">
                    <span class="material-symbols-outlined mi-filled">receipt_long</span> Đơn thuê của tôi
                </a>
                <a href="${pageContext.request.contextPath}/contracts" class="bk-sidebar-link ${_cp == '/contracts' ? 'active' : ''}">
                    <span class="material-symbols-outlined">description</span> Hợp đồng của tôi
                </a>
                <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                    <span class="material-symbols-outlined">policy</span> Chính sách
                </a>
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
                        <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                            <span class="material-symbols-outlined">policy</span> Chính sách
                        </a>
                    </c:if>

                <div class="bk-sidebar-section">Nghiệp vụ xe</div>
                <a href="${pageContext.request.contextPath}/vehicles/manage" class="bk-sidebar-link ${_cp == '/vehicles/manage' ? 'active' : ''}">
                    <span class="material-symbols-outlined">garage</span> Quản lý xe
                </a>
                <a href="${pageContext.request.contextPath}/vehicles/availability" class="bk-sidebar-link ${_cp == '/vehicles/availability' ? 'active' : ''}">
                    <span class="material-symbols-outlined">calendar_today</span> Kiểm tra xe trống
                </a>
                <a href="${pageContext.request.contextPath}/vehicles/maintenance" class="bk-sidebar-link ${_cp == '/vehicles/maintenance' ? 'active' : ''}">
                    <span class="material-symbols-outlined">build</span> Quản lý bảo trì
                </a>

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
                        <c:if test="${hasAdditionalFee}">
                            <a href="${pageContext.request.contextPath}/additional-fees" class="bk-sidebar-link ${_cp == '/additional-fees' ? 'active' : ''}">
                                <span class="material-symbols-outlined">price_change</span> Phí phát sinh
                            </a>
                        </c:if>
                    </c:if>

                <div class="bk-sidebar-section">Báo cáo & Cấu hình</div>
                <a href="${pageContext.request.contextPath}/reports/revenue" class="bk-sidebar-link ${_cp == '/reports/revenue' ? 'active' : ''}">
                    <span class="material-symbols-outlined">analytics</span> Báo cáo doanh thu
                </a>
                <a href="${pageContext.request.contextPath}/reports/vehicle-utilization" class="bk-sidebar-link ${_cp == '/reports/vehicle-utilization' ? 'active' : ''}">
                    <span class="material-symbols-outlined">query_stats</span> Hiệu suất sử dụng xe
                </a>
                <a href="${pageContext.request.contextPath}/payments/record" class="bk-sidebar-link ${_cp == '/payments/record' ? 'active' : ''}">
                    <span class="material-symbols-outlined">payments</span> Nhật ký thanh toán
                </a>
                <a href="${pageContext.request.contextPath}/policies" class="bk-sidebar-link ${_cp == '/policies' ? 'active' : ''}">
                    <span class="material-symbols-outlined">settings_suggest</span> Cấu hình chính sách
                </a>

            <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
                <div class="bk-sidebar-section">Hệ thống</div>
                <a href="${pageContext.request.contextPath}/users" class="bk-sidebar-link ${_cp == '/users' ? 'active' : ''}">
                    <span class="material-symbols-outlined">manage_accounts</span> Quản lý thành viên
                </a>
                <a href="${pageContext.request.contextPath}/roles" class="bk-sidebar-link ${_cp == '/roles' ? 'active' : ''}">
                    <span class="material-symbols-outlined">security</span> Quyền & Vai trò
                </a>
                <a href="${pageContext.request.contextPath}/tax-invoice-settings" class="bk-sidebar-link ${_cp == '/tax-invoice-settings' ? 'active' : ''}">
                    <span class="material-symbols-outlined">receipt</span> Cấu hình hóa đơn thuế
                </a>
                <a href="${pageContext.request.contextPath}/admin/payment-settings" class="bk-sidebar-link ${_cp == '/admin/payment-settings' ? 'active' : ''}">
                    <span class="material-symbols-outlined">payment</span> Cấu hình thanh toán
                </a>
                <a href="${pageContext.request.contextPath}/vehicles/brands" class="bk-sidebar-link ${_cp == '/vehicles/brands' ? 'active' : ''}">
                    <span class="material-symbols-outlined">branding_watermark</span> Hãng xe & Model
                </a>
                <a href="${pageContext.request.contextPath}/audit-logs" class="bk-sidebar-link ${_cp == '/audit-logs' ? 'active' : ''}">
                    <span class="material-symbols-outlined">history</span> Lịch sử hoạt động
                </a>
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
            <div class="bk-notification-container">
                <button class="bk-header-icon" id="notificationBell" onclick="toggleNotificationDropdown()">
                    <span class="material-symbols-outlined">notifications</span>
                    <span class="notification-badge" id="notificationBadge" style="display: none;">0</span>
                </button>
                <div class="notification-dropdown" id="notificationDropdown">
                    <div class="notification-header">
                        <h3>Thông báo</h3>
                        <button class="mark-all-btn" onclick="markAllNotificationsAsRead()">Đánh dấu tất cả đã đọc</button>
                    </div>
                    <div class="notification-list" id="notificationList">
                        <div class="no-notifications">Không có thông báo</div>
                    </div>
                </div>
            </div>
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
