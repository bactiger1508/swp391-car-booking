# Hướng dẫn Cài đặt Database (CarRentalDB)

Để cài đặt hoặc làm mới cơ sở dữ liệu cho hệ thống Car Rental, vui lòng chạy các tệp SQL theo đúng thứ tự dưới đây bằng công cụ **SQL Server Management Studio (SSMS)** hoặc qua dòng lệnh `sqlcmd`.

---

## 📌 Thứ tự chạy các tệp SQL:

### Bước 1: Tạo cấu trúc bảng (Schema)
Chạy tệp **[schema.sql](file:///c:/Users/bacb4/Documents/NetBeansProjects/car-rental-management/database/schema.sql)** để khởi tạo toàn bộ cấu trúc bảng, các khóa ngoại (Foreign Key) và chỉ mục (Indexes) mới nhất.
- *Lưu ý*: Hãy đảm bảo Database `CarRentalDB` đã được tạo trước khi chạy tệp này. Nếu muốn xóa và làm mới hoàn toàn, bạn có thể chạy tệp **[reset-db.sql](file:///c:/Users/bacb4/Documents/NetBeansProjects/car-rental-management/database/reset-db.sql)** trước.

### Bước 2: Nạp dữ liệu mẫu & Cấu hình (Seed Data)
Chạy tệp **[sample-data.sql](file:///c:/Users/bacb4/Documents/NetBeansProjects/car-rental-management/database/sample-data.sql)** để nạp:
- Các tài khoản mẫu (Admin, Staff, Customer).
- Toàn bộ danh sách 16 xe mẫu phục vụ việc test (bao gồm các hãng VinFast, Toyota, Hyundai, Honda, Mazda, Kia, Ford).
- 30+ khóa cấu hình nghiệp vụ thực tế cho gói cước (Daily, Trip, Combo 7/10 ngày), VAT, tiền cọc, khoảng cách giao xe, và thông số tài khoản ngân hàng.
- Một số giao dịch đặt xe, hợp đồng và hóa đơn thanh toán mẫu để chạy demo.

---

## ⚡ Lệnh chạy nhanh qua Console (Nếu cần):
```bash
# Xóa và tạo lại Database trống
sqlcmd -S localhost -U sa -P <your_password> -i database/reset-db.sql

# Khởi tạo bảng
sqlcmd -S localhost -U sa -P <your_password> -i database/schema.sql

# Nạp dữ liệu mẫu
sqlcmd -S localhost -U sa -P <your_password> -i database/sample-data.sql
```
