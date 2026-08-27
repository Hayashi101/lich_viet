import '../../../core/date_time/clock.dart';
import '../../../core/date_time/date_only.dart';
import '../domain/value_objects/calendar_view.dart';
import 'calendar_state.dart';

final class CalendarController {
  CalendarController({required this.clock}) {
    final today = dateOnly(clock.now());
    _state = CalendarState(selectedDate: today, visibleAnchor: today);
  }

  final Clock clock;
  late CalendarState _state;

  CalendarState get state => _state;
  DateTime get today => dateOnly(clock.now());

  void selectDate(DateTime value) {
    final selected = dateOnly(value);
    _state = _state.copyWith(selectedDate: selected, visibleAnchor: selected);
  }

  void changeView(CalendarView view) {
    _state = _state.copyWith(view: view, visibleAnchor: _state.selectedDate);
  }

  void goToToday() => selectDate(today);

  void previousPeriod() => _movePeriod(-1);

  void nextPeriod() => _movePeriod(1);

  void _movePeriod(int direction) {
    final anchor = _state.visibleAnchor;
    final moved = switch (_state.view) {
      CalendarView.day => anchor.add(Duration(days: direction)),
      CalendarView.week => anchor.add(Duration(days: 7 * direction)),
      CalendarView.month => DateTime(anchor.year, anchor.month + direction, 1),
      CalendarView.year => DateTime(anchor.year + direction, anchor.month, 1),
    };
    final followsVisiblePeriod =
        _state.view == CalendarView.day || _state.view == CalendarView.week;
    _state = _state.copyWith(
      visibleAnchor: moved,
      selectedDate: followsVisiblePeriod ? moved : null,
    );
  }
}
