import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/core/date_time/date_only.dart';

void main() {
  test('dateOnly removes the time component', () {
    expect(dateOnly(DateTime(2026, 8, 27, 19, 30)), DateTime(2026, 8, 27));
  });

  test('week starts on Monday and ends on Sunday', () {
    final date = DateTime(2026, 8, 27);
    expect(startOfWeek(date), DateTime(2026, 8, 24));
    expect(endOfWeek(date), DateTime(2026, 8, 30));
  });
}
