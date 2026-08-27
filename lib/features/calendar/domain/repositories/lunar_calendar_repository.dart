import '../value_objects/lunar_date.dart';

abstract interface class LunarCalendarRepository {
  LunarDate fromSolar(DateTime solarDate);
}
