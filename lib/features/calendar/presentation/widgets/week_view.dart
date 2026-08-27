import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/date_time/date_only.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/repositories/lunar_calendar_repository.dart';

class WeekView extends StatelessWidget {
  const WeekView({
    required this.visibleDate,
    required this.selectedDate,
    required this.today,
    required this.lunarCalendar,
    required this.onDateSelected,
    super.key,
  });

  final DateTime visibleDate;
  final DateTime selectedDate;
  final DateTime today;
  final LunarCalendarRepository lunarCalendar;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final first = startOfWeek(visibleDate);
    final weekdayLabels = [
      strings.mondayShort,
      strings.tuesdayShort,
      strings.wednesdayShort,
      strings.thursdayShort,
      strings.fridayShort,
      strings.saturdayShort,
      strings.sundayShort,
    ];
    return ListView(
      key: const ValueKey('week-view'),
      clipBehavior: Clip.hardEdge,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: List.generate(7, (index) {
        final date = first.add(Duration(days: index));
        final lunar = lunarCalendar.fromSolar(date);
        return _WeekDayTile(
          weekday: weekdayLabels[index],
          date: date,
          lunarLabel: '${lunar.day}/${lunar.month}',
          isSelected: isSameDate(date, selectedDate),
          isToday: isSameDate(date, today),
          todayLabel: strings.today,
          lunarLabelPrefix: strings.lunarCalendar,
          onTap: () => onDateSelected(date),
        );
      }),
    );
  }
}

class _WeekDayTile extends StatelessWidget {
  const _WeekDayTile({
    required this.weekday,
    required this.date,
    required this.lunarLabel,
    required this.isSelected,
    required this.isToday,
    required this.todayLabel,
    required this.lunarLabelPrefix,
    required this.onTap,
  });

  final String weekday;
  final DateTime date;
  final String lunarLabel;
  final bool isSelected;
  final bool isToday;
  final String todayLabel;
  final String lunarLabelPrefix;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Semantics(
        selected: isSelected,
        label:
            '$weekday, ${date.day}/${date.month}, âm lịch $lunarLabel${isToday ? ', $todayLabel' : ''}',
        child: Material(
          color: isSelected
              ? AppColors.selectedTab(context)
              : scheme.surfaceContainerLow,
          elevation: isSelected ? 5 : 0,
          shadowColor: AppColors.selectedTab(context).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('week-day-${date.year}-${date.month}-${date.day}'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Text(
                      weekday,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: scheme.onSurface),
                      ),
                      if (isToday)
                        Positioned(
                          right: -8,
                          top: -2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                      Text(
                        '$lunarLabelPrefix $lunarLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.lunar(context),
                        ),
                      ),
                    ],
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
