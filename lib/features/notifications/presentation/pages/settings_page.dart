import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/lunar_reminder_scheduler.dart';
import '../../application/notification_settings_controller.dart';
import '../../domain/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.controller,
    required this.onReminderChanged,
    super.key,
  });

  final NotificationSettingsController controller;
  final ValueChanged<bool> onReminderChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _setReminderEnabled(bool enabled) async {
    final strings = AppLocalizations.of(context);
    final operation = widget.controller.setEnabled(
      enabled,
      messages: LunarReminderMessages(
        title: strings.lunarReminderTitle,
        firstDayTomorrow: strings.firstDayTomorrowReminder,
        firstDayToday: strings.firstDayTodayReminder,
        fullMoonTomorrow: strings.fullMoonTomorrowReminder,
        fullMoonToday: strings.fullMoonTodayReminder,
      ),
    );
    setState(() {});
    final state = await operation;
    if (!mounted) return;
    widget.onReminderChanged(state.isEnabled);
    setState(() {});

    final message = switch (state.lastResult) {
      NotificationDeliveryResult.permissionDenied =>
        strings.notificationPermissionDenied,
      NotificationDeliveryResult.unavailable => strings.notificationUnavailable,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = widget.controller.state;
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            strings.notifications,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: state.isEnabled
                ? AppColors.selectedTab(context)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              key: const ValueKey('lunar-reminder-switch'),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              secondary: state.isSaving
                  ? SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        key: const ValueKey('notification-setting-progress'),
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.notifications_active_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              title: Text(
                strings.lunarReminderSetting,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(strings.lunarReminderSettingDescription),
              value: state.isEnabled,
              onChanged: state.isSaving ? null : _setReminderEnabled,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              strings.notificationSystemPermissionHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
