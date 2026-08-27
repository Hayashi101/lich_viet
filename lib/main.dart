import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/theme/app_theme.dart';
import 'core/date_time/clock.dart';
import 'features/calendar/application/calendar_controller.dart';
import 'features/calendar/data/vietnamese_lunar_calendar.dart';
import 'features/calendar/presentation/pages/calendar_page.dart';
import 'features/notifications/data/local_notification_service.dart';
import 'features/notifications/application/lunar_reminder_scheduler.dart';
import 'features/notifications/domain/notification_service.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = LocalNotificationService();
  await notificationService.initialize();
  const lunarCalendar = VietnameseLunarCalendar();
  const clock = SystemClock();
  runApp(
    CalendarApp(
      notificationService: notificationService,
      lunarReminderScheduler: LunarReminderScheduler(
        notificationService,
        lunarCalendar,
        clock,
      ),
    ),
  );
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({
    super.key,
    this.clock = const SystemClock(),
    this.notificationService = const UnavailableNotificationService(),
    this.lunarReminderScheduler,
    this.showTestNotificationButton = false,
  });
  final Clock clock;
  final NotificationService notificationService;
  final LunarReminderScheduler? lunarReminderScheduler;
  final bool showTestNotificationButton;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appName,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: CalendarPage(
      controller: CalendarController(clock: clock),
      lunarCalendar: const VietnameseLunarCalendar(),
      notificationService: notificationService,
      lunarReminderScheduler: lunarReminderScheduler,
      showTestNotificationButton: showTestNotificationButton,
    ),
  );
}
