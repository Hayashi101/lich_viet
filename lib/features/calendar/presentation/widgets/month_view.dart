import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/date_time/date_only.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/repositories/lunar_calendar_repository.dart';

class MonthView extends StatelessWidget {
  const MonthView({
    required this.visibleMonth,
    required this.selectedDate,
    required this.today,
    required this.lunarCalendar,
    required this.onDateSelected,
    super.key,
  });
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime today;
  final LunarCalendarRepository lunarCalendar;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final gridStart = startOfWeek(
      DateTime(visibleMonth.year, visibleMonth.month),
    );
    final weekdays = [
      strings.mondayShort,
      strings.tuesdayShort,
      strings.wednesdayShort,
      strings.thursdayShort,
      strings.fridayShort,
      strings.saturdayShort,
      strings.sundayShort,
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.86,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final date = gridStart.add(Duration(days: index));
              final lunarDate = lunarCalendar.fromSolar(date);
              return _CalendarCell(
                date: date,
                lunarLabel: lunarDate.day == 1
                    ? lunarDate.compactLabel
                    : '${lunarDate.day}',
                todayLabel: strings.today,
                isInMonth: date.month == visibleMonth.month,
                isSelected: isSameDate(date, selectedDate),
                isToday: isSameDate(date, today),
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.date,
    required this.lunarLabel,
    required this.todayLabel,
    required this.isInMonth,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });
  final DateTime date;
  final String lunarLabel;
  final String todayLabel;
  final bool isInMonth;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedBackground = AppColors.selectedDate(context);
    final selectedForeground = AppColors.onSelectedDate(context);
    final foreground = isSelected
        ? selectedForeground
        : date.weekday == DateTime.sunday
        ? scheme.error
        : scheme.onSurface;
    return Opacity(
      opacity: isInMonth ? 1 : 0.35,
      child: Semantics(
        button: true,
        selected: isSelected,
        label:
            '${date.day}/${date.month}/${date.year}, âm lịch $lunarLabel${isToday ? ', $todayLabel' : ''}',
        child: Material(
          color: isSelected ? selectedBackground : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: isToday
                ? BorderSide(
                    color: isSelected ? selectedForeground : scheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey(
              'calendar-day-${date.year}-${date.month}-${date.day}',
            ),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Column(
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lunarLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? selectedForeground.withValues(alpha: 0.86)
                          : AppColors.lunar(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
