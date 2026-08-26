import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gometer/core/notifications/notification_history.dart';
import 'package:gometer/core/settings/settings_repository.dart';
import 'package:gometer/core/theme/theme_provider.dart';
import 'package:gometer/core/widgets/push_card.dart';
import 'package:gometer/features/usage/models/usage_limit.dart';
import 'package:gometer/features/usage/providers/usage_provider.dart';
import 'package:gometer/features/usage/usage_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUsageNotifier extends UsageNotifier {
  @override
  Future<List<UsageLimit>> build() async => [
    UsageLimit(
      id: 'rolling',
      name: '5 часов',
      window: 'Скользящее окно',
      percent: 81,
      resetAt: DateTime.now().toUtc().add(const Duration(hours: 14)),
    ),
    UsageLimit(
      id: 'weekly',
      name: '7 дней',
      window: 'Неделя',
      percent: 96,
      resetAt: DateTime.now().toUtc().add(const Duration(days: 2)),
    ),
    UsageLimit(
      id: 'monthly',
      name: '30 дней',
      window: 'Месяц',
      percent: 16,
      resetAt: DateTime.now().toUtc().add(const Duration(days: 31)),
    ),
  ];
}

Future<ProviderScope> _app({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({'apiKey': 'sk-test', ...prefs});
  final repo = await SettingsRepository.create();
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(repo),
      usageProvider.overrideWith(() => _FakeUsageNotifier()),
      notificationHistoryProvider.overrideWithValue(
        NotificationHistory(await SharedPreferences.getInstance()),
      ),
    ],
    child: const MaterialApp(home: UsageScreen()),
  );
}

void main() {
  testWidgets('UsageScreen renders live push cards above limit cards', (
    tester,
  ) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    expect(find.byType(PushCardTile), findsNWidgets(2));
    expect(find.text('Лимит 80% · 7 дней'), findsOneWidget);
    expect(find.text('Лимит 80% · 5 часов'), findsNothing);
    expect(find.text('Лимит 95% · 7 дней'), findsOneWidget);
    expect(find.textContaining('Осталось 4%'), findsNWidgets(2));
  });

  testWidgets('closing a push card hides it', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Скрыть').first);
    await tester.pumpAndSettle();

    expect(find.byType(PushCardTile), findsOneWidget);
    expect(find.text('Лимит 80% · 7 дней'), findsNothing);
  });

  testWidgets('no push cards when notifications are disabled', (tester) async {
    await tester.pumpWidget(await _app(prefs: {'notificationsEnabled': false}));
    await tester.pumpAndSettle();

    expect(find.byType(PushCardTile), findsNothing);
  });
}
