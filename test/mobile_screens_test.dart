import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/app.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/router/app_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/release_info.dart';
import 'package:gometer/core/update/update_service.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/features/settings/settings_screen.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';
import 'package:gometer/features/usage/usage_screen.dart';
import 'package:gometer/core/widgets/limit_card.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _testKey = 'sk-test1234567890';

class _FakeUsageNotifier extends UsageNotifier {
  @override
  Future<List<UsageLimit>> build() async => [
        UsageLimit(
          id: 'rolling',
          name: '5 часов',
          window: 'Скользящее окно',
          percent: 14,
          resetAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
        ),
        UsageLimit(
          id: 'weekly',
          name: '7 дней',
          window: 'Неделя',
          percent: 79,
          resetAt: DateTime.now().toUtc().add(const Duration(days: 1)),
        ),
        UsageLimit(
          id: 'monthly',
          name: '30 дней',
          window: 'Месяц',
          percent: 39,
          resetAt: DateTime.now().toUtc().add(const Duration(days: 10)),
        ),
      ];
}

class _FakeUpdateService extends UpdateService {
  _FakeUpdateService()
      : super(
          Dio(),
          PackageInfo(
            appName: 'gometer',
            packageName: 'gometer',
            version: '0.1.1',
            buildNumber: '1',
          ),
        );

  @override
  Future<ReleaseInfo?> checkForUpdate() async => null;
}

Future<ProviderScope> _mobileApp({required Widget child}) async {
  SharedPreferences.setMockInitialValues({'apiKey': _testKey});
  final repo = await SettingsRepository.create();
    return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
      updateServiceProvider.overrideWithValue(_FakeUpdateService()),
      usageProvider.overrideWith(() => _FakeUsageNotifier()),
      notificationHistoryProvider.overrideWithValue(
        NotificationHistory(await SharedPreferences.getInstance()),
      ),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mobile-sized screens render', () {
    testWidgets('UsageScreen shows cards', (tester) async {
      await tester.pumpWidget(await _mobileApp(child: const UsageScreen()));
      await tester.pumpAndSettle();
      expect(find.text('5 часов'), findsOneWidget);
      expect(find.text('7 дней'), findsOneWidget);
      expect(find.text('30 дней'), findsOneWidget);
    });

    testWidgets('regression: limit cards are equal height and bars align',
        (tester) async {
      await tester.pumpWidget(await _mobileApp(child: const UsageScreen()));
      await tester.pumpAndSettle();

      final boxes = [for (final e in find.byType(LimitCard).evaluate()) e.renderObject as RenderBox];
      expect(boxes, hasLength(3));
      final firstHeight = boxes.first.size.height;
      for (final box in boxes) {
        expect(box.size.height, firstHeight);
      }
    });

    testWidgets('SettingsScreen shows sections', (tester) async {
      await tester.pumpWidget(await _mobileApp(child: const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Тема'), findsOneWidget);
    });
  });

  Future<void> pumpMobileAppWithKey(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'apiKey': _testKey});
    final repo = await SettingsRepository.create();
    final router = AppRouter(repo).router;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          updateServiceProvider.overrideWithValue(_FakeUpdateService()),
          usageProvider.overrideWith(() => _FakeUsageNotifier()),
          notificationHistoryProvider.overrideWithValue(
            NotificationHistory(await SharedPreferences.getInstance()),
          ),
        ],
        child: GoMeterApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'regression: shell body renders content on mobile (pill nav does not collapse it)',
    (tester) async {
      await pumpMobileAppWithKey(tester);

      expect(find.byType(LimitCard), findsNWidgets(3));
      expect(find.text('5 часов'), findsOneWidget);
    },
  );

  testWidgets('whole app starts on mobile with key set', (tester) async {
    await pumpMobileAppWithKey(tester);
    expect(find.text('Лимиты'), findsWidgets);
    expect(find.byType(LimitCard), findsNWidgets(3));
  });

  testWidgets(
    'onboarding flow: key entry lands on usage with content',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});
      final repo = await SettingsRepository.create();
      final router = AppRouter(repo).router;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            updateServiceProvider.overrideWithValue(_FakeUpdateService()),
            usageProvider.overrideWith(() => _FakeUsageNotifier()),
            notificationHistoryProvider.overrideWithValue(
              NotificationHistory(await SharedPreferences.getInstance()),
            ),
          ],
          child: GoMeterApp(router: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GoMeter'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        _testKey,
      );
      await tester.ensureVisible(find.text('Сохранить и начать'));
      await tester.tap(find.text('Сохранить и начать'));
      await tester.pumpAndSettle();

      expect(find.text('5 часов'), findsOneWidget);
      expect(find.text('7 дней'), findsOneWidget);
      expect(find.text('30 дней'), findsOneWidget);
      expect(find.text('Лимиты'), findsWidgets);
    },
  );
}
