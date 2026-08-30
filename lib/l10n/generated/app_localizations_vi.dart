// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Lịch Việt';

  @override
  String get today => 'Hôm nay';

  @override
  String get dayView => 'Ngày';

  @override
  String get weekView => 'Tuần';

  @override
  String get monthView => 'Tháng';

  @override
  String get yearView => 'Năm';

  @override
  String lunarDate(int day, int month, int year, String leap) {
    return 'Âm lịch: $day/$month/$year$leap';
  }

  @override
  String get leapMonthSuffix => ' nhuận';

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get previousPeriod => 'Kỳ trước';

  @override
  String get nextPeriod => 'Kỳ sau';

  @override
  String get mondayShort => 'T2';

  @override
  String get tuesdayShort => 'T3';

  @override
  String get wednesdayShort => 'T4';

  @override
  String get thursdayShort => 'T5';

  @override
  String get fridayShort => 'T6';

  @override
  String get saturdayShort => 'T7';

  @override
  String get sundayShort => 'CN';

  @override
  String selectedDate(int day, int month, int year) {
    return 'Ngày $day tháng $month, $year';
  }

  @override
  String get solarCalendar => 'Dương lịch';

  @override
  String get lunarCalendar => 'Âm lịch';

  @override
  String get leapMonthShort => 'Nhuận';

  @override
  String get testNotification => 'Thử thông báo';

  @override
  String get testNotificationTitle => 'Thông báo từ Lịch Việt';

  @override
  String get testNotificationBody =>
      'Thông báo thử nghiệm đã hoạt động thành công.';

  @override
  String get notificationSent => 'Đã gửi thông báo thử nghiệm.';

  @override
  String get notificationPermissionDenied => 'Bạn chưa cấp quyền thông báo.';

  @override
  String get notificationUnavailable =>
      'Thiết bị này chưa hỗ trợ thông báo thử nghiệm.';

  @override
  String get lunarReminderTitle => 'Nhắc lịch âm';

  @override
  String get firstDayTomorrowReminder => 'Ngày mai là mùng 1 âm lịch.';

  @override
  String get firstDayTodayReminder => 'Hôm nay là mùng 1 âm lịch.';

  @override
  String get fullMoonTomorrowReminder => 'Ngày mai là ngày Rằm (15 âm lịch).';

  @override
  String get fullMoonTodayReminder => 'Hôm nay là ngày Rằm (15 âm lịch).';

  @override
  String get settings => 'Cài đặt';

  @override
  String get notifications => 'THÔNG BÁO';

  @override
  String get lunarReminderSetting => 'Nhắc mùng 1 và ngày Rằm';

  @override
  String get lunarReminderSettingDescription =>
      'Thông báo lúc 08:00 vào ngày trước và đúng ngày âm lịch.';

  @override
  String get notificationSystemPermissionHint =>
      'Bạn có thể thu hồi quyền thông báo hoàn toàn trong phần Cài đặt của thiết bị.';
}
