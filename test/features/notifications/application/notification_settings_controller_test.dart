import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/core/date_time/clock.dart';
import 'package:lich_viet/features/calendar/domain/repositories/lunar_calendar_repository.dart';
import 'package:lich_viet/features/calendar/domain/value_objects/lunar_date.dart';
import 'package:lich_viet/features/notifications/application/lunar_reminder_scheduler.dart';
import 'package:lich_viet/features/notifications/application/notification_settings_controller.dart';
import 'package:lich_viet/features/notifications/domain/notification_preference_repository.dart';
import 'package:lich_viet/features/notifications/domain/notification_service.dart';

final class _Preferences implements NotificationPreferenceRepository {
  bool enabled = false;

  @override
  Future<bool> isLunarReminderEnabled() async => enabled;

  @override
  Future<void> setLunarReminderEnabled(bool enabled) async {
    this.enabled = enabled;
  }
}

final class _Service implements NotificationService {
  NotificationDeliveryResult result = NotificationDeliveryResult.sent;
  int cancelCalls = 0;

  @override
  Future<void> cancelLunarReminders() async => cancelCalls += 1;

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  ) async => result;

  @override
  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  }) async => result;
}

final class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2024, 2, 8, 7);
}

final class _FirstDayCalendar implements LunarCalendarRepository {
  @override
  LunarDate fromSolar(DateTime solarDate) =>
      const LunarDate(day: 1, month: 1, year: 2024, isLeapMonth: false);
}

LunarReminderScheduler _scheduler(_Service service) =>
    LunarReminderScheduler(service, _FirstDayCalendar(), _FixedClock());

const _messages = LunarReminderMessages(
  title: 'title',
  firstDayTomorrow: 'first tomorrow',
  firstDayToday: 'first today',
  fullMoonTomorrow: 'full moon tomorrow',
  fullMoonToday: 'full moon today',
);

void main() {
  test('updates toggle optimistically before scheduling finishes', () async {
    final preferences = _Preferences();
    final service = _Service();
    final controller = NotificationSettingsController(
      false,
      preferences,
      service,
      _scheduler(service),
    );

    final operation = controller.setEnabled(true, messages: _messages);

    expect(controller.state.isEnabled, isTrue);
    expect(controller.state.isSaving, isTrue);
    await operation;
    expect(controller.state.isSaving, isFalse);
  });

  test('enables and persists reminders after permission succeeds', () async {
    final preferences = _Preferences();
    final service = _Service();
    final controller = NotificationSettingsController(
      false,
      preferences,
      service,
      _scheduler(service),
    );

    final state = await controller.setEnabled(true, messages: _messages);

    expect(state.isEnabled, isTrue);
    expect(preferences.enabled, isTrue);
  });

  test('stays disabled when notification permission is denied', () async {
    final preferences = _Preferences();
    final service = _Service()
      ..result = NotificationDeliveryResult.permissionDenied;
    final controller = NotificationSettingsController(
      false,
      preferences,
      service,
      _scheduler(service),
    );

    final state = await controller.setEnabled(true, messages: _messages);

    expect(state.isEnabled, isFalse);
    expect(state.lastResult, NotificationDeliveryResult.permissionDenied);
    expect(preferences.enabled, isFalse);
  });

  test('stays disabled when notifications are unavailable', () async {
    final preferences = _Preferences();
    final service = _Service()..result = NotificationDeliveryResult.unavailable;
    final controller = NotificationSettingsController(
      false,
      preferences,
      service,
      _scheduler(service),
    );

    final state = await controller.setEnabled(true, messages: _messages);

    expect(state.isEnabled, isFalse);
    expect(state.lastResult, NotificationDeliveryResult.unavailable);
    expect(preferences.enabled, isFalse);
  });

  test('disables reminders and cancels pending notifications', () async {
    final preferences = _Preferences()..enabled = true;
    final service = _Service();
    final controller = NotificationSettingsController(
      true,
      preferences,
      service,
      _scheduler(service),
    );

    final state = await controller.setEnabled(false, messages: _messages);

    expect(state.isEnabled, isFalse);
    expect(preferences.enabled, isFalse);
    expect(service.cancelCalls, 1);
  });
}
