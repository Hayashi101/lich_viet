import 'dart:math' as math;

import '../domain/repositories/lunar_calendar_repository.dart';
import '../domain/value_objects/lunar_date.dart';

/// Vietnamese astronomical lunar calendar using UTC+7.
///
/// The formulas are adapted from Hồ Ngọc Đức's implementation of Jean Meeus'
/// astronomical algorithms. This implementation deliberately supports the
/// verified application range 1800–2199 only.
final class VietnameseLunarCalendar implements LunarCalendarRepository {
  const VietnameseLunarCalendar();

  static const int minimumYear = 1800;
  static const int maximumYear = 2199;
  static const double _timeZone = 7;

  @override
  LunarDate fromSolar(DateTime solarDate) {
    if (solarDate.year < minimumYear || solarDate.year > maximumYear) {
      throw RangeError.range(
        solarDate.year,
        minimumYear,
        maximumYear,
        'solarDate.year',
      );
    }

    final dayNumber = _julianDay(
      solarDate.day,
      solarDate.month,
      solarDate.year,
    );
    final k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    var monthStart = _newMoonDay(k + 1);
    if (monthStart > dayNumber) monthStart = _newMoonDay(k);

    var a11 = _lunarMonth11(solarDate.year);
    var b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = solarDate.year;
      a11 = _lunarMonth11(solarDate.year - 1);
    } else {
      lunarYear = solarDate.year + 1;
      b11 = _lunarMonth11(solarDate.year + 1);
    }

    final lunarDay = dayNumber - monthStart + 1;
    final difference = ((monthStart - a11) / 29).floor();
    var lunarMonth = difference + 11;
    var isLeapMonth = false;
    if (b11 - a11 > 365) {
      final leapDifference = _leapMonthOffset(a11);
      if (difference >= leapDifference) {
        lunarMonth = difference + 10;
        isLeapMonth = difference == leapDifference;
      }
    }
    if (lunarMonth > 12) lunarMonth -= 12;
    if (lunarMonth >= 11 && difference < 4) lunarYear -= 1;

    return LunarDate(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      isLeapMonth: isLeapMonth,
    );
  }

  int _julianDay(int day, int month, int year) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    var result =
        day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
    if (result < 2299161) {
      result =
          day + ((153 * m + 2) / 5).floor() + 365 * y + (y / 4).floor() - 32083;
    }
    return result;
  }

  int _newMoonDay(int k) => (_newMoon(k) + 0.5 + _timeZone / 24).floor();

  double _newMoon(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    final radians = math.pi / 180;
    var result =
        2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    result +=
        0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * radians);
    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final moon = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    final correction =
        (0.1734 - 0.000393 * t) * math.sin(m * radians) +
        0.0021 * math.sin(2 * m * radians) -
        0.4068 * math.sin(moon * radians) +
        0.0161 * math.sin(2 * moon * radians) -
        0.0004 * math.sin(3 * moon * radians) +
        0.0104 * math.sin(2 * f * radians) -
        0.0051 * math.sin((m + moon) * radians) -
        0.0074 * math.sin((m - moon) * radians) +
        0.0004 * math.sin((2 * f + m) * radians) -
        0.0004 * math.sin((2 * f - m) * radians) -
        0.0006 * math.sin((2 * f + moon) * radians) +
        0.0010 * math.sin((2 * f - moon) * radians) +
        0.0005 * math.sin((2 * moon + m) * radians);
    final deltaT = t < -11
        ? 0.001 +
              0.000839 * t +
              0.0002261 * t2 -
              0.00000845 * t3 -
              0.000000081 * t * t3
        : -0.000278 + 0.000265 * t + 0.000262 * t2;
    return result + correction - deltaT;
  }

  int _sunLongitudeSegment(int dayNumber) {
    final t = (dayNumber - 0.5 - _timeZone / 24 - 2451545.0) / 36525;
    final t2 = t * t;
    final radians = math.pi / 180;
    final m =
        357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    var delta =
        (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(m * radians);
    delta += (0.019993 - 0.000101 * t) * math.sin(2 * m * radians);
    delta += 0.000290 * math.sin(3 * m * radians);
    var longitude = (l0 + delta) * radians;
    longitude -= math.pi * 2 * (longitude / (math.pi * 2)).floor();
    return (longitude / math.pi * 6).floor();
  }

  int _lunarMonth11(int year) {
    final offset = _julianDay(31, 12, year) - 2415021;
    final k = (offset / 29.530588853).floor();
    var newMoon = _newMoonDay(k);
    if (_sunLongitudeSegment(newMoon) >= 9) newMoon = _newMoonDay(k - 1);
    return newMoon;
  }

  int _leapMonthOffset(int a11) {
    final k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    var last = 0;
    var index = 1;
    var arc = _sunLongitudeSegment(_newMoonDay(k + index));
    do {
      last = arc;
      index += 1;
      arc = _sunLongitudeSegment(_newMoonDay(k + index));
    } while (arc != last && index < 14);
    return index - 1;
  }
}
