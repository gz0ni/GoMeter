import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gometer/core/foreground/gometer_task_handler.dart';

class ForegroundService {
  static bool _initialized = false;
  static int _intervalMinutes = 5;

  static bool get isSupported => Platform.isAndroid;

  static void init({required int intervalMinutes}) {
    if (!isSupported) return;
    _intervalMinutes = intervalMinutes.clamp(1, 60);
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'gometer_foreground',
        channelName: 'GoMeter фоновый мониторинг',
        channelDescription: 'Отслеживание лимитов в фоне',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          Duration(minutes: _intervalMinutes).inMilliseconds,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
  }

  static Future<bool> get isRunningService =>
      FlutterForegroundTask.isRunningService;

  static Future<ServiceRequestResult> start() async {
    if (!isSupported || !_initialized) {
      return const ServiceRequestFailure(error: 'not initialized');
    }
    return FlutterForegroundTask.startService(
      serviceId: 1001,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: 'GoMeter',
      notificationText: 'Отслеживание лимитов',
      notificationIcon: null,
      callback: startCallback,
    );
  }

  static Future<ServiceRequestResult> stop() async {
    if (!isSupported) return const ServiceRequestFailure(error: 'unsupported');
    if (!await FlutterForegroundTask.isRunningService) {
      return const ServiceRequestSuccess();
    }
    return FlutterForegroundTask.stopService();
  }

  static Future<ServiceRequestResult> restartWithInterval(
    int intervalMinutes,
  ) async {
    if (!isSupported) return const ServiceRequestFailure(error: 'unsupported');
    final clamped = intervalMinutes.clamp(1, 60);
    if (clamped == _intervalMinutes && await isRunningService) {
      return const ServiceRequestSuccess();
    }
    _intervalMinutes = clamped;
    final wasRunning = await isRunningService;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'gometer_foreground',
        channelName: 'GoMeter фоновый мониторинг',
        channelDescription: 'Отслеживание лимитов в фоне',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          Duration(minutes: _intervalMinutes).inMilliseconds,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
    if (!wasRunning) return const ServiceRequestSuccess();
    final updateResult = await FlutterForegroundTask.updateService(
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          Duration(minutes: _intervalMinutes).inMilliseconds,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
      callback: startCallback,
    );
    if (updateResult is ServiceRequestSuccess) return updateResult;
    await FlutterForegroundTask.stopService();
    return start();
  }

  static Future<bool> shouldRun({
    required String apiKey,
    required bool notificationsEnabled,
  }) async {
    if (!isSupported) return false;
    if (apiKey.isEmpty) return false;
    if (!notificationsEnabled) return false;
    return true;
  }

  static Future<void> sync({
    required String apiKey,
    required bool notificationsEnabled,
    required int intervalMinutes,
  }) async {
    if (!isSupported) return;
    final should = await shouldRun(
      apiKey: apiKey,
      notificationsEnabled: notificationsEnabled,
    );
    final running = await isRunningService;
    if (should && !running) {
      init(intervalMinutes: intervalMinutes);
      await start();
    } else if (should && running) {
      await restartWithInterval(intervalMinutes);
    } else if (!should && running) {
      await stop();
    } else if (!should && !running) {
      init(intervalMinutes: intervalMinutes);
    }
  }

  static Future<void> requestPermissionsIfNeeded() async {
    if (!isSupported) return;
    final perm = await FlutterForegroundTask.checkNotificationPermission();
    if (perm != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }
}
