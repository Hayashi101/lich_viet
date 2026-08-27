import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/date_time/date_only.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/calendar_controller.dart';
import '../../domain/repositories/lunar_calendar_repository.dart';
import '../../domain/value_objects/calendar_view.dart';
import '../../../notifications/domain/notification_service.dart';
import '../../../notifications/application/lunar_reminder_scheduler.dart';
import '../widgets/day_view.dart';
import '../widgets/month_view.dart';
import '../widgets/week_view.dart';
import '../widgets/year_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    required this.controller,
    required this.lunarCalendar,
    required this.notificationService,
    this.lunarReminderScheduler,
    this.showTestNotificationButton = false,
    super.key,
  });
  final CalendarController controller;
  final LunarCalendarRepository lunarCalendar;
  final NotificationService notificationService;
  final LunarReminderScheduler? lunarReminderScheduler;
  final bool showTestNotificationButton;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _minimumSwipeVelocity = 250.0;
  int _navigationDirection = 1;
  bool _didScheduleLunarReminders = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didScheduleLunarReminders || widget.lunarReminderScheduler == null) {
      return;
    }
    _didScheduleLunarReminders = true;
    final strings = AppLocalizations.of(context);
    widget.lunarReminderScheduler!.schedule(
      LunarReminderMessages(
        title: strings.lunarReminderTitle,
        firstDayTomorrow: strings.firstDayTomorrowReminder,
        firstDayToday: strings.firstDayTodayReminder,
        fullMoonTomorrow: strings.fullMoonTomorrowReminder,
        fullMoonToday: strings.fullMoonTodayReminder,
      ),
    );
  }

  void _update(VoidCallback action) => setState(action);

  void _movePeriod(int direction) {
    _navigationDirection = direction;
    _update(
      direction < 0
          ? widget.controller.previousPeriod
          : widget.controller.nextPeriod,
    );
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _minimumSwipeVelocity) return;
    _movePeriod(velocity > 0 ? -1 : 1);
  }

  Future<void> _showTestNotification() async {
    final strings = AppLocalizations.of(context);
    final result = await widget.notificationService.showTestNotification(
      title: strings.testNotificationTitle,
      body: strings.testNotificationBody,
    );
    if (!mounted) return;
    final message = switch (result) {
      NotificationDeliveryResult.sent => strings.notificationSent,
      NotificationDeliveryResult.permissionDenied =>
        strings.notificationPermissionDenied,
      NotificationDeliveryResult.unavailable => strings.notificationUnavailable,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = widget.controller.state;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.appName.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                letterSpacing: 1.3,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _periodTitle(context),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  if (widget.showTestNotificationButton) ...[
                    IconButton.filledTonal(
                      key: const ValueKey('test-notification-button'),
                      tooltip: strings.testNotification,
                      onPressed: _showTestNotification,
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton.tonal(
                    onPressed: () => _update(widget.controller.goToToday),
                    child: Text(
                      strings.today,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _CalendarViewSwitcher(
              selected: state.view,
              labels: {
                CalendarView.day: strings.dayView,
                CalendarView.week: strings.weekView,
                CalendarView.month: strings.monthView,
                CalendarView.year: strings.yearView,
              },
              onSelected: (view) =>
                  _update(() => widget.controller.changeView(view)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: strings.previousPeriod,
                    onPressed: () => _movePeriod(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Spacer(),
                  Text(
                    _periodTitle(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: strings.nextPeriod,
                    onPressed: () => _movePeriod(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: _handleHorizontalDragEnd,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(_navigationDirection * 0.12, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: KeyedSubtree(
                        key: _calendarPeriodKey(),
                        child: _buildCalendarView(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (state.view != CalendarView.day)
              _SelectedDayCard(
                date: state.selectedDate,
                lunarCalendar: widget.lunarCalendar,
              ),
          ],
        ),
      ),
    );
  }

  String _periodTitle(BuildContext context) {
    final state = widget.controller.state;
    final materialStrings = MaterialLocalizations.of(context);
    return switch (state.view) {
      CalendarView.day => materialStrings.formatFullDate(state.visibleAnchor),
      CalendarView.week => _weekTitle(state.visibleAnchor),
      CalendarView.month => materialStrings.formatMonthYear(
        state.visibleAnchor,
      ),
      CalendarView.year => '${state.visibleAnchor.year}',
    };
  }

  ValueKey<String> _calendarPeriodKey() {
    final state = widget.controller.state;
    final anchor = state.visibleAnchor;
    return switch (state.view) {
      CalendarView.day => ValueKey(
        'calendar-period-day-${anchor.year}-${anchor.month}-${anchor.day}',
      ),
      CalendarView.week => ValueKey(
        'calendar-period-week-${startOfWeek(anchor).toIso8601String()}',
      ),
      CalendarView.month => ValueKey(
        'calendar-period-month-${anchor.year}-${anchor.month}',
      ),
      CalendarView.year => ValueKey('calendar-period-year-${anchor.year}'),
    };
  }

  String _weekTitle(DateTime anchor) {
    final first = startOfWeek(anchor);
    final last = endOfWeek(anchor);
    return '${first.day}/${first.month} – ${last.day}/${last.month}/${last.year}';
  }

  Widget _buildCalendarView() {
    final state = widget.controller.state;
    void select(DateTime date) =>
        _update(() => widget.controller.selectDate(date));
    return switch (state.view) {
      CalendarView.day => DayView(
        date: state.visibleAnchor,
        today: widget.controller.today,
        lunarCalendar: widget.lunarCalendar,
      ),
      CalendarView.week => WeekView(
        visibleDate: state.visibleAnchor,
        selectedDate: state.selectedDate,
        today: widget.controller.today,
        lunarCalendar: widget.lunarCalendar,
        onDateSelected: select,
      ),
      CalendarView.month => MonthView(
        visibleMonth: state.visibleAnchor,
        selectedDate: state.selectedDate,
        today: widget.controller.today,
        lunarCalendar: widget.lunarCalendar,
        onDateSelected: select,
      ),
      CalendarView.year => YearView(
        year: state.visibleAnchor.year,
        selectedDate: state.selectedDate,
        today: widget.controller.today,
        lunarCalendar: widget.lunarCalendar,
        onDateSelected: select,
      ),
    };
  }
}

class _CalendarViewSwitcher extends StatelessWidget {
  const _CalendarViewSwitcher({
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final CalendarView selected;
  final Map<CalendarView, String> labels;
  final ValueChanged<CalendarView> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('calendar-view-switcher'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: CalendarView.values.map((view) {
          final isSelected = view == selected;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              child: InkWell(
                key: ValueKey('calendar-view-${view.name}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(view),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.selectedTab(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: scheme.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[view]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({required this.date, required this.lunarCalendar});
  final DateTime date;
  final LunarCalendarRepository lunarCalendar;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final lunar = lunarCalendar.fromSolar(dateOnly(date));
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.selectedDate(date.day, date.month, date.year),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            strings.lunarDate(
              lunar.day,
              lunar.month,
              lunar.year,
              lunar.isLeapMonth ? strings.leapMonthSuffix : '',
            ),
            style: TextStyle(color: AppColors.lunar(context)),
          ),
        ],
      ),
    );
  }
}
