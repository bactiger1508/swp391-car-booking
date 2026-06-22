# QUY TẮC DỰ ÁN SWP391 CHO ANTIGRAVITY / OPUS

> **BẮT BUỘC:** Mỗi lần Antigravity/Opus làm việc với project này, phải đọc file này trước và tuân thủ toàn bộ rule bên dưới.  
> Dự án: **CarPro Rental Management System - Hệ thống quản lý thuê ô tô tự lái**  
> Môn: **SWP391**  
> Nhóm: **Group 2 - Ánh, Tỉnh, Bắc, Tùng, Tâm**  
> Công nghệ: **Apache NetBeans 30 + JDK 21 + Apache Tomcat 10.1.55 + Jakarta Servlet/JSP + JDBC/DAO + SQL Server/SSMS**

---

## 1. Phạm vi dự án

Dự án là **hệ thống quản lý nội bộ cho một cửa hàng/công ty cho thuê ô tô tự lái quy mô vừa** (theo SRS: "CarPro Rental Management System... medium-sized self-drive car rental business").

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

**Out of Scope** (lấy đúng theo SRS, không tự thêm/bớt):

```text
- Không hoạt động như marketplace kết nối nhiều chủ xe với khách hàng.
- Không hỗ trợ thuê xe có lái (chauffeur-based rental).
- Không có GPS tracking, real-time vehicle telematics.
- Không có automatic vehicle damage detection.
- Không tích hợp accounting software.
- Không xử lý insurance claim.
- Không có AI-based price prediction.
- Payment Gateway chỉ là external supporting system: project chỉ gửi dữ liệu
  payment/refund và ghi nhận kết quả trả về trong hệ thống CarPro, không
  implement payment gateway thật.
```

Không tự thêm chức năng ngoài scope nếu chưa được yêu cầu.

---

## 2. Rule của cô giáo

### 2.1 Sử dụng AI

- Mỗi lần dùng AI phải lưu evidence (lịch sử chat với AI) để gửi cho cô.
- Evidence có thể là ảnh chụp màn hình hoặc lịch sử chat.
- Không copy nguyên xi AI output nếu chưa hiểu. Phải hiểu luồng trước khi dùng.
- Phải đọc, hiểu, kiểm tra và chỉnh sửa output AI.
- AI không thay thế việc hiểu nghiệp vụ của sinh viên.

AI hỗ trợ theo từng Iteration (không dùng AI ngoài phạm vi của Iteration đó nếu chưa được yêu cầu):

```text
Iteration 1: AI assist document   (yêu cầu, SRS/SDS, mô tả)
Iteration 2: AI assist debug      (sửa lỗi, review code)
Iteration 3: AI gen test case     (sinh test case)
```

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

Document phải tham khảo cả 2 nguồn **CMS** và **FLM**. Riêng System Test bên FLM không có sẵn thì phải lấy/đối chiếu từ CMS.

### 2.2.1 RACI

Mỗi tài liệu/quy trình có phân vai trò RACI:

```text
R - Responsible: bắt buộc phải có (người trực tiếp thực hiện)
A - Accountable: bắt buộc phải có (người chịu trách nhiệm cuối cùng)
C - Consulted: optional (người được hỏi ý kiến)
I - Informed: optional (người được thông báo kết quả)
```

R và A bắt buộc phải khai báo rõ cho mỗi screen/function; C và I không bắt buộc.

### 2.3 Không code thừa

Không viết code hoặc tạo màn hình trùng ý nghĩa.

Ví dụ bắt buộc:

- Không tạo riêng màn **Driver License**. Bằng lái nằm trong **Update Profile** / **Verify Customer Profile**.
- Không tạo riêng **Car Image CRUD**, **Car Price CRUD**, **Car Status CRUD**. Tất cả nằm trong **Create Vehicle Profile** / **Update Vehicle Profile**.
- **Update Booking** và **Cancel Booking** là 2 function tách riêng theo Project Tracking, không gộp chung "Booking Edit".
- **Record Deposit Payment** và **Record Rental Payment** là 2 function tách riêng, không gộp chung "Payment Record".
- **Process Handover** và **Process Return** là 2 function tách riêng, không gộp chung.
- Người làm Login/Register phải làm luôn **View User List**.
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
- Không viết tắt, trừ từ viết tắt quá phổ biến (URL, HTML, ID, DAO, DTO).

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
- Mỗi dòng khai báo tối đa 1 biến. Đặt khai báo biến ở đầu khối code `{}`.
- Luôn dùng `{}` cho if/else/for/while, kể cả khi block chỉ có 1 dòng lệnh.
- Dấu `{` đặt cuối dòng khai báo.
- Dấu `}` nằm riêng một dòng.
- Có khoảng trắng quanh toán tử nhị phân (`+`, `-`, `=`, `&&`, ...).
- Có khoảng trắng sau dấu phẩy `,` trong danh sách tham số.
- Có khoảng trắng sau từ khóa (`if`, `while`, `for`, `switch`) trước dấu `(`.
- Không có khoảng trắng giữa tên method và `(`.

Đúng:

```java
if (bookingId > 0) {
    booking = bookingService.findBookingById(bookingId);
}

public void recordPayment(int bookingId, double amount) {
    ...
}
```

Sai:

```java
if(bookingId>0) booking=service.find(bookingId);
public void recordPayment(int bookingId,double amount){...}
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

Tên screen/function phải ngắn gọn, đúng tiếng Anh, đúng ngữ pháp, lấy đúng theo **Project Tracking** (sheet `RMS`).

Không dùng:

```text
Admin Car CRUD
Customer Profile & Driver License
Car Image Status CRUD
Do Booking
Booking Update Cancel Page
```

Danh sách function chuẩn (theo Project Tracking, 34 function, cột `Function`):

```text
Login Account
Register Account
View User List
Update User Account
Lock User Account
Update Profile
Verify Customer Profile

View Vehicle Catalog
View Vehicle Detail
View Vehicle Management List
Search Vehicle
Create Vehicle Profile
Update Vehicle Profile
Record Vehicle Maintenance

Create Booking
View Booking
Check Vehicle Availability
Update Booking
Cancel Booking
Process Booking Request
View Booking Calendar
View Booking Policy

Prepare Contract
Configure Payment Method
View Contract
Record Deposit Payment
Record Rental Payment
Update Contract
Configure Rental Policy

Process Handover
Process Return
Record Additional Fee
Settle Deposit
Record Refund
View Revenue Report
View Vehicle Utilization Report
```

Quy tắc gộp (không tách nhỏ hơn các function này):

- Update User Account và Lock User Account là 2 function riêng, không gộp.
- Update Profile và Verify Customer Profile là 2 function riêng (Update = Customer tự sửa, Verify = Staff/Admin xác minh).
- Create/Update Vehicle Profile gồm thông tin xe, ảnh xe, giá thuê, deposit, status. Không tách riêng Car Image/Price/Status CRUD.
- Record Vehicle Maintenance xử lý bảo dưỡng/đăng kiểm/bảo hiểm xe.
- Update Booking và Cancel Booking là 2 function riêng trong Project Tracking (không gộp chung "Booking Edit" như trước).
- Process Booking Request là function của Staff/Admin để duyệt/từ chối booking (không tách riêng "Booking Approval").
- Record Deposit Payment và Record Rental Payment là 2 function riêng (không gộp chung "Payment Record").
- Process Handover và Process Return là 2 function riêng (không gộp "Vehicle Handover"/"Vehicle Return").
- Settle Deposit là function riêng xử lý hoàn cọc/trừ phí sau khi trả xe, khác với Record Refund (Refund tổng quát hơn, dùng ở Iteration 3).

---

## 9. Phân công team

Theo cột `In Charge` trong Project Tracking. Vai trò module:

```text
Ánh - Auth/Profile + User Account
Tỉnh - Vehicle
Bắc - Booking & Availability
Tùng - Contract & Payment/Policy
Tâm - Handover/Return/Fee/Report
```

### Ánh

```text
Login Account            (Iter 1)
Register Account         (Iter 1)
View User List           (Iter 1)
Update Profile           (Iter 2)
Verify Customer Profile  (Iter 2)
Update User Account      (Iter 3)
Lock User Account        (Iter 3)
```

### Tỉnh

```text
View Vehicle Catalog            (Iter 1)
View Vehicle Detail             (Iter 1)
View Vehicle Management List    (Iter 1)
Search Vehicle                  (Iter 2)
Create Vehicle Profile          (Iter 2)
Update Vehicle Profile          (Iter 2)
Record Vehicle Maintenance      (Iter 3)
```

### Bắc

```text
Create Booking            (Iter 1)
View Booking               (Iter 1)
Check Vehicle Availability (Iter 2)
Update Booking              (Iter 2)
Cancel Booking               (Iter 2)
Process Booking Request      (Iter 2)
View Booking Calendar        (Iter 3)
View Booking Policy          (Iter 3)
```

### Tùng

```text
Prepare Contract          (Iter 1)
Configure Payment Method   (Iter 1)
View Contract               (Iter 2)
Record Deposit Payment       (Iter 2)
Record Rental Payment        (Iter 2)
Update Contract              (Iter 3)
Configure Rental Policy      (Iter 3)
```

### Tâm

```text
Process Handover         (Iter 1)
Process Return             (Iter 2)
Record Additional Fee       (Iter 2)
Settle Deposit               (Iter 2)
Record Refund                 (Iter 3)
View Revenue Report            (Iter 3)
View Vehicle Utilization Report (Iter 3)
```

Tâm không chỉ là thư ký. Vai trò thư ký chỉ là ghi lời cô nói trên lớp, còn Tâm vẫn phải code chức năng như mọi người.

---

## 10. Quy tắc iteration

Theo sheet `Iteration Plan` trong Project Tracking:

```text
Iteration 1 - Foundation and first runnable screens
  Ánh: Login Account, Register Account, View User List
  Tỉnh: View Vehicle Catalog, View Vehicle Detail, View Vehicle Management List
  Bắc: Create Booking, View Booking
  Tùng: Prepare Contract, Configure Payment Method
  Tâm: Process Handover

Iteration 2 - Main rental business flow (quan trọng nhất)
  Ánh: Update Profile, Verify Customer Profile
  Tỉnh: Search Vehicle, Create Vehicle Profile, Update Vehicle Profile
  Bắc: Check Vehicle Availability, Update Booking, Cancel Booking, Process Booking Request
  Tùng: View Contract, Record Deposit Payment, Record Rental Payment
  Tâm: Process Return, Record Additional Fee, Settle Deposit

Iteration 3 - Final policies, settlement, maintenance and reports
  Ánh: Update User Account, Lock User Account
  Tỉnh: Record Vehicle Maintenance
  Bắc: View Booking Calendar, View Booking Policy
  Tùng: Update Contract, Configure Rental Policy
  Tâm: Record Refund, View Revenue Report, View Vehicle Utilization Report
```

Nguyên tắc:

- Mỗi iteration phải có đủ 5 thành viên ("All 5 members have assigned work").
- Mỗi thành viên có 1-4 function trong mỗi iteration (Bắc/Tâm có 3-4 ở Iter 2/3, còn lại thường 2-3).
- Mỗi thành viên phải làm đủ số function được phân công trong cả 3 iteration (xem mục 9).
- Iteration 2 là quan trọng nhất vì chứa luồng nghiệp vụ chính (availability, process booking, payment, return, settle deposit).
- Project Tracking viết dưới dạng screen/function trong sheet `RMS`, mỗi dòng gồm: `Function, Description, Roles/Actors, In Charge, Iter, SRS, SDS, Status, Notes`.
- Bảng `Iteration Plan` (Focus, Expected Demo, Participation Rule) phải tách riêng sheet/bảng khỏi sheet `RMS` chính, không gộp chung.
- Cột `Status` lấy giá trị từ sheet `_Dropdowns`: `To do`, `Doing`, `Done`, `Cancelled`.
- Không sửa cột SRS, SDS, Status, Notes nếu chưa được yêu cầu.
- Không đưa task test vào Project Tracking (sheet `RMS` chỉ tracking screen/function, test case nằm ở file System Test riêng).

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

Lấy đúng theo SRS Document (`SWP391_SRS_Document.docx`, mục 5.1 Business Rules). Không tự đặt số BR khác, không tự diễn giải lại nội dung.

```text
BR01: A Guest can view the vehicle catalog, search/filter vehicles, view vehicle details,
      check vehicle availability, view booking policy, and register a customer account
      without logging in.
BR02: A Customer must log in before creating a booking request, updating a booking,
      cancelling a booking, viewing personal booking details, viewing contract details,
      or making payment.
BR03: A Customer can only view and manage bookings, contracts, payments, refunds, and
      deposit settlement records that belong to their own account.
BR04: A Customer must provide required profile information and driver license information
      before the booking can be fully processed by Staff or Admin.
BR05: Staff or Admin can verify customer profile and driver license information. A booking
      may be rejected or delayed if the customer profile is incomplete, invalid, or not
      verified.
BR06: A vehicle can be booked only if its status is Available and it is not already
      reserved or rented during the requested rental period.
BR07: The system must prevent overlapping bookings for the same vehicle during the same
      rental period.
BR08: The rental return date must be later than the rental start date. The system must
      reject invalid rental date ranges.
BR09: A booking is created with Pending status after the Customer submits a valid booking
      request.
BR10: Staff or Admin processes a pending booking request based on vehicle availability,
      customer profile validity, and rental policy.
BR11: A Customer can update or cancel a booking only when the booking status and booking
      policy allow it.
BR12: A cancelled booking must no longer reserve the vehicle for the selected rental period.
BR13: A confirmed booking may require a deposit payment before contract preparation or
      vehicle handover, depending on rental policy.
BR14: A rental contract can only be prepared from a confirmed booking.
BR15: Contract information can only be updated by Staff or Admin when the contract is
      still editable according to business rules.
BR16: Deposit payment and rental payment must be recorded separately to support payment
      tracking and deposit settlement.
BR17: Vehicle handover can only be processed after the booking and required payment
      conditions are satisfied.
BR18: Handover records must include initial odometer, fuel level, vehicle condition,
      accessories, evidence images, handover time, and staff notes.
BR19: After successful handover, the booking status becomes In Progress and the vehicle
      status becomes Rented.
BR20: Vehicle return must record final odometer, fuel level, return time, vehicle condition,
      damage notes, missing items, and supporting evidence.
BR21: Additional fees may be recorded for late return, extra kilometer usage, fuel shortage,
      vehicle damage, cleaning, or lost items.
BR22: The system calculates additional fees based on rental policy and return information
      recorded by Staff or Admin.
BR23: Deposit settlement is performed after vehicle return and additional fee calculation.
BR24: If the deposit is greater than the additional fees, the remaining amount must be
      refunded to the Customer.
BR25: If the deposit is equal to the additional fees, no additional payment or refund is
      required.
BR26: If the additional fees are greater than the deposit, the Customer must pay the
      remaining amount.
BR27: A booking can be marked as Completed only after vehicle return and required
      payment/deposit settlement are finalized.
BR28: Vehicles with Maintenance or Inactive status must not be available for new bookings.
BR29: Staff can process vehicle handover to record initial vehicle condition, fuel level,
      mileage, accessories, images, and handover notes.
BR30: Staff can process vehicle return to record return time, final mileage, fuel level,
      vehicle condition, damage notes, and supporting evidence.
BR31: Staff can record additional charges such as late return fee, cleaning fee, fuel
      charge, damage compensation, or other penalties.
BR32: Staff can settle the deposit after return by refunding, deducting additional fees,
      or requesting extra payment from the customer.
BR33: Staff or Admin can view revenue reports by time period, payment type, booking status,
      and additional fees.
BR34: Staff or Admin can view vehicle usage, rental frequency, idle vehicles, and
      most-rented vehicles reports.
BR35: Each email address can only be registered for one customer account.
BR36: A locked account cannot log into the system.
BR37: Only Admin can lock or unlock user accounts.
```

Mapping BR → function (để biết BR nào áp dụng cho module nào khi code):

```text
BR01, BR35           -> Register Account, Login Account
BR36, BR37            -> Login Account, Update User Account, Lock User Account
BR02, BR03, BR04, BR05 -> Update Profile, Verify Customer Profile
BR06, BR07, BR08, BR28 -> Check Vehicle Availability, Create Vehicle Profile, Update Vehicle Profile
BR09, BR10            -> Create Booking, Process Booking Request
BR11, BR12             -> Update Booking, Cancel Booking
BR13, BR14              -> Prepare Contract
BR15                    -> Update Contract
BR16                    -> Record Deposit Payment, Record Rental Payment
BR17, BR18, BR19          -> Process Handover
BR20, BR21, BR22           -> Process Return, Record Additional Fee
BR23, BR24, BR25, BR26      -> Settle Deposit
BR27                          -> Process Return, Settle Deposit (điều kiện Completed)
BR29, BR30, BR31, BR32         -> Process Handover, Process Return, Record Additional Fee, Settle Deposit
BR33                              -> View Revenue Report
BR34                               -> View Vehicle Utilization Report
```

---

## 13. Thuế, pháp lý và policy

Lấy đúng theo SRS Document, mục 5.3 Other Requirements. Không tự bịa thêm rule khác.

### 13.1 Tax, Invoice and Payment Policy (TAX)

Hệ thống không cần tích hợp thật với hệ thống hóa đơn điện tử quốc gia hoặc cơ quan thuế ở giai đoạn này. Tuy nhiên cấu trúc dữ liệu thanh toán phải được thiết kế để lưu deposit, rental fee, additional fee, refund, và thông tin liên quan hóa đơn nếu áp dụng. Văn bản tham chiếu: Nghị định 181/2025/NĐ-CP về Luật Thuế GTGT và Nghị định 70/2025/NĐ-CP về hóa đơn, chứng từ.

```text
TAX-01: Payment records must store paymentType, including Deposit, RentalFee,
        AdditionalFee, and Refund.
TAX-02: If tax or invoice management is applied, the system should store
        amountBeforeTax, taxRate, taxAmount, and totalAmount.
TAX-03: taxRate must not be hard-coded in the source code. It should be configurable
        in policy or system settings to support future changes.
TAX-04: If invoices are issued, the system should store invoiceCode, invoiceDate,
        and invoiceStatus for internal tracking.
TAX-05: Within the scope of this academic project, the system only records
        invoice-related data and does not directly integrate with a real
        e-invoice system.
```

### 13.2 Legal and Vehicle Operation Requirements (LEGAL)

Văn bản tham chiếu: Luật số 36/2024/QH15 về Trật tự, an toàn giao thông đường bộ (hiệu lực từ 01/01/2025), và Nghị định 67/2023/NĐ-CP về bảo hiểm bắt buộc trách nhiệm dân sự chủ xe cơ giới.

```text
LEGAL-01: The Customer must provide valid identity information and driver license
          information before receiving the vehicle.
LEGAL-02: Staff/Admin must review or verify the customer profile before vehicle
          handover.
LEGAL-03: The vehicle must be in Available status and meet operational conditions
          before handover.
LEGAL-04: The system should store insurance expiration date, vehicle inspection
          expiration date, and maintenance schedule for internal management.
LEGAL-05: The rental contract should include customer information, vehicle
          information, rental period, rental price, deposit amount,
          responsibilities of both parties, and additional fee terms.
```

### 13.3 Cancellation, Change and No-show Policy

```text
Customer cancels booking before Staff confirmation
  -> Customer can cancel. Status -> Cancelled, no fee charged.

Customer cancels booking after it has been confirmed
  -> Allowed before vehicle pickup time. Cancellation fee or deposit deduction
     may apply depending on rental policy.

Customer requests to change vehicle
  -> Staff checks replacement vehicle availability. System updates carId and
     recalculates rental fee/deposit if needed.

Customer requests to change rental dates
  -> System must run checkVehicleAvailability again. If new period overlaps
     another booking, the change is not allowed.

The shop cannot provide the booked vehicle
  -> Staff may assign an equivalent or higher-class replacement vehicle, or
     refund the deposit to the Customer.

Customer does not arrive to receive the vehicle (no-show)
  -> Staff may change booking status to No-show or Cancelled and process the
     deposit according to rental policy.
```

### 13.4 Return, Damage and Repair Policy (RETURN)

```text
RETURN-01: When the vehicle is returned, Staff must enter finalOdometer,
           finalFuelLevel, and returnCondition.
RETURN-02: If finalOdometer is less than initialOdometer, the system must
           display a data error message.
RETURN-03: extraKmFee = max(0, actualKm - allowedKm) * extraKmRate.
RETURN-04: lateFee is calculated when the actual return time is later than the
           booking endDate.
RETURN-05: If damage or accident is detected, Staff records damageFee, evidence
           images/notes, and may change the vehicle status to Maintenance.
RETURN-06: A booking can only be marked as Completed after VehicleReturn has
           been recorded and all required payments have been completed.
```

Legal references (đầy đủ, dùng để trích dẫn trong document): Luật số 36/2024/QH15 (Trật tự, an toàn giao thông đường bộ); Nghị định 67/2023/NĐ-CP (bảo hiểm bắt buộc TNDS xe cơ giới); Nghị định 181/2025/NĐ-CP (Luật Thuế GTGT); Nghị định 70/2025/NĐ-CP (hóa đơn, chứng từ).

### 13.5 System Messages

Lấy đúng theo SRS Document, mục 5.2 System Messages. Code message phải dùng đúng định dạng `MSG-<MODULE>-<NN>`, không tự đặt mã khác khi code servlet/service trả message cho người dùng.

```text
MSG-AUTH-01  Success  Register Account            Account registered successfully. Please log in to continue.
MSG-AUTH-02  Error    Register Account            This email or phone number is already registered.
MSG-AUTH-03  Error    Register Account            Please fill in all required registration information.
MSG-AUTH-04  Success  Login Account                Login successful.
MSG-AUTH-05  Error    Login Account                Invalid email or password.
MSG-AUTH-06  Error    Login Account                Your account has been locked. Please contact the administrator.

MSG-PRO-01   Success  Update Profile               Profile updated successfully.
MSG-PRO-02   Warning  Update Profile               Your profile is incomplete. Please update your identity and driver license information.
MSG-PRO-03   Success  Verify Customer Profile      Customer profile verified successfully.
MSG-PRO-04   Error    Verify Customer Profile      Customer profile verification was rejected. Please update the required information.

MSG-VEH-01   Success  Vehicle Catalog              Vehicle list loaded successfully.
MSG-VEH-02   Error    Vehicle Catalog              No vehicles match the selected search criteria.
MSG-VEH-03   Success  Vehicle Management           Vehicle profile saved successfully.
MSG-VEH-04   Error    Vehicle Management           Vehicle information is invalid or incomplete.
MSG-VEH-05   Warning  Vehicle Status               This vehicle is currently not available for booking.

MSG-BK-01    Success  Check Vehicle Availability   The vehicle is available for the selected rental period.
MSG-BK-02    Error    Check Vehicle Availability   The vehicle is not available for the selected rental period. Please choose another vehicle or rental period.
MSG-BK-03    Error    Create Booking               The return date must be later than the rental start date.
MSG-BK-04    Success  Create Booking               Booking request created successfully and is waiting for staff processing.
MSG-BK-05    Success  Update Booking               Booking updated successfully.
MSG-BK-06    Error    Update Booking               This booking cannot be updated because its current status does not allow modification.
MSG-BK-07    Success  Cancel Booking               Booking cancelled successfully.
MSG-BK-08    Error    Cancel Booking               This booking cannot be cancelled according to the booking policy.
MSG-BK-09    Success  Process Booking Request      Booking request processed successfully.
MSG-BK-10    Warning  Process Booking Request      Customer profile is incomplete or not verified. Please review before processing the booking.

MSG-CON-01   Success  Prepare Contract             Rental contract prepared successfully.
MSG-CON-02   Error    Prepare Contract             A rental contract can only be prepared from a confirmed booking.
MSG-CON-03   Success  Update Contract              Contract updated successfully.
MSG-CON-04   Error    Update Contract              This contract cannot be updated because its current status does not allow modification.

MSG-PAY-01   Success  Record Deposit Payment       Deposit payment recorded successfully.
MSG-PAY-02   Success  Record Rental Payment        Rental payment recorded successfully.
MSG-PAY-03   Error    Payment                      Payment failed. Please try again or choose another payment method.
MSG-PAY-04   Warning  Payment                      Payment is pending confirmation from the payment gateway.
MSG-PAY-05   Success  Record Refund                Refund recorded successfully.

MSG-HR-01    Success  Process Handover             Vehicle handover recorded successfully.
MSG-HR-02    Error    Process Handover             Vehicle handover cannot be processed before the required booking, contract, or payment conditions are satisfied.
MSG-HR-03    Success  Process Return               Vehicle return recorded successfully.
MSG-HR-04    Success  Record Additional Fee        Additional fee recorded successfully.
MSG-HR-05    Success  Settle Deposit               Deposit settlement completed successfully.
MSG-HR-06    Warning  Settle Deposit               Additional fees exceed the deposit amount. The customer must pay the remaining amount.

MSG-RPT-01   Success  View Revenue Report               Revenue report generated successfully.
MSG-RPT-02   Success  View Vehicle Utilization Report    Vehicle utilization report generated successfully.

MSG-SYS-01   Error    Authorization                You do not have permission to access this function.
MSG-SYS-02   Error    System                        An unexpected error occurred. Please try again later.
```

### 13.6 Non-Functional Requirements (NFR)

Lấy đúng theo SRS Document, mục 4.2 Quality Attributes. Dùng làm tiêu chí khi review code/feature.

```text
Usability       : Giao diện đơn giản, dễ dùng cho Guest/Customer/Staff/Admin; menu/page rõ ràng.
Performance     : Login, search vehicle, view detail, load booking list, filter report phải
                  phản hồi trong 3 giây ở điều kiện sử dụng bình thường.
Availability    : Hệ thống khả dụng trong giờ vận hành bình thường, trừ maintenance định kỳ
                  hoặc lỗi kỹ thuật bất ngờ.
Reliability     : Không double-booking, lưu đúng transaction, không mất dữ liệu rental quan
                  trọng sau khi submit thành công.
Security        : Password phải được mã hóa trước khi lưu; trang hạn chế cần login; mỗi actor
                  chỉ truy cập được function theo authorization matrix.
Data Integrity  : Vehicle status, booking status, payment status, contract status phải nhất
                  quán sau mỗi business operation liên quan.
Maintainability : Code theo cấu trúc Controller/Servlet, DAO, Model, View; business logic
                  không trộn vào presentation code.
Scalability     : Database và cấu trúc app phải hỗ trợ mở rộng thêm xe, account, policy, loại
                  report mới mà không cần redesign lớn.
Compatibility   : Chạy trên Apache Tomcat với Java Servlet/JSP, JDBC/DAO, SQL Server theo
                  đúng môi trường project.
Auditability    : Các hành động quan trọng (login, process booking, record payment, handover,
                  return, settle deposit, lock account) phải traceable qua dữ liệu hệ thống.
Backup/Recovery : Hỗ trợ backup database định kỳ; dữ liệu quan trọng phục hồi được khi cần.
Privacy         : Identity info và driver license image chỉ truy cập được bởi role được phép
                  (Customer chính chủ, Staff, Admin) theo permission rule.
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

Đặt tên servlet theo đúng function trong Project Tracking (PascalCase + "Servlet"):

```text
HomeServlet
LoginServlet
RegisterServlet
LogoutServlet
ViewUserListServlet
UpdateUserAccountServlet
LockUserAccountServlet
UpdateProfileServlet
VerifyCustomerProfileServlet

ViewVehicleCatalogServlet
ViewVehicleDetailServlet
ViewVehicleManagementListServlet
SearchVehicleServlet
CreateVehicleProfileServlet
UpdateVehicleProfileServlet
RecordVehicleMaintenanceServlet

CreateBookingServlet
ViewBookingServlet
CheckVehicleAvailabilityServlet
UpdateBookingServlet
CancelBookingServlet
ProcessBookingRequestServlet
ViewBookingCalendarServlet
ViewBookingPolicyServlet

PrepareContractServlet
ConfigurePaymentMethodServlet
ViewContractServlet
RecordDepositPaymentServlet
RecordRentalPaymentServlet
UpdateContractServlet
ConfigureRentalPolicyServlet

ProcessHandoverServlet
ProcessReturnServlet
RecordAdditionalFeeServlet
SettleDepositServlet
RecordRefundServlet
ViewRevenueReportServlet
ViewVehicleUtilizationReportServlet

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

user/view-user-list.jsp
user/update-user-account.jsp
user/lock-user-account.jsp
user/update-profile.jsp
user/verify-customer-profile.jsp

vehicle/view-vehicle-catalog.jsp
vehicle/view-vehicle-detail.jsp
vehicle/view-vehicle-management-list.jsp
vehicle/search-vehicle.jsp
vehicle/create-vehicle-profile.jsp
vehicle/update-vehicle-profile.jsp
vehicle/record-vehicle-maintenance.jsp

booking/create-booking.jsp
booking/view-booking.jsp
booking/check-vehicle-availability.jsp
booking/update-booking.jsp
booking/cancel-booking.jsp
booking/process-booking-request.jsp
booking/view-booking-calendar.jsp
booking/view-booking-policy.jsp

contract/prepare-contract.jsp
contract/configure-payment-method.jsp
contract/view-contract.jsp
contract/update-contract.jsp

payment/record-deposit-payment.jsp
payment/record-rental-payment.jsp
payment/settle-deposit.jsp
payment/record-refund.jsp

policy/configure-rental-policy.jsp

handover/process-handover.jsp
handover/process-return.jsp
handover/record-additional-fee.jsp

report/view-revenue-report.jsp
report/view-vehicle-utilization-report.jsp

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
/users
/users/update
/users/lock
/profile/update
/profile/verify

/vehicles
/vehicles/detail
/vehicles/manage
/vehicles/search
/vehicles/create
/vehicles/update
/vehicles/maintenance

/bookings/create
/bookings/view
/bookings/availability
/bookings/update
/bookings/cancel
/bookings/process
/bookings/calendar
/bookings/policy

/contracts/prepare
/contracts/payment-method
/contracts/view
/contracts/update

/payments/deposit
/payments/rental
/payments/settle-deposit
/payments/refund

/policies/rental

/handovers/process
/returns/process
/fees/additional

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

Project Tracking phải (theo cấu trúc file `SWP391_Project_Tracking.xlsx` thực tế):

- Sheet `RMS`: bảng tracking chính, mỗi dòng là 1 function với cột `Function, Description, Roles/Actors, In Charge, Iter, SRS, SDS, Status, Notes`.
- Sheet `Iteration Plan`: bảng riêng với cột `Iteration, Focus, Expected Demo, Participation Rule`, tách hoàn toàn khỏi sheet `RMS`.
- Sheet `_Dropdowns`: định nghĩa danh sách giá trị hợp lệ cho cột `Iter` (Iter 1/2/3) và `Status` (To do/Doing/Done/Cancelled), dùng làm data validation cho sheet `RMS`.
- Viết screen/function như use case (tên là cụm động từ + danh từ, ví dụ "Create Booking", "View Vehicle Catalog").
- Tên screen/function rõ ràng, lấy đúng theo danh sách ở mục 8.
- Một screen/function có một main owner (cột `In Charge`).
- Chia đều screen/function cho team theo mục 9 và 10.
- Không sửa cột SRS, SDS, Status, Notes nếu chưa được yêu cầu.
- Không đưa task test vào sheet `RMS`, vì đây chỉ tracking screen/function (test case nằm ở file System Test riêng theo từng thành viên).

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
