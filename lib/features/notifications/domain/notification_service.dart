enum NotificationDeliveryResult { sent, permissionDenied, unavailable }

final class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
}

abstract interface class NotificationService {
  Future<void> initialize();

  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  });

  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  );
}

final class UnavailableNotificationService implements NotificationService {
  const UnavailableNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  }) async => NotificationDeliveryResult.unavailable;

  @override
  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  ) async => NotificationDeliveryResult.unavailable;
}
