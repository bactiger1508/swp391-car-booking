# 🚗 Car Rental Management System

Chào mừng đến với dự án **Hệ Thống Quản Lý Thuê Xe Tự Lái (Car Rental Management)**. Đây là đồ án môn học SWP391, được thiết kế nhằm số hóa và tự động hóa toàn bộ quy trình thuê xe, quản lý hợp đồng, bảo dưỡng và thanh toán của một doanh nghiệp cho thuê ô tô.

## 🌟 Chức Năng Chính

Hệ thống được phân quyền chặt chẽ dành cho 3 đối tượng người dùng chính:

### 1. Khách hàng (Customer)
- 🔍 Tìm kiếm và xem thông tin chi tiết các dòng xe (giá, chỗ ngồi, truyền động).
- 📅 Đặt lịch thuê xe (Booking) và quản lý chuyến đi của mình.
- 💳 Xem lịch sử thanh toán và hóa đơn.

### 2. Nhân viên (Staff)
- ✅ Quản lý và phê duyệt yêu cầu đặt xe từ khách hàng.
- 🔑 Làm thủ tục Giao Xe (Handover) và Nhận Lại Xe (Return).
- 📄 Quản lý hợp đồng thuê xe.
- 💰 Ghi nhận phụ phí phát sinh (nếu có hỏng hóc hoặc quá giờ).

### 3. Quản trị viên (Admin)
- 👥 Quản lý tài khoản người dùng và phân quyền hệ thống.
- ⚙️ Quản lý danh mục xe và lập lịch bảo dưỡng (Maintenance).
- ⚖️ Cấu hình các chính sách thuê xe, thuế, hóa đơn.
- 📈 Xem báo cáo thống kê doanh thu và hiệu suất sử dụng xe.

## 🛠 Công Nghệ Sử Dụng

- **Ngôn ngữ:** Java 21
- **Kiến trúc:** Mô hình MVC (Model - View - Controller) chuẩn 3 tầng.
- **Backend:** Java Servlet (API Jakarta EE 10), JDBC.
- **Frontend:** JSP, JSTL, HTML5, CSS3, JavaScript.
- **Web Server:** Apache Tomcat 10.1.x
- **Database:** Microsoft SQL Server
- **Bảo mật:** Thuật toán băm mật khẩu BCrypt.

## 👥 Đội Ngũ Phát Triển (Team Members)

Dự án được phát triển và hoàn thiện bởi các thành viên:
- **Ánh**
- **Tỉnh**
- **Bắc**
- **Tùng**
- **Tâm**

## 🚀 Hướng Dẫn Cài Đặt (Dành Cho Team)

Để tiến hành cài đặt môi trường và chạy dự án lên máy cá nhân, vui lòng xem hướng dẫn chi tiết từng bước tại file:
👉 **[onboarding.html](onboarding.html)** *(Hãy mở file này bằng trình duyệt web).*

---
*Developed for SWP391 - 2026* 🎓
