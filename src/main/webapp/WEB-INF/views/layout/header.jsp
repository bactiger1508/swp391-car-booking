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
                <a href="${pageContext.request.contextPath}/bookings/policy" class="bk-sidebar-link ${_cp == '/bookings/policy' ? 'active' : ''}">
                    <span class="material-symbols-outlined">policy</span> Chính sách
                </a>

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
                        <c:if test="${hasAdditionalFee}">
                            <a href="${pageContext.request.contextPath}/additional-fees" class="bk-sidebar-link ${_cp == '/additional-fees' ? 'active' : ''}">
                                <span class="material-symbols-outlined">price_change</span> Phí phát sinh
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
                            <a href="${pageContext.request.contextPath}/vehicles/brands" class="bk-sidebar-link ${_cp == '/vehicles/brands' ? 'active' : ''}">
                                <span class="material-symbols-outlined">branding_watermark</span> Hãng xe & Model
                            </a>
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
                        <a href="${pageContext.request.contextPath}/notifications" class="bk-header-icon">
                            <span class="material-symbols-outlined">notifications</span>
                        </a>
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

            <%-- CONTENT START --%>
            <div class="bk-content">
