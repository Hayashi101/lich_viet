import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/notification_service.dart';

final class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _testNotificationId = 1001;
  static const _channelId = 'calendar_test';
  static const _channelName = 'Thử thông báo';
  static const _channelDescription =
      'Kênh tạm để kiểm tra thông báo của Lịch Việt';
  static const _reminderChannelId = 'lunar_calendar_reminders';
  static const _reminderChannelName = 'Nhắc ngày âm lịch';
  static const _reminderChannelDescription =
      'Nhắc trước và trong ngày mùng 1, ngày Rằm âm lịch';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_calendar'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    _isInitialized = true;
  }

  @override
  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  ) async {
    await initialize();
    final hasPermission = await _requestPermission();
    if (!hasPermission) return NotificationDeliveryResult.permissionDenied;

    final pending = await _plugin.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.id >= 20000000 && notification.id < 70000000) {
        await _plugin.cancel(id: notification.id);
      }
    }

    for (final notification in notifications) {
      final at = notification.scheduledAt;
      await _plugin.zonedSchedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: tz.TZDateTime(
          tz.local,
          at.year,
          at.month,
          at.day,
          at.hour,
          at.minute,
        ),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannelId,
            _reminderChannelName,
            channelDescription: _reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    return NotificationDeliveryResult.sent;
  }

  @override
  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    final hasPermission = await _requestPermission();
    if (!hasPermission) return NotificationDeliveryResult.permissionDenied;

    await _plugin.show(
      id: _testNotificationId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    return NotificationDeliveryResult.sent;
  }

  Future<bool> _requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }
}
