import '../domain/notification_preference_repository.dart';
import '../domain/notification_service.dart';
import 'lunar_reminder_scheduler.dart';

final class NotificationSettingsState {
  const NotificationSettingsState({
    required this.isEnabled,
    this.isSaving = false,
    this.lastResult,
  });

  final bool isEnabled;
  final bool isSaving;
  final NotificationDeliveryResult? lastResult;
}

final class NotificationSettingsController {
  NotificationSettingsController(
    bool initialValue,
    this._preferences,
    this._notificationService,
    this._scheduler,
  ) : state = NotificationSettingsState(isEnabled: initialValue);

  final NotificationPreferenceRepository _preferences;
  final NotificationService _notificationService;
  final LunarReminderScheduler _scheduler;
  NotificationSettingsState state;

  Future<NotificationSettingsState> setEnabled(
    bool enabled, {
    required LunarReminderMessages messages,
  }) async {
    if (state.isSaving || enabled == state.isEnabled) return state;
    state = NotificationSettingsState(isEnabled: enabled, isSaving: true);
    await Future<void>.delayed(Duration.zero);

    if (!enabled) {
      await _notificationService.cancelLunarReminders();
      await _preferences.setLunarReminderEnabled(false);
      state = const NotificationSettingsState(isEnabled: false);
      return state;
    }

    final result = await _scheduler.schedule(messages);
    final isEnabled = result == NotificationDeliveryResult.sent;
    await _preferences.setLunarReminderEnabled(isEnabled);
    state = NotificationSettingsState(isEnabled: isEnabled, lastResult: result);
    return state;
  }
}
