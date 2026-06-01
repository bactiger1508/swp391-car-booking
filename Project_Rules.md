# QUY TẮC DỰ ÁN SWP391 CHO ANTIGRAVITY / OPUS

> **BẮT BUỘC:** Mỗi lần Antigravity/Opus làm việc với project này, phải đọc file này trước và tuân thủ toàn bộ rule bên dưới.  
> Dự án: **Car Rental Management System - Hệ thống quản lý thuê ô tô tự lái**  
> Môn: **SWP391**  
> Nhóm: **Group 2 - Ánh, Tỉnh, Bắc, Tùng, Tâm**  
> Công nghệ: **Apache NetBeans 30 + JDK 21 + Apache Tomcat 10.1.55 + Jakarta Servlet/JSP + JDBC/DAO + SQL Server/SSMS**

---

## 1. Phạm vi dự án

Dự án là **hệ thống quản lý nội bộ cho một cửa hàng/công ty cho thuê ô tô tự lái quy mô vừa**.

Đây **không phải** marketplace giống Mioto, Turo, Chungxe hoặc TravelCar.

Hệ thống tập trung vào nghiệp vụ vận hành của một đơn vị cho thuê xe, gồm:

- Quản lý xe, ảnh xe, giá thuê, trạng thái xe, lịch bảo dưỡng.
- Quản lý tài khoản và hồ sơ khách hàng.
- CCCD và bằng lái nằm trong cùng màn **Profile**.
- Kiểm tra xe trống theo ngày/giờ.
- Tạo booking, xem booking của khách, sửa/hủy booking.
- Staff/Admin xác nhận hoặc từ chối booking.
- Quản lý hợp đồng thuê xe.
- Ghi nhận đặt cọc, tiền thuê, phí phát sinh, hoàn cọc.
- Lưu dữ liệu thuế/hóa đơn ở mức nội bộ.
- Bàn giao xe, trả xe, tính phí phát sinh.
- Báo cáo doanh thu và hiệu suất sử dụng xe.

Không tự thêm chức năng ngoài scope nếu chưa được yêu cầu.

---

## 2. Rule của cô giáo

### 2.1 Sử dụng AI

- Mỗi lần dùng AI phải lưu evidence.
- Evidence có thể là ảnh chụp màn hình hoặc lịch sử chat.
- Không copy nguyên xi AI output nếu chưa hiểu.
- Phải đọc, hiểu, kiểm tra và chỉnh sửa output AI.
- AI chỉ hỗ trợ requirement, design, debug, sinh test case, sinh code skeleton.
- AI không thay thế việc hiểu nghiệp vụ của sinh viên.

### 2.2 Requirement và Design phải matching

Nếu SRS có chức năng nào thì SDS, database, class design, servlet, JSP và project tracking phải phản ánh đúng chức năng đó.

Nếu đổi tên/bỏ/gộp chức năng, phải cập nhật đồng bộ:

- Project Tracking
- SRS
- SDS
- Database design
- Tên screen
- Tên servlet
- Tên JSP
- Test case sau này

### 2.3 Không code thừa

Không viết code hoặc tạo màn hình trùng ý nghĩa.

Ví dụ bắt buộc:

- Không tạo riêng màn **Driver License**. Bằng lái nằm trong **Profile**.
- Không tạo riêng **Car Image CRUD**, **Car Price CRUD**, **Car Status CRUD**. Tất cả nằm trong **Vehicle Management**.
- Update booking và Cancel booking nằm trong **Booking Edit**.
- Người làm Login/Register/Logout phải làm luôn **User Management**.
- Không viết validation lặp lại vô nghĩa.

Validation guideline:

- Frontend/JSP/JavaScript: validate cơ bản như required, format, độ dài.
- Backend/Service: validate business rule như chống trùng lịch, phân quyền, payment, profile verification.

### 2.4 Commit và merge

- Cả nhóm phải commit code theo tuần.
- Code phải merge trước review ít nhất 3 ngày.
- Không push trực tiếp vào `main`.
- Dùng feature branch.
- Phải review trước khi merge.
- Commit message phải rõ ràng.

Branch gợi ý:

```text
main
develop
feature/auth-anh
feature/vehicle-tinh
feature/booking-bac
feature/contract-payment-tung
feature/handover-report-tam
```

Commit message gợi ý:

```text
feat(auth): add login page
feat(vehicle): add vehicle list servlet
feat(booking): add create booking skeleton
fix(payment): correct payment validation
docs(readme): update setup guide
```

---

## 3. Công nghệ bắt buộc

Dùng:

```text
Apache NetBeans 30
JDK 21
Apache Tomcat 10.1.55
Jakarta Servlet/JSP
JDBC/DAO
Microsoft SQL Server / SSMS
HTML, CSS, JavaScript, JSP
MVC / Controller-Service-DAO
```

Không dùng:

```text
Spring Boot
Hibernate/JPA
MySQL
React/Vue/Angular
Framework nặng không cần thiết
```

Tomcat 10 dùng Jakarta, do đó servlet phải import:

```java
import jakarta.servlet.*;
import jakarta.servlet.http.*;
```

Không dùng:

```java
import javax.servlet.*;
```

---

## 4. Kiến trúc bắt buộc

Dùng kiến trúc:

```text
JSP View -> Servlet Controller -> Service -> DAO/JDBC -> SQL Server
```

Quy tắc layer:

- JSP chỉ hiển thị UI, form, table, message. Không chứa business logic.
- Servlet nhận request, đọc parameter, gọi service, forward/redirect. Không viết SQL trong servlet.
- Service xử lý nghiệp vụ, rule, flow, gọi DAO.
- DAO chỉ làm việc với SQL Server bằng JDBC/PreparedStatement.
- Model chứa field, constructor, getter/setter.
- Util chứa helper như DBContext, DateUtil, PasswordUtil, FeeCalculator.

---

## 5. Package structure

Package root:

```text
com.swp391.carrental
```

Bắt buộc có:

```text
com.swp391.carrental.controller
com.swp391.carrental.controller.auth
com.swp391.carrental.controller.user
com.swp391.carrental.controller.vehicle
com.swp391.carrental.controller.booking
com.swp391.carrental.controller.contract
com.swp391.carrental.controller.payment
com.swp391.carrental.controller.handover
com.swp391.carrental.controller.report
com.swp391.carrental.controller.policy

com.swp391.carrental.service
com.swp391.carrental.dao
com.swp391.carrental.model
com.swp391.carrental.dto
com.swp391.carrental.filter
com.swp391.carrental.util
com.swp391.carrental.constant
com.swp391.carrental.exception
```

Không gom toàn bộ code vào một package.

---

## 6. Comment đầu file Java

Mọi file `.java` phải bắt đầu bằng comment:

```java
/*
 * Name: [ClassName]
 * @Author: [AuthorCode]
 * Date: [dd/MM/yyyy]
 * Version: 1.0
 * Description: [Mô tả ngắn gọn chức năng của file]
 */
```

Author code:

```text
Bùi Xuân Bắc: BacBXHE186736
Nguyễn Ngọc Ánh: AnhNNHE160896
Hoàng Ngọc Tỉnh: TinhHNHE172394
Nguyễn Lâm Tùng: TungNLHE186756
Trần Thị Minh Tâm: TamTTMHE190340
```

Ví dụ:

```java
/*
 * Name: CreateBookingServlet
 * @Author: BacBXHE186736
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Handles create booking request and forwards to create booking page.
 */
```

---

## 7. Coding Convention

### 7.1 Class / Interface

- Dùng PascalCase.
- Phải là danh từ hoặc cụm danh từ.
- Không dùng tên chung chung.

Tên tốt:

```text
BookingService
VehicleManagementServlet
PaymentRecordDAO
CustomerProfile
```

Tên không tốt:

```text
DoBooking
CarCRUD
RunProcess
Manager
```

### 7.2 Method

- Dùng camelCase.
- Bắt đầu bằng động từ.

Tên tốt:

```text
createBooking()
updateBooking()
cancelBooking()
checkAvailability()
recordPayment()
calculateAdditionalFee()
findUserByEmail()
```

Tên không tốt:

```text
booking()
run()
execute()
process()
doIt()
```

### 7.3 Variable / Field

- Dùng camelCase.
- Là danh từ/cụm danh từ.
- Tránh biến 1 ký tự, trừ i, j, k trong vòng lặp.

Tên tốt:

```text
bookingId
customerProfile
rentalPricePerDay
paymentStatus
```

Tên không tốt:

```text
x
data
obj
temp
```

### 7.4 Constant

Viết hoa và cách nhau bằng `_`:

```text
MAX_LOGIN_ATTEMPTS
DEFAULT_TAX_RATE
BOOKING_STATUS_PENDING
```

### 7.5 Format code

- Indent 4 spaces.
- Mỗi dòng khai báo tối đa 1 biến.
- Luôn dùng `{}` cho if/else/for/while.
- Dấu `{` đặt cuối dòng khai báo.
- Dấu `}` nằm riêng một dòng.
- Có khoảng trắng quanh toán tử.
- Không có khoảng trắng giữa tên method và `(`.

Đúng:

```java
if (bookingId > 0) {
    booking = bookingService.findBookingById(bookingId);
}
```

Sai:

```java
if(bookingId>0) booking=service.find(bookingId);
```

### 7.6 Switch

- Mọi switch phải có `default`.
- Nếu cố tình rơi case, thêm comment:

```java
/* falls through */
```

### 7.7 Javadoc

Phải có Javadoc cho public class và public method.

---

## 8. Quy tắc đặt tên screen/function

Tên screen/function phải ngắn gọn, đúng tiếng Anh, đúng ngữ pháp.

Không dùng:

```text
Admin Car CRUD
Customer Profile & Driver License
Car Image Status CRUD
Do Booking
Booking Update Cancel Page
```

Dùng:

```text
Vehicle Management
Profile
Create Booking
Booking Edit
My Bookings
Payment Record
Vehicle Handover
Vehicle Return
Revenue Report
Policy Settings
```

Danh sách screen/function chuẩn:

```text
Home Page
Login
Register
Logout
Profile
User Management
Role Permissions
Vehicle List
Vehicle Detail
Vehicle Management
Vehicle Availability
Maintenance Schedule
Create Booking
My Bookings
Booking Edit
Booking Calendar
Booking Management
Booking Approval
Contract Management
Contract Detail
Payment Record
Tax Invoice Settings
Policy Settings
Vehicle Handover
Vehicle Return
Additional Fees
Revenue Report
Vehicle Utilization Report
```

Quy tắc gộp:

- Customer Profile + Driver License = **Profile**.
- Car Image/Price/Status CRUD = **Vehicle Management**.
- Update Booking + Cancel Booking = **Booking Edit**.
- Booking list của Customer = **My Bookings**.
- Staff/Admin duyệt booking = **Booking Approval** hoặc **Booking Management**.

---

## 9. Phân công team

### Ánh

```text
Login
Register
Logout
Profile
User Management
Role Permissions
```

### Tỉnh

```text
Vehicle List
Vehicle Detail
Vehicle Management
Vehicle Availability
Maintenance Schedule
```

### Bắc

```text
Home Page
Create Booking
My Bookings
Booking Edit
Booking Calendar
```

### Tùng

```text
Booking Approval
Contract Management
Payment Record
Policy Settings
Tax Invoice Settings
```

### Tâm

```text
Vehicle Handover
Vehicle Return
Additional Fees
Revenue Report
Vehicle Utilization Report
```

Tâm không chỉ là thư ký. Vai trò thư ký chỉ là ghi lời cô nói trên lớp, còn Tâm vẫn phải code chức năng như mọi người.

---

## 10. Quy tắc iteration

- Mỗi iteration phải có đủ 5 thành viên.
- Mỗi thành viên có 1-2 screen/function trong mỗi iteration.
- Mỗi thành viên phải làm ít nhất 4 screen/function trong cả dự án.
- Iteration 2 là quan trọng nhất vì chứa luồng nghiệp vụ chính.
- Project Tracking viết dưới dạng screen/function/use case.
- Bảng iteration plan phải tách khỏi bảng project tracking chính.
- Không sửa cột SRS, SDS, Status, Notes nếu chưa được yêu cầu.
- Không đưa task test vào Project Tracking nếu file đó chỉ tracking screen/function.

---

## 11. Luồng nghiệp vụ chính

```text
Customer xem danh sách xe
-> Customer kiểm tra xe trống
-> Customer tạo booking
-> Staff duyệt hoặc từ chối booking
-> Staff tạo hợp đồng
-> Customer/Staff ghi nhận cọc/thanh toán
-> Staff bàn giao xe
-> Customer sử dụng xe
-> Staff nhận xe trả
-> Hệ thống tính phí phát sinh
-> Staff ghi nhận thanh toán cuối
-> Booking hoàn tất
-> Admin/Staff xem báo cáo
```

Mọi thay đổi code phải hỗ trợ luồng này.

---

## 12. Business Rules

```text
BR-01: Ngày kết thúc thuê phải sau hoặc bằng ngày bắt đầu thuê.
BR-02: Một xe không được có hai booking Confirmed/InProgress giao nhau.
BR-03: Customer phải đăng nhập trước khi tạo booking.
BR-04: Chỉ Staff/Admin được duyệt hoặc từ chối booking.
BR-05: Hợp đồng chỉ được tạo từ booking đã Confirmed.
BR-06: Xe chuyển sang Rented sau khi bàn giao.
BR-07: Phí trả xe gồm late fee, extra km fee, damage fee, cleaning fee, lost item fee.
BR-08: Booking chỉ Completed sau khi đã có vehicle return và thanh toán cần thiết.
BR-09: Xe đang Maintenance không được đặt.
BR-10: Dữ liệu thuế/hóa đơn chỉ lưu nội bộ trong phạm vi SWP391.
BR-11: Profile khách hàng phải có thông tin định danh và bằng lái.
BR-12: Booking Edit xử lý update booking và cancel booking.
BR-13: Vehicle Management xử lý thông tin xe, ảnh xe, giá thuê, trạng thái và bảo dưỡng.
```

---

## 13. Thuế, pháp lý và policy

Không cần tích hợp thật với cơ quan thuế hoặc nhà cung cấp hóa đơn điện tử.

Nhưng hệ thống phải lưu được:

```text
amountBeforeTax
taxRate
taxAmount
totalAmount
invoiceCode
invoiceDate
invoiceStatus
```

Pháp lý/profile:

```text
Customer phải cung cấp thông tin định danh và bằng lái.
Staff/Admin nên xác minh profile trước khi bàn giao.
Xe phải Available và đủ điều kiện vận hành trước khi bàn giao.
Xe có thể lưu ngày hết hạn bảo hiểm, đăng kiểm và lịch bảo dưỡng.
```

Policy hủy/đổi/no-show:

```text
Booking Pending có thể hủy.
Booking Confirmed có thể hủy trước khi bàn giao tùy policy.
Booking Edit có thể đổi xe/ngày thuê nếu checkAvailability thành công.
Staff có thể đánh dấu No-show.
```

Policy trả xe/hư hỏng/sửa chữa:

```text
Khi trả xe phải ghi final odometer, final fuel level, return condition.
finalOdometer không được nhỏ hơn initialOdometer.
extraKmFee = max(0, actualKm - allowedKm) * extraKmRate.
lateFee tính nếu thời gian trả thực tế sau thời gian kết thúc booking.
Nếu có hư hỏng, ghi damage fee, evidence note và có thể chuyển xe sang Maintenance.
```

---

## 14. Database rules

Chỉ dùng SQL Server.

Database name:

```text
CarRentalDB
```

Dùng:

```text
INT IDENTITY(1,1) cho primary key
NVARCHAR cho tiếng Việt
DATETIME2 cho thời gian
DECIMAL(18,2) cho tiền
BIT cho boolean
Foreign key cho quan hệ bảng
```

Bảng bắt buộc:

```text
users
customer_profiles
cars
car_images
bookings
rental_contracts
payments
vehicle_handovers
vehicle_returns
reviews
policy_settings
audit_logs
```

Không dùng MySQL syntax:

```sql
AUTO_INCREMENT
LIMIT
NOW()
```

Dùng SQL Server syntax:

```sql
IDENTITY(1,1)
TOP
SYSDATETIME()
```

---

## 15. SQL Server connection

Dùng `db.properties`:

```properties
db.server=localhost
db.port=1433
db.name=CarRentalDB
db.user=car_rental_user
db.password=CarRental@123456
db.encrypt=true
db.trustServerCertificate=true
```

JDBC URL:

```text
jdbc:sqlserver://localhost:1433;databaseName=CarRentalDB;encrypt=true;trustServerCertificate=true
```

Tất cả SQL có parameter phải dùng `PreparedStatement`. Không nối chuỗi SQL với input người dùng.

---

## 16. Constant bắt buộc

```text
Role
BookingStatus
CarStatus
PaymentStatus
PaymentType
ContractStatus
ProfileVerificationStatus
```

Giá trị gợi ý:

```text
Role: CUSTOMER, STAFF, ADMIN

BookingStatus:
PENDING, CONFIRMED, REJECTED, CANCELLED, IN_PROGRESS, COMPLETED, NO_SHOW, PENDING_SETTLEMENT

CarStatus:
AVAILABLE, RESERVED, RENTED, MAINTENANCE, INACTIVE

PaymentStatus:
PENDING, SUCCESS, FAILED, REFUNDED

PaymentType:
DEPOSIT, RENTAL_FEE, ADDITIONAL_FEE, REFUND

ContractStatus:
DRAFT, ACTIVE, COMPLETED, CANCELLED

ProfileVerificationStatus:
PENDING, VERIFIED, REJECTED
```

---

## 17. Servlet bắt buộc

```text
HomeServlet
LoginServlet
RegisterServlet
LogoutServlet
ProfileServlet
UserManagementServlet
RolePermissionsServlet
VehicleListServlet
VehicleDetailServlet
VehicleManagementServlet
VehicleAvailabilityServlet
MaintenanceScheduleServlet
CreateBookingServlet
MyBookingsServlet
BookingEditServlet
BookingCalendarServlet
BookingManagementServlet
BookingApprovalServlet
ContractManagementServlet
ContractDetailServlet
PaymentRecordServlet
TaxInvoiceSettingsServlet
PolicySettingsServlet
VehicleHandoverServlet
VehicleReturnServlet
AdditionalFeesServlet
RevenueReportServlet
VehicleUtilizationReportServlet
TestDatabaseServlet
```

Mỗi servlet phải:

- Dùng `@WebServlet`
- Dùng `jakarta.servlet`
- Có doGet/doPost nếu cần
- Gọi service layer
- Forward sang JSP
- Không chứa SQL

---

## 18. JSP bắt buộc

Đặt trong:

```text
src/main/webapp/WEB-INF/views/
```

Cấu trúc:

```text
layout/header.jsp
layout/footer.jsp
layout/sidebar.jsp

auth/login.jsp
auth/register.jsp
auth/forgot-password.jsp

user/profile.jsp
user/user-management.jsp
user/role-permissions.jsp

vehicle/vehicle-list.jsp
vehicle/vehicle-detail.jsp
vehicle/vehicle-management.jsp
vehicle/vehicle-availability.jsp
vehicle/maintenance-schedule.jsp

booking/home.jsp
booking/create-booking.jsp
booking/my-bookings.jsp
booking/booking-edit.jsp
booking/booking-calendar.jsp
booking/booking-management.jsp
booking/booking-approval.jsp

contract/contract-management.jsp
contract/contract-detail.jsp

payment/payment-record.jsp
payment/tax-invoice-settings.jsp

handover/vehicle-handover.jsp
handover/vehicle-return.jsp
handover/additional-fees.jsp

report/revenue-report.jsp
report/vehicle-utilization-report.jsp

policy/policy-settings.jsp

error/404.jsp
error/500.jsp
error/access-denied.jsp
```

Mỗi JSP phải có:

- Header include
- Footer include
- Page title
- Description rõ ràng
- UI đơn giản
- Không có business logic

---

## 19. URL rules

Dùng URL rõ ràng:

```text
/
/login
/register
/logout
/profile
/users
/roles
/vehicles
/vehicles/detail
/vehicles/manage
/vehicles/availability
/maintenance
/bookings/create
/bookings/my
/bookings/edit
/bookings/calendar
/bookings/manage
/bookings/approval
/contracts
/contracts/detail
/payments/record
/tax-invoice-settings
/policies
/handovers
/returns
/additional-fees
/reports/revenue
/reports/vehicle-utilization
/test-db
```

Không dùng URL xấu:

```text
/doCarCRUD
/adminCarCrud
/customerProfileAndDriverLicense
/updateCancelBookingPage
```

---

## 20. Quy tắc tài liệu

Tài liệu phải khớp với code.

SRS phải có:

- Actors
- Use cases
- Screen/function list
- Business rules
- System messages
- NFRs
- Tax/legal/policy requirements
- Khảo sát 5 đối thủ

SDS phải có:

- Architecture
- Package diagram
- Database design
- State transition
- Class/sequence placeholder
- Policy design impact

Project Tracking phải:

- Viết screen/function như use case.
- Tên screen/function rõ ràng.
- Một screen/function có một main owner.
- Chia đều screen/function cho team.
- Bảng iteration plan tách khỏi bảng tracking chính.
- Không đưa task test nếu file chỉ tracking screen/function.

---

## 21. Bối cảnh khảo sát 5 đối thủ

Requirement rút ra từ:

```text
1. Green Future
2. ALoGiaRe - thuê xe tự lái Thạch Thất
3. Mioto / Kanow / TravelCar
4. Văn Minh Corporation
5. Dịch vụ thuê xe tự lái/có lái Thạch Hòa - Hòa Lạc
```

Điểm chung:

- Cần quản lý xe.
- Cần booking/availability.
- Cần CCCD/bằng lái khách hàng.
- Có đặt cọc/thanh toán.
- Có hợp đồng.
- Bàn giao/trả xe cần km, nhiên liệu/pin, tình trạng xe, ảnh/note.
- Vấn đề chính: trùng lịch, quản lý thủ công, khó theo dõi cọc/thanh toán, khó báo cáo.

---

## 22. Quy tắc khi AI sinh code

Khi sinh code:

- Không sinh một file khổng lồ.
- Không bỏ package structure.
- Không bỏ comment đầu file.
- Không bỏ Javadoc.
- Không dùng MySQL.
- Không tự thêm feature ngoài scope.
- Hỏi trước khi đổi kiến trúc.
- Giữ naming convention và folder structure.
- Không rewrite code đang chạy ổn nếu không cần.
- Chỉ sửa module được yêu cầu.
- Nếu sửa file chung như `pom.xml`, `DBContext`, `schema.sql`, `header.jsp`, phải giải thích ảnh hưởng.

Khi fix code:

- Tìm root cause trước.
- Sửa tối thiểu.
- Giữ format.
- Không làm hỏng module khác.
- Giải thích ngắn gọn file đã sửa.

Khi tạo SQL:

- Dùng SQL Server syntax.
- Thêm foreign key nếu cần.
- Dùng `NVARCHAR` cho tiếng Việt.
- Java DAO dùng `PreparedStatement`.

---

## 23. Definition of Done cho feature

Một feature chỉ xong khi:

```text
[ ] Dùng đúng tên screen/function
[ ] Đúng owner/module
[ ] Có servlet
[ ] Có JSP
[ ] Có service skeleton hoặc logic
[ ] Có DAO skeleton hoặc logic nếu liên quan database
[ ] Có model/DTO nếu cần
[ ] Tuân thủ business rules
[ ] Không có SQL trong JSP
[ ] Không có business logic trong JSP
[ ] JSP không gọi DAO trực tiếp
[ ] Code đúng comment và naming convention
[ ] Chạy được trên Tomcat 10.1.55
[ ] Không thêm feature ngoài scope
```

---

## 24. Chỉ dẫn cuối cùng

Luôn giữ project:

```text
Đúng requirement
Tên rõ ràng
MVC chuẩn
Tương thích SQL Server
Ít conflict giữa các thành viên
Tuân thủ rule của cô
Code dễ đọc
Có tiến độ theo tuần
```

Không over-engineer. Không đổi stack. Không thêm tính năng ngoài scope.
