# Lịch Việt

Ứng dụng Flutter xem lịch dương và lịch âm Việt Nam với giao diện sáng sủa, gọn gàng và ưu tiên hoạt động ngoại tuyến.

## Tính năng

- Xem lịch theo ngày, tuần, tháng và năm.
- Hiển thị ngày âm đi kèm ngày dương.
- Vuốt trái/phải để chuyển ngày, tuần, tháng hoặc năm.
- Đánh dấu ngày hiện tại và ngày đang chọn.
- Thông báo vào ngày trước và đúng ngày mùng 1/Rằm âm lịch.
- Trang Cài đặt cho phép chủ động bật/tắt thông báo âm lịch.
- Giao diện Material 3, hỗ trợ light/dark theme và text scaling.

## Thông báo âm lịch

Ứng dụng tạo lịch nhắc cho 370 ngày tiếp theo mỗi khi khởi động:

- 08:00 ngày trước mùng 1 âm lịch.
- 08:00 đúng ngày mùng 1 âm lịch.
- 08:00 ngày trước Rằm (15 âm lịch).
- 08:00 đúng ngày Rằm.

Thời gian được tính theo múi giờ `Asia/Ho_Chi_Minh`. Android dùng lịch nhắc không chính xác tuyệt đối để tối ưu pin, vì vậy hệ điều hành có thể giao thông báo trễ nhẹ.

Thông báo mặc định tắt nếu người dùng chưa từng lựa chọn. Khi bật trong trang Cài đặt, ứng dụng mới xin quyền hệ điều hành và tạo lịch nhắc. Khi tắt, các lịch nhắc đang chờ được hủy; quyền hệ điều hành có thể được thu hồi riêng trong Cài đặt của thiết bị.

## Kiến trúc

Mã nguồn được tổ chức theo feature với luồng phụ thuộc:

```text
presentation -> application -> domain
data ------------------------> domain
```

- `lib/features/calendar`: lịch ngày, tuần, tháng, năm và thuật toán âm lịch.
- `lib/features/notifications`: lập lịch và gửi thông báo cục bộ.
- `lib/core`: quy tắc ngày giờ và thành phần dùng chung.
- `docs/architecture.md`: tài liệu kiến trúc chi tiết.
- `AGENTS.md`: nguyên tắc bắt buộc khi phát triển mã mới.

## Yêu cầu

- Flutter SDK tương thích Dart `^3.12.0`.
- Xcode để chạy iOS.
- Android Studio/Android SDK để chạy Android.

Kiểm tra môi trường:

```bash
flutter doctor
```

## Cài đặt và chạy

```bash
flutter pub get
flutter run
```

Chọn thiết bị cụ thể nếu cần:

```bash
flutter devices
flutter run -d <device-id>
```

Ứng dụng chỉ yêu cầu quyền thông báo khi người dùng chủ động bật tính năng trong trang Cài đặt.

## Kiểm tra chất lượng

Trước khi gửi thay đổi, chạy:

```bash
dart format .
flutter analyze
flutter test
```

Thuật toán âm lịch hiện hỗ trợ miền năm 1800–2199 và dùng UTC+7 cho nghiệp vụ lịch Việt Nam.
