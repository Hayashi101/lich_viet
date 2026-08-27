import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/features/calendar/data/vietnamese_lunar_calendar.dart';
import 'package:lich_viet/features/calendar/domain/value_objects/lunar_date.dart';

void main() {
  const calendar = VietnameseLunarCalendar();

  group('VietnameseLunarCalendar', () {
    test('converts verified Tet boundaries in UTC+7', () {
      expect(
        calendar.fromSolar(DateTime(2024, 2, 9)),
        const LunarDate(day: 30, month: 12, year: 2023),
      );
      expect(
        calendar.fromSolar(DateTime(2024, 2, 10)),
        const LunarDate(day: 1, month: 1, year: 2024),
      );
      expect(
        calendar.fromSolar(DateTime(2025, 1, 29)),
        const LunarDate(day: 1, month: 1, year: 2025),
      );
    });

    test('identifies the leap second lunar month of 2023', () {
      expect(
        calendar.fromSolar(DateTime(2023, 3, 22)),
        const LunarDate(day: 1, month: 2, year: 2023, isLeapMonth: true),
      );
    });

    test('rejects years outside the supported range', () {
      expect(
        () => calendar.fromSolar(DateTime(1799, 12, 31)),
        throwsRangeError,
      );
      expect(() => calendar.fromSolar(DateTime(2200, 1, 1)), throwsRangeError);
    });
  });
}
