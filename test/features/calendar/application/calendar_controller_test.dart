import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/core/date_time/clock.dart';
import 'package:lich_viet/features/calendar/application/calendar_controller.dart';
import 'package:lich_viet/features/calendar/domain/value_objects/calendar_view.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

void main() {
  late CalendarController controller;
  setUp(
    () => controller = CalendarController(
      clock: _FixedClock(DateTime(2026, 8, 27, 15)),
    ),
  );

  test('initializes with a normalized today in month view', () {
    expect(controller.today, DateTime(2026, 8, 27));
    expect(controller.state.selectedDate, DateTime(2026, 8, 27));
    expect(controller.state.view, CalendarView.month);
  });

  test('moves between months across year boundaries', () {
    controller.selectDate(DateTime(2026, 1, 15));
    controller.previousPeriod();
    expect(controller.state.visibleAnchor, DateTime(2025, 12, 1));
  });

  test('changing view preserves selected date', () {
    controller.selectDate(DateTime(2026, 9, 2));
    controller.changeView(CalendarView.week);
    expect(controller.state.selectedDate, DateTime(2026, 9, 2));
    expect(controller.state.visibleAnchor, DateTime(2026, 9, 2));
  });

  test('day and week navigation move the selected date with the period', () {
    controller.changeView(CalendarView.day);
    controller.nextPeriod();
    expect(controller.state.selectedDate, DateTime(2026, 8, 28));

    controller.changeView(CalendarView.week);
    controller.nextPeriod();
    expect(controller.state.selectedDate, DateTime(2026, 9, 4));
  });
}
