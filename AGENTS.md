# AGENTS.md

## Mục tiêu sản phẩm

Ứng dụng Flutter để xem lịch dương và lịch âm Việt Nam theo ngày, tuần, tháng và năm. Trải nghiệm phải nhanh, sáng sủa, dễ đọc và ưu tiên hoạt động ngoại tuyến.

## Nguyên tắc kiến trúc

- Tổ chức mã nguồn theo feature; phần dùng chung đặt trong `core`.
- Tuân theo luồng phụ thuộc: `presentation -> application -> domain`; `data` triển khai các interface do `domain` khai báo.
- `domain` chỉ dùng Dart thuần, không import Flutter, plugin, widget hoặc chi tiết lưu trữ.
- Thuật toán chuyển đổi âm/dương lịch phải nằm sau một interface, có tài liệu về múi giờ và miền ngày hỗ trợ.
- Plugin thông báo chỉ được truy cập qua `NotificationService`; widget không gọi plugin hoặc API quyền hệ điều hành trực tiếp.
- Widget không tự tính ngày, không chứa thuật toán âm lịch và không truy cập lưu trữ trực tiếp.
- Chỉ thêm dependency khi giải quyết nhu cầu rõ ràng; ưu tiên SDK và giải pháp đơn giản trước.
- Dùng kiểu bất biến (`final`, `const`) và tên thể hiện ý nghĩa nghiệp vụ; tránh boolean khó hiểu trong API công khai.

## Cấu trúc dự kiến

```text
lib/
  app/                         # Khởi tạo app, theme, router
  core/
    date_time/                 # Clock, chuẩn hóa ngày, múi giờ
    errors/                    # Failure/exception dùng chung
  features/calendar/
    domain/                    # Entity, value object, repository contract
    application/               # State + use case điều phối màn hình lịch
    data/                      # Thuật toán âm lịch, cache/preferences
    presentation/              # Page, widget theo day/week/month/year
```

## Quy tắc ngày giờ

- Mọi giá trị đại diện cho một ngày phải được chuẩn hóa về `DateTime(year, month, day)` trước khi so sánh.
- Không dùng thời điểm UTC như ngày dân sự nếu chưa chuyển sang múi giờ hiển thị.
- Mặc định nghiệp vụ âm lịch Việt Nam dùng múi giờ `Asia/Ho_Chi_Minh` (UTC+7); mọi ngoại lệ phải được ghi rõ.
- Tuần bắt đầu vào Thứ Hai. Khi thay đổi quy ước này, phải sửa test tương ứng.
- Tách “hôm nay” qua `Clock` có thể inject; không gọi `DateTime.now()` rải rác trong widget hoặc use case.

## Kiểm thử bắt buộc

- Mỗi function nghiệp vụ mới hoặc sửa đổi phải có unit test cho đường đi chính, biên và dữ liệu không hợp lệ.
- Thuật toán âm lịch phải có regression test với ngày Tết, tháng nhuận và các mốc giao năm đã được đối chiếu từ nguồn tin cậy.
- Mỗi state/controller phải test chuyển trạng thái; widget quan trọng phải có widget test cho nội dung và thao tác chính.
- Bug fix phải thêm test tái hiện lỗi trước hoặc cùng lúc với bản sửa.
- Không dùng thời gian hệ thống thật, network thật hoặc dữ liệu ngẫu nhiên không cố định trong test.
- Luồng thông báo phải test ít nhất các kết quả gửi thành công, từ chối quyền và nền tảng không hỗ trợ.
- Trước khi hoàn tất thay đổi: chạy `dart format .`, `flutter analyze` và `flutter test`.

## Quy tắc giao diện

- Material 3, hỗ trợ light/dark theme và Dynamic Type/Text Scaling.
- Ngày dương là thông tin chính; ngày âm là thông tin phụ nhưng phải xuất hiện nhất quán.
- Không chỉ dùng màu để biểu đạt trạng thái; bảo đảm vùng chạm tối thiểu 48x48 logical pixels.
- Các màn hình ngày/tuần/tháng/năm dùng cùng mô hình chọn ngày và cùng hành vi “Về hôm nay”.
- Chuỗi hiển thị đi qua localization; không hard-code chuỗi rải rác trong widget.

## Design baseline đã chốt — không tự ý thay đổi

Người dùng đã duyệt và muốn giữ nguyên style hiện tại. Không redesign, đổi màu, thêm/bớt border, shadow hoặc thay đổi phân cấp typography của các thành phần dưới đây nếu không có yêu cầu trực tiếp từ người dùng:

- Thanh chuyển `Ngày / Tuần / Tháng / Năm`: không border; nền chung nhẹ; tab chọn dùng nền mint sáng và shadow tinh tế.
- Màu âm lịch: chữ đỏ son; dùng nền đỏ kem ấm ở khối âm lịch của Day View; phải có biến thể phù hợp cho dark theme.
- Day View: hai khối màu tách biệt bằng khoảng trắng, không border và không divider. Khối dương lịch dùng nền mint, số ngày dương là typography lớn nhất. Khối âm lịch dùng nền đỏ kem, chữ đỏ son và nhỏ hơn ngày dương.
- Week View: mỗi ngày là một card không border. Ngày thường dùng nền surface nhẹ; ngày chọn dùng nền mint và shadow sáng cùng tông, không dùng shadow đen. Hôm nay dùng chấm màu nhỏ.
- Month View: ngày chọn phải có nền opaque rõ ràng; hôm nay và ngày chọn là hai trạng thái độc lập. Ngày âm thường chỉ hiện số ngày, riêng mùng 1 hiện `1/tháng`.
- `_SelectedDayCard`: không border; dùng nền surface nhẹ và shadow mềm.
- Các view hỗ trợ vuốt ngang để đổi kỳ; Week/Year View vẫn phải giữ cuộn dọc hoạt động bình thường.

Khi thêm UI mới, ưu tiên tái sử dụng token trong `AppColors` và phong cách trên. Nếu một yêu cầu kỹ thuật buộc phải thay đổi design baseline, phải thông báo và xin ý kiến người dùng trước.

## Kỷ luật thay đổi

- Đọc file này và `docs/architecture.md` trước khi tạo code mới.
- Không chỉnh sửa file sinh tự động trong các thư mục nền tảng nếu có thể cấu hình từ Flutter.
- Giữ commit/thay đổi tập trung vào yêu cầu; không refactor phần không liên quan.
- Không xóa hoặc ghi đè thay đổi chưa rõ nguồn gốc của người dùng.
- Cập nhật tài liệu kiến trúc khi thêm layer, dependency hoặc thay đổi luồng dữ liệu.
