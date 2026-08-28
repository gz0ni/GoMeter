import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/foreground/foreground_service.dart';
import 'core/notifications/flutter_local_notifications_service.dart';
import 'core/notifications/notification_history.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_repository.dart';
import 'core/theme/theme_provider.dart';
import 'core/tray/tray_controller.dart';
import 'core/update/update_controller.dart';
import 'core/update/update_service.dart';
import 'features/usage/services/usage_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final quietStart = Platform.executableArguments.contains('--quiet');

  final prefs = await SharedPreferences.getInstance();
  final repo = SettingsRepository(prefs);
  final router = AppRouter(repo).router;

  final dio = Dio(
    BaseOptions(
      headers: {'User-Agent': 'GoMeter'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  final packageInfo = await PackageInfo.fromPlatform();
  final updateService = UpdateService(dio, packageInfo);
  final usageApiService = UsageApiService(dio);

  final isDesktop = !Platform.isAndroid && !Platform.isIOS;
  if (isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1000, 700),
        minimumSize: Size(640, 480),
        center: true,
        title: 'GoMeter',
      ),
      () async {
        if (quietStart) {
          await windowManager.hide();
        } else {
          await windowManager.show();
        }
      },
    );
    await windowManager.setPreventClose(true);
    await TrayController.instance.attachToTray();
  }

  final notificationsService = FlutterLocalNotificationsService();
  await notificationsService.init();

  if (Platform.isAndroid) {
    final initial = repo.load();
    ForegroundService.init(intervalMinutes: initial.checkIntervalMinutes);
    await ForegroundService.sync(
      apiKey: initial.apiKey,
      notificationsEnabled: initial.notificationsEnabled,
      intervalMinutes: initial.checkIntervalMinutes,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        updateServiceProvider.overrideWithValue(updateService),
        usageApiServiceProvider.overrideWithValue(usageApiService),
        notificationsServiceProvider.overrideWithValue(notificationsService),
        notificationHistoryProvider.overrideWithValue(
          NotificationHistory(prefs),
        ),
      ],
      child: GoMeterApp(router: router),
    ),
  );
}
