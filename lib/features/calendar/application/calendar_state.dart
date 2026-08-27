import '../../../core/date_time/date_only.dart';
import '../domain/value_objects/calendar_view.dart';

final class CalendarState {
  CalendarState({
    required DateTime selectedDate,
    required DateTime visibleAnchor,
    this.view = CalendarView.month,
  }) : selectedDate = dateOnly(selectedDate),
       visibleAnchor = dateOnly(visibleAnchor);

  final DateTime selectedDate;
  final DateTime visibleAnchor;
  final CalendarView view;

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? visibleAnchor,
    CalendarView? view,
  }) => CalendarState(
    selectedDate: selectedDate ?? this.selectedDate,
    visibleAnchor: visibleAnchor ?? this.visibleAnchor,
    view: view ?? this.view,
  );
}
