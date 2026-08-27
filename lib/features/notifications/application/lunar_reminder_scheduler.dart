import '../../../core/date_time/clock.dart';
import '../../calendar/domain/repositories/lunar_calendar_repository.dart';
import '../domain/notification_service.dart';

final class LunarReminderMessages {
  const LunarReminderMessages({
    required this.title,
    required this.firstDayTomorrow,
    required this.firstDayToday,
    required this.fullMoonTomorrow,
    required this.fullMoonToday,
  });

  final String title;
  final String firstDayTomorrow;
  final String firstDayToday;
  final String fullMoonTomorrow;
  final String fullMoonToday;
}

final class LunarReminderScheduler {
  const LunarReminderScheduler(
    this._notificationService,
    this._lunarCalendar,
    this._clock,
  );

  static const _scheduleDays = 370;
  static const _notificationHour = 8;
  final NotificationService _notificationService;
  final LunarCalendarRepository _lunarCalendar;
  final Clock _clock;

  Future<NotificationDeliveryResult> schedule(LunarReminderMessages messages) {
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final notifications = <ScheduledNotification>[];

    for (var offset = 0; offset <= _scheduleDays; offset++) {
      final eventDate = today.add(Duration(days: offset));
      final lunar = _lunarCalendar.fromSolar(eventDate);
      if (lunar.day != 1 && lunar.day != 15) continue;

      final isFirstDay = lunar.day == 1;
      _addIfFuture(
        notifications,
        now: now,
        date: eventDate.subtract(const Duration(days: 1)),
        id: _notificationId(eventDate, isDayOf: false),
        title: messages.title,
        body: isFirstDay
            ? messages.firstDayTomorrow
            : messages.fullMoonTomorrow,
      );
      _addIfFuture(
        notifications,
        now: now,
        date: eventDate,
        id: _notificationId(eventDate, isDayOf: true),
        title: messages.title,
        body: isFirstDay ? messages.firstDayToday : messages.fullMoonToday,
      );
    }

    return _notificationService.replaceScheduledNotifications(notifications);
  }

  void _addIfFuture(
    List<ScheduledNotification> notifications, {
    required DateTime now,
    required DateTime date,
    required int id,
    required String title,
    required String body,
  }) {
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      _notificationHour,
    );
    if (!scheduledAt.isAfter(now)) return;
    notifications.add(
      ScheduledNotification(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
      ),
    );
  }

  int _notificationId(DateTime eventDate, {required bool isDayOf}) {
    final datePart =
        eventDate.year * 10000 + eventDate.month * 100 + eventDate.day;
    return 20000000 + datePart * 2 + (isDayOf ? 1 : 0);
  }
}
