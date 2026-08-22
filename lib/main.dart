import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_repository.dart';
import 'core/theme/theme_provider.dart';
import 'core/update/update_controller.dart';
import 'core/update/update_service.dart';
import 'features/usage/services/usage_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        updateServiceProvider.overrideWithValue(updateService),
        usageApiServiceProvider.overrideWithValue(usageApiService),
      ],
      child: GoMeterApp(router: router),
    ),
  );
}
