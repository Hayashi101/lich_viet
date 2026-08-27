import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lich_viet/app/theme/app_theme.dart';
import 'package:lich_viet/core/date_time/clock.dart';
import 'package:lich_viet/features/calendar/presentation/widgets/month_view.dart';
import 'package:lich_viet/features/notifications/domain/notification_service.dart';
import 'package:lich_viet/main.dart';

final class _FixedClock implements Clock {
  const _FixedClock(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}

final class _FakeNotificationService implements NotificationService {
  NotificationDeliveryResult result = NotificationDeliveryResult.sent;
  int showCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationDeliveryResult> showTestNotification({
    required String title,
    required String body,
  }) async {
    showCalls += 1;
    return result;
  }

  @override
  Future<NotificationDeliveryResult> replaceScheduledNotifications(
    List<ScheduledNotification> notifications,
  ) async => result;
}

void main() {
  testWidgets('only the first lunar day includes its month in a cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    expect(find.text('1/1'), findsWidgets);
    expect(find.text('2/1'), findsNothing);
    expect(find.text('Âm lịch: 1/1/2024'), findsOneWidget);
  });

  testWidgets('today remains marked after another date is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-day-2024-2-11')));
    await tester.pump();

    final semantics = tester.getSemantics(
      find.byKey(const ValueKey('calendar-day-2024-2-10')),
    );
    expect(semantics.label, contains('Hôm nay'));
  });

  testWidgets('selected month and week items paint an opaque background', (
    tester,
  ) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2026, 8, 5))),
    );
    await tester.pumpAndSettle();

    bool hasSelectedBackground(Finder item, Color expectedColor) {
      return tester
          .widgetList<Material>(
            find.ancestor(of: item, matching: find.byType(Material)),
          )
          .any((material) => material.color == expectedColor);
    }

    expect(
      hasSelectedBackground(
        find.byKey(const ValueKey('calendar-day-2026-8-5')),
        AppColors.selectedDate(
          tester.element(find.byKey(const ValueKey('calendar-day-2026-8-5'))),
        ),
      ),
      isTrue,
    );

    await tester.tap(find.text('Tuần').first);
    await tester.pumpAndSettle();
    expect(
      hasSelectedBackground(
        find.byKey(const ValueKey('week-day-2026-8-5')),
        AppColors.selectedTab(
          tester.element(find.byKey(const ValueKey('week-day-2026-8-5'))),
        ),
      ),
      isTrue,
    );
  });

  testWidgets('selecting another day updates the detail', (tester) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('calendar-day-2024-2-11')));
    await tester.pump();

    expect(find.text('Ngày 11 tháng 2, 2024'), findsOneWidget);
    expect(find.text('Âm lịch: 2/1/2024'), findsOneWidget);
  });

  testWidgets('switches between day, week, and year views', (tester) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ngày').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('day-view-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('day-view-lunar-date')), findsOneWidget);
    expect(find.text('Âm lịch: 1/1/2024'), findsNothing);

    await tester.tap(find.text('Tuần').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('week-day-2024-2-5')), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('week-view')),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('calendar-view-switcher')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Năm').first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('year-view')), findsOneWidget);
    expect(find.byKey(const ValueKey('year-month-1')), findsOneWidget);
  });

  testWidgets('horizontal swipes navigate all calendar periods', (
    tester,
  ) async {
    await tester.pumpWidget(
      CalendarApp(clock: _FixedClock(DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(MonthView), const Offset(-400, 0), 900);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('calendar-period-month-2024-3')),
      findsOneWidget,
    );

    await tester.tap(find.text('Ngày').first);
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const ValueKey('day-view-card')),
      const Offset(-400, 0),
      900,
    );
    await tester.pumpAndSettle();
    expect(find.text('2/1/2024'), findsOneWidget);

    await tester.tap(find.text('Tuần').first);
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const ValueKey('week-view')),
      const Offset(-400, 0),
      900,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-day-2024-2-12')), findsOneWidget);

    await tester.tap(find.text('Năm').first);
    await tester.pumpAndSettle();
    await tester.fling(
      find.byKey(const ValueKey('year-view')),
      const Offset(400, 0),
      900,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('calendar-period-year-2023')),
      findsOneWidget,
    );
  });

  testWidgets('temporary notification button sends a test notification', (
    tester,
  ) async {
    final notifications = _FakeNotificationService();
    await tester.pumpWidget(
      CalendarApp(
        clock: _FixedClock(DateTime(2024, 2, 10)),
        notificationService: notifications,
        showTestNotificationButton: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('test-notification-button')));
    await tester.pumpAndSettle();

    expect(notifications.showCalls, 1);
    expect(find.text('Đã gửi thông báo thử nghiệm.'), findsOneWidget);
  });

  testWidgets('notification button reports denied permission', (tester) async {
    final notifications = _FakeNotificationService()
      ..result = NotificationDeliveryResult.permissionDenied;
    await tester.pumpWidget(
      CalendarApp(
        clock: _FixedClock(DateTime(2024, 2, 10)),
        notificationService: notifications,
        showTestNotificationButton: true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('test-notification-button')));
    await tester.pumpAndSettle();

    expect(notifications.showCalls, 1);
    expect(find.text('Bạn chưa cấp quyền thông báo.'), findsOneWidget);
  });
}
