abstract interface class NotificationPreferenceRepository {
  Future<bool> isLunarReminderEnabled();

  Future<void> setLunarReminderEnabled(bool enabled);
}

final class UnavailableNotificationPreferenceRepository
    implements NotificationPreferenceRepository {
  const UnavailableNotificationPreferenceRepository();

  @override
  Future<bool> isLunarReminderEnabled() async => false;

  @override
  Future<void> setLunarReminderEnabled(bool enabled) async {}
}
