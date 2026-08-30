import 'package:shared_preferences/shared_preferences.dart';

import '../domain/notification_preference_repository.dart';

final class SharedPreferencesNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  SharedPreferencesNotificationPreferenceRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _lunarReminderEnabledKey = 'lunar_reminder_enabled';
  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> isLunarReminderEnabled() async =>
      await _preferences.getBool(_lunarReminderEnabledKey) ?? false;

  @override
  Future<void> setLunarReminderEnabled(bool enabled) =>
      _preferences.setBool(_lunarReminderEnabledKey, enabled);
}
