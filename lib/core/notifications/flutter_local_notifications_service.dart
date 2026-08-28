import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gometer/core/notifications/notification_service.dart';
import 'package:gometer/core/tray/tray_controller.dart';

const _windowsAppUserModelId = 'dev.gometer.gometer';
const _windowsGuid = '8b47fe3c-5f9e-4b1d-9c4e-2e5a6f7a8b9c';

class FlutterLocalNotificationsService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  FlutterLocalNotificationsService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      final settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_gometer'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Открыть GoMeter',
        ),
        windows: WindowsInitializationSettings(
          appName: 'GoMeter',
          appUserModelId: _windowsAppUserModelId,
          guid: _windowsGuid,
          iconPath: resolveTrayIconPath(),
        ),
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
      await _requestPermissions();
    } catch (_) {
      // Notifications are best-effort: fail silently when the platform has
      // no notification service (e.g. Linux without a notification daemon).
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);

      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      await macos?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {
      // Permission request failures should not affect the app.
    }
  }

  @override
  Future<void> show({required String title, required String body}) async {
    if (!_initialized) await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'limit_warnings',
        'Напоминания о лимитах',
        channelDescription: 'Уведомления о пересечении порогов лимитов',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_stat_gometer',
        color: Color(0xFF2196F3),
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(),
    );
    await _plugin.show(
      id: title.hashCode & 0x0fffffff,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'open',
    );
  }
}
