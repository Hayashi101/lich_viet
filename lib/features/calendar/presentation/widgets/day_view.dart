import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/date_time/date_only.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/repositories/lunar_calendar_repository.dart';

class DayView extends StatelessWidget {
  const DayView({
    required this.date,
    required this.today,
    required this.lunarCalendar,
    super.key,
  });

  final DateTime date;
  final DateTime today;
  final LunarCalendarRepository lunarCalendar;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final lunar = lunarCalendar.fromSolar(date);
    final isToday = isSameDate(date, today);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          header: true,
          label: isToday ? strings.today : null,
          child: Container(
            key: const ValueKey('day-view-card'),
            constraints: const BoxConstraints(maxWidth: 420),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  key: const ValueKey('solar-day-section'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.selectedTab(context),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      if (isToday) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              strings.today,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        strings.solarCalendar.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                      ),
                      Text(
                        MaterialLocalizations.of(context).formatFullDate(date),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  key: const ValueKey('lunar-day-section'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lunarSurface(context),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Text(
                        strings.lunarCalendar.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.lunar(context),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${lunar.day}/${lunar.month}/${lunar.year}',
                        key: const ValueKey('day-view-lunar-date'),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.lunar(context),
                            ),
                      ),
                      if (lunar.isLeapMonth)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            strings.leapMonthShort,
                            style: TextStyle(color: AppColors.lunar(context)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
