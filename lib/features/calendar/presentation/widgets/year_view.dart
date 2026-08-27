import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/date_time/date_only.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/repositories/lunar_calendar_repository.dart';

class YearView extends StatelessWidget {
  const YearView({
    required this.year,
    required this.selectedDate,
    required this.today,
    required this.lunarCalendar,
    required this.onDateSelected,
    super.key,
  });

  final int year;
  final DateTime selectedDate;
  final DateTime today;
  final LunarCalendarRepository lunarCalendar;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) => ListView.builder(
    key: const ValueKey('year-view'),
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
    itemCount: 12,
    itemBuilder: (context, index) => _YearMonth(
      month: DateTime(year, index + 1),
      selectedDate: selectedDate,
      today: today,
      lunarCalendar: lunarCalendar,
      onDateSelected: onDateSelected,
    ),
  );
}

class _YearMonth extends StatelessWidget {
  const _YearMonth({
    required this.month,
    required this.selectedDate,
    required this.today,
    required this.lunarCalendar,
    required this.onDateSelected,
  });
  final DateTime month;
  final DateTime selectedDate;
  final DateTime today;
  final LunarCalendarRepository lunarCalendar;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final first = startOfWeek(month);
    final weekdays = [
      strings.mondayShort,
      strings.tuesdayShort,
      strings.wednesdayShort,
      strings.thursdayShort,
      strings.fridayShort,
      strings.saturdayShort,
      strings.sundayShort,
    ];
    return Card(
      key: ValueKey('year-month-${month.month}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MaterialLocalizations.of(context).formatMonthYear(month),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: weekdays
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.95,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final date = first.add(Duration(days: index));
                final lunar = lunarCalendar.fromSolar(date);
                final inMonth = date.month == month.month;
                final selected = isSameDate(date, selectedDate);
                final isToday = isSameDate(date, today);
                final selectedBackground = AppColors.selectedDate(context);
                final selectedForeground = AppColors.onSelectedDate(context);
                return Opacity(
                  opacity: inMonth ? 1 : 0.2,
                  child: InkWell(
                    key: ValueKey(
                      'year-day-${date.year}-${date.month}-${date.day}-in-${month.month}',
                    ),
                    onTap: () => onDateSelected(date),
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: selected
                            ? selectedBackground
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(
                                color: selected
                                    ? selectedForeground
                                    : Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? selectedForeground
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            lunar.day == 1
                                ? lunar.compactLabel
                                : '${lunar.day}',
                            style: TextStyle(
                              fontSize: 8,
                              color: selected
                                  ? selectedForeground
                                  : AppColors.lunar(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
