import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/core/date_time/clock.dart';
import 'package:lich_viet/features/calendar/data/vietnamese_lunar_calendar.dart';
import 'package:lich_viet/features/notifications/application/lunar_reminder_scheduler.dart';
import 'package:lich_viet/features/notifications/domain/notification_service.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

final class _RecordingNotificationService implements NotificationService {
  NotificationDeliveryResult result = NotificationDeliveryResult.sent;
  List<ScheduledNotification> scheduled = const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> cancelLunarReminders() async {}

  @override
  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  ) async {
    scheduled = notifications;
    return result;
  }

  @override
  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  }) async => result;
}

const _messages = LunarReminderMessages(
  title: 'Nhắc lịch âm',
  firstDayTomorrow: 'Mùng 1 ngày mai',
  firstDayToday: 'Mùng 1 hôm nay',
  fullMoonTomorrow: 'Rằm ngày mai',
  fullMoonToday: 'Rằm hôm nay',
);

void main() {
  test(
    'schedules both previous-day and same-day lunar reminders at 08:00',
    () async {
      final service = _RecordingNotificationService();
      final scheduler = LunarReminderScheduler(
        service,
        const VietnameseLunarCalendar(),
        _FixedClock(DateTime(2024, 2, 8, 7)),
      );

      await scheduler.schedule(_messages);

      expect(
        service.scheduled,
        contains(
          isA<ScheduledNotification>()
              .having(
                (item) => item.scheduledAt,
                'time',
                DateTime(2024, 2, 9, 8),
              )
              .having((item) => item.body, 'body', 'Mùng 1 ngày mai'),
        ),
      );
      expect(
        service.scheduled,
        contains(
          isA<ScheduledNotification>()
              .having(
                (item) => item.scheduledAt,
                'time',
                DateTime(2024, 2, 10, 8),
              )
              .having((item) => item.body, 'body', 'Mùng 1 hôm nay'),
        ),
      );
      expect(
        service.scheduled,
        contains(
          isA<ScheduledNotification>()
              .having(
                (item) => item.scheduledAt,
                'time',
                DateTime(2024, 2, 23, 8),
              )
              .having((item) => item.body, 'body', 'Rằm ngày mai'),
        ),
      );
      expect(
        service.scheduled,
        contains(
          isA<ScheduledNotification>()
              .having(
                (item) => item.scheduledAt,
                'time',
                DateTime(2024, 2, 24, 8),
              )
              .having((item) => item.body, 'body', 'Rằm hôm nay'),
        ),
      );
    },
  );

  test('does not schedule a reminder whose 08:00 time has passed', () async {
    final service = _RecordingNotificationService();
    final scheduler = LunarReminderScheduler(
      service,
      const VietnameseLunarCalendar(),
      _FixedClock(DateTime(2024, 2, 9, 9)),
    );

    await scheduler.schedule(_messages);

    expect(
      service.scheduled.any(
        (item) => item.scheduledAt == DateTime(2024, 2, 9, 8),
      ),
      isFalse,
    );
    expect(
      service.scheduled.any(
        (item) => item.scheduledAt == DateTime(2024, 2, 10, 8),
      ),
      isTrue,
    );
  });
}
