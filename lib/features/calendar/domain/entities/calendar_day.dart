import '../../../../core/date_time/date_only.dart';
import '../value_objects/lunar_date.dart';

final class CalendarDay {
  CalendarDay({required DateTime solarDate, required this.lunarDate})
    : solarDate = dateOnly(solarDate);

  final DateTime solarDate;
  final LunarDate lunarDate;
}
