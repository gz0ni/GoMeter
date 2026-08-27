import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/app.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/router/app_router.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/update/release_info.dart';
import 'package:gometer/core/update/update_controller.dart';
import 'package:gometer/core/update/update_service.dart';
import 'package:gometer/core/widgets/brand_logo.dart';
import 'package:gometer/core/widgets/limit_card.dart';
import 'package:gometer/core/widgets/status_card.dart';
import 'package:gometer/features/settings/settings_screen.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';
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

Future<void> _pumpDesktopApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 800);
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

void main() {
  testWidgets('desktop usage: rail brand, page-head actions, cards, status',
      (tester) async {
    await _pumpDesktopApp(tester);

    expect(find.byType(BrandLogo), findsOneWidget);
    expect(find.byType(LimitCard), findsNWidgets(3));
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.key_outlined), findsOneWidget);
    expect(find.byType(StatusCard), findsOneWidget);
    expect(find.text('Почти у предела'), findsOneWidget);

    final firstCard = tester.renderObject(find.byType(LimitCard).first)
        as RenderBox;
    final secondCard = tester.renderObject(find.byType(LimitCard).at(1))
        as RenderBox;
    expect(firstCard.size.width, lessThan(400));
    expect(secondCard.size.width, lessThan(400));
  });

  testWidgets('desktop settings page is narrow (<=640)', (tester) async {
    await _pumpDesktopApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    final settingsEl = find.byType(SettingsScreen).evaluate().single;
    final scope = ProviderScope.containerOf(settingsEl);
    expect(scope, isNotNull);
    final listView = tester.renderObject(
      find.descendant(
        of: find.byType(SettingsScreen),
        matching: find.byType(ListView),
      ),
    ) as RenderBox;
    expect(listView.size.width, lessThanOrEqualTo(640));
  });

  testWidgets('desktop about is a rail destination', (tester) async {
    await _pumpDesktopApp(tester);
    await tester.tap(find.text('О приложении'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Версия'), findsOneWidget);
    expect(find.textContaining('мокап'), findsNothing);
  });
}
